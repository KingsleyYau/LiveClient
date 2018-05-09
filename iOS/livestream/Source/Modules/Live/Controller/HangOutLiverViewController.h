//
//  HangOutLiverViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/4/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImageView.h>
#import "LSGoogleAnalyticsViewController.h"

#import "LiveRoom.h"

#import "GiftStatisticsView.h"

@class HangOutLiverViewController;
@protocol HangOutLiverViewControllerDelegate <NSObject>
@optional
- (void)inviteAnchorJoinHangOut:(HangOutLiverViewController *)liverVC;
- (void)loadVideoOvertime:(HangOutLiverViewController *)liverVC;
- (void)invitationHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg liverVC:(HangOutLiverViewController *)liverVC;
- (void)cancelInviteHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg liverVC:(HangOutLiverViewController *)liverVC;
- (void)inviteHangoutNotAgreeNotice:(HangOutLiverViewController *)liverVC;
- (void)leaveHangoutRoomNotice:(HangOutLiverViewController *)liverVC;
@end

@interface HangOutLiverViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

@property (weak, nonatomic) IBOutlet UIView *comboGiftView;

@property (weak, nonatomic) IBOutlet GiftStatisticsView *giftCountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountViewWidth;

@property (weak, nonatomic) IBOutlet UIImageView *videoLoadingView;

@property (weak, nonatomic) IBOutlet UIImageView *nameShadowView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIView *tipMessageView;

@property (weak, nonatomic) IBOutlet UIImageView *tipIconView;

@property (weak, nonatomic) IBOutlet UILabel *tipMessageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipIconViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipMessageViewTop;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) NSString *inviteId;

@property (weak, nonatomic) id <HangOutLiverViewControllerDelegate> inviteDelegate;

#pragma mark - 播放礼物
- (void)onSendGiftNoticePlay:(IMRecvHangoutGiftItemObject *)model;

#pragma mark - 发送HangOut邀请
- (void)sendHangoutInvite:(LSHangoutAnchorItemObject *)item;

#pragma mark - 状态界面显示
// 重置界面
- (void)resetView:(BOOL)isClean;

// 显示正在邀请
- (void)showInvitingAnchorTip;

// 显示主播正在进入
- (void)showAnchorComingTip;

// 显示进入倒计时
- (void)showAnchorEnterCountdown:(NSInteger)sec;

// 显示主播正在播流
- (void)showAnchorLoading;


@end
