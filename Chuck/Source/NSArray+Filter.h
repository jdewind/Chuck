//
//  NSArray+Filter.h
//  Chuck
//
//  Created by Michael on 6/23/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSArray (Filter)

//
// Evaluates a given block against each object in the receiver and returns a
// new array containing the objects for which the block returns true.
//
// The given block should be safe to be used concurrently.
//
- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id object))block;

@end
