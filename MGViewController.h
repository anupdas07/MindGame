//
//  MGViewController.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end


