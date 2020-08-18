//
//  PublicVipViewController.h
//  livestream
//
//  Created by randy on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "LSVIPInputViewController.h"
#import "LiveRoom.h"

#import "VIPAudienceView.h"
#import "LSUIImageViewTopFit.h"

@interface PublicVipViewController : LSGoogleAnalyticsViewController
#pragma mark - 数据参数
/**
 直播间对象
 */
@property (nonatomic, strong) LiveRoom* liveRoom;

/**
 播放控制器
 */
@property (nonatomic, strong) LSVIPInputViewController *playVC;

#pragma mark - 界面控件
/**
 女士头像
 */
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *laddyHeadImageView;

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
/**
 观众席
 */
@property (weak, nonatomic) IBOutlet VIPAudienceView *audienceView;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

#pragma mark - 界面事件

- (IBAction)pushLiveHomePage:(id)sender;


- (IBAction)closeAction:(id)sender;

@end
