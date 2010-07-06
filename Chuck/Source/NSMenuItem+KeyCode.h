//
//  NSMenuItem+KeyCode.h
//  Chuck
//
//  Created by Michael on 5/28/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

@interface NSMenuItem (KeyCode)

//
// Sets the receiver's keyboard equivalent using its key code instead
// of a string.
//
// Analogous to -setKeyEquivalentModifierMask: (looks like a missing method if
// you ask me).
//
- (void)setKeyEquivalentKeyCode:(unsigned short)keyCode;

@end
