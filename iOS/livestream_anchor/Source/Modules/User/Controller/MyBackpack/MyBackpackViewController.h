//
//  MyBackpackViewController.h
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@interface MyBackpackViewController : LSGoogleAnalyticsViewController
@property (nonatomic, assign) NSInteger curIndex;
- (void)getunreadCount;
@end
