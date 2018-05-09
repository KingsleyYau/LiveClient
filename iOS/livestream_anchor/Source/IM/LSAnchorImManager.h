//
//  LSAnchorImManager.h
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZBImClientOC.h"
#import "ZBImHeader.h"

#import "LiveRoom.h"

//#import "GetInviteInfoRequest.h"

#define INVALID_REQUEST_ID -1

@protocol ZBIMManagerDelegate <NSObject>
@optional
/**
 断线重登陆获取到的邀请状态

 */
- (void)onZBRecvInviteReply:(ZBImInviteIdItemObject * _Nonnull)item;

/**
 第一次登陆成功, 需要强制进入的直播间

 @param roomId 直播间Id
 */
- (void)onZBHandleLoginRoom:(NSString * _Nonnull)roomId roomType:(LiveRoomType)roomType;

/**
 第一次登陆成功, 本人邀请中有效的立即私密邀请

 @param inviteItem 本人邀请中有效的立即私密邀请
 */
- (void)onZBHandleLoginInvite:(ZBImInviteIdItemObject * _Nonnull)inviteItem;

/**
 第一次登陆成功, 预约并且未进入过直播间的提示

 @param scheduleRoomList 预约并且未进入过直播间的提示
 */
- (void)onZBHandleLoginSchedule:(NSArray<ZBImScheduleRoomObject*> * _Nonnull)scheduleRoomList;


/**
 *  9.6.接收观众接受预约通知接口 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     预约ID
 *  @param bookTime         预约时间（1970年起的秒数）
 */
- (void)onZBHandleRecvScheduleAcceptNotice:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl invitationId:(NSString* _Nonnull)invitationId bookTime:(long)bookTime;

@end

@interface LSAnchorImManager : NSObject
@property (strong) ZBImClientOC *_Nonnull client;

#pragma mark - 获取实例
+ (instancetype _Nonnull)manager;

// 将c的直播间类型转OC中的直播类型
- (LiveRoomType)roomTypeToLiveRoomType:(ZBRoomType)type;

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<ZBIMManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<ZBIMManagerDelegate> _Nonnull)delegate;

/**
 注销
 */
- (void)logout;

#pragma mark - 直播间状态

typedef void (^EnterPublicRoomHandler)(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ZBImLiveRoomObject *_Nonnull roomItem);
/**
 3.1.新建/进入公开直播间
 
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterPublicRoom:(EnterPublicRoomHandler _Nullable)finishHandler;

typedef void (^EnterRoomHandler)(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ZBImLiveRoomObject *_Nonnull roomItem);
/**
 3.2.主播进入指定直播间

 @param roomId 直播间Id
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterRoom:(NSString *_Nonnull)roomId finishHandler:(EnterRoomHandler _Nullable)finishHandler;



/**
 3.3.主播退出直播间

 @param roomId 直播间Id
 @return YES:成功/NO:失败
 */
- (BOOL)leaveRoom:(NSString *_Nonnull)roomId;

#pragma mark - 消息和礼物
/**
 4.1.发送消息

 @param roomId 直播间Id
 @param nickName 名字
 @param msg 消息文本
 @param at 需要提醒人的Id
 @return YES:成功/NO:失败
 */
- (BOOL)sendLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at;

///**
// 发弹幕
//
// @param roomId 直播间Id
// @param nickName 名字
// @param msg 消息文本
// @return YES:成功/NO:失败
// */
//- (BOOL)sendToast:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg;


#pragma maek - 发送礼物
typedef void (^SendGiftHandler)(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg);

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
- (BOOL)sendGift:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id finishHandler:(SendGiftHandler _Nullable)finishHandler;

#pragma mark -私密邀请
typedef void (^SendImmediatePrivateInviteHandler)(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitation, int timeOut, NSString *_Nonnull roomId);

/**
 *  9.1.主播发送立即私密邀请
 *
 *  @param userId                主播ID
 *
 */
- (BOOL)anchorSendImmediatePrivateInvite:(NSString *_Nonnull)userId finishHandler:(SendImmediatePrivateInviteHandler _Nullable)finishHandler;

typedef void (^GetInviteInfoHandler)(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ZBImInviteIdItemObject *_Nonnull item);
/**
 *  9.5.获取指定立即私密邀请信息
 *
 *  @param invitationId  邀请ID
 *
 */
-(BOOL)anchorGetInviteInfo:(NSString *_Nonnull)invitationId finishHandler:(GetInviteInfoHandler _Nullable)finishHandler;


@end
