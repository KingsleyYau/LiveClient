//
//  PrivateViewController.h
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoom.h"
#import "PlayViewController.h"

#import "LSUITapImageView.h"
#import "ChardTipView.h"
#import "RoomTypeIsFirstManager.h"

@class PrivateViewController;
@protocol PrivateViewControllerDelegate <NSObject>
@optional
- (void)onSetupViewController:(PrivateViewController *)vc;
- (void)setUpLiveRoomType:(PrivateViewController *)vc;
@end

@interface PrivateViewController : LSGoogleAnalyticsViewController
#pragma mark - 数据参数
/**
 直播间对象
 */
@property (nonatomic, strong) LiveRoom* liveRoom;

/**
 代理
 */
@property (nonatomic, weak) id<PrivateViewControllerDelegate> privateDelegate;

/**
 播放控制器
 */
@property (nonatomic, strong) PlayViewController *playVC;

#pragma mark - 标题栏
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;


@end
