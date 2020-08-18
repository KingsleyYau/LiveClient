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
#import "LSGiftManager.h"

#import "GiftStatisticsView.h"

typedef enum {
    LIVETYPE_ONLIVRROOM,
    LIVETYPE_INVITING,
    LIVETYPE_COUNTDOWN,
    LIVETYPE_CANCELLING,
    LIVETYPE_OPENINGDOOR,
    LIVETYPE_OUTLIEROOM
} LIVETYPE;

@class HangOutLiverViewController;
@protocol HangOutLiverViewControllerDelegate <NSObject>
@optional
- (void)inviteAnchorJoinHangOut:(HangOutLiverViewController *)liverVC;
- (void)invitationHangoutRequest:(HTTP_LCC_ERR_TYPE)errnum errMsg:(NSString *)errMsg anchorId:(NSString *)anchorId liverVC:(HangOutLiverViewController *)liverVC;
- (void)cancelInviteHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg anchorId:(NSString *)anchorId liverVC:(HangOutLiverViewController *)liverVC;
- (void)inviteHangoutNotAgreeNotice:(IMRecvDealInviteItemObject *)item liverVC:(HangOutLiverViewController *)liverVC;
- (void)leaveHangoutRoomNotice:(HangOutLiverViewController *)liverVC;
- (void)liverLongPressTap:(HangOutLiverViewController *)liverVC isBoost:(BOOL)isBoost;
@end

@interface HangOutLiverViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

@property (weak, nonatomic) IBOutlet UIView *comboGiftView;

@property (weak, nonatomic) IBOutlet GiftStatisticsView *giftCountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountViewWidth;

@property (weak, nonatomic) IBOutlet UIImageView *videoLoadingView;

@property (weak, nonatomic) IBOutlet UIImageView *nameShadowView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewWidth;

@property (weak, nonatomic) IBOutlet UIView *tipMessageView;

@property (weak, nonatomic) IBOutlet UIImageView *tipIconView;

@property (weak, nonatomic) IBOutlet UILabel *tipMessageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipIconViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipMessageViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipMessageViewBottom;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIImageView *firstIcon;

@property (nonatomic, assign) NSInteger index;

#pragma mark - 吧台礼物数量记录队列
@property (nonatomic, strong) NSMutableArray *barGiftNumArray;

// 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

// 直播间中的主播列表对象
@property (nonatomic, strong) IMLivingAnchorItemObject *anchorItem;

@property (nonatomic, assign) BOOL isBoostView;

@property (weak, nonatomic) id <HangOutLiverViewControllerDelegate> inviteDelegate;

#pragma mark - 停止播流 置空播放器
- (void)stopPlay;

#pragma mark - 获取/设置播流声音
- (void)setThePlayMute:(BOOL)isMute;

#pragma mark - 播放礼物
- (void)onSendGiftNoticePlay:(IMRecvHangoutGiftItemObject *)model;

#pragma mark - 发送HangOut邀请
- (void)sendHangoutInvite:(LSHangoutAnchorItemObject *)anchorItem;

#pragma mark - 状态界面显示
// 获取直播间状态
- (LIVETYPE)getTheLiveType;

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

// 进入直播间状态界面
- (void)showEnterRoomType;

// 显示吧台礼物列表
- (void)showGiftCount:(NSMutableArray *)bugforList;
// 刷新吧台礼物列表
- (void)reloadGiftCountView;

// 发送连击礼物
- (void)sendHangoutComboGift:(LSGiftManagerItem *)item clickId:(int)clickId isPrivate:(NSInteger)isPrivate;

// 发送其他礼物 (吧台 大礼物)
- (void)sendHangoutGift:(LSGiftManagerItem *)item clickId:(int)clickId isPrivate:(NSInteger)isPrivate;


@end
