//
//  MGAppDelegate.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import "MGImageHandler.h"
#import "MGAppUtil.h"

#define THUMBNAIL_SIZE 50
#define FULLRES_HEIGHT 1280
#define FULLRES_WIDTH 960
#define URL_IMAGE @"https://api.flickr.com/services/feeds/photos_public.gne?ids=25053835@N03&format=json"

@implementation MGImageHandler



-(void) writeImageToDownloadedCacheNoChange:(UIImage *) image name:(NSString *) imageName
{
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        // Create a Download directory in Caches Folder
        NSString *dataPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloaded"];
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        // Write Image in Download folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *imagePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Downloaded/%@.jpg",imageName]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            NSData *webData = UIImageJPEGRepresentation(image, 1.0);
            [webData writeToFile:imagePath atomically:YES];
        }
    
    });
    
}

- (UIImage *)getImageFromDownloadedCache:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Downloaded/%@.jpg",imageName]];
    UIImage *presentImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        presentImage = [UIImage imageWithContentsOfFile:imagePath];  
    }
    return presentImage;
}


- (void)deleteImageWithName:(NSString *)imageName 
{
    NSLog(@"deletingImageWithName");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
    
    
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

-(void)deleteFilesInCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSError *error = nil;  
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Print out the path to verify we are in the right place
        NSString *directory = [paths objectAtIndex:0];
        NSLog(@"Directory: %@", directory);
        
        // For each file in the cache, create full path and delete the file
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error])
        {    
            NSString *filePath = [directory stringByAppendingPathComponent:file];
            NSLog(@"File : %@", filePath);
            
            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            
            if (fileDeleted != YES || error != nil)
            {
                // Deal with the error...
            }
        }
        
    }
}

-(void)deleteCacheDirectory{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSLog(@"Path: %@", [paths objectAtIndex:0]);
        
        NSError *error = nil;  
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Remove all files in the cache directory
        BOOL deleted = [fileManager removeItemAtPath:[paths objectAtIndex:0] error:&error];
        
        if (deleted != YES || error != nil)
        {
            // Deal with the error...
        }
        else
            // Recreate the Documents directory
            [fileManager createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
}

-(void)deleteDownloadedCacheDirectory {
    [self deleteDirectoryInCacheWithName:@"Downloaded"];
    
}

-(void)deleteDirectoryInCacheWithName:(NSString *) dirName{
    
    
    NSString *dataPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:dirName];    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; 
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSLog(@"Path: %@", [paths objectAtIndex:0]);
        
        NSError *error = nil;  
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Remove all files in the cache directory
        BOOL deleted = [fileManager removeItemAtPath: [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName] error:&error];
        
        if (deleted != YES || error != nil)
        {
            // Deal with the error...
        }
        else
            // Recreate the Documents directory
            [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:dirName] withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
}

- (UIImage *)ensureCorrectRoation:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
//            boundHeight = bounds.size.height;
//            bounds.size.height = bounds.size.width;
//            bounds.size.width = boundHeight;
//            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
//            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
//            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    return imageCopy;
}




@end
