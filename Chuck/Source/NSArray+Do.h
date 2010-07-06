//
//  NSArray+Do.h
//  Chuck
//
//  Created by Michael on 6/18/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSArray (Do)

//
// Enumerates over the object in the reciever in order.
// A convenient alternative to -enumerateObjectsUsingBlock:.
//
- (void)do:(void (^)(id obj))block;

//
// Enumerates over the object in the receiever concurrently.
// A convenient alternative to -enumerateObjectsWithOptions:usingBlock:.
//
- (void)doConcurrently:(void (^)(id obj))block;

@end
