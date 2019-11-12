//
//  PreLiveViewController.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

#import "LiveRoom.h"

@interface PreLiveViewController : LSGoogleAnalyticsViewController
#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

#pragma mark - 界面
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) IBOutlet UILabel* handleCountDownLabel;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

@property (nonatomic, weak) IBOutlet UIImageView *ladyImageView;
@property (nonatomic, weak) IBOutlet UILabel* ladyNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;


@property (nonatomic, weak) IBOutlet UIButton *retryButton;
@property (nonatomic, weak) IBOutlet UIButton *addCreditButton;
@property (nonatomic, weak) IBOutlet UIButton *bookButton;
@property (nonatomic, weak) IBOutlet UIButton *vipStartButton;
@property (weak, nonatomic) IBOutlet UIButton *chatNowBtn;
@property (nonatomic, weak) IBOutlet UIButton *sendMailButton;
@property (nonatomic, weak) IBOutlet UIImageView *loadingView;


@end
