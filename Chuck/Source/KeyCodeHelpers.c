/*
 *  KeyCodeHelpers.m
 *  Chuck
 *
 *  Created by Michael on 5/26/10.
 *  Copyright 2010 Michael Sanders.
 *
 *  This is an Objective-C (*.m) file ONLY in order to get Unicode support --
 *  only pure C is used.
 *  (See http://lists.apple.com/archives/xcode-users/2008/Jul/msg00209.html).
 *
 */

#include "KeyCodeHelpers.h"
#include <Carbon/Carbon.h> /* For kVK_codes (we really only
                            * need <HIToolbox/Events.h>) */

/* Returns a constant CFString for the given key, or NULL if it does not
 * require a special representation (does not need to be released, but doesn't
 * hurt if it is.) */
static CFStringRef stringForSpecialKey(CGKeyCode keyCode);

bool isSpecialKey(CGKeyCode keyCode)
{
	return stringForSpecialKey(keyCode) != NULL;
}

CFStringRef createStringForMapping(CGKeyCode keyCode, CGEventFlags modifiers)
{
	CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);
	CFStringRef specialKeyString;

	if (string == NULL) return NULL; /* Error. */

	if (modifiers & kCGEventFlagMaskControl) {
		CFStringAppend(string, CFSTR("\u2303"));
	}

	if (modifiers & kCGEventFlagMaskAlternate) {
		CFStringAppend(string, CFSTR("\u2325"));
	}

	if (modifiers & kCGEventFlagMaskShift) {
		CFStringAppend(string, CFSTR("\u21E7"));
	}

	if (modifiers & kCGEventFlagMaskCommand) {
		CFStringAppend(string, CFSTR("\u2318"));
	}

	specialKeyString = stringForSpecialKey(keyCode);
	if (specialKeyString == NULL) { /* Extract key from keyboard layout. */
		TISInputSourceRef currentKeyboard =
			TISCopyCurrentKeyboardInputSource();
		if (currentKeyboard != NULL) {
			CFDataRef uchr =
				TISGetInputSourceProperty(currentKeyboard,
										  kTISPropertyUnicodeKeyLayoutData);
			const UCKeyboardLayout *keyboardLayout =
				(const UCKeyboardLayout *)CFDataGetBytePtr(uchr);

			UInt32 deadKeyState = 0;
			UniCharCount stringLength = 0;
			UniChar characters[255];

			OSStatus status = UCKeyTranslate(keyboardLayout,
			                                 keyCode,
			                                 kUCKeyActionDown,
			                                 0,
			                                 LMGetKbdType(),
			                                 0,
			                                 &deadKeyState,
			                                 255,
			                                 &stringLength,
			                                 characters);
			if (status != noErr) {
				fprintf(stderr, "%s error translating from keycode %d to "
				                "string: %s\n",
				        GetMacOSStatusErrorString(status),
				        keyCode,
				        GetMacOSStatusCommentString(status));
			} else if (stringLength > 0) {
				CFStringAppendCharacters(string, characters, stringLength);
				CFStringCapitalize(string, CFLocaleGetSystem());
			}

			CFRelease(currentKeyboard);
		}
	} else {
		CFStringAppend(string, specialKeyString);
	}

	return string;
}

bool globalMappingTaken(CGKeyCode needleKeyCode, CGEventFlags modifiers)
{
	CFArrayRef globalHotKeys = NULL;
	CFIndex i, count;

	const bool cmdKeyHeld = modifiers & kCGEventFlagMaskCommand;
	const bool optionKeyHeld = modifiers & kCGEventFlagMaskAlternate;
	const bool shiftKeyHeld = modifiers & kCGEventFlagMaskShift;
	const bool controlKeyHeld = modifiers & kCGEventFlagMaskControl;

	if (CopySymbolicHotKeys(&globalHotKeys) != noErr ||
	    globalHotKeys == NULL) {
		return true;
	}

	count = CFArrayGetCount(globalHotKeys);
	for (i = 0; i < count; ++i) {
		CFDictionaryRef hotKeyInfoDict = CFArrayGetValueAtIndex(globalHotKeys,
		                                                        i);
		/* Only check if hotkey is enabled. */
		if (CFDictionaryGetValue(hotKeyInfoDict,
		                         kHISymbolicHotKeyEnabled) == kCFBooleanTrue) {
			CFNumberRef hotKeyCodeRef =
				CFDictionaryGetValue(hotKeyInfoDict, kHISymbolicHotKeyCode);
			if (hotKeyCodeRef != NULL) {
				CGKeyCode hotKeyCode;
				CFNumberRef hotKeyModifiersRef;
				CFNumberGetValue(hotKeyCodeRef, kCFNumberShortType,
				                 &hotKeyCode);

				hotKeyModifiersRef =
					CFDictionaryGetValue(hotKeyInfoDict,
					                     kHISymbolicHotKeyModifiers);
				if (hotKeyModifiersRef != NULL) {
					CGEventFlags hotKeyModifiers;
					CFNumberGetValue(hotKeyModifiersRef,
					                 kCFNumberSInt32Type,
					                 &hotKeyModifiers);

					const bool hotKeyHasCmdHeld =
						hotKeyModifiers & kCGEventFlagMaskCommand;
					const bool hotKeyHasOptionHeld =
						hotKeyModifiers & kCGEventFlagMaskAlternate;
					const bool hotKeyHasShiftHeld =
						hotKeyModifiers & kCGEventFlagMaskShift;
					const bool hotKeyHasControlHeld =
						hotKeyModifiers & kCGEventFlagMaskControl;

					/* Check if the key mappings are the same. */
					if (hotKeyCode == needleKeyCode &&
					    hotKeyHasCmdHeld == cmdKeyHeld &&
						hotKeyHasOptionHeld == optionKeyHeld &&
						hotKeyHasShiftHeld == shiftKeyHeld &&
						hotKeyHasControlHeld == controlKeyHeld) {
						CFRelease(globalHotKeys);
						return true;
					}
				}
			}
		}

	}

	CFRelease(globalHotKeys);
	return false;
}

static CFStringRef stringForSpecialKey(CGKeyCode keyCode)
{
	switch (keyCode) {
		case kVK_Space:
			return CFSTR("Space");
		case kVK_Return:
			return CFSTR("\u2305");
		case kVK_Delete:
			return CFSTR("\u232B");
		case kVK_ForwardDelete:
			return CFSTR("\u2326");
		case kVK_RightArrow:
			return CFSTR("\u2192");
		case kVK_LeftArrow:
			return CFSTR("\u2190");
		case kVK_UpArrow:
			return CFSTR("\u2191");
		case kVK_DownArrow:
			return CFSTR("\u2193");
		case kVK_Escape:
			return CFSTR("\u238B");
		case kVK_PageDown:
			return CFSTR("\u21DF");
		case kVK_PageUp:
			return CFSTR("\u21DE");
		case kVK_Tab:
			return CFSTR("\u21E5");
		case kVK_Help:
			return CFSTR("\uF746");
		case kVK_F1:
			return CFSTR("F1");
		case kVK_F2:
			return CFSTR("F2");
		case kVK_F3:
			return CFSTR("F3");
		case kVK_F4:
			return CFSTR("F4");
		case kVK_F5:
			return CFSTR("F5");
		case kVK_F6:
			return CFSTR("F6");
		case kVK_F7:
			return CFSTR("F7");
		case kVK_F8:
			return CFSTR("F8");
		case kVK_F9:
			return CFSTR("F9");
		case kVK_F10:
			return CFSTR("F10");
		case kVK_F11:
			return CFSTR("F11");
		case kVK_F12:
			return CFSTR("F12");
		case kVK_F13:
			return CFSTR("F13");
		case kVK_F14:
			return CFSTR("F14");
		case kVK_F15:
			return CFSTR("F15");
		case kVK_F16:
			return CFSTR("F16");
		case kVK_F17:
			return CFSTR("F17");
		case kVK_F18:
			return CFSTR("F18");
		case kVK_F19:
			return CFSTR("F19");
		// Number pad glyphs:
		case kVK_ANSI_KeypadDecimal:
			return CFSTR("Keypad .");
		case kVK_ANSI_KeypadMultiply:
			return CFSTR("Keypad *");
		case kVK_ANSI_KeypadPlus:
			return CFSTR("Keypad +");
		case kVK_ANSI_KeypadClear:
			return CFSTR("Clear");
		case kVK_ANSI_KeypadDivide:
			return CFSTR("Keypad Divide");
		case kVK_ANSI_KeypadEnter:
			return CFSTR("Keypad Enter");
		case kVK_ANSI_KeypadMinus:
			return CFSTR("Keypad -");
		case kVK_ANSI_KeypadEquals:
			return CFSTR("Keypad =");
		case kVK_ANSI_Keypad0:
			return CFSTR("Keypad 0");
  		case kVK_ANSI_Keypad1:
			return CFSTR("Keypad 1");
  		case kVK_ANSI_Keypad2:
			return CFSTR("Keypad 2");
  		case kVK_ANSI_Keypad3:
			return CFSTR("Keypad 3");
  		case kVK_ANSI_Keypad4:
			return CFSTR("Keypad 4");
  		case kVK_ANSI_Keypad5:
			return CFSTR("Keypad 5");
  		case kVK_ANSI_Keypad6:
			return CFSTR("Keypad 6");
  		case kVK_ANSI_Keypad7:
			return CFSTR("Keypad 7");
  		case kVK_ANSI_Keypad8:
			return CFSTR("Keypad 8");
  		case kVK_ANSI_Keypad9:
			return CFSTR("Keypad 9");
		default:
			return NULL;
	}
}
