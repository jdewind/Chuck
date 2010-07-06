//
//  NSMenuItem+KeyCode.m
//  Chuck
//
//  Created by Michael on 5/28/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSMenuItem+KeyCode.h"
#import "NSString+FromChar.h"
#include "KeyCodeHelpers.h"
#include <Carbon/Carbon.h> /* For kVK_codes (we really only
                            * need <HIToolbox/Events.h>) */

static unichar charForSpecialKey(CGKeyCode keyCode)
{
	switch (keyCode) {
        case kVK_Return:
            return '\r';
        case kVK_Tab:
            return '\t';
        case kVK_Space:
            return 0x2423;
        case kVK_Delete:
            return '\177';
        case kVK_Escape:
            return '\37';
        case kVK_F1:
            return NSF1FunctionKey;
        case kVK_F2:
            return NSF2FunctionKey;
        case kVK_F3:
            return NSF3FunctionKey;
        case kVK_F4:
            return NSF4FunctionKey;
        case kVK_F5:
            return NSF5FunctionKey;
        case kVK_F6:
            return NSF6FunctionKey;
        case kVK_F7:
            return NSF7FunctionKey;
        case kVK_F8:
            return NSF8FunctionKey;
        case kVK_F9:
            return NSF9FunctionKey;
        case kVK_F10:
            return NSF10FunctionKey;
        case kVK_F11:
            return NSF11FunctionKey;
        case kVK_F12:
            return NSF12FunctionKey;
        case kVK_F13:
            return NSF13FunctionKey;
        case kVK_F14:
            return NSF14FunctionKey;
        case kVK_F15:
            return NSF15FunctionKey;
        case kVK_F16:
            return NSF16FunctionKey;
        case kVK_F17:
            return NSF17FunctionKey;
        case kVK_F18:
            return NSF18FunctionKey;
        case kVK_F19:
            return NSF19FunctionKey;
        case kVK_F20:
            return NSF20FunctionKey;
        case kVK_Help:
            return NSHelpFunctionKey;
        case kVK_Home:
            return NSHomeFunctionKey;
        case kVK_PageDown:
            return NSPageDownFunctionKey;
        case kVK_PageUp:
            return NSPageUpFunctionKey;
        case kVK_ForwardDelete:
            return NSDeleteFunctionKey;
        case kVK_End:
            return NSEndFunctionKey;
        case kVK_LeftArrow:
            return NSLeftArrowFunctionKey;
        case kVK_RightArrow:
            return NSRightArrowFunctionKey;
        case kVK_DownArrow:
            return NSDownArrowFunctionKey;
        case kVK_UpArrow:
            return NSUpArrowFunctionKey;
		case kVK_ANSI_KeypadClear:
            return NSClearDisplayFunctionKey;
		default:
			return '\0';
	}
}

static NSString *stringForSpecialKey(CGKeyCode keyCode)
{
    unichar c = charForSpecialKey(keyCode);
    return (c == '\0') ? nil : [NSString stringWithCharacter:c];
}

static NSString *keyEquivalentStringForKeyCode(CGKeyCode code)
{
    NSString *specialKeyString = stringForSpecialKey(code);

    if (specialKeyString == nil) {
        NSString *readableString = (NSString *)createStringForMapping(code, 0);
        NSString *ret = [readableString lowercaseString];
        [readableString release];
        return ret;
    }

    return specialKeyString;
}

@implementation NSMenuItem (KeyCode)

- (void)setKeyEquivalentKeyCode:(unsigned short)code
{
    [self setKeyEquivalent:keyEquivalentStringForKeyCode(code)];
}

@end
