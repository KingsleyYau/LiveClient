//
//  HangOutViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "LiveSendBarView.h"
#import "LSGoogleAnalyticsViewController.h"
@interface HangOutViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (weak, nonatomic) IBOutlet UIView *videoBottomView;

/** @聊天观众昵称控件 **/
@property (weak, nonatomic) IBOutlet UIView *chatAudienceView;
@property (weak, nonatomic) IBOutlet UILabel *audienceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet LSCheckButton *selectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audienceNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImageViewWidth;

/** 聊天按钮 **/
@property (nonatomic, weak) IBOutlet UIButton * chatBtn;

/** 礼物按钮 **/
@property (nonatomic, weak) IBOutlet UIButton *giftBtn;

@property (weak, nonatomic) IBOutlet LiveSendBarView *liveSendBarView;

/** 发送栏 **/
@property (nonatomic, weak) IBOutlet UIView *inputMessageView;

/** 发送栏底部约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;

/** 输入框高度约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;


@end
