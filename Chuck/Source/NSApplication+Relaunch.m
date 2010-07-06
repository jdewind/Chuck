//
//  NSApplication+Relaunch.m
//  Chuck
//
//  Created by Michael on 5/29/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSApplication+Relaunch.h"
#include <ApplicationServices/ApplicationServices.h>

@implementation NSApplication (Relaunch)

//
// This uses a different method than most category methods I've seen trying to
// accomplish this, the most common methods I've seen being either:
//
// 1.) Including a "relauncher" executable in the app bundle that is
//     immediately called upon the app quitting to relaunch it.
// 2.) Forking the app to simulate the above executable.
//
// Instead of doing either of these, this method simply uses Launch Services to
// launch a new instance of the app, and then quits the old one. Couldn't
// be simpler. :)
//
- (void)relaunch:(id)sender
{
    DLog(@"Relaunching...");

    // Post this notification manually before we begin, so we can
    // exit() immediately.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:NSApplicationWillTerminateNotification
                                 object:NSApp];

    LSLaunchURLSpec appURLSpec = {NULL, NULL, NULL, 0, NULL};

    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    appURLSpec.appURL = (CFURLRef)[NSURL URLWithString:executablePath];

    // Force the app to be launched even though it is already running.
    appURLSpec.launchFlags = kLSLaunchNewInstance;

    // Launch a new instance of our app.
    if (LSOpenFromURLSpec(&appURLSpec, NULL) != noErr) {
        NSLog(@"Could not relaunch app %@", executablePath);
        return;
    }

    // Quit the old one.
    exit(0);
}

@end
