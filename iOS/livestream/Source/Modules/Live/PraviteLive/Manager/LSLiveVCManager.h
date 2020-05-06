//
//  LSLiveVCManager.h
//  livestream
//
//  Created by Randy_Fan on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgItem.h"
#import "LiveRoom.h"
#import "BarrageModel.h"
#import "AudienceModel.h"
#import "RoomStyleItem.h"
#import "LSScheduleInviteItem.h"

#import "LSImManager.h"
#import "LSLoginManager.h"
#import "LSGiftManager.h"
#import "LSPrePaidManager.h"
#import "LSChatEmotionManager.h"
#import "LSRoomUserInfoManager.h"
#import "PraviteLiveMsgManager.h"
#import "LSSessionRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LSLiveVCManagerDelegate <NSObject>
/* 多人互动邀请回调 */
- (void)onRecvInvitationHangout:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg inviteId:(NSString *)inviteId recommendId:(NSString *)recommendId recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName;
/* 获取多人互动邀请状态回调 */
- (void)onRecvGetHangoutInvitStatus:(BOOL)success status:(HangoutInviteStatus)status roomId:(NSString *)roomId;
/* 开启双向视频回调 */
- (void)onRecvManPush:(LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg isStart:(BOOL)isStart manPushUrls:(NSArray<NSString *> *)manPushUrls;
/* 接收直播间礼物 */
- (void)onRecvSendGiftItem:(GiftItem *)giftItem;
/* 接收直播间弹幕弹幕 */
- (void)onRecvSendToastBarrage:(BarrageModel *)model;
/* 接收消息列表消息 */
- (void)onRecvMessageListItem:(MsgItem *)msgItem;
/* 接收预付费消息 */
- (void)onRecvScheduleMessageItem:(MsgItem *)msgItem;
/* 接收观众座驾入场 */
- (void)onRecvAudienceRideIn:(AudienceModel *)model;
/* 接收发送预付费邀请回调 */
- (void)onRecvSendScheduleInviteToAnchor:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg item:(LSSendScheduleInviteItemObject *)item;
/* 接收发送同意预付费邀请回调 */
- (void)onRecvSendAcceptScheduleToAnchor:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem;
/* 接收直播间预付费列表数 */
- (void)onRecvGetScheduleListCount:(NSInteger)maxCount confirms:(NSInteger)confirms pendings:(NSInteger)pendings;
/* 接收女士发送预付费消息通知 */
- (void)onRecvAnchorSendScheduleToMeNotice:(ImScheduleRoomInfoObject *)item;
/* 接收获取男士/主播信息通知 */
- (void)onRecvUserOrAnchorInfo:(LSUserInfoModel *)item;
@end

@interface LSLiveVCManager : NSObject

/* 直播间信息(外面赋值) */
@property (nonatomic, strong) LiveRoom *liveRoom;

/* IM管理器 */
@property (nonatomic, strong) LSImManager *imManager;

/* 登录管理器 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/* 直播间字体样式(外面赋值) */
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

/* 礼物下载器 */
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

/* 用户信息管理器 */
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

/* 接口管理器 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

/* 消息管理器 */
@property (nonatomic, strong) PraviteLiveMsgManager *msgManager;

/* 表情管理器 */
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

/* 预付费管理器 */
@property (nonatomic, strong) LSPrePaidManager *paidManager;

@property (nonatomic, weak) id<LSLiveVCManagerDelegate> delegate;

/// 初始化
+ (instancetype)manager;

/// 发起多人互动邀请
/// @param recommendId 推荐Id
/// @param recommendAnchorId 推荐主播Id
/// @param recommendAnchorName 推荐主播名字
- (void)sendHangoutInvite:(NSString *)recommendId recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName;

/// 取消多人互动邀请
/// @param inviteId 邀请ID    
- (void)sendCancelHangoutInvite:(NSString *)inviteId;

/// 查询hangout邀请状态
/// @param inviteId 邀请id
- (void)getHangoutInviteStatu:(NSString *)inviteId;

/// 获取座驾信息
/// @param userId 用户id
- (void)getDriveInfo:(NSString *)userId;

/// 发送预付费邀请
/// @param inviteItem 邀请Item
- (void)sendScheduleInviteToAnchor:(LSScheduleInviteItem *)inviteItem;

/// 接受预付费邀请
/// @param inviteId 邀请Id
/// @param duration 时长
/// @param infoObj 消息Item
- (void)sendAcceptScheduleInviteToAnchor:(NSString *)inviteId duration:(int)duration infoObj:(LSScheduleInviteItem *)infoObj;

/// 获取直播间预付费邀请列表
- (void)getScheduleList;

/// 获取直播间观众信息
/// @param userId 用户id
- (void)getLiveRoomUserInfo:(NSString *)userId;

/// 获取直播间主播信息
/// @param userId 用户id
- (void)getLiveRoomAnchorInfo:(NSString *)userId;

/// 发送弹幕
/// @param text 文本
- (void)sendRoomToast:(NSString *)text;

/// 发送直播间消息
/// @param text 文本
/// @param at at队列
- (void)sendLiveRoomChat:(NSString *)text at:(NSArray<NSString *> *_Nullable)at;

/// 开启双向视频
/// @param start YES开启/NO关闭
- (BOOL)sendVideoControl:(BOOL)start;

/// 插入公告提示语
/// @param text 文本
- (void)addTips:(NSString *)text;

/// 插入试聊卷提示
- (void)addVouchTipsToList;

/// 插入预付费邀请消息
/// @param useId 发送人id
/// @param item 预付费item
- (void)addScheduleInviteMsg:(NSString *)useId item:(ImScheduleRoomInfoObject *)item;

/// 插入主播发送/回复预付费邀请消息
/// @param item 预付费item
- (void)addAncherSendScheduleMsg:(ImScheduleRoomInfoObject *)item;

/// 插入预付费邀请回复状态消息
/// @param item 消息item
- (void)addScheduleInviteReplyMsg:(MsgItem *)item;
@end

NS_ASSUME_NONNULL_END
