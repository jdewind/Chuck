//
//  NSString+FromChar.h
//  Chuck
//
//  Created by Michael on 5/28/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

@interface NSString (FromChar)

//
// Convenience method that returns string of length 1 containing the
// given character.
//
+ (id)stringWithCharacter:(unichar)c;

//
// Convenience method to deduce whether string is of length 1 and its only
// character is equal to the given argument.
//
- (BOOL)isEqualToCharacter:(unichar)c;

@end
