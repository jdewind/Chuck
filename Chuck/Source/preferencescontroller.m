//
//  PreferencesController.m
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import "PreferencesController.h"
#import "HotKey.h"
#import "HotKeyTextField.h"
#include "LoginItem.h"

NSString * const recursionLevelKey = @"RecursionLevel";
NSString * const enableAnimationsKey = @"EnableAnimations";
NSString * const showIconPreviewsKey = @"ShowIconPreviews";
NSString * const showInMenuBarKey = @"ShowInMenuBar";
NSString * const showInDockKey = @"ShowDockIcon";
NSString * const globalShortcutKey = @"GlobalHotKey";
NSString * const excludedItemsKey = @"ExcludedItems";
NSString * const aliasesKey = @"Aliases";

static PreferencesController *sharedPreferencesController = nil;

@interface PreferencesController ()

- (void)savePreferences:(NSNotification *)note;
- (void)tabView:(NSTabView *)view didSelectTabViewItem:(NSTabViewItem *)item;

@end

@implementation PreferencesController
@synthesize delegate;
@synthesize openAtLogin;
@synthesize enableAnimations;
@synthesize showIconPreviews;
@synthesize showInMenuBar;
@synthesize showInDock;
@synthesize recursionLevel;
@synthesize excludedItems;
@synthesize aliases;
@synthesize recursionLevelDescription;

+ (PreferencesController *)sharedPreferencesController
{
    @synchronized(sharedPreferencesController) {
        if (sharedPreferencesController == nil) {
            sharedPreferencesController = [[PreferencesController alloc] init];
        }
    }

    return sharedPreferencesController;
}

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];

    if (self != nil) {
        NSString *appPath = [[NSBundle mainBundle] bundlePath];
        CFURLRef appURL =
            CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                          (CFStringRef)appPath,
                                          kCFURLPOSIXPathStyle,
                                          true);
        if (appURL != NULL) {
            openAtLogin = isLoginItem(appURL, false) ? YES : NO;
            CFRelease(appURL);
        }
    }

    return self;
}

- (void)dealloc
{
    DLog(@"And we're gone!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"excludedItems"];
    [self removeObserver:self forKeyPath:@"aliases"];

    [self savePreferences:nil];

    [excludedItems release];
    [aliases release];
    [globalHotKey release];
    [recursionLevelDescription release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSInteger recurseLevel = [userDefaults integerForKey:recursionLevelKey];
    [self setRecursionLevel:recurseLevel < 0 ? 0 : recurseLevel];
    [self setEnableAnimations:[userDefaults boolForKey:enableAnimationsKey]];
    [self setShowIconPreviews:[userDefaults boolForKey:showIconPreviewsKey]];
    [self setShowInMenuBar:[userDefaults boolForKey:showInMenuBarKey]];
    [self setShowInDock:[userDefaults boolForKey:showInDockKey]];
    [self setExcludedItems:[userDefaults arrayForKey:excludedItemsKey]];
    [self setAliases:[userDefaults dictionaryForKey:aliasesKey]];

    // Write to the preferences when our mutable arrays change.
    [self addObserver:self forKeyPath:@"excludedItems" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"aliases" options:0 context:NULL];

    id encodedKey = [userDefaults objectForKey:globalShortcutKey];
    globalHotKey = [[HotKey alloc] initWithEncodedValue:encodedKey];
    if (globalHotKey != nil) {
        [hotKeyField setKeyCodeValue:[globalHotKey keyCode]
                       withModifiers:[globalHotKey modifierFlags]];
    }

    // Make sure the window is the correct size upon loading from the nib file.
    [self tabView:tabView didSelectTabViewItem:[tabView selectedTabViewItem]];
}

#pragma mark Properties

- (void)observeValueForKeyPath:(NSString *)key
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self) {
        if ([key isEqualToString:@"excludedItems"]) {
            DLog(@"excludedItems changed");
            [[NSUserDefaults standardUserDefaults] setObject:excludedItems
                                                      forKey:excludedItemsKey];
        } else if ([key isEqualToString:@"aliases"]) {
            [[NSUserDefaults standardUserDefaults] setObject:aliases
                                                      forKey:aliasesKey];
        } else {
            DLog(@"Observing unknown key \"%@\"", key);
        }
    } else {
        DLog(@"Observing unknown key \"%@\" for unknown object \"%@\"",
             key, object);
    }
}

- (void)setExcludedItems:(NSArray *)items
{
    if (excludedItems == nil) {
        excludedItems = [[NSMutableArray alloc] init];
    }

    [excludedItems setArray:items];
}

- (void)setAliases:(NSDictionary *)newAliases
{
    if (aliases == nil) {
        aliases = [[NSMutableDictionary alloc] init];
    }

    [aliases setDictionary:newAliases];
}

- (void)addExcludedItem:(NSString *)excludedPath
{
    if (![excludedItems containsObject:excludedPath]) {
        [self willChangeValueForKey:@"excludedItems"];
        [excludedItems addObject:excludedPath];
        [self didChangeValueForKey:@"excludedItems"];
    }
}

- (void)removeExcludedItemAtIndex:(NSUInteger)index
{
    NSParameterAssert(index < [excludedItems count]);

    [self willChangeValueForKey:@"excludedItems"];
    [excludedItems removeObjectAtIndex:index];
    [self didChangeValueForKey:@"excludedItems"];
}

- (void)addAlias:(NSString *)alias forPath:(NSString *)path
{
    NSParameterAssert(alias != nil);
    NSParameterAssert(path != nil);

    [self willChangeValueForKey:@"aliases"];
    [aliases setObject:path forKey:alias];
    [self didChangeValueForKey:@"aliases"];

    // Select the row of the newly-created or previously-created alias.
    NSArray *arrangedObjects = [aliasesDictionaryController arrangedObjects];
    NSUInteger index =
        [arrangedObjects indexOfObjectWithOptions:NSEnumerationConcurrent
                                      passingTest:^(id obj,
                                                    NSUInteger idx,
                                                    BOOL *stop) {
        return [[(NSString *)obj key] isEqualToString:alias];
    }];


    if (index != NSNotFound) {
        [aliasesTableView editColumn:0 row:index withEvent:nil select:YES];
    } else {
        DLog(@"Couldn't find alias in table");
    }
}

- (void)removeAlias:(NSString *)alias
{
    NSParameterAssert(alias != nil);

    [self willChangeValueForKey:@"aliases"];
    DLog(@"Removing alias %@", alias);
    [aliases removeObjectForKey:alias];
    [self didChangeValueForKey:@"aliases"];
}

- (BOOL)enableDeleteSelectedExcludedItem
{
    return [excludedItemsTableView selectedRow] > -1;
}

- (BOOL)enableDeleteSelectedAlias
{
    return [aliasesTableView selectedRow] > -1;
}

- (void)setOpenAtLogin:(BOOL)shouldWeDoIt
{
    openAtLogin = shouldWeDoIt;

    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef appURL = (CFURLRef)[[NSURL alloc] initFileURLWithPath:appPath];
    if (appURL != NULL) {
        if (openAtLogin) {
            addAsLoginItem(appURL, false);
        } else {
            removeLoginItem(appURL, false);
        }
        CFRelease(appURL);
    }
}

- (void)setEnableAnimations:(BOOL)shouldWeDoIt
{
    enableAnimations = shouldWeDoIt;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:enableAnimationsKey] != shouldWeDoIt) {
        [userDefaults setBool:enableAnimations forKey:enableAnimationsKey];
    }
}

- (void)setShowIconPreviews:(BOOL)shouldWeDoIt
{
    showIconPreviews = shouldWeDoIt;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:showIconPreviewsKey] != shouldWeDoIt) {
        [userDefaults setBool:showIconPreviews forKey:showIconPreviewsKey];
    }
}

- (void)setShowInMenuBar:(BOOL)shouldWeDoIt
{
    showInMenuBar = shouldWeDoIt;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:showInMenuBarKey] != shouldWeDoIt) {
        [userDefaults setBool:showInMenuBar forKey:showInMenuBarKey];
    }
}

- (void)setShowInDock:(BOOL)shouldWeDoIt
{
    showInDock = shouldWeDoIt;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:showInDockKey] != shouldWeDoIt) {
        [userDefaults setBool:showInDock forKey:showInDockKey];
    }
}

- (void)setRecursionLevel:(NSUInteger)newRecursionLevel
{
    recursionLevel = newRecursionLevel;

    NSString *description;
    if (recursionLevel == 1) {
        description = @"1 directory deep";
    } else {
        description = [[NSString alloc] initWithFormat:@"%lu directories deep",
                       (unsigned long)recursionLevel];
    }

    [self setRecursionLevelDescription:description];
    [description release];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:recursionLevelKey] != recursionLevel) {
        [userDefaults setInteger:recursionLevel forKey:recursionLevelKey];
    }
}

#pragma mark -

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Close preferences window upon switching apps.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(hideOurWindow:)
                          name:NSWindowDidResignKeyNotification
                        object:[self window]];

    [defaultCenter addObserver:self
                      selector:@selector(hideOurWindow:)
                          name:NSApplicationDidResignActiveNotification
                        object:NSApp];

    [defaultCenter addObserver:self
                      selector:@selector(savePreferences:)
                          name:NSApplicationWillTerminateNotification
                        object:NSApp];
}

#pragma mark NSTabView delegate

- (void)tabView:(NSTabView *)view willSelectTabViewItem:(NSTabViewItem *)item
{
    // Fade-out the old view.
    [[[[view subviews] objectAtIndex:0] animator] setAlphaValue:0.0];

    // Prepare next view to be faded in.
    [[item view] setAlphaValue:0.0];
}

- (void)tabView:(NSTabView *)view didSelectTabViewItem:(NSTabViewItem *)item
{
    NSInteger itemNumber = [[item identifier] intValue];

    // Resize the window to the correct height when switching tabs.
    // TODO: Surely there's a better solution than hard-coding dimensions...
    NSUInteger height = 0;
    if (itemNumber == 1) {
        height = 350;
    } else if (itemNumber == 2) {
        height = 400;
    } else {
        return;
    }

    NSWindow *window = [view window];
    NSRect frame = [window frame];

    // The window's rect is relative to the lower left. However, we want the
    // window to seem as though it is growing upwards, and the upper left
    // should stay in a fixed position.  So, we have to slightly move the
    // window frame's origin to create the illusion of its title bar staying in
    // place (like System Preferences does).
    frame.origin.y += frame.size.height - height;
    frame.size.height = height;

    [window setFrame:frame display:YES animate:YES];

    // Fade-in the new view.
    [[[item view] animator] setAlphaValue:1.0];
}

#pragma mark -

#pragma mark NSApp notifications

- (void)hideOurWindow:(NSNotification *)note
{
    // Ignore sheets or alerts from stealing our focus.
    NSWindow *keyWindow = [NSApp keyWindow];
    if ([keyWindow isSheet] ||
        // [keyWindow preventsApplicationTerminationWhenModal] ||
        [[self window] attachedSheet] != nil) {
        return;
    }

    // Hide our window.
    [[self window] performClose:nil];

    // We want to save any memory we can since this is running all the time,
    // and there's no need for us to cache our shared controller when it's in
    // the background.
    @synchronized(self) {
        if (self == sharedPreferencesController) {
            sharedPreferencesController = nil;
            [self release];
        }
    }
}

- (void)savePreferences:(NSNotification *)note
{
    if (savedPreferences) return;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // Save hot key to preferences.
    if (globalHotKey != nil) {
        [userDefaults setObject:[globalHotKey encodedValue]
                         forKey:globalShortcutKey];
    }

    // Make sure the preferences are actually saved.
    [userDefaults synchronize];

    savedPreferences = YES;
    DLog(@"Saved preferences.");
}

#pragma mark -

#pragma mark HotKeyTextField delegate

- (void)hotKeyTextField:(HotKeyTextField *)textField
           choseKeyCode:(unsigned short)keyCode
          withModifiers:(NSUInteger)modifiers
{
    if ([delegate respondsToSelector:@selector(globalKeyMappingSetToKeyCode:withModifiers:)]) {
        [delegate globalKeyMappingSetToKeyCode:keyCode
                                 withModifiers:modifiers];
    }

    [globalHotKey release];
    globalHotKey = [[HotKey alloc] initWithKeyCode:keyCode
                                         modifiers:modifiers];
}

#pragma mark -

#pragma mark NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)note
{
    id sender = [note object];
    if (sender == excludedItemsTableView) {
        [self willChangeValueForKey:@"enableDeleteSelectedExcludedItem"];
        [self didChangeValueForKey:@"enableDeleteSelectedExcludedItem"];
    } else if (sender == aliasesTableView) {
        [self willChangeValueForKey:@"enableDeleteSelectedAlias"];
        [self didChangeValueForKey:@"enableDeleteSelectedAlias"];
    }
}

#pragma mark -

#pragma mark IBActions

- (IBAction)newExcludedItem:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"app", nil]];
    [openPanel setDirectoryURL:[NSURL URLWithString:@"/Applications"]];
    [openPanel beginSheetModalForWindow:[self window]
                      completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self addExcludedItem:[[[openPanel URLs] lastObject] path]];
        }
    }];

    [pool drain];
}

- (IBAction)newAlias:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"app", nil]];
    [openPanel setDirectoryURL:[NSURL URLWithString:@"/Applications"]];
    [openPanel beginSheetModalForWindow:[self window]
                      completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self addAlias:@""
                   forPath:[[[openPanel URLs] lastObject] path]];
        }
    }];

    [pool drain];
}

- (IBAction)removeSelectedExcludedItem:(id)sender
{
    NSInteger rowNumber = [excludedItemsTableView selectedRow];
    if (rowNumber != -1) {
        NSAssert(rowNumber < [excludedItems count], @"Row out of bounds!");
        [self removeExcludedItemAtIndex:rowNumber];
    }
}

- (IBAction)removeSelectedAlias:(id)sender
{
    NSInteger rowNumber = [aliasesTableView selectedRow];
    if (rowNumber != -1) {
        NSArray *arrangedObjects =
            [aliasesDictionaryController arrangedObjects];
        NSAssert(rowNumber < [arrangedObjects count], @"Row out of bounds!");
        [self removeAlias:[[arrangedObjects objectAtIndex:rowNumber] key]];
    }
}

#pragma mark -

@end
