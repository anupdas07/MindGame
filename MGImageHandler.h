//
//  MGAppDelegate.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGImageHandler : NSObject


- (UIImage *) getImageFromDownloadedCache:(NSString *)imageName;
- (UIImage *) ensureCorrectRoation:(UIImage *)image;

- (void) deleteImageWithName:(NSString *)imageName ;

- (void) writeImageToDownloadedCacheNoChange:(UIImage *) image name:(NSString *) imageName;
- (void) deleteDownloadedCacheDirectory;
- (void) deleteDirectoryInCacheWithName:(NSString *) dirName;


@end
