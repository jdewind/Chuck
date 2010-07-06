//
//  NSArray+Filter.m
//  Chuck
//
//  Created by Michael on 6/23/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSArray+Filter.h"

@implementation NSArray (Filter)

- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id object))block
{
    NSIndexSet *validIndexes =
        [self indexesOfObjectsWithOptions:NSEnumerationConcurrent
                              passingTest:^(id obj,
                                            NSUInteger idx,
                                            BOOL *stop) {
            return block(obj);
        }];

    return [self objectsAtIndexes:validIndexes];
}

@end
