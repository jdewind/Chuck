//
//  NSWorkspace+LoginItem.m
//  Chuck
//
//  Created by Michael on 6/14/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSWorkspace+LoginItem.h"
#include <Carbon/Carbon.h>

static bool launchedByProcess(CFStringRef bundleIdentifier);

@implementation NSWorkspace (LoginItem)

- (BOOL)launchedAsLoginItem
{
    // We were a login item if (and only if! (as far as I know)) we were
    // launched by the loginwindow process.
    return launchedByProcess(CFSTR("com.apple.loginwindow"));
}

@end

#define CFStringEqual(s1, s2) \
    (CFStringCompare((s1), (s2), 0) == kCFCompareEqualTo)

static bool launchedByProcess(CFStringRef possibleLauncherName)
{
    NSCParameterAssert(possibleLauncherName != NULL);

    /* Get our PSN. */
    ProcessSerialNumber currentPSN;
    if (GetCurrentProcess(&currentPSN) != noErr) return false;

    ProcessInfoRec procInfo = {0};
    procInfo.processInfoLength = sizeof(ProcessInfoRec);
    if (GetProcessInformation(&currentPSN, &procInfo) != noErr) return false;

    /* Get info of the launching process. */
    ProcessSerialNumber parentPSN = procInfo.processLauncher;
    CFDictionaryRef parentProcessInfoDict =
        ProcessInformationCopyDictionary(&parentPSN,
                                         kProcessDictionaryIncludeAllInformationMask);
    if (parentProcessInfoDict == NULL) return false;

    /* Check if the name of that parent process matches our needle. */
    CFStringRef parentName =
        CFDictionaryGetValue(parentProcessInfoDict, kCFBundleIdentifierKey);

    bool launchedByProcess = parentName != NULL &&
                             CFStringEqual(parentName, possibleLauncherName);

    CFRelease(parentProcessInfoDict);

    return launchedByProcess;
}
