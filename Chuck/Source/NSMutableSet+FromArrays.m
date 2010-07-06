//
//  NSMutableSet+FromArrays.m
//  Chuck
//
//  Created by Michael on 6/21/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSMutableSet+FromArrays.h"
#import "NSArray+Do.h"

@implementation NSMutableSet (FromArrays)

- (void)addObjectsFromArrays:(NSArray *)arrayOfArrays
{
    [arrayOfArrays doConcurrently:^(id array) {
        [self addObjectsFromArray:array];
    }];
}

@end
