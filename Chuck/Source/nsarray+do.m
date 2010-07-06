//
//  NSArray+Do.m
//  Chuck
//
//  Created by Michael on 6/18/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSArray+Do.h"

@implementation NSArray (Do)

- (void)do:(void (^)(id obj))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)doConcurrently:(void (^)(id obj))block
{
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent
                           usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

@end
