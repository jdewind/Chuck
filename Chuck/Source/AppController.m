//
//  AppController.m
//  Chuck
//
//  Created by Michael on 5/18/10.
//  Copyright 2010 Michael Sanders.
//

#import "AppController.h"
#import "NSApplication+Relaunch.h"
#import "NSArray+Filter.h"
#import "NSArray+Map.h"
#import "NSArray+Rank.h"
#import "NSMenuItem+KeyCode.h"
#import "NSString+FileName.h"
#import "NSWorkspace+LoginItem.h"
#import "ChuckSearchPanel.h"
#import "GlobalHotKeyRegistrar.h"
#import "HotKey.h"

@interface AppController ()

- (NSString *)pathForAlias:(NSString *)alias;
- (void)preferencesChanged:(NSNotification *)note;
- (void)showMenuBarItem;
- (void)updateMenuItemKeyBindings;
- (void)setSearchFieldEnabled:(BOOL)enabled;

@end

@implementation AppController
@synthesize selectedAppPath;
@synthesize customAliases;

- (id)init
{
    self = [super init];

    if (self != nil) {
        appLister = [[AppLister alloc] initWithDelegate:self];
        globalHotKeyRegistrar = [[GlobalHotKeyRegistrar alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [globalHotKeyRegistrar release];
    [appLister release];
    [statusBarItem release];
    [selectedAppPath release];
    [customAliases release];
    [super dealloc];
}

#pragma mark NSApplication delegate

- (void)awakeFromNib
{
    [searchFieldCell setCancelButtonCell:nil];
}

- (void)applicationWillFinishLaunching:(NSNotification *)note
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // Set default recursion level for preference panel and later use.
    NSInteger recursionLevel = [userDefaults integerForKey:recursionLevelKey];
    if (recursionLevel <= 0) {
        [userDefaults setInteger:[appLister maxRecurseLevel]
                          forKey:recursionLevelKey];
    }

    // Default to showing icon in dock and menubar, and enabling animations.
    if ([userDefaults objectForKey:showInDockKey] == nil) {
        [userDefaults setBool:YES forKey:showInDockKey];
    }

    if ([userDefaults objectForKey:showInMenuBarKey] == nil) {
        [userDefaults setBool:YES forKey:showInMenuBarKey];
    }

    if ([userDefaults objectForKey:enableAnimationsKey] == nil) {
        [userDefaults setBool:YES forKey:enableAnimationsKey];
    }

    // Notify us when the preferences have changed.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(preferencesChanged:)
               name:NSUserDefaultsDidChangeNotification
             object:userDefaults];

    // Reload preferences on startup.
    [self preferencesChanged:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    // Force our window to become active if we were not launched as a
    // login item.
    if ([[NSWorkspace sharedWorkspace] launchedAsLoginItem]) {
        [NSApp hide:nil];
        [searchWindow setAlphaValue:0.0];
    } else {
        [self activateSearchPanel:nil];
    }

    // Called when our hot key is pressed.
    [globalHotKeyRegistrar setHotKeyBlock:^() {
        BOOL appIsActive = [NSApp isActive];
        if (!appIsActive || [searchWindow alphaValue] == 0.0) {
            [self activateSearchPanel:nil];
        } else if (appIsActive && [searchWindow isKeyWindow]) {
            [globalHotKeyRegistrar unregisterEscapeKey];
            [NSApp hide:nil];
        }

        return (OSStatus)noErr;
    }];


    // Get hot key from last time, if we saved one.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id encodedKey = [userDefaults objectForKey:globalShortcutKey];
    HotKey *savedHotKey = [[HotKey alloc] initWithEncodedValue:encodedKey];
    if (savedHotKey != nil) {
        [self globalKeyMappingSetToKeyCode:[savedHotKey keyCode]
                             withModifiers:[savedHotKey modifierFlags]];
        [savedHotKey release];
    }

    // We don't want to start scanning after our application has loaded because
    // our delegate method uses a spinner.
    [appLister startScanning];
}

#pragma mark -

- (NSString *)pathForAlias:(NSString *)alias
{
    return [customAliases objectForKey:alias];
}

#pragma mark NSTextField delegate

- (IBAction)filterApps:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Get the application name.
    NSString *term = [searchField stringValue];
    NSString *appName = @"";
    NSString *appPath = nil;
    if ([term length] > 0) {
        NSString *aliasPath = [self pathForAlias:term];
        if (aliasPath != nil) {
            appName = [aliasPath fileNameWithoutExtension];
            appPath = aliasPath;
        } else {
            NSArray *results =
                [[[appLister list] allObjects] sortedResultsUsingTerm:term];
            if ([results count] > 0) {
                SearchResult *result = [results objectAtIndex:0];
                appName = [result name];
                appPath = [result path];
            }
        }
    }

    // Get the application icon (if necessary).
    if (showIconPreviews && [appName length] > 0) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        appPath = [workspace fullPathForApplication:appName];

        if (appPath == nil) {
            appName = @"";
        } else {
            NSImage *icon = [workspace iconForFile:appPath];
            [icon setSize:NSMakeSize(16.0, 16.0)];
            [iconView setImage:icon];
        }
    }

    // Remove application icon (if necessary).
    if (appPath == nil && [iconView image]) {
        [iconView setImage:nil];
    }

    [appLabel setStringValue:appName];
    [appLabel setToolTip:appPath];

    [self setSelectedAppPath:appPath];

    [pool drain];
}

- (NSArray *)control:(NSControl *)control
            textView:(NSTextView *)textView
         completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange
 indexOfSelectedItem:(NSInteger *)index
{
    if (control != searchField) return words;

    NSString *term = [[textView textStorage] string];
    NSArray *results =
        [[[appLister list] allObjects] sortedResultsUsingTerm:term];

    // We only need the names to complete.
    results = [results map:^(id result) {
        return (id)[(SearchResult *)result name];
    }];

    // If an alias exists, it is to be preferred as the first item.
    NSString *aliasPath = [self pathForAlias:term];
    if (aliasPath != nil) {
        NSString *aliasName = [aliasPath fileNameWithoutExtension];
        results = [NSMutableArray arrayWithArray:results];
        [(NSMutableArray *)results removeObject:aliasName];
        [(NSMutableArray *)results insertObject:aliasName atIndex:0];
    }

    return results;
}

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView
doCommandBySelector:(SEL)command
{
    if (control != searchField) return NO;

    if (command == @selector(insertNewline:)) {
        [self launchApp:control];
        return YES;
    }

    // Show completion menu upon pressing escape, the down arrow, or tab.
    // TODO: Use a pretty custom menu here instead of the default.
    if (command == @selector(complete:) ||
        command == @selector(moveDown:) ||
        command == @selector(insertTab:)) {
        [textView selectAll:nil]; // Make sure we clear the text field
                                  // when completing.
        [textView complete:nil];
        return YES;
    }

    return NO;
}

#pragma mark -

#pragma mark IBActions

- (IBAction)refreshAppList:(id)sender
{
    [appLister refresh];
}

- (IBAction)toggleSearchPanel:(id)sender
{
    [globalHotKeyRegistrar unregisterEscapeKey];
    [globalHotKeyRegistrar hotKeyBlock]();
}

- (IBAction)activateSearchPanel:(id)sender
{
    [globalHotKeyRegistrar registerEscapeKey];
    [NSApp activateIgnoringOtherApps:YES];
    [searchField selectText:nil];
    [searchWindow makeKeyAndOrderFront:nil];
}

- (IBAction)launchApp:(id)sender
{
    if ([selectedAppPath length] > 0) {
        if (![[NSWorkspace sharedWorkspace] openFile:selectedAppPath]) {
            NSString *alertMsg =
                [NSString stringWithFormat:@"“%@” doesn’t appear to be "
                                           @"a launchable app. Is this an "
                                           @"out-of-date alias?",
                 selectedAppPath];
            NSRunAlertPanel(@"Failed to launch app",
                            alertMsg, @"… Oh.", nil, nil);
            NSLog(@"Failed to launch \"%@\"", selectedAppPath);
        } else {
          [globalHotKeyRegistrar unregisterEscapeKey];
        }
    }
}

- (IBAction)revealAppInFinder:(id)sender
{
    if ([selectedAppPath length] > 0) {
        [[NSWorkspace sharedWorkspace] selectFile:selectedAppPath
                         inFileViewerRootedAtPath:selectedAppPath];
    }
}

- (IBAction)showPreferencePanel:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    PreferencesController *preferencesController =
        [PreferencesController sharedPreferencesController];
    [preferencesController setDelegate:self];
	[preferencesController showWindow:sender];
}

- (IBAction)closeOrHideKeyWindow:(id)sender
{
    [globalHotKeyRegistrar unregisterEscapeKey];
    NSWindow *keyWindow = [NSApp keyWindow];
    if ([keyWindow styleMask] & NSClosableWindowMask) {
        [keyWindow performClose:sender];
    } else {
        [keyWindow resignKeyWindow];
        if (keyWindow == searchWindow) {
            [NSApp hide:nil];
        }
    }
}

- (IBAction)orderFrontStandardAboutPanelAndActivateApp:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

#pragma mark -

- (void)setSearchFieldEnabled:(BOOL)enabled
{
    if (enabled) {
        if (![searchField isEnabled]) {
            [searchField setEnabled:YES];
            [[searchField window] makeFirstResponder:searchField];
        }
    } else {
        [searchField setEnabled:NO];
    }
}

#pragma mark AppLister delegate

- (void)loadingAppList:(AppLister *)appList
{
    if ([iconView image]) {
        [iconView setImage:nil];
    }

    [spinner startAnimation:nil];
    [self setSearchFieldEnabled:NO];
}

- (void)doneLoadingAppList:(AppLister *)appList
{
    [spinner stopAnimation:nil];
    [self setSearchFieldEnabled:YES];

    // Refresh any term the user may have entered.
    [self filterApps:nil];
}

#pragma mark -

#pragma mark PreferencesController delegate

- (void)globalKeyMappingSetToKeyCode:(unsigned short)keyCode
                       withModifiers:(NSUInteger)modifiers
{
    [globalHotKeyRegistrar setHotKeyToKeyCode:keyCode andModifiers:modifiers];
    [self updateMenuItemKeyBindings];
}

#pragma mark -

#pragma mark NSUserDefaults notifications

- (void)updateMenuItemKeyBindings
{
    // Update hot key string in menu bar.
    if (statusBarItem != nil) {
        NSString *toggleSearchPanelTitle = @"Toggle Search Panel";
        NSMenuItem *toggleSearchStatusItem =
            [[statusBarItem menu] itemWithTitle:toggleSearchPanelTitle];
        NSMenu *fileMenu = [[[NSApp mainMenu] itemWithTitle:@"File"] submenu];
        NSMenuItem *toggleSearchMenuItem =
            [fileMenu itemWithTitle:toggleSearchPanelTitle];

        if ([globalHotKeyRegistrar wasModified]) {
            unsigned short keyCode = [globalHotKeyRegistrar keyCode];
            NSUInteger modifierFlags = [globalHotKeyRegistrar modifierFlags];

            [toggleSearchStatusItem setKeyEquivalentKeyCode:keyCode];
            [toggleSearchStatusItem setKeyEquivalentModifierMask:modifierFlags];

            [toggleSearchMenuItem setKeyEquivalentKeyCode:keyCode];
            [toggleSearchMenuItem setKeyEquivalentModifierMask:modifierFlags];
        }
    }
}

- (void)preferencesChanged:(NSNotification *)note
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    showInMenuBar = [userDefaults boolForKey:showInMenuBarKey];
    showIconPreviews = [userDefaults boolForKey:showIconPreviewsKey];

    BOOL enableAnimations = [userDefaults boolForKey:enableAnimationsKey];
    [searchWindow setEnableAnimations:enableAnimations];

    if (showInMenuBar && statusBarItem == nil) {
        [self showMenuBarItem];
    } else if (!showInMenuBar && statusBarItem != nil) {
        [statusBarItem release];
        statusBarItem = nil;
    }

    if ([userDefaults boolForKey:showInDockKey]) {
        // Force the icon to show in the dock.
        if (!currentlyForeground) {
            ProcessSerialNumber psn = { 0, kCurrentProcess };
            TransformProcessType(&psn,
                                 kProcessTransformToForegroundApplication);
            currentlyForeground = YES;
        }
        cancelledRelaunch = NO;
    } else if (currentlyForeground && !cancelledRelaunch) {
        NSInteger button =
            NSRunAlertPanel(@"That task requires a relaunch (sorry!)",
                            @"Should we get it over with now?",
                            @"Relaunch now",
                            @"I’ll do it later",
                            nil);
        cancelledRelaunch = YES;
        if (button == NSAlertDefaultReturn) {
            [NSApp relaunch:nil];
        }
    }

    // Refresh array of excluded items and convert it to a set.
    NSArray *excludedItems = [userDefaults arrayForKey:excludedItemsKey];
    NSSet *excludedItemsSet = [[NSSet alloc] initWithArray:excludedItems];

    // Avoid refreshing the app list if we don't have to.
    if (![[appLister excludedItems] isEqual:excludedItemsSet]) {
        [appLister setExcludedItems:excludedItemsSet];
    }

    [excludedItemsSet release];

    // Refresh aliases.
    [self setCustomAliases:[userDefaults dictionaryForKey:aliasesKey]];

    // Refresh app list if recursion level was changed.
    NSInteger recursionLevel = [userDefaults integerForKey:recursionLevelKey];
    if (recursionLevel > 0 && recursionLevel != [appLister maxRecurseLevel]) {
        [appLister setMaxRecurseLevel:recursionLevel];
        if ([appLister hasScanned]) {
            [appLister refresh];
        }
    }
}

- (void)showMenuBarItem
{
    if (statusBarItem != nil) return; // Sanity check.

    // Show menu icon.
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    statusBarItem =
        [systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
    [statusBarItem retain];
    [statusBarItem setImage:[NSImage imageNamed:@"stache.png"]];
    [statusBarItem setAlternateImage:[NSImage imageNamed:@"stache_active.png"]];
    [statusBarItem setHighlightMode:YES];
    [statusBarItem setTitle:@""];
    [statusBarItem setEnabled:YES];

    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];

    [menu addItemWithTitle:@"Toggle Search Panel"
                    action:@selector(toggleSearchPanel:)
             keyEquivalent:@""];

    [menu addItemWithTitle:@"Refresh App List"
                    action:@selector(refreshAppList:)
             keyEquivalent:@"r"];

    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItemWithTitle:@"About Chuck"
                    action:@selector(orderFrontStandardAboutPanelAndActivateApp:)
             keyEquivalent:@""];

    [menu addItemWithTitle:@"Preferences…"
                    action:@selector(showPreferencePanel:)
             keyEquivalent:@","];

    [menu addItemWithTitle:@"Quit Chuck"
                    action:@selector(terminate:)
             keyEquivalent:@"q"];

    [statusBarItem setMenu:menu];
    [menu release];

    [self updateMenuItemKeyBindings];
}

#pragma mark -

@end
