//
//  ShowLiveViewController.h
//  livestream
//
//  Created by Calvin on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoom.h"
#import "PlayViewController.h"
#import "LSUITapImageView.h"
#import "VIPAudienceView.h"
#import "ChardTipView.h"

@interface ShowLiveViewController : LSGoogleAnalyticsViewController

#pragma mark - 数据参数
/**
 直播间对象
 */
@property (nonatomic, strong) LiveRoom* liveRoom;

/**
 播放控制器
 */
@property (nonatomic, strong) PlayViewController *playVC;

#pragma mark - 界面控件
/**
 女士头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *laddyHeadImageView;

/**
 女士姓名
 */
@property (weak, nonatomic) IBOutlet UILabel *laddyNameLabel;

/**
 女士头部背景
 */
@property (weak, nonatomic) IBOutlet UIView *headBackgroundView;

/**
 底部背景
 */
@property (weak, nonatomic) IBOutlet UIImageView *titleBackGroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBgImageTop;
/**
 直播间类型资费提示(暂时不用)
 */
@property (weak, nonatomic) IBOutlet LSUITapImageView *roomTypeImageView;

/**
 关注按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnWidth;

/**
 观众席
 */
@property (weak, nonatomic) IBOutlet VIPAudienceView *audienceView;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (strong, nonatomic) ChardTipView *tipView;

#pragma mark - 界面事件

- (IBAction)pushLiveHomePage:(id)sender;

- (IBAction)followLiverAction:(id)sender;

- (IBAction)closeAction:(id)sender;

@end
