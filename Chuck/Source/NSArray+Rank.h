//
//  NSArray+Rank.h
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>

//
// Every object ranked by us must conform to this protocol.
//
@protocol RankableObject <NSObject>

//
// Should return "score" of the item using the given term, from 0.0 to 1.0.
//
- (CGFloat)scoreUsingTerm:(NSString *)term;

@end

@interface NSArray (Rank)

//
// Returns array of given results (which must conform to the RankableObject
// protocol) sorted from highest score to lowest, where each result has
// a score > 0.0.
//
- (NSArray *)sortedResultsUsingTerm:(NSString *)term;

@end
