//
//  HotKey.h
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

//
// Used for archiving keyboard shortcuts in NSUserDefaults.
//
@interface HotKey : NSObject
{
    unsigned short keyCode;
    NSUInteger modifierFlags;
}

@property (nonatomic, readonly) unsigned short keyCode;
@property (nonatomic, readonly) NSUInteger modifierFlags;

- (id)initWithKeyCode:(unsigned short)code
            modifiers:(NSUInteger)modifiers;

//
// Returns human-readable value valid for being used in NSUserDefaults (as
// opposed to NSCoding, which encodes the value in binary gibberish).
//
- (id)encodedValue;

//
// Returns new HotKey object from an object previously archived
// with -encodedValue.
//
- (id)initWithEncodedValue:(id)encodedValue;

@end
