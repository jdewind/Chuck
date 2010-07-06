/*
 *  QSense.h
 *  Chuck
 *
 *  Created by Alcor on November 22, 04 (used in QuickSilver).
 *  Edited by Michael Sanders on May 24, 09.
 *  Copyright 2004 Blacktree. All rights reserved.
 *
 */

#ifndef QSENSE_H
#define QSENSE_H

#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h> /* For CGFloat */

/* 
 * Returns "score" denoting relevance of string to given term, from 0.0 (least
 * relevant) to 1.0 (most relevant), or -1.0 on error. 
 */
CGFloat QSScoreForAbbreviation(CFStringRef str, CFStringRef abbr);

#endif
