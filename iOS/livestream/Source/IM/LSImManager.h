//
//  LSImManager.h
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImClientOC.h"
#import "ImHeader.h"

#import "GetInviteInfoRequest.h"

#import "LiveRoom.h"

#define INVALID_REQUEST_ID -1

@protocol IMManagerDelegate <NSObject>
@optional
/**
 断线重登陆获取到的邀请状态

 */
- (void)onRecvInviteReply:(ImInviteIdItemObject *)item;

/**
 第一次登陆成功, 需要强制进入的直播间

 @param roomId 直播间Id
 */
- (void)onHandleLoginRoom:(NSString *)roomId userId:(NSString *)userId userName:(NSString *)userName;

/**
 第一次登陆成功, 本人邀请中有效的立即私密邀请

 @param inviteItem 本人邀请中有效的立即私密邀请
 */
- (void)onHandleLoginInvite:(ImInviteIdItemObject *)inviteItem;

/**
 第一次登陆成功, 预约并且未进入过直播间的提示

 @param scheduleRoomList 预约并且未进入过直播间的提示
 */
- (void)onHandleLoginSchedule:(NSArray<ImScheduleRoomObject *> *)scheduleRoomList;

/**
 第一次登陆成功, 显示可以进入的节目
 
 @param ongoingShowList 显示可以进入的节目
 */
- (void)onHandleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList;

/**
 接收到多人互动主播推荐好友通知
 
 @param firendItem 推荐好友的信息
 */
- (void)onHandleRecommendHangoutFriend:(IMRecommendHangoutItemObject *)firendItem;

/**
 在多人直播间接收多人互动主播敲门通知
 
 @param knockItem 推荐好友的信息
 */
- (void)onHandleKnockRequest:(IMKnockRequestItemObject *)knockItem;

/**
 在多人直播间接收进入多人互动直播间倒数通知
 
 @param roomId 待进入的直播间ID
 @param anchorId 主播ID
 @param leftSecond 进入直播间的剩余秒数
 */
- (void)onHandleEnterHangoutCountDown:(NSString *)roomId anchorId:(NSString *)anchorId leftSecond:(int)leftSecond;

/**
 接收主播Hang-out邀请通知
 @param item 主播数据
 */
- (void)onRecvHandoutInviteNotice:(IMHangoutInviteItemObject *)item;
@end

@interface LSImManager : NSObject
@property (strong) ImClientOC *client;

// 是否第一次IM登陆
@property (nonatomic, assign) BOOL isFirstLogin;
// 是否已经登陆
@property (nonatomic, assign) BOOL isIMLogin;
#pragma mark - 获取实例
+ (instancetype)manager;

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<IMManagerDelegate>)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<IMManagerDelegate>)delegate;

/**
 登录
 */
- (void)login;
/**
 注销
 */
- (void)logout;

/**
 重置状态
 */
- (void)resetIMStatus;

#pragma mark - 直播间状态
typedef void (^EnterRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, ImLiveRoomObject *roomItem, ImAuthorityItemObject* priv);
/**
 发送观众进入直播间

 @param roomId 直播间Id
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterRoom:(NSString *)roomId finishHandler:(EnterRoomHandler)finishHandler;

typedef void (^EnterPublicRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, ImLiveRoomObject *roomItem, ImAuthorityItemObject* priv);
/**
 发送观众进入公开直播间
 
 @param anchorId 直播间Id
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterPublicRoom:(NSString *)anchorId finishHandler:(EnterPublicRoomHandler)finishHandler;

/**
 发送观众退出直播间

 @param liveRoom 直播间Id
 @return YES:成功/NO:失败
 */
- (BOOL)leaveRoom:(LiveRoom *)liveRoom;

#pragma mark - 私密直播间
typedef void (^InviteHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, NSString *invitationId, int timeout, NSString *roomId, ImInviteErrItemObject* inviteErrItem);
/**
 发送私密邀请
 
 @param userId 用户Id
 @param logId 主播邀请的记录ID
 @return YES:成功/NO:失败
 */
- (BOOL)invitePrivateLive:(NSString *)userId logId:(NSString *)logId force:(BOOL)force finishHandler:(InviteHandler)finishHandler;

typedef void (^CancelInviteHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, NSString *roomId);
/**
 发送私密邀请(取消)
 
 @return YES:成功/NO:失败
 */
- (BOOL)cancelPrivateLive:(CancelInviteHandler)finishHandler;

typedef void (^InstantInviteUserReportHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg);
/**
 观众端是否显示主播立即私密邀请
 
 @return YES:成功/NO:失败
 */
- (BOOL)InstantInviteUserReport:(NSString *)inviteId isShow:(BOOL)isShow finishHandler:(InstantInviteUserReportHandler)finishHandler;

typedef void (^GetIMInviteInfoHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, ImInviteIdItemObject *item, ImAuthorityItemObject *priv);
/**
 获取指定立即私密邀请信息
 *  param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)getInviteInfo:(GetIMInviteInfoHandler)finishHandler;
/**
 发送才艺点播

 @param roomId 直播间Id
 @param talentId 点播Id
 @return YES:成功/NO:失败
 */
- (BOOL)sendTalent:(NSString *)roomId talentId:(NSString *)talentId;

#pragma mark - 消息和礼物
/**
 发送消息

 @param roomId 直播间Id
 @param nickName 名字
 @param msg 消息文本
 @param at 需要提醒人的Id
 @return YES:成功/NO:失败
 */
- (BOOL)sendLiveChat:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg at:(NSArray<NSString *> *)at;

/**
 发弹幕

 @param roomId 直播间Id
 @param nickName 名字
 @param msg 消息文本
 @return YES:成功/NO:失败
 */
- (BOOL)sendToast:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg;

#pragma maek - 发送礼物
typedef void (^SendGiftHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, double credit, double rebateCredit);

/**
 发礼物

 @param roomId 直播间Id
 @param nickName 名称
 @param giftId 礼物Id
 @param giftName 礼物名字
 @param isBackPack 是否背包
 @param giftNum 礼物数量
 @param multi_click 是否连接
 @param multi_click_start 连击开始位置
 @param multi_click_end 连接结束位置
 @param multi_click_id 连击Id
 @param finishHandler 请求回调
 @return YES:成功/NO:失败
 */
- (BOOL)sendGift:(NSString *)roomId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id finishHandler:(SendGiftHandler)finishHandler;

#pragma mark - 视频互动
typedef void (^ControlManPushHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, NSArray<NSString *> *manPushUrl);
/**
 开始／结束视频互动

 @param roomId 直播间ID
 @param control 视频操作
 @return YES:成功/NO:失败
 */
- (BOOL)controlManPush:(NSString *)roomId control:(IMControlType)control finishHandler:(ControlManPushHandler)finishHandler;

// ------------- 多人互动 -------------
typedef void (^EnterHangoutRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, IMHangoutRoomItemObject *item);
/**
 *  10.3.观众新建/进入多人互动直播间接口
 *
 *  @param roomId           直播间ID
 *
 */
- (BOOL)enterHangoutRoom:(NSString *)roomId finishHandler:(EnterHangoutRoomHandler)finishHandler;

typedef void (^LeaveHangoutRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg);
/**
 *  10.4.退出多人互动直播间接口
 *
 *  @param roomId           直播间ID
 *
 */
- (BOOL)leaveHangoutRoom:(NSString *)roomId finishHandler:(LeaveHangoutRoomHandler)finishHandler;

typedef void (^SendHangoutGiftHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, double credit);
/**
 *  10.7.发送多人互动直播间礼物消息接口
 *
 * @roomId              直播间ID
 * @nickName            发送人昵称
 * @toUid               接收者ID
 * @giftId              礼物ID
 * @giftName            礼物名称
 * @isBackPack          是否背包礼物（1：是，0：否）
 * @giftNum             本次发送礼物的数量
 * @isMultiClick        是否连击礼物（1：是，0：否）
 * @multiClickStart     连击起始数（整型）（可无，multi_click=0则无）
 * @multiClickEnd       连击结束数（整型）（可无，multi_click=0则无）
 * @multiClickId        连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则无）
 * @isPrivate           是否私密发送（1：是，0：否）
 *
 */
- (BOOL)sendHangoutGift:(NSString* )roomId nickName:(NSString* )nickName toUid:(NSString* )toUid giftId:(NSString* )giftId giftName:(NSString* )giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate finishHandler:(SendHangoutGiftHandler)finishHandler;

typedef void (^ControlManPushHangoutHandler)(BOOL success, LCC_ERR_TYPE errType, NSString * errMsg, NSArray<NSString *> * manPushUrl);
/**
 10.11.多人互动观众开始/结束视频互动
 
 @param roomId 直播间ID
 @param control 视频操作
 @return YES:成功/NO:失败
 */
- (BOOL)controlManPushHangout:(NSString *)roomId control:(IMControlType)control finishHandler:(ControlManPushHangoutHandler)finishHandler;

/**
 *  10.12.发送多人互动直播间文本消息接口
 *
 *  @param roomId           直播间ID
 *  @param nickName         发送者昵称
 *  @param msg              发送的信息
 *  @param at               用户ID，用于指定接收者（字符串数组）（可无，无则表示发送给直播间所有人）
 *
 */
- (BOOL)sendHangoutLiveChat:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg at:(NSArray<NSString *> *)at;

@end
