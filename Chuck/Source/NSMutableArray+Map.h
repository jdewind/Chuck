//
//  NSMutableArray+Map.h
//  Chuck
//
//  Created by Michael on 6/18/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Map)

//
// Modifies array in-place using the given block.
// This block must be safe to be used concurrently, and can never return nil.
//
- (void)replaceObjectsUsingBlock:(id (^)(id obj))block;

@end
