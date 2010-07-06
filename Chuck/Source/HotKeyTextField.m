//
//  HotKeyTextField.m
//  Chuck
//
//  Created by Michael on 5/25/10.
//  Copyright 2010 Michael Sanders.
//

#import "HotKeyTextField.h"
#import "NSMenu+KeyCode.h"
#import "NSString+FromChar.h"
#include "KeyCodeHelpers.h"

@implementation HotKeyTextField
@synthesize delegate;

- (void)awakeFromNib
{
    [self setTextContainerInset:NSMakeSize(3.0, 6.0)];
}

- (BOOL)shouldDrawInsertionPoint
{
    return NO; // Don't draw the caret.
}

//
// Force forcus ring to be drawn by our custom class (FocusRingScrollView).
//
- (BOOL)becomeFirstResponder
{
    NSView *superview = [self superview];
    [superview setKeyboardFocusRingNeedsDisplayInRect:[superview bounds]];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    NSView *superview = [self superview];
    [superview setKeyboardFocusRingNeedsDisplayInRect:[superview bounds]];
    return [super resignFirstResponder];
}

- (void)setKeyCodeValue:(unsigned short)keyCode
          withModifiers:(NSUInteger)modifiers
{
    NSString *readableString = (NSString *)createStringForMapping(keyCode,
                                                                  modifiers);
    [self setString:readableString];
    [readableString release];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    // Sanity check.
    if ([[self window] firstResponder] != self) return NO;

    CGEventFlags modifiers = [event modifierFlags];
    CGKeyCode keyCode = [event keyCode];

    if (!((modifiers & NSAlternateKeyMask) || (modifiers & NSShiftKeyMask) ||
          (modifiers & NSCommandKeyMask) || (modifiers & NSControlKeyMask))) {
        return NO;
    }

    NSString *readableString = (NSString *)createStringForMapping(keyCode,
                                                                  modifiers);
    if (globalMappingTaken(keyCode, modifiers)) {
        DLog(@"Already taken!");
        NSString *errorMsg =
            [NSString stringWithFormat:@"The key combination “%@” cannot be "
                                       @"used because it is already used as "
                                       @"a global shortcut.", readableString];
        NSBeginAlertSheet(@"Oops!", nil, nil, nil,
                          [self window], nil, NULL, NULL, NULL, errorMsg);
    }

    NSMenuItem *menuItemWithMapping =
        [[NSApp mainMenu] menuItemForKeyCode:keyCode withModifiers:modifiers];
    if (menuItemWithMapping != nil) {
        NSString *errorMsg =
            [NSString stringWithFormat:@"The key combination “%@” cannot be "
                                       @"used because it is already used by "
                                       @"the menu item “%@”.", readableString,
                                                 [menuItemWithMapping title]];
        NSBeginAlertSheet(@"Oops!", nil, nil, nil,
                          [self window], nil, NULL, NULL, NULL, errorMsg);
    } else {
        [self setString:readableString];
        if (delegate != nil) {
            [delegate hotKeyTextField:self
                         choseKeyCode:keyCode
                        withModifiers:modifiers];
        }
    }

    [readableString release];
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    // Sanity check.
    NSWindow *window = [self window];
    if ([window firstResponder] != self) return;

    NSUInteger modifierFlags = [event modifierFlags];
    NSString *characters = [event characters];

    if ((modifierFlags & NSAlternateKeyMask) ||
        ((modifierFlags & NSShiftKeyMask) && isSpecialKey([event keyCode]))) {
        [self performKeyEquivalent:event];
    } else if ([characters isEqualToString:@"\t"]) { // Tab
        [window makeFirstResponder:[self nextKeyView]];
    } else if ([characters isEqualToString:@"\177"] || // Delete
               [characters isEqualToCharacter:NSDeleteFunctionKey]) { // Forward delete
        [self setString:@""];
    } else if ([characters isEqualToString:@"\37"]) { // Escape
        [window makeFirstResponder:nil];
    } else {
        NSBeep();
    }
}

@end
