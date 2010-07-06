//
//  NSMutableSet+Filter.h
//  Chuck
//
//  Created by Michael on 6/23/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (Filter)

//
// Evaluates a given block against each object in the receiver and removes the
// objects for which the block returns false.
//
// The given block should be safe to be used concurrently.
//
- (void)filterUsingBlock:(BOOL (^)(id object))block;

@end
