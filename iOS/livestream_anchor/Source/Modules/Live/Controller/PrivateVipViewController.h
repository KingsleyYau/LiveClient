//
//  PrivateVipViewController.h
//  livestream
//
//  Created by Max on 2017/9/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"

@interface PrivateVipViewController : LSGoogleAnalyticsViewController
@property (nonatomic, strong) LiveRoom* liveRoom;
@end
