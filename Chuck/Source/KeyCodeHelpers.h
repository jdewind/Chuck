/*
 *  KeyCodeHelpers.h
 *  Chuck
 *
 *  Created by Michael on 5/26/10.
 *  Copyright 2010 Michael Sanders.
 *
 */

#ifndef KEYCODEHELPERS_H
#define KEYCODEHELPERS_H

#include <ApplicationServices/ApplicationServices.h>

/* 
 * Returns a human-readable for the given keyboard mapping.
 * Any modifiers come first (as unicode characters), followed by the
 * representation of the key pressed in all caps.
 *
 * Note that this is merely *human-readable* and NOT compatible with
 * NSEvent strings (e.g. those used in NSMenu's -keyEquivalent methods). 
 */
CFStringRef createStringForMapping(CGKeyCode keyCode, CGEventFlags modifiers);

/* 
 * Returns true if given keycode is "special" and universal across
 * international keyboards (e.g., function keys, tab, delete, etc.) 
 */
bool isSpecialKey(CGKeyCode key);

/* 
 * Returns true if given key mapping is taken as a global shortcut, or false
 * if not. 
 */
bool globalMappingTaken(CGKeyCode keyCode, CGEventFlags modifiers);

#endif
