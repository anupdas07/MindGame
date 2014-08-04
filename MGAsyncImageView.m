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

#import "MGAsyncImageView.h"
#import "MGImageHandler.h"

@implementation MGAsyncImageView

@synthesize uid, imageURL, placeholder;
@synthesize needsRefresh;
@synthesize imageCache;
@synthesize delegate;
@synthesize imageId;

#define kNetworkConnectionTimeout   60

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"drawRect");
}


#pragma mark --
#pragma mark Lifecycle

- (void)loadImageFromURL:(NSString*)aUrl 
                uniqueID:(NSString *)filename 
         withPlaceholder:(NSString *)aPlaceholder 
         usingImageCache:(MGImageHandler *)anImageCache
		 withImageViewId:(int)aImageId
{	
    UIImage *image = [[[MGImageHandler alloc] init] getImageFromDownloadedCache:filename];
    if (image != nil && self.delegate != nil) {
        self.image = image;
        return;
    }
    
    
    if (connection!=nil) { 
		[connection cancel];
		connection = nil;
	}
    
	if (data!=nil) { 
		data = nil;
	}
	
	// set a placeholder till we get some actual data
	self.uid = filename;
	self.placeholder = aPlaceholder;
	self.imageURL = aUrl;
	self.imageId = aImageId;
    if (self.placeholder) {
		UIImage *holder = [self newImageFromResource:self.placeholder];
        self.image = holder;
    }
    self.imageCache = anImageCache;
	needsRefresh = NO;
	
	NSURL *urlString = [NSURL URLWithString:self.imageURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:urlString
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:kNetworkConnectionTimeout];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
}


- (UIImage *)newImageFromResource:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@",
                           [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = nil;
    image = [[UIImage alloc] initWithContentsOfFile:imageFile];
    return image;
}


#pragma mark --
#pragma mark Connections

- (void)cancelSync {
    if (connection) {
        [connection cancel];
    }
    delegate = nil;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
		data = [[NSMutableData alloc] initWithCapacity:512];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
    connection = nil;
	
    UIImage *theImage = [UIImage imageWithData:data];
  	needsRefresh = YES;
    self.image = theImage;
	[self setNeedsLayout];
    
	[self.imageCache writeImageToDownloadedCacheNoChange:theImage name:self.uid];
	
    data = nil;
}


@end
