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

#pragma mark - 其他
- (long)getImClient;

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
 *  @param userId      主播ID
 *
 */
- (BOOL)publicRoomIn:(SEQ_T)reqId userId:(NSString *_Nonnull)userId;
/**
 *  3.14.观众开始／结束视频互动
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *  @param control       视频操作（1:开始 2:关闭）
 *
 */
-(BOOL)controlManPush:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId control:(IMControlType)control;

/**
 *  3.15.获取指定立即私密邀请信息
 *
 *  @param reqId         请求序列号
 *  @param invitationId  邀请ID
 *
 */
-(BOOL)getInviteInfo:(SEQ_T)reqId invitationId:(NSString *_Nonnull)invitationId;
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
 *  7.8.观众端是否显示主播立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param inviteId              邀请ID
 *  @param isShow                观众端是否弹出邀请
 *
 */
- (BOOL)sendInstantInviteUserReport:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId isShow:(BOOL)isShow;

/**
 *  8.1.发送直播间才艺点播邀请
 *
 *  @param reqId                 请求序列号
 *  @param roomId                直播间ID
 *  @param talentId              才艺点播ID
 *
 */
- (BOOL)sendTalent:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId talentId:(NSString* _Nonnull)talentId;

// ------------- 多人互动 -------------
/**
 *  10.3.观众新建/进入多人互动直播间接口
 *
 *  @param reqId            请求序列号
 *  @param roomId           直播间ID
 *  @param isCreateOnly     是否仅创建新的Hangout直播间，若已有Hangout直播间则先关闭（NO：否，YES：是）（可无，无则默认为NO）
 *
 */
- (BOOL)enterHangoutRoom:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId isCreateOnly:(BOOL)isCreateOnly;

/**
 *  10.4.退出多人互动直播间接口
 *
 *  @param reqId            请求序列号
 *  @param roomId           直播间ID
 *
 */
- (BOOL)leaveHangoutRoom:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId;

/**
 *  10.7.发送多人互动直播间礼物消息接口
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
- (BOOL)sendHangoutGift:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName toUid:(NSString* _Nonnull)toUid giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate;

/**
 *  10.1.退出多人互动直播间接口
 *
 *  @param reqId            请求序列号
 *  @param roomId           直播间ID
 *  @param control          视频操作（IMCONTROLTYPE_START：开始 IMCONTROLTYPE_CLOSE：关闭）
 *
 */
- (BOOL)controlManPushHangout:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId control:(IMControlType)control;

/**
 *  10.12.发送多人互动直播间文本消息接口
 *
 *  @param reqId            请求序列号
 *  @param roomId           直播间ID
 *  @param nickName         发送者昵称
 *  @param msg              发送的信息
 *  @param at               用户ID，用于指定接收者（字符串数组）（可无，无则表示发送给直播间所有人）
 *
 */
- (BOOL)SendHangoutLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at;

@end
