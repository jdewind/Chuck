//
//  AppController.h
//  Chuck
//
//  Created by Michael on 5/18/10.
//  Copyright 2010 Michael Sanders.
//

#import <Cocoa/Cocoa.h>
#import "AppLister.h"
#import "PreferencesController.h"

@class GlobalHotKeyRegistrar, ChuckSearchPanel;
@interface AppController : NSObject <AppListerDelegate,
                                     PreferencesControllerDelegate>
{
    AppLister *appLister;
    GlobalHotKeyRegistrar *globalHotKeyRegistrar;
    NSString *selectedAppPath;

    BOOL showIconPreviews;
    BOOL showInMenuBar;
    BOOL showInDock;
    BOOL currentlyForeground;
    BOOL cancelledRelaunch;
    NSStatusItem *statusBarItem;
    NSDictionary *customAliases;

    IBOutlet ChuckSearchPanel *searchWindow;
    IBOutlet NSTextField *appLabel;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSSearchFieldCell *searchFieldCell;
    IBOutlet NSProgressIndicator *spinner;
    IBOutlet NSImageView *iconView;
}

@property (nonatomic, copy) IBOutlet NSString *selectedAppPath;
@property (nonatomic, copy) NSDictionary *customAliases;

- (IBAction)filterApps:(id)sender;
- (IBAction)launchApp:(id)sender;
- (IBAction)revealAppInFinder:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)toggleSearchPanel:(id)sender;
- (IBAction)activateSearchPanel:(id)sender;
- (IBAction)refreshAppList:(id)sender;
- (IBAction)closeOrHideKeyWindow:(id)sender;
- (IBAction)orderFrontStandardAboutPanelAndActivateApp:(id)sender;

@end
