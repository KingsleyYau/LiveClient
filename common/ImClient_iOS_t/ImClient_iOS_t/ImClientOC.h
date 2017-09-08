//
//  ImClientOC.h
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IMLiveRoomManagerListener.h"

@interface ImClientOC : NSObject
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;
#pragma mark - 委托
/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate;

/**
 *  获取一个请求seq
 *
 *
 *  @return 请求序列号
 */
- (SEQ_T)getReqId;
- (BOOL)initClient:(NSArray<NSString *> *_Nonnull)urls;
/**
 *  2.1.登录
 *
 *  @param token    统一验证身份标识
 *  @param pageName socket所在的页面
 *
 */
- (BOOL)login:(NSString *_Nonnull)token pageName:(PageNameType)pageName;
// 2.2.注销
- (BOOL)logout;
/**
 *  3.1.观众进入直播间
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *
 */
- (BOOL)roomIn:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;
/**
 *  3.2.观众退出直播间
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *
 */
- (BOOL)roomOut:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;
/**
 *  3.13.观众进入公开直播间
 *
 *  @param reqId         请求序列号
 *  @param anchorId        主播ID
 *
 */
- (BOOL)publicRoomIn:(SEQ_T)reqId anchorId:(NSString *_Nonnull)anchorId;
/**
 *  4.1.发送直播间文本消息
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *  @param nickName      发送者昵称
 *  @param msg           发送的信息
 *  @param at           用户ID，用于指定接收者
 *
 */
- (BOOL)sendLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at;
/**
 *  5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
 *
 *  @param reqId                    请求序列号
 *  @param roomId                   直播间ID
 *  @param nickName                 发送人昵称
 *  @param giftId                   礼物ID
 *  @param giftName                 礼物名称
 *  @param giftNum                  本次发送礼物的数量
 *  @param multi_click              是否连击礼物
 *  @param multi_click_start        连击起始数
 *  @param multi_click_end          连击结束数
 *  @param multi_click_id           连击ID，相同则表示是同一次连击（生成方式：timestamp秒％10000）
 *
 */
- (BOOL)sendGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id;
/**
 *  6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
 *
 *  @param reqId                 请求序列号
 *  @param roomId                直播间ID
 *  @param nickName              发送人昵称
 *  @param msg                   消息内容
 *
 */
- (BOOL)sendToast:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg;
/**
 *  7.1.观众立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param userId                主播ID
 *  @param logId              主播邀请的记录ID（可无，则表示操作未《接收主播立即私密邀请通知》触发）
 *
 */
- (BOOL)sendPrivateLiveInvite:(SEQ_T)reqId userId:(NSString *_Nonnull)userId logId:(NSString *_Nonnull)logId force:(BOOL)force;
/**
 *  7.2.观众取消立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param inviteId              邀请ID
 *
 */
- (BOOL)sendCancelPrivateLiveInvite:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId;

/**
 *  8.1.发送直播间才艺点播邀请
 *
 *  @param reqId                 请求序列号
 *  @param roomId                直播间ID
 *  @param talentId              才艺点播ID
 *
 */
- (BOOL)sendTalent:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId talentId:(NSString* _Nonnull)talentId;

@end
