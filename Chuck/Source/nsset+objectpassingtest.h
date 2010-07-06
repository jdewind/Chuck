//
//  NSSet+ObjectPassingTest.h
//  Chuck
//
//  Created by Michael on 6/17/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSSet (Search)

//
// Returns the first object in the receiver that passes a test in the
// given block.
//
// The counterpart to -objectsPassingTest:.
//
// (Not sure why this isn't included by default. Seems like a missing method
// to me!)
//
- (id)objectPassingTest:(BOOL (^)(id obj))test;

@end
