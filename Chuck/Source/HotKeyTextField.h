//
//  HotKeyTextField.h
//  Chuck
//
//  Created by Michael on 5/25/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

@class HotKeyTextField;
@protocol HotKeyTextFieldDelegate
- (void)hotKeyTextField:(HotKeyTextField *)textField
           choseKeyCode:(unsigned short)keyCode
          withModifiers:(NSUInteger)modifiers;
@end

@interface HotKeyTextField : NSTextView
{
    id <HotKeyTextFieldDelegate> delegate;
}

@property (nonatomic, assign) id <HotKeyTextFieldDelegate> delegate;

//
// Sets text field string to the readable equivalent of the given keycode and
// modifier flags.
//
// This method does not notify the delegate or check whether the hotkey is
// already taken.
//
- (void)setKeyCodeValue:(unsigned short)keyCode
          withModifiers:(NSUInteger)modifiers;

@end
