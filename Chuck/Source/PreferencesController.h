//
//  PreferencesController.h
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

extern NSString * const recursionLevelKey;
extern NSString * const enableAnimationsKey;
extern NSString * const showIconPreviewsKey;
extern NSString * const showInMenuBarKey;
extern NSString * const showInDockKey;
extern NSString * const globalShortcutKey;
extern NSString * const excludedItemsKey;
extern NSString * const aliasesKey;

@protocol PreferencesControllerDelegate <NSObject>

@optional
- (void)globalKeyMappingSetToKeyCode:(unsigned short)keyCode
                       withModifiers:(NSUInteger)modifiers;

@end

@class HotKey, HotKeyTextField;
@interface PreferencesController : NSWindowController
{
    id <PreferencesControllerDelegate> delegate;
    BOOL openAtLogin;
    BOOL enableAnimations;
    BOOL showIconPreviews;
    BOOL showInMenuBar;
    BOOL showInDock;
    NSUInteger recursionLevel;
    NSMutableArray *excludedItems;
    NSMutableDictionary *aliases;
    NSString *recursionLevelDescription;

    IBOutlet HotKeyTextField *hotKeyField;
    IBOutlet NSTabView *tabView;
    IBOutlet NSTableView *excludedItemsTableView;
    IBOutlet NSTableView *aliasesTableView;
    IBOutlet NSDictionaryController *aliasesDictionaryController;

@private
    HotKey *globalHotKey;
    BOOL savedPreferences;
}

+ (PreferencesController *)sharedPreferencesController;

- (IBAction)newExcludedItem:(id)sender;
- (IBAction)removeSelectedExcludedItem:(id)sender;
- (IBAction)newAlias:(id)sender;
- (IBAction)removeSelectedAlias:(id)sender;

@property (nonatomic, assign) id <PreferencesControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet BOOL openAtLogin;
@property (nonatomic, assign) IBOutlet BOOL enableAnimations;
@property (nonatomic, assign) IBOutlet BOOL showIconPreviews;
@property (nonatomic, assign) IBOutlet BOOL showInMenuBar;
@property (nonatomic, assign) IBOutlet BOOL showInDock;
@property (nonatomic, assign) IBOutlet NSUInteger recursionLevel;
@property (nonatomic, readonly) IBOutlet BOOL enableDeleteSelectedExcludedItem;
@property (nonatomic, readonly) IBOutlet BOOL enableDeleteSelectedAlias;
@property (nonatomic, copy) IBOutlet NSString *recursionLevelDescription;

@property (nonatomic, retain) IBOutlet NSArray *excludedItems;

//
// A dictionary of aliases/shortcuts, composed of strings of the aliases mapped
// to their paths.
//
@property (nonatomic, copy) IBOutlet NSDictionary *aliases;

//
// Adds the given item to the list of excluded items if it is not
// already listed.
//
- (void)addExcludedItem:(NSString *)excludedPath;

//
// Removes the item at the given index from the list of excluded items.
//
- (void)removeExcludedItemAtIndex:(NSUInteger)index;

//
// Adds the item to the list of aliases if it is not already stored.
//
- (void)addAlias:(NSString *)alias forPath:(NSString *)path;

//
// Removes given alias from list of saved aliases.
//
- (void)removeAlias:(NSString *)alias;

@end
