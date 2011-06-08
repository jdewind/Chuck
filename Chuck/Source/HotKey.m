//
//  HotKey.m
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import "HotKey.h"

@implementation HotKey
@synthesize keyCode;
@synthesize modifierFlags;

- (id)initWithKeyCode:(unsigned short)code
            modifiers:(NSUInteger)modifiers
{
    self = [super init];

    if (self != nil) {
        keyCode = code;
        modifierFlags = modifiers;
    }

    return self;
}

- (id)initWithEncodedValue:(id)encodedValue
{
    if (encodedValue != nil &&
        [encodedValue isKindOfClass:[NSDictionary class]]) {
        NSNumber *code = [encodedValue objectForKey:@"keyCode"];
        NSNumber *modifiers = [encodedValue objectForKey:@"modifierFlags"];

        if (code != nil && modifiers != nil) {
            return [self initWithKeyCode:[code unsignedShortValue]
                               modifiers:[modifiers unsignedIntegerValue]];
        }
    }

    return nil;
}

- (id)encodedValue
{
    NSNumber *code = [NSNumber numberWithUnsignedShort:keyCode];
    NSNumber *modifiers = [NSNumber numberWithUnsignedInteger:modifierFlags];
    return [NSDictionary dictionaryWithObjectsAndKeys:code,
                                                      @"keyCode",
                                                      modifiers,
                                                      @"modifierFlags",
                                                      nil];
}

- (BOOL)isEqual:(id)someObject
{
    return self == someObject ||
           ([someObject isKindOfClass:[self class]] &&
            [someObject keyCode] == keyCode &&
            [someObject modifierFlags] == modifierFlags);
}

@end
