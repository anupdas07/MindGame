//
//  MGPhotoCell.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGAsyncImageView.h"
#import "MGImageDO.h"

@interface MGPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet MGAsyncImageView *asyncImageView;

-(void) setWithImageDO:(MGImageDO*)imageDO delegate:(id)delegate;

@end
