//
//  NSArray+Map.h
//  Chuck
//
//  Created by Michael on 6/2/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSArray (Map)

//
// Constructs a new array using the given block.
// This block must be safe to be used concurrently.
//
// Unlike its mutable equivalent (-replaceObjectsUsingBlock:), this block may
// return nil, in which case that item is skipped and not added to the
// returned array.
//
- (NSArray *)map:(id (^)(id obj))block;

@end
