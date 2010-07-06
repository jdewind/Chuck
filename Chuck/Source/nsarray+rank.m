//
//  NSArray+Rank.m
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import "NSArray+Rank.h"
#import "NSArray+Map.h"
#import "NSMutableArray+Map.h"
#import "SearchResult.h"

//
// Temporary wrapper to store rank of sorted objects.
// Every object ranked by us must conform to the RankableObject protocol.
//
@interface RankableObjectContainer : NSObject
{
    id <RankableObject> item;
    CGFloat score;
}

@property (nonatomic, readonly) id <RankableObject> item;
@property (nonatomic, readonly) CGFloat score;

- (id)initWithItem:(id <RankableObject>)anItem score:(CGFloat)someScore;

@end

@implementation NSArray (Rank)

- (NSArray *)sortedResultsUsingTerm:(NSString *)term
{
    if ([self count] == 0) return [[self retain] autorelease];

    NSMutableArray *results =
        [NSMutableArray arrayWithArray:[self map:^(id result) {
            NSAssert1([result conformsToProtocol:@protocol(RankableObject)],
                      @"Item \"%@\" does not conform to the "
                      @"RankableObject protocol",
                      result);

            const CGFloat score = [result scoreUsingTerm:term];
            if (score > 0.0) {
                RankableObjectContainer *scoreContainer =
                    [[RankableObjectContainer alloc] initWithItem:result
                                                            score:score];
                return [scoreContainer autorelease];
            }

            return (id)nil;
        }]];

    [results sortUsingSelector:@selector(compare:)];

    // We only want to return the SearchResults.
    [results replaceObjectsUsingBlock:^(id result) {
        return [result item];
    }];

    return results;
}

@end

@implementation RankableObjectContainer
@synthesize item;
@synthesize score;

- (id)initWithItem:(id <RankableObject>)anItem score:(CGFloat)someScore
{
    if (self = [super init]) {
        item = [anItem retain];
        score = someScore;
    }

    return self;
}

- (NSComparisonResult)compare:(RankableObjectContainer *)otherResult
{
    const CGFloat otherScore = [otherResult score];
    if (score > otherScore) {
        return NSOrderedAscending;
    } else if (score < otherScore) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (void)dealloc
{
    [item release];
    [super dealloc];
}

@end
