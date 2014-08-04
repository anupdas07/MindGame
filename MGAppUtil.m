//
//  MGAppUtil.m
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import "MGAppUtil.h"


@implementation MGAppUtil


+ (NSString *) GetDocumentDirectoryPath
{
	NSArray  *paths	= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *) GetResourceDirectoryPath
{
	return [[NSBundle mainBundle] resourcePath];
}


+ (MGAppDelegate *) appDelegate
{
	return (MGAppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString*) uniqueID
{
	//[[NSProcessInfo processInfo] globallyUniqueString]; //# unique across network but "free formatted"
	CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
	NSString* UUIDString = (__bridge NSString*)CFUUIDCreateString(kCFAllocatorDefault,UUID); //m need to CFRelease it but we let caller manage
	
	CFRelease(UUID);
	//CFRelease(UUIDString);
	return UUIDString;
}


@end
