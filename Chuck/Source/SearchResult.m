//
//  SearchResult.m
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import "SearchResult.h"
#include "QSense.h"

@implementation SearchResult
@synthesize path;
@synthesize name;

// Designated initializer.
- (id)initWithName:(NSString *)newName path:(NSString *)newPath
{
    if (self = [super init]) {
        name = [newName copy];
        path = [newPath copy];
    }

    return self;
}

- (id)init
{
    return [self initWithName:nil path:nil];
}

- (void)dealloc
{
    [name release];
    [path release];
    [super dealloc];
}

- (CGFloat)scoreUsingTerm:(NSString *)term
{
    return QSScoreForAbbreviation((CFStringRef)name, (CFStringRef)term);
}

- (BOOL)isEqual:(id)someObject
{
    return [someObject isKindOfClass:[self class]] &&
           [[someObject name] isEqualToString:name] &&
           [[someObject path] isEqualToString:path];
}

- (NSUInteger)hash
{
    return [name hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ (%p)>", [self className],
            name, self];
}

@end
