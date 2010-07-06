//
//  NSMenu+KeyCode.h
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

@interface NSMenu (KeyCode)

//
// Searches and traverses all submenus of menu to find item with the given key
// code and modifier flags. Returns it if found, or nil if not.
//
- (NSMenuItem *)menuItemForKeyCode:(NSInteger)keyCode
                     withModifiers:(NSUInteger)flags;

@end
