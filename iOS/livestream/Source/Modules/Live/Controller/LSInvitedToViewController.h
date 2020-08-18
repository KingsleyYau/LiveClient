//
//  LSInvitedToViewController.h
//  livestream
//
//  Created by randy on 2017/10/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"

@interface LSInvitedToViewController : LSGoogleAnalyticsViewController

#pragma mark - 邀请ID
@property (nonatomic, strong) NSString *inviteId;

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (nonatomic, weak) IBOutlet UILabel* handleCountDownLabel;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *liverHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *liverNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (weak, nonatomic) IBOutlet UIButton *vipStartPrivateBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipStartPrivateBtnHeight;

@property (weak, nonatomic) IBOutlet UIButton *bookPrivateBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookPrivateBtnTop;

@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (weak, nonatomic) IBOutlet UIImageView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *vipView;
@property (weak, nonatomic) IBOutlet UIImageView *talentIcon;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end
