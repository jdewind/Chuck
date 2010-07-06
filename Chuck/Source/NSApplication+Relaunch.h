//
//  NSApplication+Relaunch.h
//  Chuck
//
//  Created by Michael on 5/29/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

@interface NSApplication (Relaunch)

//
// Quits and immediately reopens the application.
//
- (void)relaunch:(id)sender;

@end
