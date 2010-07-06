//
//  AppLister.h
//  Chuck
//
//  Created by Michael on 5/23/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>
#import "SearchResult.h"

@class AppLister;
@protocol AppListerDelegate <NSObject>
@optional
- (void)loadingAppList:(AppLister *)appList;
- (void)doneLoadingAppList:(AppLister *)appList;
@end

//
// A class used to search for applications.
//
@interface AppLister : NSObject
{
    NSMutableSet *list;
    NSSet *excludedItems;
    NSUInteger maxRecurseLevel;
    id <AppListerDelegate> delegate;
    NSArray *foldersToSearch;

    BOOL foldersToSearchNeedUpdating;
    BOOL currentlyLoading;
    BOOL hasScanned;
}

- (id)initWithDelegate:(id <AppListerDelegate>)delegate;

//
// Starts scanning for applications in the background, and notifies delegate
// upon completion (should only be called once).
//
- (void)startScanning;

//
// Refreshes list of applications in the background (returns immediately, and
// notifies delegate upon completion).
//
// This should only be called AFTER -startScanning: has been called (when
// -hasScanned returns YES).
//
- (void)refresh;

@property (nonatomic, readonly) id <AppListerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasScanned;

//
// A read-only set of the current list of applications as SearchResult objects.
//
@property (nonatomic, readonly) NSSet *list;

//
// The maximum level to recurse when searching for applications in
// supported folders.
//
// Set to a low value for faster launch speed, or a high value for a more
// exhaustive search.
//
// Defaults to 3.
//
@property (nonatomic, assign) NSUInteger maxRecurseLevel;

//
// List of folders to blacklist from searching, and applications to ignore.
//
// When set, the app list is automatically refreshed.
//
@property (nonatomic, copy) NSSet *excludedItems;

@end
