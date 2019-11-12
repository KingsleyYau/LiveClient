//
//  LSStoreListToLadyViewController.h
//  livestream
//
//  Created by Calvin on 2019/10/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>  
#import "LSViewController.h"

@interface LSStoreListToLadyViewController : LSListViewController

@property (nonatomic, copy) NSString * anchorId;
@property (nonatomic, copy) NSString * anchorName;
@property (nonatomic, copy) NSString * anchorImageUrl;

@property (nonatomic, assign) BOOL isAddSuccess;
@end

 
