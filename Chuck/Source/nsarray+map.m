//
//  NSArray+Map.m
//  Chuck
//
//  Created by Michael on 6/2/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)map:(id (^)(id obj))block
{
    CFIndex count = [self count];
    if (count == 0) return [[self retain] autorelease];

    // We use a C array here instead of a mutable array in order to construct
    // our new array concurrently.
    id objects[count];

    // We have to use a pointer to access our array from within the block.
    id *objectsPtr = objects;
    __block BOOL checkForNil = NO;

    [self enumerateObjectsWithOptions:NSEnumerationConcurrent
                           usingBlock:^(id obj,
                                        NSUInteger idx,
                                        BOOL *stop) {
        id newObj = block(obj);
        if (newObj == nil && !checkForNil) checkForNil = YES;

        // We have to issue a -retain here to avoid a confusing bug
        // concerning blocks and autorelease pools.
        objectsPtr[idx] = [newObj retain];
    }];

    // Remove nil items if we need to.
    if (checkForNil) {
        CFIndex i, j;
        for (i = j = 0; i < count; ++i) {
            if (objects[i] != nil) {
                objects[j++] = objects[i];
            }
        }

        if (objects[0] == nil) { // We have an array full of nil!
            return [NSArray array];
        }

        count = j;
    }

    // Here we a CFArray that does NOT retain its values (since we've already
    // retained them above), to avoid looping over them again.
    CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
    arrayCallBacks.retain = NULL;
    CFArrayRef result = CFArrayCreate(kCFAllocatorDefault,
                                      (void const **)&objects,
                                      (CFIndex)count,
                                      &arrayCallBacks);
    return [(NSArray *)result autorelease];
}

@end
