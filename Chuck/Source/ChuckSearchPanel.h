//
//  ChuckSearchPanel.h
//  Chuck
//
//  Created by Michael on 5/22/10.
//  Copyright 2010 Michael Sanders.
//

#import <AppKit/AppKit.h>

//
// The main, sort-of-cool-looking-but-still-simplistic, search window
// for Chuck.
//
@interface ChuckSearchPanel : NSWindow
{
	NSView *childContentView;
    BOOL enableAnimations;
}

@property (nonatomic, assign) BOOL enableAnimations;

@end
