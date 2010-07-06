//
//  NSMenu+KeyCode.m
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSMenu+KeyCode.h"
#include "KeyCodeHelpers.h"

@implementation NSMenu (KeyCode)

- (NSMenuItem *)menuItemForKeyCode:(NSInteger)keyCode
                     withModifiers:(NSUInteger)modifiers
{
    NSString *keyCodeString = (NSString *)createStringForMapping(keyCode, 0);
    if (keyCodeString == nil) return nil;

    NSMenuItem *foundItem = nil;

    const BOOL commandKeyHeld = modifiers & NSCommandKeyMask;
    const BOOL optionKeyHeld = modifiers & NSAlternateKeyMask;
    const BOOL shiftKeyHeld = modifiers & NSShiftKeyMask;
    const BOOL controlKeyHeld = modifiers & NSControlKeyMask;

	for (NSMenuItem *menuItem in [self itemArray]) {
        // Recurse into all submenus.
	    if ([menuItem hasSubmenu]) {
            foundItem = [[menuItem submenu] menuItemForKeyCode:keyCode
                                                 withModifiers:modifiers];
            if (foundItem != nil) break;
        }

        NSString *itemKey = [menuItem keyEquivalent];
        if (itemKey != nil &&
            [itemKey isEqualToString:[keyCodeString lowercaseString]]) {
            NSUInteger itemModifiers = [menuItem keyEquivalentModifierMask];

            const BOOL itemKeyHasCommandHeld =
                itemModifiers & NSCommandKeyMask;
            const BOOL itemKeyHasOptionHeld =
                itemModifiers & NSAlternateKeyMask;
            const BOOL itemKeyHasShiftHeld =
                itemModifiers & NSShiftKeyMask;
            const BOOL itemKeyHasControlHeld =
                itemModifiers & NSControlKeyMask;

            if (itemKeyHasCommandHeld == commandKeyHeld &&
                itemKeyHasOptionHeld == optionKeyHeld &&
                itemKeyHasShiftHeld == shiftKeyHeld &&
                itemKeyHasControlHeld == controlKeyHeld) {
                foundItem = [[menuItem retain] autorelease];
                break;
            }
        }
	}

    [keyCodeString release];
    return foundItem;
}

@end
