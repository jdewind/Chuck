/*
 *  LoginItem.h
 *  Chuck
 *
 *  Created by Michael on 5/25/10.
 *  Copyright 2010 Michael Sanders.
 *
 */

#ifndef LOGINITEM_H
#define LOGINITEM_H

#include <CoreFoundation/CoreFoundation.h>

/* 
 * Adds given application as a login item; pass true for global to use as
 * login item for all users, or false to use just for the current user. 
 */
void addAsLoginItem(CFURLRef itemURL, const bool global);

/* 
 * Deletes given login item; pass true for global to delete from all users'
 * login items, or false to delete only from the current user's. 
 */
void removeLoginItem(CFURLRef itemURL, const bool global);

/* 
 * Returns true if given item is set to open as login; pass true to search
 * global login items, or false to search only the current user's. 
 */
bool isLoginItem(CFURLRef itemURL, const bool global);

#endif
