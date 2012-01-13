//
//  GlobalHotKeyRegistrar.h
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h> // For EventHotKeyRef (TODO: remove this from the
                           // header file. Is there an @class for
                           // generic pointers?)

typedef OSStatus (^HotKeyBlock)();

//
// A convenience class that calls the given block whenever the given hot key
// is pressed.
//
@interface GlobalHotKeyRegistrar : NSObject
{
    EventHotKeyRef hotKeyRef;
    EventHotKeyRef escapeKeyHotKeyRef;
    CGKeyCode keyCode;
    CGEventFlags modifierFlags;
    HotKeyBlock hotKeyBlock;
    BOOL modified;
}

@property (nonatomic, copy) HotKeyBlock hotKeyBlock;
@property (nonatomic, readonly) CGKeyCode keyCode;
@property (nonatomic, readonly) CGEventFlags modifierFlags;
@property (nonatomic, readonly, getter=wasModified) BOOL modified;

//
// Replaces the previous hot key with the given key code and modifiers.
//
- (void)registerEscapeKey;
- (void)unregisterEscapeKey;
- (void)setHotKeyToKeyCode:(CGKeyCode)code
              andModifiers:(CGEventFlags)modifiers;

@end
