//
//  LiveChatManagerListener.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImHeader.h"

@protocol IMLiveRoomManagerDelegate <NSObject>
@optional

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item        登录返回结构体
 */
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ImLoginReturnObject* _Nonnull)item;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

/**
 *  2.4.用户被挤掉线回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

#pragma mark - 直播间主动操作回调
/**
 *  3.1.观众进入直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item         直播间信息
 *
 */
- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ImLiveRoomObject* _Nonnull)item;
/**
 *  3.2.观众退出直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

/**
 *  3.13.观众进入公开直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param item         直播间信息
 *
 */
- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg item:(ImLiveRoomObject* _Nonnull)item;

/**
 *  3.14.观众开始／结束视频互动接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param manPushUrl       观众视频流url
 *
 */
- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg manPushUrl:(NSArray<NSString *> *_Nonnull)manPushUrl;

/**
 *  3.15.获取指定立即私密邀请信息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param item             立即私密邀请
 *
 */
- (void)onGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg item:(ImInviteIdItemObject *_Nonnull)item;

#pragma mark - 直播间接收操作回调
/**
 *  3.3.接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *
 */
- (void)onRecvRoomCloseNotice:(NSString* _Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

/**
 *  3.4.接收观众进入直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param riderId     座驾ID
 *  @param riderName   座驾名称
 *  @param riderUrl    座驾图片url
 *  @param fansNum     观众人数
 *  @param honorImg    勋章图片url
 *  @param isHasTicket 是否已购票（NO：否，YES：是）
 *
 */
- (void)onRecvEnterRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl riderId:(NSString* _Nonnull)riderId riderName:(NSString* _Nonnull)riderName riderUrl:(NSString* _Nonnull)riderUrl fansNum:(int)fansNum honorImg:(NSString* _Nonnull)honorImg isHasTicket:(BOOL)isHasTicket;

/**
 *  3.5.接收观众退出直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param fansNum     观众人数
 *
 */
- (void)onRecvLeaveRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl fansNum:(int)fansNum;

/**
 *  3.6.接收返点通知回调
 *
 *  @param roomId      直播间ID
 *  @param rebateInfo  返点信息
 *
 */
- (void)onRecvRebateInfoNotice:(NSString* _Nonnull)roomId rebateInfo:(RebateInfoObject* _Nonnull) rebateInfo;

/**
 *  3.7.接收关闭直播间倒数通知回调
 *
 *  @param roomId      直播间ID
 *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
 *  @param err         错误码
 *  @param errMsg      错误描述
 *
 */
- (void)onRecvLeavingPublicRoomNotice:(NSString* _Nonnull)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg;


/**
 *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
 *
 *  @param roomId      直播间ID
 *  @param errType     踢出原因错误码
 *  @param errmsg      踢出原因描述
 *  @param credit      信用点
 *
 */
- (void)onRecvRoomKickoffNotice:(NSString* _Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString* _Nonnull)errmsg credit:(double)credit;

/**
 *  3.9.接收充值通知回调
 *
 *  @param roomId      直播间ID
 *  @param msg         充值提示
 *  @param credit      信用点
 *
 */
- (void)onRecvLackOfCreditNotice:(NSString* _Nonnull)roomId msg:(NSString* _Nonnull)msg credit:(double)credit;

/**
 *  3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）回调
 *
 *  @param roomId      直播间ID
 *  @param credit      信用点
 *
 */
- (void)onRecvCreditNotice:(NSString* _Nonnull)roomId credit:(double)credit;

/**
 *  3.11.直播间开播通知 回调
 *
 *  @param item  直播间开播通知结构体
 *
 */
- (void) onRecvWaitStartOverNotice:(ImStartOverRoomObject* _Nonnull)item;

/**
 *  3.12.接收观众／主播切换视频流通知接口 回调
 *
 *  @param roomId       房间ID
 *  @param isAnchor     是否是主播推流（1:是 0:否）
 *  @param playUrl      播放url
 *  @param userId       主播/观众ID（可无，仅在多人互动直播间才存在）
 *
 */
- (void)onRecvChangeVideoUrl:(NSString* _Nonnull)roomId  isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*>* _Nonnull)playUrl userId:(NSString* _Nonnull)userId;

#pragma mark - 直播间文本消息信息
/**
 *  4.1.发送直播间文本消息回调
 *
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;
/**
 *  4.2.接收直播间文本消息通知回调
 *
 *  @param roomId      直播间ID
 *  @param level       发送方级别
 *  @param fromId      发送方的用户ID
 *  @param nickName    发送方的昵称
 *  @param msg         文本消息内容
 *  @param honorUrl    勋章图片url
 *
 */
- (void)onRecvSendChatNotice:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg honorUrl:(NSString* _Nonnull)honorUrl;

/**
 *  4.3.接收直播间公告消息回调
 *
 *  @param roomId      直播间ID
 *  @param msg         公告消息内容
 *  @param link        公告链接（可无，无则表示不是带链接的公告消息）（仅当type=0有效）
 *  @param type        公告类型（0：普通，1：警告）
 *
 */
- (void)onRecvSendSystemNotice:(NSString* _Nonnull)roomId msg:(NSString* _Nonnull)msg link:(NSString* _Nonnull)link type:(IMSystemType)type;

#pragma mark - 直播间礼物消息操作回调
/**
 *  5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param errType       结果类型
 *  @param errmsg        结果描述
 *  @param credit        信用点
 *  @param rebateCredit  返点
 *
 */
- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;
/**
 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param giftId               礼物ID
 *  @param giftName             礼物名称
 *  @param giftNum              本次发送礼物的数量
 *  @param multi_click          是否连击礼物
 *  @param multi_click_start    连击起始数
 *  @param multi_click_end      连击结束数
 *  @param multi_click_id       连击ID，相同则表示是同一次连击
 *  @param honorUrl             勋章图片url
 *
 */
- (void)onRecvSendGiftNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString* _Nonnull)honorUrl;

#pragma mark - 直播间弹幕消息操作回调
/**
 *  6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param errType       结果类型
 *  @param errmsg        结果描述
 *  @param credit        信用点
 *  @param rebateCredit  返点
 *
 */
- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;
/**
 *  6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param msg                  消息内容
 *  @param honorUrl             勋章图片url
 *
 */
- (void)onRecvSendToastNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg honorUrl:(NSString* _Nonnull)honorUrl;

#pragma mark - 邀请私密直播
/**
 *  7.1.观众立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *  @param invitationId      邀请ID
 *  @param timeOut           邀请的剩余有效时间
 *  @param roomId            直播间ID
 *
 */
- (void) onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg invitationId:(NSString* _Nonnull)invitationId timeOut:(int)timeOut roomId:(NSString* _Nonnull)roomId;

/**
 *  7.2.观众取消立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *  @param roomId        直播间ID
 *
 */
- (void)onSendCancelPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg roomId:(NSString* _Nonnull)roomId;

/**
 *  7.3.接收立即私密邀请回复通知 回调
 *
 *  @param inviteId      邀请ID
 *  @param replyType     主播回复 （0:拒绝 1:同意）
 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *  @param roomType      直播间类型
 *  @param anchorId      主播ID
 *  @param nickName      主播昵称
 *  @param avatarImg     主播头像
 *  @param msg           提示文字
 *
 */
- (void)onRecvInstantInviteReplyNotice:(NSString* _Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString* _Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg;

/**
 *  7.4.接收主播立即私密邀请通知 回调
 *
 *  @param inviteId     邀请ID
 *  @param anchorId     主播ID
 *  @param nickName     主播昵称
 *  @param avatarImg    主播头像url
 *  @param msg          提示文字
 *
 */
- (void)onRecvInstantInviteUserNotice:(NSString* _Nonnull)inviteId anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg;

/**
 *  7.5.接收主播预约私密邀请通知 回调
 *
 *  @param inviteId     邀请ID
 *  @param anchorId     主播ID
 *  @param nickName     主播昵称
 *  @param avatarImg    主播头像url
 *  @param msg          提示文字
 *
 */
- (void)onRecvScheduledInviteUserNotice:(NSString* _Nonnull)inviteId anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg;;

/**
 *  7.6.接收预约私密邀请回复通知 回调
 *
 *  @param item     预约私密邀请回复知结构体
 *
 */
- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject* _Nonnull)item;

/**
 *  7.7.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param avatarImg    对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
- (void)onRecvBookingNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg  leftSeconds:(int)leftSeconds;

/**
 *  7.8.观众端是否显示主播立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *
 */
- (void)onSendInstantInviteUserReport:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg;
// ------------- 直播间才艺点播邀请 -------------
/**
 *  8.1.发送直播间才艺点播邀请 回调
 *
 *  @param success           操作是否成功
 *  @param reqId             请求序列号
 *  @param err               结果类型
 *  @param errMsg            结果描述
 *  @param talentInviteId    才艺邀请ID
 *  @param talentId          才艺ID
 *
 */
- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg talentInviteId:(NSString* _Nonnull)talentInviteId talentId:(NSString* _Nonnull)talentId;

/**
 *  8.2.接收直播间才艺点播回复通知 回调
 *
 *  @param item           才艺回复通知
 *
 */
- (void)onRecvSendTalentNotice:(ImTalentReplyObject* _Nonnull)item;

/**
 *  8.3.接收直播间才艺点播提示公告通知 回调
 *
 *  @param roomId          直播间ID
 *  @param introduction    公告描述
 *
 */
- (void)onRecvTalentPromptNotice:(NSString* _Nonnull)roomId introduction:(NSString* _Nonnull)introduction;

#pragma mark - 公共
/**
 *  9.1.观众等级升级通知 回调
 *
 *  @param level           当前等级
 *
 */
- (void)onRecvLevelUpNotice:(int)level;

/**
 *  9.2.观众亲密度升级通知
 *
 *  @param loveLevelItem           观众亲密度信息
 *
 */
- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *  _Nonnull)loveLevelItem;

/**
 *  9.3.背包更新通知
 *
 *  @param item          新增的背包礼物
 *
 */
- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject * _Nonnull)item;

/**
 *  9.4.观众勋章升级通知
 *
 *  @param honorId          勋章ID
 *  @param honorUrl         勋章图片url
 *
 */
- (void)onRecvGetHonorNotice:(NSString * _Nonnull)honorId honorUrl:(NSString * _Nonnull)honorUrl;

#pragma mark - 多人互动
/**
 *  10.1.接收主播推荐好友通知接口 回调
 *
 *  @param item         接收主播推荐好友通知
 *
 */
- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject * _Nonnull)item;

/**
 *  10.2.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject * _Nonnull)item;

/**
 *  10.3.观众新建/进入多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *  @param item        进入多人互动直播间信息
 *
 */
- (void)onEnterHangoutRoom:(SEQ_T)reqId succes:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg item:(IMHangoutRoomItemObject * _Nonnull)item;

/**
 *  10.4.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
- (void)onLeaveHangoutRoom:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg;

/**
 *  10.5.接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject * _Nonnull)item;

/**
 *  10.6.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject * _Nonnull)item;

/**
 *  10.7.发送多人互动直播间礼物消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param credit           信用点（浮点型）（若小于0，则表示信用点不变）
 *
 */
- (void)onSendHangoutGift:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg credit:(double)credit;

/**
 *  10.8.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject * _Nonnull)item;

/**
 *  10.9.接收主播敲门通知接口 回调
 *
 *  @param item         接收主播发起的敲门信息
 *
 */
- (void)onRecvKnockRequestNotice:(IMKnockRequestItemObject * _Nonnull)item;

/**
 *  10.10.接收多人互动余额不足导致主播将要离开的通知接口 回调
 *
 *  @param item         观众账号余额不足信息
 *
 */
- (void)onRecvLackCreditHangoutNotice:(IMLackCreditHangoutItemObject * _Nonnull)item;

/**
 *  10.11.多人互动观众开始/结束视频互动接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param manPushUrl       观众视频流url
 *
 */
- (void)onControlManPushHangout:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg manPushUrl:(NSArray<NSString*>* _Nonnull)manPushUrl;

/**
 *  10.12.发送多人互动直播间文本消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendHangoutLiveChat:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg;

/**
 *  10.13.接收直播间文本消息接口 回调
 *
 *  @param item         接收直播间文本消息
 *
 */
- (void)onRecvHangoutChatNotice:(IMRecvHangoutChatItemObject * _Nonnull)item;

/**
 *  10.14.接收进入多人互动直播间倒数通知接口 回调
 *
 *  @param roomId         待进入的直播间ID
 *  @param anchorId       主播ID
 *  @param leftSecond     进入直播间的剩余秒数
 *
 */
- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(NSString * _Nonnull)roomId anchorId:(NSString * _Nonnull)anchorId leftSecond:(int)leftSecond;

// ------------- 节目 -------------
/**
 *  11.1.接收节目开播通知接口 回调
 *
 *  @param item                     节目信息
 *  @param type                     通知类型（1：已购票的开播通知，2：仅关注的开播通知）
 *  @param msg                      消息提示文字
 *
 */
- (void)onRecvProgramPlayNotice:(IMProgramItemObject *_Nonnull)item type:(IMProgramNoticeType)type msg:(NSString * _Nonnull)msg;

/**
 *  11.2.接收节目已取消通知接口 回调
 *
 *  @param item         节目
 *
 */
- (void)onRecvCancelProgramNotice:(IMProgramItemObject *_Nonnull)item;

/**
 *  11.3.接收节目已退票通知接口 回调
 *
 *  @param item         节目
 *  @param leftCredit   当前余额
 *
 */
- (void)onRecvRetTicketNotice:(IMProgramItemObject *_Nonnull)item leftCredit:(double)leftCredit;

// ------------- 信件 -------------
/**
 *  13.1.接收意向信通知接口 回调
 *
 *  @param anchorId                  主播ID
 *  @param loiId                     意向信ID
 *
 */
- (void)onRecvLoiNotice:(NSString * _Nonnull)anchorId loiId:(NSString * _Nonnull)loiId;

/**
 *  13.2.接收EMF通知接口 回调
 *
 *  @param anchorId                  主播ID
 *  @param emfId                     信件ID
 *
 */
- (void)onRecvEMFNotice:(NSString * _Nonnull)anchorId emfId:(NSString * _Nonnull)emfId;

@end
