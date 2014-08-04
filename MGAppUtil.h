//
//  MGAppUtil.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAppDelegate.h"

@interface MGAppUtil : NSObject

+ (NSString *) GetResourceDirectoryPath;
+ (NSString *) GetDocumentDirectoryPath;
+ (MGAppDelegate *) appDelegate;
+ (NSString*) uniqueID;

@end
