//
//  PrivateViewController.h
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "PlayViewController.h"
#import "LiveRoom.h"

#import "LSUITapImageView.h"
#import "ChardTipView.h"
#import "RoomTypeIsFirstManager.h"

@class PrivateViewController;
@protocol PrivateViewControllerDelegate <NSObject>
@optional
- (void)onSetupViewController:(PrivateViewController *)vc;
- (void)setUpLiveRoomType:(PrivateViewController *)vc;
- (void)showHangoutTipView:(PrivateViewController *)vc;
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
@property (nonatomic, weak) id<PrivateViewControllerDelegate> vcDelegate;

/**
 播放控制器
 */
@property (nonatomic, strong) PlayViewController *playVC;

#pragma mark - 标题栏
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *titleBackGroundView;

#pragma mark - 直播间资费提醒(暂时不用)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargeTipImageWidth;
@property (weak, nonatomic) IBOutlet LSUITapImageView *roomTypeImageView;
@property (strong, nonatomic) ChardTipView *tipView;

#pragma mark - 标题栏背景
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBgImageTop;

#pragma mark - 女士头像(控件)
@property (weak, nonatomic) IBOutlet UIView *ladyHeadView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *ladyImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnWidth;
@property (weak, nonatomic) IBOutlet UILabel *laddyNameLabel;


#pragma mark - 亲密度控件
@property (weak, nonatomic) IBOutlet UIView *intimacyHeadView;
@property (weak, nonatomic) IBOutlet UIImageView *intimacyManImageView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *intimacyLadyImageView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *intimacyImageView;

#pragma mark - 按钮
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end
