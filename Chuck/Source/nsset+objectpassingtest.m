//
//  NSSet+ObjectPassingTest.m
//  Chuck
//
//  Created by Michael on 6/17/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSSet+ObjectPassingTest.h"

@implementation NSSet (Search)

- (id)objectPassingTest:(BOOL (^)(id o))test
{
    return [[self objectsPassingTest:^(id obj, BOOL *stop) {
        BOOL passes = test(obj);
        if (passes) *stop = YES;
        return passes;
    }] anyObject];
}

@end
