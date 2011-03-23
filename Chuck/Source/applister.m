//
//  AppLister.m
//  Chuck
//
//  Created by Michael on 5/23/10.
//  Copyright 2010 Michael Sanders.
//

#import "AppLister.h"
#import "NSArray+Do.h"
#import "NSArray+Filter.h"
#import "NSArray+Map.h"
#import "NSMutableSet+Filter.h"
#import "NSMutableSet+FromArrays.h"
#import "NSSet+ObjectPassingTest.h"

//
// Returns list of applications (.app bundles) recursively found in the given
// directory, or nil if none are found.
//
static NSArray *listOfAppsInDir(NSString *dir,
                                const NSUInteger maxRecurseLevel);

//
// Returns whether given directory is a parent of the given path.
// Both paths are assumed to be given without a trailing slash.
//
static BOOL directoryContainsPath(NSString *dir, NSString *path)
{
    NSCParameterAssert(![dir hasSuffix:@"/"]);
    NSCParameterAssert(![path hasSuffix:@"/"]);

    return [dir isEqualToString:path] ||
           [path hasPrefix:[dir stringByAppendingString:@"/"]];
}

@interface AppLister ()

- (void)_actuallyRefresh;
- (void)filterListFromExcludedItems;
- (void)refreshFoldersToSearch;

@end

@implementation AppLister
@synthesize delegate;
@synthesize hasScanned;
@synthesize list;
@synthesize maxRecurseLevel;
@synthesize excludedItems;

// Designated initializer.
- (id)initWithDelegate:(id <AppListerDelegate>)newDelegate
{
    self = [super init];

    if (self != nil) {
        list = [[NSMutableSet alloc] init];
        delegate = newDelegate;
        maxRecurseLevel = 3;
    }

    return self;
}

- (id)init
{
    return [self initWithDelegate:nil];
}

- (void)dealloc
{
    [foldersToSearch release];
    [excludedItems release];
    [list release];
    [super dealloc];
}

- (void)startScanning
{
    [self refresh];
}

#pragma mark Excluded items

- (void)setExcludedItems:(NSSet *)items
{
    NSSet *copy = [items copy];
    [excludedItems release];
    excludedItems = copy;

    // Make sure we aren't already scanning when we do this.
    if (currentlyLoading) {
        foldersToSearchNeedUpdating = YES;
    } else if (foldersToSearch != nil) {
        DLog(@"Excluded items set; refreshing list");
        [self refreshFoldersToSearch];
        [self filterListFromExcludedItems];
    }
}

- (BOOL)pathIsExcluded:(NSString *)path
{
    return [excludedItems objectPassingTest:^(id item) {
        return directoryContainsPath(item, path);
    }] != nil;
}

- (void)filterListFromExcludedItems
{
    if (excludedItems != nil && [excludedItems count] > 0) {
        [list filterUsingBlock:^(id app) {
            return (BOOL)![self pathIsExcluded:[(SearchResult *)app path]];
        }];
    }
}

- (void)refreshFoldersToSearch
{
    [foldersToSearch release];
    foldersToSearch =
        NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory,
                                            NSAllDomainsMask, YES);

    if (excludedItems != nil && [excludedItems count] > 0) {
        foldersToSearch = [foldersToSearch filteredArrayUsingBlock:^(id obj) {
            return (BOOL)![self pathIsExcluded:obj];
        }];
    }

    [foldersToSearch retain];
}

#pragma mark -

#if defined(DEBUG)
#include <sys/time.h>

static inline double getSeconds(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return tv.tv_sec + (tv.tv_usec / 1000000.0);
}

#endif

- (void)refresh
{
    if (!currentlyLoading) {
        if (foldersToSearchNeedUpdating || foldersToSearch == nil) {
            [self refreshFoldersToSearch];
        }

        dispatch_queue_t queue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self _actuallyRefresh];
        });
    }
}

- (void)_actuallyRefresh
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    currentlyLoading = YES;

    [list removeAllObjects];

    if ([delegate respondsToSelector:@selector(loadingAppList:)]) {
        [delegate loadingAppList:self];
    }

#if defined(DEBUG)
    const double cur = getSeconds();
#endif

    [list addObjectsFromArrays:[foldersToSearch map:^(id dir) {
        return (id)listOfAppsInDir(dir, maxRecurseLevel);
    }]];

    [self filterListFromExcludedItems];

#if defined(DEBUG)
    DLog(@"took %.4f seconds", getSeconds() - cur);
    DLog(@"Found %d apps", [list count]);
#endif

    if ([delegate respondsToSelector:@selector(doneLoadingAppList:)]) {
        [delegate doneLoadingAppList:self];
    }

    // For next time (-filterListFromExcludedItems should take care of this if
    // we don't catch it in time, but this avoids the need to scan the folders
    // altogether, and hence should be more efficient should we find the need
    // to scan again).
    if (foldersToSearchNeedUpdating) {
        DLog(@"Refreshing folders to search");
        [self refreshFoldersToSearch];
        foldersToSearchNeedUpdating = NO;
    }

    currentlyLoading = NO;
    hasScanned = YES;

    [pool drain];
}

@end

//
// Returns newly allocated list of applications in given directory, or an empty
// array if the directory does not exist or no applications are in it.
//
// "recurseLevel" should always be set to 0 by the caller; it is only set to a
// non-zero value from within the function for obvious reasons.
//
// Follows the Create Rule (returned array is to be freed by caller).
//
static NSArray *copyListOfAppsInSubDir(NSString *dir,
                                       NSUInteger recurseLevel,
                                       const NSUInteger maxRecurseLevel)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath:dir error:NULL];
    if (files == nil) return nil;

    NSMutableArray *apps = [[NSMutableArray alloc] init];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    const BOOL canRecurse = recurseLevel < maxRecurseLevel;

    [files do:^(id filename) {
        NSString *fullPath = [dir stringByAppendingPathComponent:filename];
        if ([filename hasSuffix:@".app"]) {
            NSString *appName = [filename stringByDeletingPathExtension];
            SearchResult *result = [[SearchResult alloc] initWithName:appName
                                                                 path:fullPath];
            [apps addObject:result];
            [result release];
        } else if (canRecurse) {
            // Recurse directories if we need to, but ignore bundles.
            BOOL isDir;
            if ([manager fileExistsAtPath:fullPath
                              isDirectory:&isDir] && isDir &&
                ![workspace isFilePackageAtPath:fullPath]) {
                NSArray *moreApps = copyListOfAppsInSubDir(fullPath,
                                                           recurseLevel + 1,
                                                           maxRecurseLevel);
                [apps addObjectsFromArray:moreApps];
                [moreApps release];
            }
        }
    }];

    return apps;
}

static inline NSArray *listOfAppsInDir(NSString *dir,
                                       const NSUInteger maxRecurseLevel)
{
    return [copyListOfAppsInSubDir(dir, 0, maxRecurseLevel) autorelease];
}
