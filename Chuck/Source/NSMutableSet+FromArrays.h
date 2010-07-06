//
//  NSMutableSet+FromArrays.h
//  Chuck
//
//  Created by Michael on 6/21/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (FromArrays)

//
// Adds the objects contained in each array given in the nested array.
//
- (void)addObjectsFromArrays:(NSArray *)arrayOfArrays;

@end
