//
//  ChuckSearchPanel.m
//  Chuck
//
//  Created by Michael on 5/22/10.
//  Copyright 2010 Michael Sanders.
//

#import "ChuckSearchPanel.h"

@interface ChuckSearchFrameView : NSView
{
    NSBezierPath *roundedPath;
    NSGradient *backgroundGradient;
}

@end

@implementation ChuckSearchPanel
@synthesize enableAnimations;

// Standard window init method. Sets up some special stuff for custom windows.
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)styleMask
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag
{

    // Pass NSBorderlessWindowMask for the styleMask so we don't get a title
    // bar, and an NSTexturedBackgroundWindowMask so the user can drag
    // the window.
    styleMask = NSBorderlessWindowMask | NSTexturedBackgroundWindowMask;

    self = [super initWithContentRect:contentRect
                            styleMask:styleMask
                              backing:bufferingType
                                defer:flag];

    if (self != nil) {

        // Set window to be clear and non-opaque so we can see through it.
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];

        // We want to fade out manually when hidden.
        [self setCanHide:NO];

        // Pull the window up to status level.
        [self setLevel:NSStatusWindowLevel];

        // Make window appear on all spaces.
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];

        // Fade out on deactivation and fade in when called to front.
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(fadeInAndBecomeActive)
                              name:NSWindowDidBecomeKeyNotification
                            object:self];

        [defaultCenter addObserver:self
                          selector:@selector(fadeOutAndHide)
                              name:NSWindowDidResignKeyNotification
                            object:self];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark NSNotifications

//
// These methods are called automatically upon the window becoming and leaving
// the key window.
//
- (void)fadeInAndBecomeActive
{
    if ([self enableAnimations]) {
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[self animator] setAlphaValue:1.0];
        [NSAnimationContext endGrouping];
    } else {
        [self setAlphaValue:1.0];
    }

    [self makeKeyAndOrderFront:nil];
}

- (void)fadeOutAndHide
{
    if ([self enableAnimations]) {
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[self animator] setAlphaValue:0.0];
        [NSAnimationContext endGrouping];
    } else {
        [self setAlphaValue:0.0];
    }
}

#pragma mark -

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)setContentView:(NSView *)view
{
	if (childContentView == view) return;

	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;

    // Keep our frame view as the content view and make the specified view a child
    // of that.
	ChuckSearchFrameView *frameView = [super contentView];
	if (frameView == nil) {
		frameView = [[ChuckSearchFrameView alloc] initWithFrame:bounds];
		[super setContentView:frameView];
        [frameView release];
	}

    [childContentView removeFromSuperview];
	childContentView = view;
	[frameView addSubview:childContentView];
}

//
// Returns the child of our frame view instead of our frame view.
//
- (NSView *)contentView
{
	return childContentView;
}

@end

@implementation ChuckSearchFrameView

- (void)dealloc
{
    [backgroundGradient release], backgroundGradient = nil;
    [roundedPath release], roundedPath = nil;
    [super dealloc];
}

//
// Draws the frame of the window.
//
- (void)drawRect:(NSRect)rect
{
    // Lazily load and then cache the bezier path & background gradient.
    if (roundedPath == nil) {
        NSRect bounds = [self bounds];
        roundedPath = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                      xRadius:6.0
                                                      yRadius:6.0];
        [roundedPath retain];
    }

    if (backgroundGradient == nil) {
        backgroundGradient =
            [[NSGradient alloc] initWithColorsAndLocations:
             [NSColor colorWithCalibratedWhite:0.7 alpha:1.0], 0.0,
             [NSColor whiteColor], 0.8, nil];
    }

	[backgroundGradient drawInBezierPath:roundedPath angle:90.0];
	[[NSColor whiteColor] set];
	[roundedPath stroke];
}

@end
