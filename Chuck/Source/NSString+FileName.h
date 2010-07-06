//
//  NSString+FileName.h
//  Chuck
//
//  Created by Michael on 6/19/10.
//  Copyright 2010 Michael Sanders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileName)

//
// Returns last path component of the reciever with the extension removed.
//
- (NSString *)fileNameWithoutExtension;

@end
