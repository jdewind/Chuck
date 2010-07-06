//
//  NSWorkspace+LoginItem.h
//  Chuck
//
//  Created by Michael on 6/14/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

@interface NSWorkspace (LoginItem)

//
// Returns whether the current process was launched as a login item (as opposed
// to, e.g., the Finder).
//
- (BOOL)launchedAsLoginItem;

@end
