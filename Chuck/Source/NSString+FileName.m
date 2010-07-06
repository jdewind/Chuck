//
//  NSString+FileName.m
//  Chuck
//
//  Created by Michael on 6/19/10.
//  Copyright 2010 Michael Sanders. All rights reserved.
//

#import "NSString+FileName.h"

@implementation NSString (FileName)

- (NSString *)fileNameWithoutExtension
{
    return [[self lastPathComponent] stringByDeletingPathExtension];
}

@end
