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

@property (weak, nonatomic) IBOutlet UIImageView *liverHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *liverNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (weak, nonatomic) IBOutlet UIButton *vipStartPrivateBtn;

@property (weak, nonatomic) IBOutlet UIButton *bookPrivateBtn;

@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
// 33
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryBtnHeight;
// 26
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startPrivateHeight;
// 35
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookPrivateHeight;
// 33
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCreditHeight;


@end
