//
//  SearchResult.h
//  Chuck
//
//  Created by Michael on 5/24/10.
//  Copyright 2010 Michael Sanders.
//

#import <Foundation/Foundation.h>
#import "NSArray+Rank.h"

//
// A simple model class used in AppLister.m to contain results.
//
@interface SearchResult : NSObject <RankableObject>
{
    NSString *name;
    NSString *path;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *path;

- (id)initWithName:(NSString *)name path:(NSString *)path;

- (CGFloat)scoreUsingTerm:(NSString *)term;

@end
