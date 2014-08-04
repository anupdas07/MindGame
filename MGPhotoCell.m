//
//  MGPhotoCell.m
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import "MGPhotoCell.h"
#import "MGImageHandler.h"

@implementation MGPhotoCell

#define DEFAULT_CELL_IMAGE @""

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"drawRect");
}
 
 */

-(void) setWithImageDO:(MGImageDO*)imageDO delegate:(id)delegate
{
    @autoreleasepool {
        MGImageHandler *imgHandler = [[MGImageHandler alloc] init];
        
        UIImage *image = [imgHandler getImageFromDownloadedCache:imageDO.imageName];
        if (image != nil) {
            [self.asyncImageView setImage:image];
            
        }else
        {
            [self.asyncImageView loadImageFromURL:imageDO.serverDownlaodStringURL
                                         uniqueID:imageDO.imageName
                                  withPlaceholder:nil
                                  usingImageCache:imgHandler
                                  withImageViewId:0
             ];
            
        }
    }
    

    
    
   
    
    
    
}


@end
