/*
 *  LoginItem.c
 *  Chuck
 *
 *  Created by Michael on 5/25/10.
 *  Copyright 2010 Michael Sanders.
 *
 */

#include "LoginItem.h"
#include <CoreServices/CoreServices.h>
#include <assert.h>

void addAsLoginItem(CFURLRef itemURL, const bool global)
{
	assert(itemURL != NULL);

	CFStringRef loginItemType = global ? kLSSharedFileListGlobalLoginItems
	                                   : kLSSharedFileListSessionLoginItems;
	LSSharedFileListRef loginItems =
		LSSharedFileListCreate(kCFAllocatorDefault, loginItemType, NULL);
	if (loginItems != NULL) {
		LSSharedFileListItemRef item =
			LSSharedFileListInsertItemURL(loginItems,
			                              kLSSharedFileListItemLast,
			                              NULL, NULL, itemURL, NULL, NULL);
		if (item != NULL) {
			CFRelease(item);
		}
		CFRelease(loginItems);
	}
}

static LSSharedFileListItemRef getLoginItemFromLoginItemsArray(CFArrayRef itemsArray,
                                                               CFURLRef desiredItemURL)
{
	assert(itemsArray != NULL);
	assert(desiredItemURL != NULL);

	CFIndex i, count = CFArrayGetCount(itemsArray);
	for (i = 0; i < count; ++i) {
		LSSharedFileListItemRef thisItem =
			(LSSharedFileListItemRef)CFArrayGetValueAtIndex(itemsArray, i);
		CFURLRef thisItemURL;
		if (LSSharedFileListItemResolve(thisItem, 0,
		                                &thisItemURL,
		                                NULL) == noErr &&
			CFEqual(thisItemURL, desiredItemURL)) {
			return thisItem;
		}
	}

	return NULL;
}

void removeLoginItem(CFURLRef itemURL, const bool global)
{
	assert(itemURL != NULL);

	CFStringRef loginItemType = global ? kLSSharedFileListGlobalLoginItems
	                                   : kLSSharedFileListSessionLoginItems;
	LSSharedFileListRef loginItems =
		LSSharedFileListCreate(kCFAllocatorDefault, loginItemType, NULL);
	if (loginItems != NULL) {
		CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems,
		                                                          NULL);
		if (loginItemsArray != NULL) {
			LSSharedFileListItemRef loginItem =
				getLoginItemFromLoginItemsArray(loginItemsArray, itemURL);
			LSSharedFileListItemRemove(loginItems, loginItem);
			CFRelease(loginItemsArray);
		}
		CFRelease(loginItems);
	}
}

bool isLoginItem(CFURLRef itemURL, const bool global)
{
	assert(itemURL != NULL);

	bool isLoginItem = false;
	CFStringRef loginItemType = global ? kLSSharedFileListGlobalLoginItems
	                                   : kLSSharedFileListSessionLoginItems;
	LSSharedFileListRef loginItems =
		LSSharedFileListCreate(kCFAllocatorDefault, loginItemType, NULL);
	if (loginItems != NULL) {
		CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems,
		                                                          NULL);
		if (loginItemsArray != NULL) {
			LSSharedFileListItemRef loginItem =
				getLoginItemFromLoginItemsArray(loginItemsArray, itemURL);
			if (loginItem != NULL) {
				isLoginItem = true;
			}
			CFRelease(loginItemsArray);
		}
		CFRelease(loginItems);
	}

	return isLoginItem;
}
