//
//  NSString+FromChar.m
//  Chuck
//
//  Created by Michael on 5/28/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSString+FromChar.h"

@implementation NSString (FromChar)

+ (id)stringWithCharacter:(unichar)c
{
    return [NSString stringWithCharacters:&c length:1];
}

- (BOOL)isEqualToCharacter:(unichar)c
{
    return [self length] == 1 &&
           [self isEqualToString:[NSString stringWithCharacter:c]];
}

@end