//
//  GlobalHotKeyRegistrar.m
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import "GlobalHotKeyRegistrar.h"

static const CGKeyCode kEscapeKeyCode = 53;

static OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,
                              EventRef event, void *info)
{
    GlobalHotKeyRegistrar *registrar = info;
    return [registrar hotKeyBlock]();
}

// Converts Foundation modifier flags their Carbon equivalents.
static inline UInt32 NSModifierFlagsToCarbonModifiers(NSUInteger mask)
{
    UInt32 modifiers = 0;

    if (mask & NSCommandKeyMask) modifiers |= cmdKey;
    if (mask & NSAlternateKeyMask) modifiers |= optionKey;
    if (mask & NSControlKeyMask) modifiers |= controlKey;
    if (mask & NSShiftKeyMask) modifiers |= shiftKey;

    return modifiers;
}

@implementation GlobalHotKeyRegistrar
@synthesize hotKeyBlock;
@synthesize keyCode;
@synthesize modifierFlags;
@synthesize modified;

- (void)dealloc
{
    [hotKeyBlock release];
    [super dealloc];
}

- (void)registerHotKey
{
	// Setup hotkey callback.
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, self, NULL);

	// Register the hotkeys.
    UInt32 flags = NSModifierFlagsToCarbonModifiers(modifierFlags);
	EventHotKeyID hotKeyID;
	hotKeyID.signature = 0;
	hotKeyID.id = 1;
	RegisterEventHotKey(keyCode, flags, hotKeyID,
	                    GetApplicationEventTarget(), 0, &hotKeyRef);
}

- (void)registerEscapeKey {
  if (escapeKeyHotKeyRef == NULL) {
    EventHotKeyID hotKeyID;
    hotKeyID.signature = 0;
    hotKeyID.id = 1;
    RegisterEventHotKey(kEscapeKeyCode, 0, hotKeyID, GetApplicationEventTarget(), 0, &escapeKeyHotKeyRef);    
  }
}

- (void)unregisterEscapeKey {
  UnregisterEventHotKey(escapeKeyHotKeyRef);
  escapeKeyHotKeyRef = NULL;
}

- (void)setHotKeyToKeyCode:(CGKeyCode)code
              andModifiers:(CGEventFlags)modifiers
{
	if (hotKeyRef != NULL) {
        if (UnregisterEventHotKey(hotKeyRef) != noErr) {
            DLog(@"Could not unregister hot key.");
            return;
        }
    }

    keyCode = code;
    modifierFlags = modifiers;
    modified = YES;

    [self registerHotKey];
}

@end
