//
//  PublicVipViewController.h
//  livestream
//
//  Created by randy on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoom.h"
#import "PlayViewController.h"
#import "LSUITapImageView.h"
#import "VIPAudienceView.h"
#import "ChardTipView.h"

@interface PublicVipViewController : LSGoogleAnalyticsViewController
#pragma mark - 数据参数
/**
 直播间对象
 */
@property (nonatomic, strong) LiveRoom* liveRoom;

/**
 播放控制器
 */
@property (nonatomic, strong) PlayViewController *playVC;

@end
