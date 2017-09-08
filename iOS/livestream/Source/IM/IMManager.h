//
//  IMManager.h
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImClientOC.h"
#import "ImHeader.h"

#import "GetInviteInfoRequest.h"

#define INVALID_REQUEST_ID -1

@protocol IMManagerDelegate <NSObject>
@optional
/**
 断线重登陆获取到的邀请状态

 */
- (void)onRecvInviteReply:(InviteIdItemObject * _Nonnull)item;

/**
 第一次登陆成功, 需要强制进入的直播间

 @param roomId 直播间Id
 */
- (void)onHandleLoginRoom:(NSString * _Nonnull)roomId;

/**
 第一次登陆成功, 本人邀请中有效的立即私密邀请

 @param inviteItem 本人邀请中有效的立即私密邀请
 */
- (void)onHandleLoginInvite:(ImInviteIdItemObject * _Nonnull)inviteItem;

/**
 第一次登陆成功, 预约并且未进入过直播间的提示

 @param scheduleRoomList 预约并且未进入过直播间的提示
 */
- (void)onHandleLoginSchedule:(NSArray<ImScheduleRoomObject*> * _Nonnull)scheduleRoomList;

@end

@interface IMManager : NSObject
@property (strong) ImClientOC *_Nonnull client;

#pragma mark - 获取实例
+ (instancetype _Nonnull)manager;

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<IMManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<IMManagerDelegate> _Nonnull)delegate;

#pragma mark - 直播间状态
typedef void (^EnterRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem);
/**
 发送观众进入直播间

 @param roomId 直播间Id
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterRoom:(NSString *_Nonnull)roomId finishHandler:(EnterRoomHandler _Nullable)finishHandler;

typedef void (^EnterPublicRoomHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem);
/**
 发送观众进入公开直播间
 
 @param anchorId 直播间Id
 @param finishHandler 处理回调
 @return YES:成功/NO:失败
 */
- (BOOL)enterPublicRoom:(NSString *_Nonnull)anchorId finishHandler:(EnterPublicRoomHandler _Nullable)finishHandler;

/**
 发送观众退出直播间

 @param roomId 直播间Id
 @return YES:成功/NO:失败
 */
- (BOOL)leaveRoom:(NSString *_Nonnull)roomId;

#pragma mark - 私密直播间
typedef void (^InviteHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId);
/**
 发送私密邀请
 
 @param userId 用户Id
 @param logId 主播邀请的记录ID
 @return YES:成功/NO:失败
 */
- (BOOL)invitePrivateLive:(NSString *_Nonnull)userId logId:(NSString *_Nonnull)logId force:(BOOL)force finishHandler:(InviteHandler _Nullable)finishHandler;

typedef void (^CancelInviteHandler)(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId);
/**
 发送私密邀请(取消)
 
 @return YES:成功/NO:失败
 */
- (BOOL)cancelPrivateLive:(CancelInviteHandler _Nullable)finishHandler;

/**
 发送才艺点播

 @param roomId 直播间Id
 @param talentId 点播Id
 @return 请求惟一Id
 */
- (NSInteger)sendTalent:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId;

#pragma mark - 消息和礼物
/**
 发送消息

 @param roomId 直播间Id
 @param nickName 名字
 @param msg 消息文本
 @param at 需要提醒人的Id
 @return 请求惟一Id
 */
- (NSInteger)sendLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at;

/**
 发弹幕

 @param roomId 直播间Id
 @param nickName 名字
 @param msg 消息文本
 @return 请求惟一Id
 */
- (NSInteger)sendToast:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg;

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
 @return 请求惟一Id
 */
- (NSInteger)sendGift:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id;

@end
