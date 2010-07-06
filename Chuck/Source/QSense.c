/*
 *  QSense.c
 *  Chuck
 *
 *  Created by Alcor on November 22, 04 (used in QuickSilver).
 *  Edited by Michael Sanders on May 24, 09.
 *  Copyright 2004 Blacktree. All rights reserved.
 *
 */

#include "QSense.h"

#define CFFullRange(str) CFRangeMake(0, CFStringGetLength(str))

#define CFCharFromInlineBuf CFStringGetCharacterFromInlineBuffer

#define IGNORED_SCORE 0.9
#define SKIPPED_SCORE 0.15
#define INVALID_SCORE -1.0

static CFCharacterSetRef CFWhitespaceCharacterSet = NULL;
static CFCharacterSetRef CFUpperCaseCharacterSet = NULL;

static CGFloat QSScoreForAbbreviationWithRanges(CFStringRef str,
                                                CFStringRef abbr,
                                                CFRange strRange,
                                                CFRange abbrRange);

inline CGFloat QSScoreForAbbreviation(CFStringRef str, CFStringRef abbr)
{
	return QSScoreForAbbreviationWithRanges(str,
	                                        abbr,
	                                        CFFullRange(str),
	                                        CFFullRange(abbr));
}

static CGFloat QSScoreForAbbreviationWithRanges(CFStringRef str,
                                                CFStringRef abbr,
                                                CFRange strRange,
                                                CFRange abbrRange)
{
	/* Deduct some points for all remaining letters. */
	if (abbrRange.length == 0) return IGNORED_SCORE;

	if (abbrRange.length > strRange.length) return 0.0;

	/* Create an inline buffer version of str. Will be used in loop below
	 * for faster lookups. */
	CFStringInlineBuffer inlineBuffer;
	CFStringInitInlineBuffer(str, &inlineBuffer, strRange);

	/* Initialize our static variables. */
	if (CFWhitespaceCharacterSet == NULL) {
		CFWhitespaceCharacterSet =
			CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
	}

	if (CFUpperCaseCharacterSet == NULL) {
		CFUpperCaseCharacterSet =
			CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
	}

	/* Search for steadily smaller portions of the abbreviation. */
	CGFloat score = 0.0;
	CFIndex i;
	for (i = abbrRange.length; i > 0; --i) {
		CFRange matchedRange;
		CFStringRef currentAbbr =
			CFStringCreateWithSubstring(kCFAllocatorDefault,
			                            abbr,
			                            CFRangeMake(abbrRange.location, i));
		if (currentAbbr == NULL) {
			return INVALID_SCORE; /* Error. */
		} else {
			Boolean found =
				CFStringFindWithOptionsAndLocale(str,
				                                 currentAbbr,
				                                 CFRangeMake(strRange.location,
				                                             strRange.length -
				                                             abbrRange.length + i),
				                                 kCFCompareCaseInsensitive |
	 			                                 kCFCompareDiacriticInsensitive |
	 			                                 kCFCompareLocalized,
				                                 NULL,
				                                 &matchedRange);
			CFRelease(currentAbbr);

			if (!found) continue;
		}

		CFRange remainingStrRange;
		remainingStrRange.location =
			matchedRange.location + matchedRange.length;
		remainingStrRange.length =
			strRange.location + strRange.length - remainingStrRange.location;

		/* Search what is left of the string with the rest of
		 * the abbreviation. */
		const CGFloat remainingScore =
			QSScoreForAbbreviationWithRanges(str, abbr, remainingStrRange,
			                                 CFRangeMake(abbrRange.location + i,
			                                             abbrRange.length - i));

		if (remainingScore > 0.0) {
			score = remainingStrRange.location - strRange.location;

			if (matchedRange.location > strRange.location) {
				CFIndex j;
				CFCharacterSetRef characterSet = NULL;

				/* Ignore skipped characters if is first letter of a word. */
				if (CFCharacterSetIsCharacterMember(CFWhitespaceCharacterSet,
				    CFCharFromInlineBuf(&inlineBuffer,
				                        matchedRange.location - 1))) {
					j = matchedRange.location - 2;
					characterSet = CFWhitespaceCharacterSet;
				} else if (CFCharacterSetIsCharacterMember(CFUpperCaseCharacterSet,
				           CFCharFromInlineBuf(&inlineBuffer,
				                               matchedRange.location))) {
					j = matchedRange.location - 1;
					characterSet = CFUpperCaseCharacterSet;
				}

				if (characterSet == NULL) {
					score -= matchedRange.location - strRange.location;
				} else {
					for (; j >= strRange.location; --j) {
						UniChar c = CFCharFromInlineBuf(&inlineBuffer, j);
						if (CFCharacterSetIsCharacterMember(characterSet, c)) {
							score -= 1.0;
						} else {
							score -= SKIPPED_SCORE;
						}
					}
				}
			}

			score += remainingScore * remainingStrRange.length;
			score /= strRange.length;
			return score;
		}
	}

	return 0.0;
}
