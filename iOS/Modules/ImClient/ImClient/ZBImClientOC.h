//
//  ZBImClientOC.h
//  ZBImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZBIMLiveRoomManagerListener.h"

@interface ZBImClientOC : NSObject
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
- (BOOL)addDelegate:(id<ZBIMLiveRoomManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<ZBIMLiveRoomManagerDelegate> _Nonnull)delegate;

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
- (BOOL)anchorLogin:(NSString *_Nonnull)token pageName:(ZBPageNameType)pageName;
// 2.2.注销
- (BOOL)anchorLogout;

/**
 *  3.1.新建/进入公开直播间
 *
 *  @param reqId         请求序列号
 *
 */
- (BOOL)anchorPublicRoomIn:(SEQ_T)reqId;
/**
 *  3.2.主播进入指定直播间
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *
 */
- (BOOL)anchorRoomIn:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;
/**
 *  3.3.主播退出直播间
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *
 */
- (BOOL)anchorRoomOut:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;


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
- (BOOL)anchorSendLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at;
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
- (BOOL)anchorSendGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id;

/**
 *  9.1.主播发送立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param userId                主播ID
 *
 */
- (BOOL)anchorSendImmediatePrivateInvite:(SEQ_T)reqId userId:(NSString *_Nonnull)userId;

/**
 *  9.5.获取指定立即私密邀请信息
 *
 *  @param reqId         请求序列号
 *  @param invitationId  邀请ID
 *
 */
-(BOOL)anchorGetInviteInfo:(SEQ_T)reqId invitationId:(NSString *_Nonnull)invitationId;

/**
 *  10.1.进入多人互动直播间
 *
 *  @param reqId         请求序列号
 *  @param roomId 多人互动直播间ID
 *
 */
-(BOOL)anchorEnterHangoutRoom:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;

/**
 *  10.2.退出多人互动直播间
 *
 *  @param reqId            请求序列号
 *  @param roomId           多人互动直播间ID
 *
 */
-(BOOL)anchorLeaveHangoutRoom:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId;

/**
 *  10.11.发送多人互动直播间礼物消息
 *
 * @param reqId         请求序列号
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
-(BOOL)anchorSendHangoutGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName toUid:(NSString *_Nonnull)toUid giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate;


@end
