//
//  MGImageDO.h
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGImageDO : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *serverDownlaodStringURL;
@property (nonatomic, strong) NSString *localDownloadStringURL;
@property (nonatomic, assign) BOOL hasBeenIdentified;

@end
