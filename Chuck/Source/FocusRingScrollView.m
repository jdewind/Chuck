//
//  FocusRingScrollView.m
//  Chuck
//
//  Created by Michael on 5/26/10.
//  Copyright 2010 Michael Sanders.
//

#import "FocusRingScrollView.h"

@implementation FocusRingScrollView

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    NSResponder *responder = [[self window] firstResponder];
    if ((responder == self ||
        ([responder isKindOfClass:[NSView class]] &&
         [(NSView *)responder isDescendantOf:self])) &&
        [NSGraphicsContext currentContextDrawingToScreen]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill([self bounds]);
        [NSGraphicsContext restoreGraphicsState];
    }
}

@end
