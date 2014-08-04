//
//  MGAppDelegate.h
//  MindGame
//  AsyncImageViewDelegate
//
//  Provides the interface for the delegate used by AsyncImageViewDelegate. This
//  Provides a mechanism for an interested party to know when an Image has been received
//
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageHandler.h"

@protocol AsyncImageViewDelegate
- (void)didReceiveImage:(UIImage *)theImage withImageViewId:(int)imageId withName:(NSString *)name;
@end



@interface MGAsyncImageView : UIImageView  {
	NSURLConnection* connection;
    NSMutableData* data;
	
	NSString *uid;
	NSString *imageURL;
	NSString *placeholder; 
	BOOL needsRefresh;
	int imageId;
}

@property (nonatomic, strong) MGImageHandler *imageCache;
@property (nonatomic, strong) id<AsyncImageViewDelegate> delegate;
@property (copy) NSString *uid;
@property (copy) NSString *imageURL;
@property (copy) NSString *placeholder; 
@property BOOL needsRefresh;
@property int imageId;

- (void)cancelSync;

- (void)loadImageFromURL:(NSString*)aUrl
                uniqueID:(NSString *)filename
         withPlaceholder:(NSString *)aPlaceholder
         usingImageCache:(MGImageHandler *)anImageCache
		 withImageViewId:(int)aImageId;

@end


