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
 <#Description#>
 */
@property (nonatomic, weak) id<PrivateViewControllerDelegate> delegate;

/**
 播放控制器
 */
@property (nonatomic, strong) PlayViewController *playVC;

#pragma mark - 标题栏
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *titleBackGroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargeTipImageWidth;
@property (weak, nonatomic) IBOutlet LSUITapImageView *roomTypeImageView;
@property (strong, nonatomic) ChardTipView *tipView;

#pragma mark - 男女士头像
@property (weak, nonatomic) IBOutlet UIImageView *manHeadBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *manHeadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ladyHeadBgImageView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *ladyHeadImageView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *intimacyImageView;

#pragma mark - 按钮
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end
