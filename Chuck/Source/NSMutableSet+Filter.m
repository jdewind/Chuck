//
//  NSMutableSet+Filter.m
//  Chuck
//
//  Created by Michael on 6/23/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSMutableSet+Filter.h"

@implementation NSMutableSet (Filter)

- (void)filterUsingBlock:(BOOL (^)(id object))block
{
    NSSet *validObjects = [self objectsWithOptions:NSEnumerationConcurrent
                                       passingTest:^(id obj, BOOL *stop) {
        return block(obj);
    }];

    [self setSet:validObjects];
}

@end
