//
//  NSMutableArray+Map.m
//  Chuck
//
//  Created by Michael on 6/18/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSMutableArray+Map.h"
#import "NSArray+Map.h"
#include <dispatch/dispatch.h>

@implementation NSMutableArray (Map)

- (void)replaceObjectsUsingBlock:(id (^)(id obj))block
{
    //
    // Here we have to use GCD directly to make this concurrent, because there
    // is no guarantee -enumerateObjectsUsingBlock: or even
    // -enumerateObjectsWithOptions:usingBlock: will not simply use (or fall
    // back to) fast enumeration, which does not support modifying the array.
    //
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply([self count], queue, ^(size_t idx) {
        [self replaceObjectAtIndex:idx
                        withObject:block([self objectAtIndex:idx])];
    });
}

@end
