//
//  ZBImClientOC.m
//  ZBImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "ZBImClientOC.h"

#include "IZBImClient.h"

static ZBImClientOC *gClientOC = nil;
class ZBImClientCallback;

@interface ZBImClientOC () {
}

@property (nonatomic, assign) IZBImClient *client;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) ZBImClientCallback *imClientCallback;

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item        登录返回结构体
 */
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const ZBLoginReturnItem &)item;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

/**
 *  3.1.新建/进入公开直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param item         直播间信息
 *
 */
- (void)onZBPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const ZBRoomInfoItem &)item;

/**
 *  2.4.用户被挤掉线回调
 *
 */
- (void)onZBKickOff:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 直播间主动操作回调
/**
 *  3.2.观众进入直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item        直播间信息
 *
 */

- (void)onZBRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const ZBRoomInfoItem &)item;
/**
 *  3.3.观众退出直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onZBRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;
//
#pragma mark - 直播间接收操作回调
/**
 *  3.4.接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *
 */
- (void)onZBRecvRoomCloseNotice:(const string &)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

/**
 *  3.6.接收观众进入直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param riderId     座驾ID
 *  @param riderName   座驾名称
 *  @param riderUrl    座驾图片url
 *  @param fansNum     观众人数
 *  @param isHasTicket 是否已购票
 *
 */
- (void)onZBRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum isHasTicket:(bool)isHasTicket;

/**
 *  3.7.接收观众退出直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param fansNum   `观众人数
 *
 */
- (void)onZBRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum;
/**
 *  3.8.接收关闭直播间倒数通知回调
 *
 *  @param roomId      直播间ID
 *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
 *  @param err         错误码
 *  @param errMsg      倒数原因描述
 *
 */
- (void)onZBRecvLeavingPublicRoomNotice:(const string &)roomId leftSeconds:(int)leftSeconds err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg;

/**
 *  3.9.接收主播退出直播间通知回调
 *
 *  @param roomId       直播间ID
 *  @param anchorId     退出直播间的主播ID
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(const string &)roomId anchorId:(const string &)anchorId;

/**
 *  3.5.接收踢出直播间通知回调
 *
 *  @param roomId     直播间ID
 *  @param errType    踢出原因错误码
 *  @param errmsg     踢出原因描述
 *  @param credit     信用点
 *
 */
- (void)onZBRecvRoomKickoffNotice:(const string &)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;



#pragma mark - 直播间文本消息信息
/**
 *  4.1.发送直播间文本消息回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onZBSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;
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
- (void)onZBRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl;

/**
 *  4.3.接收直播间公告消息回调
 *
 *  @param roomId      直播间ID
 *  @param msg         公告消息内容
 *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
 *  @param type        公告类型（0：普通，1：警告）
 *
 */
- (void)onZBRecvSendSystemNotice:(const string &)roomId msg:(const string &)msg link:(const string &)link type:(ZBIMSystemType)type;

#pragma mark - 直播间礼物消息操作回调
/**
 *  5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param errType       结果类型
 *  @param errmsg        结果描述
 *
 */
- (void)onZBSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;
/**
 *  5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param giftId               礼物ID
 *  @param giftName             礼物名字
 *  @param giftNum              本次发送礼物的数量
 *  @param multi_click          是否连击礼物
 *  @param multi_click_start    连击起始数
 *  @param multi_click_end      连击结束数
 *  @param multi_click_id       连击ID相同则表示同一次连击
 *  @param honorUrl             勋章图片url
 *  @param totalCredit          总礼物价格
 */
- (void)onZBRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftName:(const string &)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(const string &)honorUrl totalCredit:(int)totalCredit;

#pragma mark - 直播间弹幕消息操作回调
/**
 *  6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param msg                  消息内容
 *  @param honorUrl             勋章图片url
 *
 */
- (void)onZBRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl;

// ------------- 直播间才艺点播邀请 -------------
/**
 *  7.1.接收直播间才艺点播邀请通知回调
 *  @param talentRequestItem             才艺点播请求
 *
 */
- (void)onZBRecvTalentRequestNotice:(const ZBTalentRequestItem&) talentRequestItem;

// ------------- 直播间视频互动 -------------
/**
 *  8.1.接收观众启动/关闭视频互动通知回调
 *
 *  @param Item            互动切换
 *
 */
- (void)onZBRecvControlManPushNotice:(const ZBControlPushItem&)item;



#pragma mark - 邀请私密直播
// ------------- 邀请私密直播 -------------
/**
 *  9.1.主播发送立即私密邀请 回调
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
- (void)onZBSendImmediatePrivateInvite:(BOOL)success reqId:(SEQ_T)reqId err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg invitationId:(const string &)invitationId timeOut:(int)timeOut roomId:(const string &)roomId;
/**
 *  9.2.接收立即私密邀请回复通知 回调
 *
 *  @param inviteId      邀请ID
 *  @param replyType     主播回复 （0:拒绝 1:同意）
 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *  @param roomType      直播间类型
 *  @param userId        观众ID
 *  @param nickName      主播昵称
 *  @param avatarImg     主播头像
 *
 */
- (void)onZBRecvInstantInviteReplyNotice:(const string &)inviteId replyType:(ZBReplyType)replyType roomId:(const string &)roomId roomType:(ZBRoomType)roomType userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg;
/**
 *  9.3.接收立即私密邀请通知 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     邀请ID
 *
 */
- (void)onZBRecvInstantInviteUserNotice:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl invitationId:(const string &)invitationId;


/**
 *  9.4.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param avatarImg    对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
- (void)onZBRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg leftSeconds:(int)leftSeconds;


/**
 *  9.5.获取指定立即私密邀请信息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param item             立即私密邀请
 *
 */
- (void)onZBGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const ZBPrivateInviteItem &)item;

/**
 *  9.6.接收观众接受预约通知接口 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     预约ID
 *  @param bookTime         预约时间（1970年起的秒数）
 */
- (void)onZBRecvInvitationAcceptNotice:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl invitationId:(const string &)invitationId bookTime:(long)bookTime;

#pragma mark - 多人互动直播间
// ------------- 多人互动直播间 -------------
/**
 *  10.1.进入多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *  @param item        进入多人互动直播间信息
 *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
 *
 */
- (void)onAnchorEnterHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const AnchorHangoutRoomItem&)item expire:(int)expire;

/**
 *  10.2.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
- (void)onAnchorLeaveHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg;

/**
 *  10.3.收观众邀请多人互动通知接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg       结果描述
 *  @param item         观众邀请多人互动信息
 */
- (void)onRecvAnchorInvitationHangoutNotice:(const AnchorHangoutInviteItem&)item;

/**
 *  10.4.接收推荐好友通知接口 回调
 *
 *  @param item         主播端接收自己推荐好友给观众的信息
 *
 */
- (void)onRecvAnchorRecommendHangoutNotice:(const IMAnchorRecommendHangoutItem&)item;

/**
 *  10.5.接收敲门回复通知接口 回调
 *
 *  @param item         接收敲门回复信息
 *
 */
- (void)onRecvAnchorDealKnockRequestNotice:(const IMAnchorKnockRequestItem&)item;

/**
 *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
 *
 *  @param item         接收观众邀请其它主播加入多人互动信息
 *
 */
- (void)onRecvAnchorOtherInviteNotice:(const IMAnchorRecvOtherInviteItem&)item;

/**
 *  10.7.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorDealInviteNotice:(const IMAnchorRecvDealInviteItem&)item;

/**
 *  10.8.观众端/主播端接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorEnterRoomNotice:(const IMAnchorRecvEnterRoomItem&)item;

/**
 *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(const IMAnchorRecvLeaveRoomItem&)item;

/**
 *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
 *
 *  @param roomId         直播间ID
 *  @param isAnchor       是否主播（0：否，1：是）
 *  @param userId         观众/主播ID
 *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
 *
 */
- (void)onRecvAnchorChangeVideoUrl:(const string&)roomId isAnchor:(bool)isAnchor userId:(const string&)userId playUrl:(const list<string>&)playUrl;

/**
 *  10.11.发送多人互动直播间礼物消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendAnchorHangoutGift:(SEQ_T)reqId success:(bool)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg;

/**
 *  10.12.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
- (void)onRecvAnchorGiftNotice:(const IMAnchorRecvGiftItem&)item;

/**
 *  10.13.接收多人互动直播间观众启动/关闭视频互动通知回调
 *
 *  @param Item            互动切换
 *
 */
- (void)onRecvAnchorControlManPushHangoutNotice:(const ZBControlPushItem&)item;

/**
 *  10.14.发送多人互动直播间文本消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendAnchorHangoutLiveChat:(SEQ_T)reqId success:(bool)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg;

/**
 *  10.15.接收直播间文本消息回调
 *
 *  @param item            接收直播间的文本消息
 *
 */
-(void)onRecvAnchorHangoutChatNotice:(const IMAnchorRecvHangoutChatItem&)item;

#pragma mark - 节目
// ------------- 节目 -------------
/**
 *  11.1.接收节目开播通知接口 回调
 *
 *  @param item         节目信息
 *  @param msg          消息提示文字
 *
 */
- (void)onRecvAnchorProgramPlayNotice:(const IMAnchorProgramInfoItem&)item msg:(const string&)msg;

/**
 *  11.2.接收节目状态改变通知接口 回调
 *
 *  @param item         节目信息
 *
 */
- (void)onRecvAnchorChangeStatusNotice:(const IMAnchorProgramInfoItem&)item;

/**
 *  11.3.接收无操作的提示通知接口 回调
 *
 *  @param backgroundUrl    背景图url
 *  @param msg           描述
 *
 */
- (void)onRecvAnchorShowMsgNotice:(const string&)backgroundUrl msg:(const string&)msg;

@end

class ZBImClientCallback : public IZBImClientListener {
  public:
    ZBImClientCallback(ZBImClientOC *clientOC) {
        this->clientOC = clientOC;
    };
    virtual ~ZBImClientCallback(){};

  public:
    virtual void OnZBLogin(ZBLCC_ERR_TYPE err, const string &errmsg, const ZBLoginReturnItem &item) {
        if (nil != clientOC) {
            [clientOC onZBLogin:err errMsg:errmsg item:item];
        }
    }
    virtual void OnZBLogout(ZBLCC_ERR_TYPE err, const string &errmsg) {
        if (nil != clientOC) {
            [clientOC onZBLogout:err errMsg:errmsg];
        }
    }
    virtual void OnZBKickOff(ZBLCC_ERR_TYPE err, const string &errmsg) {
        if (nil != clientOC) {
            [clientOC onZBKickOff:err errMsg:errmsg];
        }
    }
    virtual void OnZBRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg, const ZBRoomInfoItem &item) {
        if (nil != clientOC) {
            [clientOC onZBRoomIn:success reqId:reqId errType:err errMsg:errMsg item:item];
        }
    }
    virtual void OnZBRoomOut(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBRoomOut:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    
    // 4.1.发送直播间文本消息
    virtual void OnZBSendLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBSendLiveChat:success reqId:reqId errType:err errMsg:errMsg];
        }
    }

    virtual void OnZBRecvRoomCloseNotice(const string &roomId, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBRecvRoomCloseNotice:roomId errType:err errMsg:errMsg];
        }
    }
    
 // 3.6.接收观众进入直播间通知
    virtual void OnZBRecvEnterRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, const string &riderId, const string &riderName, const string &riderUrl, int fansNum, bool isHasTicket) {
        if (nil != clientOC) {
            [clientOC onZBRecvEnterRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl riderId:riderId riderName:riderName riderUrl:riderUrl fansNum:fansNum isHasTicket:isHasTicket];
        }
    }
    // 3.7.接收观众退出直播间通知
    virtual void OnZBRecvLeaveRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, int fansNum) {
        if (nil != clientOC) {
            [clientOC onZBRecvLeaveRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl fansNum:fansNum];
        }
    }

    // 3.8.接收关闭直播间倒数通知
    virtual void OnZBRecvLeavingPublicRoomNotice(const string &roomId, int leftSeconds, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBRecvLeavingPublicRoomNotice:roomId leftSeconds:leftSeconds err:err errMsg:errMsg];
        }
    }
    // 3.5.接收踢出直播间通知
    virtual void OnZBRecvRoomKickoffNotice(const string &roomId, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBRecvRoomKickoffNotice:roomId errType:err errMsg:errMsg];
        }
    }

    /**
     *  3.9.接收主播退出直播间通知回调
     *
     *  @param roomId       直播间ID
     *  @param anchorId     退出直播间的主播ID
     *
     */
    virtual void OnRecvAnchorLeaveRoomNotice(const string& roomId, const string& anchorId) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorLeaveRoomNotice:roomId anchorId:anchorId];
        }
    }

    /**
     *  3.1.新建/进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param item         直播间信息
     *
     */
    virtual void OnZBPublicRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg, const ZBRoomInfoItem &item) {
        if (nil != clientOC) {
            [clientOC onZBPublicRoomIn:reqId success:success err:err errMsg:errMsg item:item];
        }
    }

    virtual void OnZBRecvSendChatNotice(const string &roomId, int level, const string &fromId, const string &nickName, const string &msg, const string &honorUrl) {
        if (nil != clientOC) {
            [clientOC onZBRecvSendChatNotice:roomId level:level fromId:fromId nickName:nickName msg:msg honorUrl:honorUrl];
        }
    }
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）（仅当type=0有效）
     *  @param type        公告类型（0：普通，1：警告）
     *
     */
    virtual void OnZBRecvSendSystemNotice(const string &roomId, const string &msg, const string &link, ZBIMSystemType type) {
        if (nil != clientOC) {
            [clientOC onZBRecvSendSystemNotice:roomId msg:msg link:link type:type];
        }
    }


    // ------------- 直播间点赞 -------------
    // 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnZBSendGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg) {
        if (nil != clientOC) {
            [clientOC onZBSendGift:success reqId:reqId errType:err errMsg:errMsg];
        }
    }

    // 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnZBRecvSendGiftNotice(const string &roomId, const string &fromId, const string &nickName, const string &giftId, const string &giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string &honorUrl, int totalCredit) {
        if (nil != clientOC) {
            [clientOC onZBRecvSendGiftNotice:roomId fromId:fromId nickName:nickName giftId:giftId giftName:giftName giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id honorUrl:honorUrl totalCredit:totalCredit];
        }
    }

    // ------------- 直播间弹幕消息 -------------
    // 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnZBRecvSendToastNotice(const string &roomId, const string &fromId, const string &nickName, const string &msg, const string &honorUrl) {
        if (nil != clientOC) {
            [clientOC onZBRecvSendToastNotice:roomId fromId:fromId nickName:nickName msg:msg honorUrl:honorUrl];
        }
    }
    
    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  7.1.接收直播间才艺点播邀请通知回调
     *
     *  @param talentRequestItem             才艺点播请求
     *
     */
    virtual void OnZBRecvTalentRequestNotice(const ZBTalentRequestItem talentRequestItem) {
        if (nil != clientOC) {
            [clientOC onZBRecvTalentRequestNotice:talentRequestItem];
        }
    }
    
    // ------------- 直播间视频互动 -------------
    /**
     *  8.1.接收观众启动/关闭视频互动通知回调
     *
     *  @param Item            互动切换
     *
     */
    virtual void OnZBRecvControlManPushNotice(const ZBControlPushItem item) {
        if (nil != clientOC) {
            [clientOC onZBRecvControlManPushNotice:item];
        }
    }
    

    // ------------- 邀请私密直播 -------------
    /**
     *  9.1.邀请私密直播 回调
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
    virtual void OnZBSendPrivateLiveInvite(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg, const string &invitationId, int timeOut, const string &roomId) {
        if (nil != clientOC) {
            [clientOC onZBSendImmediatePrivateInvite:success reqId:reqId err:err errMsg:errMsg invitationId:invitationId timeOut:timeOut roomId:roomId];
        }
    }

    /**
     *  9.2.接收立即私密邀请回复通知 回调
     *
     *  @param inviteId      邀请ID
     *  @param replyType     主播回复 （0:拒绝 1:同意）
     *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
     *  @param roomType      直播间类型
     *  @param userId        观众ID
     *  @param nickName      主播昵称
     *  @param avatarImg     主播头像
     *
     */
    virtual void OnZBRecvInstantInviteReplyNotice(const string &inviteId, ZBReplyType replyType, const string &roomId, ZBRoomType roomType, const string &userId, const string &nickName, const string &avatarImg) {
        if (nil != clientOC) {
            [clientOC onZBRecvInstantInviteReplyNotice:inviteId replyType:replyType roomId:roomId roomType:roomType userId:userId nickName:nickName avatarImg:avatarImg];
        }
    }

    /**
     *  9.3.接收立即私密邀请通知 回调
     *
     *  @param userId           观众ID
     *  @param nickName         观众昵称
     *  @param photoUrl         观众头像url
     *  @param invitationId     邀请ID
     *
     */
    virtual void OnZBRecvInstantInviteUserNotice(const string& userId, const string& nickName, const string& photoUrl ,const string& invitationId) {
        if (nil != clientOC) {
            [clientOC onZBRecvInstantInviteUserNotice:userId nickName:nickName photoUrl:photoUrl invitationId:invitationId];
        }
    }

    /**
     *  9.4.接收预约开始倒数通知 回调
     *
     *  @param roomId       直播间ID
     *  @param userId       对端ID
     *  @param nickName     对端昵称
     *  @param avatarImg    对端头像url
     *  @param leftSeconds  倒数时间（秒）
     *
     */
    virtual void OnZBRecvBookingNotice(const string &roomId, const string &userId, const string &nickName, const string &avatarImg, int leftSeconds) {
        if (nil != clientOC) {
            [clientOC onZBRecvBookingNotice:roomId userId:userId nickName:nickName avatarImg:avatarImg leftSeconds:leftSeconds];
        }
    }
    
    /**
     *  9.5.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       直播间信息
     *
     */
    virtual void OnZBGetInviteInfo(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string &errMsg, const ZBPrivateInviteItem &item) {
        if (nil != clientOC) {
            [clientOC onZBGetInviteInfo:reqId success:success err:err errMsg:errMsg item:item];
        }
    };

    /**
     *  9.6.接收观众接受预约通知接口 回调
     *
     *  @param userId           观众ID
     *  @param nickName         观众昵称
     *  @param photoUrl         观众头像url
     *  @param invitationId     预约ID
     *  @param bookTime         预约时间（1970年起的秒数）
     */
    virtual void OnZBRecvInvitationAcceptNotice(const string& userId, const string& nickName, const string& photoUrl, const string& invitationId, long bookTime) {
        if (nil != clientOC) {
            [clientOC onZBRecvInvitationAcceptNotice:userId nickName:nickName photoUrl:photoUrl invitationId:invitationId bookTime:bookTime];
        }
    };

    // ------------- 多人互动直播间 -------------
    /**
     *  10.1.进入多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item        进入多人互动直播间信息
     *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
     *
     */
    virtual void OnAnchorEnterHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const AnchorHangoutRoomItem& item, int expire) {
        if (nil != clientOC) {
            [clientOC onAnchorEnterHangoutRoom:reqId success:success err:err errMsg:errMsg item:item expire:expire];
        }
    };

    /**
     *  10.2.退出多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item        进入多人互动直播间信息
     *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
     *
     */
    virtual void OnAnchorLeaveHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
        if (nil != clientOC) {
            [clientOC onAnchorLeaveHangoutRoom:reqId success:success err:err errMsg:errMsg];
        }
    };

    /**
     *  10.3.接收观众邀请多人互动通知接口 回调
     *
     *  @param item         观众邀请多人互动信息
     *
     */
    virtual void OnRecvAnchorInvitationHangoutNotice(const AnchorHangoutInviteItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorInvitationHangoutNotice:item];
        }
    };

    /**
     *  10.4.接收推荐好友通知接口 回调
     *
     *  @param item         主播端接收自己推荐好友给观众的信息
     *
     */
    virtual void OnRecvAnchorRecommendHangoutNotice(const IMAnchorRecommendHangoutItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorRecommendHangoutNotice:item];
        }
    };

    /**
     *  10.5.接收敲门回复通知接口 回调
     *
     *  @param item         接收敲门回复信息
     *
     */
    virtual void OnRecvAnchorDealKnockRequestNotice(const IMAnchorKnockRequestItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorDealKnockRequestNotice:item];
        }
    };

    /**
     *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
     *
     *  @param item         接收观众邀请其它主播加入多人互动信息
     *
     */
    virtual void OnRecvAnchorOtherInviteNotice(const IMAnchorRecvOtherInviteItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorOtherInviteNotice:item];
        }
    };

    /**
     *  10.7.接收主播回复观众多人互动邀请通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    virtual void OnRecvAnchorDealInviteNotice(const IMAnchorRecvDealInviteItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorDealInviteNotice:item];
        }
    };

    /**
     *  10.8.观众端/主播端接收观众/主播进入多人互动直播间通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    virtual void OnRecvAnchorEnterRoomNotice(const IMAnchorRecvEnterRoomItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorEnterRoomNotice:item];
        }
    };

    /**
     *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
     *
     *  @param item         接收观众/主播退出多人互动直播间信息
     *
     */
    virtual void OnRecvAnchorLeaveRoomNotice(const IMAnchorRecvLeaveRoomItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorLeaveRoomNotice:item];
        }
    };

    /**
     *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
     *
     *  @param roomId         直播间ID
     *  @param isAnchor       是否主播（0：否，1：是）
     *  @param userId         观众/主播ID
     *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
     *
     */
    virtual void OnRecvAnchorChangeVideoUrl(const string& roomId, bool isAnchor, const string& userId, const list<string>& playUrl) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorChangeVideoUrl:roomId isAnchor:isAnchor userId:userId playUrl:playUrl];
        }
    };

    /**
     *  10.11.发送多人互动直播间礼物消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *
     */
    virtual void OnSendAnchorHangoutGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
        if (nil != clientOC) {
            [clientOC onSendAnchorHangoutGift:reqId success:success err:err errMsg:errMsg];
        }
    };

    /**
     *  10.12.接收多人互动直播间礼物通知接口 回调
     *
     *  @param item         接收多人互动直播间礼物信息
     *
     */
    virtual void OnRecvAnchorGiftNotice(const IMAnchorRecvGiftItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorGiftNotice:item];
        }
    };
    
    /**
     *  10.13.接收多人互动直播间观众启动/关闭视频互动通知回调
     *
     *  @param Item            互动切换
     *
     */
    virtual void OnRecvAnchorControlManPushHangoutNotice(const ZBControlPushItem item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorControlManPushHangoutNotice:item];
        }
    };
    
    /**
     *  10.14.发送多人互动直播间文本消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *
     */
    virtual void OnSendAnchorHangoutLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
        if (nil != clientOC) {
            [clientOC onSendAnchorHangoutLiveChat:reqId success:success err:err errMsg:errMsg];
        }
    };
    
    /**
     *  10.15.接收直播间文本消息回调
     *
     *  @param item            接收直播间的文本消息
     *
     */
    virtual void OnRecvAnchorHangoutChatNotice(const IMAnchorRecvHangoutChatItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorHangoutChatNotice:item];
        }
    };
    
    // ------------- 节目 -------------
    /**
     *  11.1.接收节目开播通知接口 回调
     *
     *  @param item         节目信息
     *
     */
    virtual void OnRecvAnchorProgramPlayNotice(const IMAnchorProgramInfoItem& item, const string& msg) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorProgramPlayNotice:item msg:msg];
        }
    };
    
    /**
     *  11.2.接收节目状态改变通知接口 回调
     *
     *  @param item         节目信息
     *
     */
    virtual void OnRecvAnchorChangeStatusNotice(const IMAnchorProgramInfoItem& item) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorChangeStatusNotice:item];
        }
    };
    
    /**
     *  11.3.接收无操作的提示通知接口 回调
     *
     *  @param backgroundUrl    背景图url
     *  @param msg              描述
     *
     */
    virtual void OnRecvAnchorShowMsgNotice(const string& backgroundUrl, const string& msg) {
        if (nil != clientOC) {
            [clientOC onRecvAnchorShowMsgNotice:backgroundUrl msg:msg];
        }
    };

  private:
    __weak typeof(ZBImClientOC *) clientOC;
};

@implementation ZBImClientOC

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gClientOC == nil) {
        gClientOC = [[[self class] alloc] init];
    }
    return gClientOC;
}

- (instancetype _Nullable)init {
    self = [super init];
    if (nil != self) {
        self.delegates = [NSMutableArray array];
        self.client = IZBImClient::CreateClient();
        self.imClientCallback = new ZBImClientCallback(self);
        self.client->AddListener(self.imClientCallback);
    }
    return self;
}

- (void)dealloc {
    if (self.client) {
        if (self.imClientCallback) {
            self.client->RemoveListener(self.imClientCallback);
            delete self.imClientCallback;
            self.imClientCallback = NULL;
        }

        IZBImClient::ReleaseClient(self.client);
        self.client = NULL;
    }
}

- (BOOL)addDelegate:(id<ZBIMLiveRoomManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    NSLog(@"ZBZBImClientOC::addDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> item = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"ZBImClientOC::addDelegate() add again, delegate:<%@>", delegate);
                result = YES;
                break;
            }
        }

        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }

    return result;
}

- (BOOL)removeDelegate:(id<ZBIMLiveRoomManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    NSLog(@"ZBImClientOC::removeDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> item = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    // log
    if (!result) {
        NSLog(@"ZBZBImClientOC::removeDelegate() fail, delegate:<%@>", delegate);
    }

    return result;
}

- (SEQ_T)getReqId {
    SEQ_T reqId = 0;
    if (NULL != self.client) {
        reqId = self.client->GetReqId();
    }
    return reqId;
}

- (BOOL)initClient:(NSArray<NSString *> *_Nonnull)urls {
    BOOL result = NO;
    if (NULL != self.client) {
        list<string> strUrls;
        for (NSString *url in urls) {
            if (nil != url) {
                strUrls.push_back([url UTF8String]);
            }
        }
        result = self.client->Init(strUrls);
    }
    return result;
}

- (BOOL)anchorLogin:(NSString *_Nonnull)token pageName:(ZBPageNameType)pageName {
    BOOL result = NO;
    if (NULL != self.client) {

        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }

        result = self.client->ZBLogin(strToken, pageName);
    }
    return result;
}

- (BOOL)anchorLogout {
    BOOL result = NO;
    if (NULL != self.client) {
        result = self.client->ZBLogout();
    }
    return result;
}

- (BOOL)anchorRoomIn:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->ZBRoomIn(reqId, strRoomId);
    }
    return result;
}

- (BOOL)anchorRoomOut:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->ZBRoomOut(reqId, strRoomId);
    }
    return result;
}

- (BOOL)anchorPublicRoomIn:(SEQ_T)reqId {
    BOOL result = NO;
    if (NULL != self.client) {

        result = self.client->ZBPublicRoomIn(reqId);
    }
    return result;
}

- (BOOL)anchorSendLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strName;
        if (nil != nickName) {
            strName = [nickName UTF8String];
        }
        string strMsg;
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }

        list<string> strAts;
        for (NSString *strId in at) {
            if (nil != strId) {
                strAts.push_back([strId UTF8String]);
            }
        }

        result = self.client->ZBSendLiveChat(reqId, strRoomId, strName, strMsg, strAts);
    }
    return result;
}

- (BOOL)anchorSendGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        string strNickName;
        if (nil != nickName) {
            strNickName = [nickName UTF8String];
        }

        string strGiftId;
        if (nil != giftId) {
            strGiftId = [giftId UTF8String];
        }

        string strGiftName;
        if (nil != giftName) {
            strGiftName = [giftName UTF8String];
        }

        result = self.client->ZBSendGift(reqId, strRoomId, strNickName, strGiftId, strGiftName, isBackPack, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    }
    return result;
}

- (BOOL)anchorSendImmediatePrivateInvite:(SEQ_T)reqId userId:(NSString *)userId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strUserId;
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }

        result = self.client->ZBSendPrivateLiveInvite(reqId, strUserId);
    }

    return result;
}

- (BOOL)anchorGetInviteInfo:(SEQ_T)reqId invitationId:(NSString *_Nonnull)invitationId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strInvitationId;
        if (nil != invitationId) {
            strInvitationId = [invitationId UTF8String];
        }
        
        result = self.client->ZBGetInviteInfo(reqId, strInvitationId);
    }
    return result;
}


-(BOOL)anchorEnterHangoutRoom:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->AnchorEnterHangoutRoom(reqId, strRoomId);
    }
    return result;
}

-(BOOL)anchorLeaveHangoutRoom:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->AnchorLeaveHangoutRoom(reqId, strRoomId);
    }
    return result;
}

-(BOOL)anchorSendHangoutGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName toUid:(NSString *_Nonnull)toUid giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate{
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strNickName = "";
        if (nil != nickName) {
            strNickName = [nickName UTF8String];
        }
        string strToUid = "";
        if (nil != toUid) {
            strToUid = [toUid UTF8String];
        }
        string strGiftId = "";
        if (nil != giftId) {
            strGiftId = [giftId UTF8String];
        }
        string strGiftName = "";
        if (nil != giftName) {
            strGiftName = [giftName UTF8String];
        }
        
        result = self.client->SendAnchorHangoutGift(reqId, strRoomId, strNickName, strToUid, strGiftId, strGiftName, isBackPack, giftNum, isMultiClick, multiClickStart, multiClickEnd, multiClickId, isPrivate);
    }
    return result;
}

/**
 *  10.14.发送多人互动直播间文本消息
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *  @param nickName      发送者昵称
 *  @param msg           发送的信息
 *  @param at           用户ID，用于指定接收者（字符串数组）
 *
 */
- (BOOL)anchorSendHangoutLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strName;
        if (nil != nickName) {
            strName = [nickName UTF8String];
        }
        string strMsg;
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }
        
        list<string> strAts;
        for (NSString *strId in at) {
            if (nil != strId) {
                strAts.push_back([strId UTF8String]);
            }
        }
        
        result = self.client->SendAnchorHangoutLiveChat(reqId, strRoomId, strName, strMsg, strAts);
    }
    return result;
}

#pragma mark - 登录/注销回调

- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const ZBLoginReturnItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ZBImLoginReturnObject *obj = [[ZBImLoginReturnObject alloc] init];
    NSMutableArray *nsRoomList = [NSMutableArray array];
    for (ZBLSLoginRoomList::const_iterator iter = item.roomList.begin(); iter != item.roomList.end(); iter++) {
        ZBImLoginRoomObject *roomItem = [[ZBImLoginRoomObject alloc] init];
        roomItem.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
        roomItem.roomType = (*iter).roomType;
        [nsRoomList addObject:roomItem];
    }
    obj.roomList = nsRoomList;

    NSMutableArray *nsInviteList = [NSMutableArray array];
    for (ZBInviteList::const_iterator iter = item.inviteList.begin(); iter != item.inviteList.end(); iter++) {
        ZBImInviteIdItemObject *inviteIdItem = [[ZBImInviteIdItemObject alloc] init];
        inviteIdItem.invitationId = [NSString stringWithUTF8String:(*iter).invitationId.c_str()];
        inviteIdItem.oppositeId = [NSString stringWithUTF8String:(*iter).oppositeId.c_str()];
        inviteIdItem.oppositeNickName = [NSString stringWithUTF8String:(*iter).oppositeNickName.c_str()];
        inviteIdItem.oppositePhotoUrl = [NSString stringWithUTF8String:(*iter).oppositePhotoUrl.c_str()];
        inviteIdItem.oppositeLevel = (*iter).oppositeLevel;
        inviteIdItem.oppositeAge = (*iter).oppositeAge;
        inviteIdItem.oppositeCountry = [NSString stringWithUTF8String:(*iter).oppositeCountry.c_str()];
        inviteIdItem.read = (*iter).read;
        inviteIdItem.inviTime = (*iter).inviTime;
        inviteIdItem.replyType = (*iter).replyType;
        inviteIdItem.validTime = (*iter).validTime;
        inviteIdItem.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
        [nsInviteList addObject:inviteIdItem];
    }
    obj.inviteList = nsInviteList;

    NSMutableArray *nsScheduleRoomList = [NSMutableArray array];
    for (ZBScheduleRoomList::const_iterator iter = item.scheduleRoomList.begin(); iter != item.scheduleRoomList.end(); iter++) {
        ZBImScheduleRoomObject *scheduleRoom = [[ZBImScheduleRoomObject alloc] init];
        scheduleRoom.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
        scheduleRoom.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
        scheduleRoom.anchorImg = [NSString stringWithUTF8String:(*iter).anchorImg.c_str()];
        scheduleRoom.anchorCoverImg = [NSString stringWithUTF8String:(*iter).anchorCoverImg.c_str()];
        scheduleRoom.canEnterTime = (*iter).canEnterTime;
        scheduleRoom.leftSeconds = (*iter).leftSeconds;
        scheduleRoom.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
        [nsScheduleRoomList addObject:scheduleRoom];
    }
    obj.scheduleRoomList = nsScheduleRoomList;

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBLogin:errMsg:item:)]) {
                [delegate onZBLogin:errType errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBLogout:errMsg:)]) {
                [delegate onZBLogout:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onZBKickOff:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBKickOff:errMsg:)]) {
                [delegate onZBKickOff:errType errMsg:nsErrMsg];
            }
        }
    }
}

//#pragma mark - 直播间主动操作回调
- (void)onZBPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const ZBRoomInfoItem &)item {
        NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
        ZBImLiveRoomObject *obj = [[ZBImLiveRoomObject alloc] init];
        obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
        obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
        obj.roomType = item.roomType;
        obj.liveShowType = item.liveShowType;
        NSMutableArray *nsManPushUrl = [NSMutableArray array];
        for (list<string>::const_iterator iter = item.pushUrl.begin(); iter != item.pushUrl.end(); iter++) {
            string strUrl = (*iter);
            NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
            [nsManPushUrl addObject:pushUrl];
        }
        obj.pushUrl = nsManPushUrl;
        obj.leftSeconds = item.leftSeconds;
        obj.maxFansiNum = item.maxFansiNum;
        obj.status = item.status;
        @synchronized(self) {
            for (NSValue *value in self.delegates) {
                id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onZBPublicRoomIn:success:err:errMsg:item:)]) {
                    [delegate onZBPublicRoomIn:reqId success:success err:err errMsg:nsErrMsg item:obj];
                }
            }
        }
}


- (void)onZBRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const ZBRoomInfoItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ZBImLiveRoomObject *obj = [[ZBImLiveRoomObject alloc] init];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.roomType = item.roomType;
    obj.liveShowType = item.liveShowType;
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.pushUrl.begin(); iter != item.pushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    obj.pushUrl = nsManPushUrl;
    obj.leftSeconds = item.leftSeconds;
    
    obj.maxFansiNum = item.maxFansiNum;
    NSMutableArray *nsManPullUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.pullUrl.begin(); iter != item.pullUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pullUrl];
    }
    obj.pullUrl = nsManPullUrl;
    obj.status = item.status;
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRoomIn:reqId:errType:errMsg:item:)]) {
                [delegate onZBRoomIn:success reqId:reqId errType:errType errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onZBRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRoomOut:reqId:errType:errMsg:)]) {
                [delegate onZBRoomOut:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}


#pragma mark - 直播间接收操作回调

- (void)onZBRecvRoomCloseNotice:(const string &)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvRoomCloseNotice:errType:errMsg:)]) {
                [delegate onZBRecvRoomCloseNotice:nsRoomId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onZBRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum isHasTicket:(bool)isHasTicket {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    NSString *nsRiderId = [NSString stringWithUTF8String:riderId.c_str()];
    NSString *nsRiderName = [NSString stringWithUTF8String:riderName.c_str()];
    NSString *nsRiderUrl = [NSString stringWithUTF8String:riderUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvEnterRoomNotice:userId:nickName:photoUrl:riderId:riderName:riderUrl:fansNum:isHasTicket:)]) {
                [delegate onZBRecvEnterRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl riderId:nsRiderId riderName:nsRiderName riderUrl:nsRiderUrl fansNum:fansNum isHasTicket:isHasTicket];
            }
        }
    }
}

- (void)onZBRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvLeaveRoomNotice:userId:nickName:photoUrl:fansNum:)]) {
                [delegate onZBRecvLeaveRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl fansNum:fansNum];
            }
        }
    }
}

// 3.8.接收关闭直播间倒数通知
- (void)onZBRecvLeavingPublicRoomNotice:(const string &)roomId leftSeconds:(int)leftSeconds err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvLeavingPublicRoomNotice:leftSeconds:err:errMsg:)]) {
                [delegate onZBRecvLeavingPublicRoomNotice:nsRoomId leftSeconds:leftSeconds err:err errMsg:nsErrMsg];
            }
        }
    }
}

/**
 *  3.9.接收主播退出直播间通知回调
 *
 *  @param roomId       直播间ID
 *  @param anchorId     退出直播间的主播ID
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(const string &)roomId anchorId:(const string &)anchorId {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorLeaveRoomNotice:anchorId:)]) {
                [delegate onRecvAnchorLeaveRoomNotice:nsRoomId anchorId:nsAnchorId];
            }
        }
    }
}

- (void)onZBRecvRoomKickoffNotice:(const string &)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvRoomKickoffNotice:errType:errmsg:)]) {
                [delegate onZBRecvRoomKickoffNotice:nsRoomId errType:errType errmsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 直播间文本消息信息
- (void)onZBSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBSendLiveChat:reqId:errType:errMsg:)]) {
                [delegate onZBSendLiveChat:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onZBRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg  honorUrl:(const string &)honorUrl{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvSendChatNotice:level:fromId:nickName:msg:honorUrl:)]) {
                [delegate onZBRecvSendChatNotice:nsRoomId level:level fromId:nsFromId nickName:nsNickName msg:nsMsg honorUrl:nsHonorUrl];
            }
        }
    }
}

- (void)onZBRecvSendSystemNotice:(const string &)roomId msg:(const string &)msg link:(const string &)link type:(ZBIMSystemType)type{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsLink = [NSString stringWithUTF8String:link.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvSendSystemNotice:msg:link:type:)]) {
                [delegate onZBRecvSendSystemNotice:nsRoomId msg:nsMsg link:nsLink type:type];
            }
        }
    }
}

#pragma mark - 直播间礼物消息操作回调

- (void)onZBSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBSendGift:reqId:errType:errMsg:)]) {
                [delegate onZBSendGift:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onZBRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftName:(const string &)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(const string &)honorUrl totalCredit:(int)totalCredit;
{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsGigtId = [NSString stringWithUTF8String:giftId.c_str()];
    NSString *nsGigtName = [NSString stringWithUTF8String:giftName.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvSendGiftNotice:fromId:nickName:giftId:giftName:giftNum:multi_click:multi_click_start:multi_click_end:multi_click_id:honorUrl:totalCredit:)]) {
                [delegate onZBRecvSendGiftNotice:nsRoomId fromId:nsFromId nickName:nsNickName giftId:nsGigtId giftName:nsGigtName giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id honorUrl:nsHonorUrl totalCredit:totalCredit];
            }
        }
    }
}

#pragma mark - 直播间弹幕消息操作回调

- (void)onZBRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvSendToastNotice:fromId:nickName:msg:honorUrl:)]) {
                [delegate onZBRecvSendToastNotice:nsRoomId fromId:nsFromId nickName:nsNickName msg:nsMsg honorUrl:nsHonorUrl];
            }
        }
    }
}


// ------------- 直播间才艺点播邀请 -------------
/**
 *  7.1.接收直播间才艺点播邀请通知回调
 *  @param talentRequestItem             才艺点播请求
 *
 */
- (void)onZBRecvTalentRequestNotice:(const ZBTalentRequestItem&)talentRequestItem {
    ZBImTalentRequestObject * obj = [[ZBImTalentRequestObject alloc] init];
    obj.talentInviteId = [NSString stringWithUTF8String:talentRequestItem.talentInviteId.c_str()];
    obj.name = [NSString stringWithUTF8String:talentRequestItem.name.c_str()];
    obj.userId = [NSString stringWithUTF8String:talentRequestItem.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:talentRequestItem.nickName.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvTalentRequestNotice:)]) {
                [delegate onZBRecvTalentRequestNotice:obj];
            }
        }
    }
}

// ------------- 直播间视频互动 -------------
/**
 *  8.1.接收观众启动/关闭视频互动通知回调
 *
 *  @param Item            互动切换
 *
 */
- (void)onZBRecvControlManPushNotice:(const ZBControlPushItem&)item {
    ZBImControlPushItemObject * obj = [[ZBImControlPushItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
    obj.control = item.control;
    
    NSMutableArray *nsManVideoUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.manVideoUrl.begin(); iter != item.manVideoUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManVideoUrl addObject:pullUrl];
    }
    obj.manVideoUrl = nsManVideoUrl;
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvControlManPushNotice:)]) {
                [delegate onZBRecvControlManPushNotice:obj];
            }
        }
    }
}

#pragma mark - 邀请私密直播

// ------------- 邀请私密直播 -------------
// 9.1.主播发送立即私密邀请
- (void)onZBSendImmediatePrivateInvite:(BOOL)success reqId:(SEQ_T)reqId err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg invitationId:(const string &)invitationId timeOut:(int)timeOut roomId:(const string &)roomId {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString *nsInvitationId = [NSString stringWithUTF8String:invitationId.c_str()];
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBSendImmediatePrivateInvite:reqId:err:errMsg:invitationId:timeOut:roomId:)]) {
                [delegate onZBSendImmediatePrivateInvite:success reqId:reqId err:err errMsg:nsErrMsg invitationId:nsInvitationId timeOut:timeOut roomId:nsRoomId];
            }
        }
    }
}


//9.2.接收立即私密邀请回复通知
- (void)onZBRecvInstantInviteReplyNotice:(const string &)inviteId replyType:(ZBReplyType)replyType roomId:(const string &)roomId roomType:(ZBRoomType)roomType userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg {
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvInstantInviteReplyNotice:replyType:roomId:roomType:userId:nickName:avatarImg:)]) {
                [delegate onZBRecvInstantInviteReplyNotice:nsInviteId replyType:replyType roomId:nsRoomId roomType:roomType userId:nsUserId nickName:nsNickName avatarImg:nsAvatarImg];
            }
        }
    }
}

/**
*  9.3.接收立即私密邀请通知 回调
*
*  @param userId           观众ID
*  @param nickName         观众昵称
*  @param photoUrl         观众头像url
*  @param invitationId     邀请ID
*
*/
- (void)onZBRecvInstantInviteUserNotice:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl invitationId:(const string &)invitationId {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    NSString *nsInvitationId = [NSString stringWithUTF8String:invitationId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvInstantInviteUserNotice:nickName:photoUrl:invitationId:)]) {
                [delegate onZBRecvInstantInviteUserNotice:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl invitationId:nsInvitationId];
            }
        }
    }
}


// 9.4.接收预约开始倒数通知
- (void)onZBRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg leftSeconds:(int)leftSeconds {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBRecvBookingNotice:userId:nickName:avatarImg:leftSeconds:)]) {
                [delegate onZBRecvBookingNotice:nsRoomId userId:nsUserId nickName:nsNickName avatarImg:nsAvatarImg leftSeconds:leftSeconds];
            }
        }
    }
}

// 9.5.获取指定立即私密邀请信息
- (void)onZBGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const ZBPrivateInviteItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    ZBImInviteIdItemObject *obj = [[ZBImInviteIdItemObject alloc] init];
    //ZBImInviteIdItemObject *inviteIdItem = [[ZBImInviteIdItemObject alloc] init];
    obj.invitationId = [NSString stringWithUTF8String:item.invitationId.c_str()];
    obj.oppositeId = [NSString stringWithUTF8String:item.oppositeId.c_str()];
    obj.oppositeNickName = [NSString stringWithUTF8String:item.oppositeNickName.c_str()];
    obj.oppositePhotoUrl = [NSString stringWithUTF8String:item.oppositePhotoUrl.c_str()];
    obj.oppositeLevel = item.oppositeLevel;
    obj.oppositeAge = item.oppositeAge;
    obj.oppositeCountry = [NSString stringWithUTF8String:item.oppositeCountry.c_str()];
    obj.read = item.read;
    obj.inviTime = item.inviTime;
    obj.replyType = item.replyType;
    obj.validTime = item.validTime;
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onZBGetInviteInfo:success:err:errMsg:item:)]) {
                [delegate onZBGetInviteInfo:reqId success:success err:err errMsg:nsErrMsg item:obj];
            }
        }
    }
}


/**
 *  9.6.接收观众接受预约通知接口 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     预约ID
 *  @param bookTime         预约时间（1970年起的秒数）
 */
- (void)onZBRecvInvitationAcceptNotice:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl invitationId:(const string &)invitationId bookTime:(long)bookTime {
        NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
        NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
        NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
        NSString *nsInvitationId = [NSString stringWithUTF8String:invitationId.c_str()];
        @synchronized(self) {
            for (NSValue *value in self.delegates) {
                id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onZBRecvInvitationAcceptNotice:nickName:photoUrl:invitationId:bookTime:)]) {
                    [delegate onZBRecvInvitationAcceptNotice:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl invitationId:nsInvitationId bookTime:bookTime];
                }
            }
        }
}

// ------------- 多人互动直播间 -------------

/**
 *  10.1.进入多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *  @param item        进入多人互动直播间信息
 *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
 *
 */
- (void)onAnchorEnterHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const AnchorHangoutRoomItem&)item expire:(int)expire {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    AnchorHangoutRoomItemObject *obj = [[AnchorHangoutRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.roomType = item.roomType;
    obj.manId = [NSString stringWithUTF8String:item.manId.c_str()];
    obj.manNickName = [NSString stringWithUTF8String:item.manNickName.c_str()];
    obj.manPhotoUrl = [NSString stringWithUTF8String:item.manPhotoUrl.c_str()];
    obj.manLevel = item.manLevel;

    NSMutableArray *nsManVideoUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.manVideoUrl.begin(); iter != item.manVideoUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *manVideoUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManVideoUrl addObject:manVideoUrl];
    }
    obj.manVideoUrl = nsManVideoUrl;

    NSMutableArray *nsPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.pushUrl.begin(); iter != item.pushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsPushUrl addObject:pullUrl];
    }
    obj.pushUrl = nsPushUrl;

    NSMutableArray *nsOtherAnchorList = [NSMutableArray array];
    for (OtherAnchorItemList::const_iterator iter = item.otherAnchorList.begin(); iter != item.otherAnchorList.end(); iter++) {
        OtherAnchorItemObject *otherObject = [[OtherAnchorItemObject alloc] init];
        otherObject.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
        otherObject.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
        otherObject.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
        otherObject.anchorStatus = (*iter).anchorStatus;
        otherObject.leftSeconds = (*iter).leftSeconds;
        otherObject.loveLevel = (*iter).loveLevel;
        NSMutableArray *nsVideoUrl = [NSMutableArray array];
        for (list<string>::const_iterator iter1 = (*iter).videoUrl.begin(); iter1 != (*iter).videoUrl.end(); iter1++) {
            string strUrl = (*iter1);
            NSString *videoUrl = [NSString stringWithUTF8String:strUrl.c_str()];
            [nsVideoUrl addObject:videoUrl];
        }
        otherObject.videoUrl = nsVideoUrl;
        [nsOtherAnchorList addObject:otherObject];
    }
    obj.otherAnchorList = nsOtherAnchorList;

    NSMutableArray *nsBuyforList = [NSMutableArray array];
    for (AnchorRecvGiftList::const_iterator iter = item.buyforList.begin(); iter != item.buyforList.end(); iter++) {
        AnchorRecvGiftItemObject *buyforObj = [[AnchorRecvGiftItemObject alloc] init];
        buyforObj.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
        NSMutableArray *nsNumList = [NSMutableArray array];
        for (AnchorGiftNumList::const_iterator iter1 = (*iter).buyforList.begin(); iter1 != (*iter).buyforList.end(); iter1++) {
            AnchorGiftNumItemObject *numObj = [[AnchorGiftNumItemObject alloc] init];
            numObj.giftId = [NSString stringWithUTF8String:(*iter1).giftId.c_str()];
            numObj.giftNum = numObj.giftNum;
            [nsNumList addObject:numObj];
        }
        [nsBuyforList addObject:buyforObj];
    }
    obj.buyforList = nsBuyforList;


    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onAnchorEnterHangoutRoom:success:err:errMsg:item:expire:)]) {
                [delegate onAnchorEnterHangoutRoom:reqId success:success err:err errMsg:nsErrMsg item:obj expire:expire];
            }
        }
    }
}

/**
 *  10.2.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
- (void)onAnchorLeaveHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onAnchorLeaveHangoutRoom:success:err:errMsg:)]) {
                [delegate onAnchorLeaveHangoutRoom:reqId success:success err:err errMsg:nsErrMsg];
            }
        }
    }
}

/**
 *  10.3.收观众邀请多人互动通知接口 回调
 *
 *  @param item         观众邀请多人互动信息
 */
- (void)onRecvAnchorInvitationHangoutNotice:(const AnchorHangoutInviteItem&)item {
    AnchorHangoutInviteItemObject* obj = [[AnchorHangoutInviteItemObject alloc] init];
    obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    NSMutableArray *nsList = [NSMutableArray array];
    for (AnchorItemList::const_iterator iter = item.anchorList.begin(); iter != item.anchorList.end(); iter++) {
        IMAnchorItemObject *anchorObject = [[IMAnchorItemObject alloc] init];
        anchorObject.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
        anchorObject.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
        anchorObject.anchorPhotoUrl = [NSString stringWithUTF8String:(*iter).anchorPhotoUrl.c_str()];
        [nsList addObject:anchorObject];
    }
    obj.anchorList = nsList;
    obj.expire = item.expire;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorInvitationHangoutNotice:)]) {
                [delegate onRecvAnchorInvitationHangoutNotice:obj];
            }
        }
    }

}


/**
 *  10.4.接收推荐好友通知接口 回调
 *
 *  @param item         主播端接收自己推荐好友给观众的信息
 *
 */
- (void)onRecvAnchorRecommendHangoutNotice:(const IMAnchorRecommendHangoutItem&)item {
    IMAnchorRecommendHangoutItemObject* obj = [[IMAnchorRecommendHangoutItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.friendId = [NSString stringWithUTF8String:item.friendId.c_str()];
    obj.friendNickName = [NSString stringWithUTF8String:item.friendNickName.c_str()];
    obj.friendPhotoUrl = [NSString stringWithUTF8String:item.friendPhotoUrl.c_str()];
    obj.friendAge = item.friendAge;
    obj.friendCountry = [NSString stringWithUTF8String:item.friendCountry.c_str()];
    obj.recommendId = [NSString stringWithUTF8String:item.recommendId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorRecommendHangoutNotice:)]) {
                [delegate onRecvAnchorRecommendHangoutNotice:obj];
            }
        }
    }

}

/**
 *  10.5.接收敲门回复通知接口 回调
 *
 *  @param item         接收敲门回复信息
 *
 */
- (void)onRecvAnchorDealKnockRequestNotice:(const IMAnchorKnockRequestItem&)item {
    IMAnchorKnockRequestItemObject* obj = [[IMAnchorKnockRequestItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.knockId = [NSString stringWithUTF8String:item.knockId.c_str()];
    obj.type = item.type;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorDealKnockRequestNotice:)]) {
                [delegate onRecvAnchorDealKnockRequestNotice:obj];
            }
        }
    }
}

/**
 *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
 *
 *  @param item         接收观众邀请其它主播加入多人互动信息
 *
 */
- (void)onRecvAnchorOtherInviteNotice:(const IMAnchorRecvOtherInviteItem&)item {
    IMAnchorRecvOtherInviteItemObject* obj = [[IMAnchorRecvOtherInviteItemObject alloc] init];
    obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.expire = item.expire;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorOtherInviteNotice:)]) {
                [delegate onRecvAnchorOtherInviteNotice:obj];
            }
        }
    }
}

/**
 *  10.7.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorDealInviteNotice:(const IMAnchorRecvDealInviteItem&)item {
    IMAnchorRecvDealInviteItemObject* obj = [[IMAnchorRecvDealInviteItemObject alloc] init];
    obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.type = item.type;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorDealInviteNotice:)]) {
                [delegate onRecvAnchorDealInviteNotice:obj];
            }
        }
    }
}

/**
 *  10.8.观众端/主播端接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorEnterRoomNotice:(const IMAnchorRecvEnterRoomItem&)item {
    IMAnchorRecvEnterRoomItemObject* obj = [[IMAnchorRecvEnterRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.isAnchor = item.isAnchor;
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    IMAnchorUserInfoItemObject *userInfo = [[IMAnchorUserInfoItemObject alloc] init];
    userInfo.riderId = [NSString stringWithUTF8String:item.userInfo.riderId.c_str()];
    userInfo.riderName = [NSString stringWithUTF8String:item.userInfo.riderName.c_str()];
    userInfo.riderUrl = [NSString stringWithUTF8String:item.userInfo.riderUrl.c_str()];
    userInfo.honorImg = [NSString stringWithUTF8String:item.userInfo.honorImg.c_str()];
    obj.userInfo = userInfo;
    NSMutableArray *nsPullUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.pullUrl.begin(); iter != item.pullUrl.end(); iter++) {
        NSString *pullUrl = [NSString stringWithUTF8String:(*iter).c_str()];
        [nsPullUrl addObject:pullUrl];
    }
    obj.pullUrl = nsPullUrl;
    NSMutableArray *nsNumList = [NSMutableArray array];
    for (AnchorGiftNumList::const_iterator iter1 = item.bugForList.begin(); iter1 != item.bugForList.end(); iter1++) {
        AnchorGiftNumItemObject *numObj = [[AnchorGiftNumItemObject alloc] init];
        numObj.giftId = [NSString stringWithUTF8String:(*iter1).giftId.c_str()];
        numObj.giftNum = numObj.giftNum;
        [nsNumList addObject:numObj];
    }
   obj.bugForList = nsNumList;

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorEnterRoomNotice:)]) {
                [delegate onRecvAnchorEnterRoomNotice:obj];
            }
        }
    }
}

/**
 *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(const IMAnchorRecvLeaveRoomItem&)item {
    IMAnchorRecvLeaveRoomItemObject* obj = [[IMAnchorRecvLeaveRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.isAnchor = item.isAnchor;
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.errNo = item.errNo;
    obj.errMsg = [NSString stringWithUTF8String:item.errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorLeaveRoomNotice:)]) {
                [delegate onRecvAnchorLeaveRoomNotice:obj];
            }
        }
    }
}

/**
 *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
 *
 *  @param roomId         直播间ID
 *  @param isAnchor       是否主播（0：否，1：是）
 *  @param userId         观众/主播ID
 *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
 *
 */
- (void)onRecvAnchorChangeVideoUrl:(const string&)roomId isAnchor:(bool)isAnchor userId:(const string&)userId playUrl:(const list<string>&)playUrl {
    NSString* strRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* strUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray *nsPlayUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = playUrl.begin(); iter != playUrl.end(); iter++) {
        NSString *playUrl = [NSString stringWithUTF8String:(*iter).c_str()];
        [nsPlayUrl addObject:playUrl];
    }
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorChangeVideoUrl:isAnchor:userId:playUrl:)]) {
                [delegate onRecvAnchorChangeVideoUrl:strRoomId isAnchor:isAnchor userId:strUserId playUrl:nsPlayUrl];
            }
        }
    }
}

/**
 *  10.11.发送多人互动直播间礼物消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendAnchorHangoutGift:(SEQ_T)reqId success:(bool)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg{
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendAnchorHangoutGift:success:err:errMsg:)]) {
                [delegate onSendAnchorHangoutGift:reqId success:success err:err errMsg:nsErrMsg];
            }
        }
    }
}

/**
 *  10.12.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
- (void)onRecvAnchorGiftNotice:(const IMAnchorRecvGiftItem&)item {
    IMAnchorRecvGiftItemObject* obj = [[IMAnchorRecvGiftItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.fromId = [NSString stringWithUTF8String:item.fromId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.toUid = [NSString stringWithUTF8String:item.toUid.c_str()];
    obj.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
    obj.giftName = [NSString stringWithUTF8String:item.giftName.c_str()];
    obj.giftNum = item.giftNum;
    obj.isMultiClick = item.isMultiClick;
    obj.multiClickStart = item.multiClickStart;
    obj.multiClickEnd = item.multiClickEnd;
    obj.multiClickId = item.multiClickId;
    obj.isPrivate = item.isPrivate;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorGiftNotice:)]) {
                [delegate onRecvAnchorGiftNotice:obj];
            }
        }
    }
}

/**
 *  10.13.接收多人互动直播间观众启动/关闭视频互动通知回调
 *
 *  @param Item            互动切换
 *
 */
- (void)onRecvAnchorControlManPushHangoutNotice:(const ZBControlPushItem&)item {
    ZBImControlPushItemObject * obj = [[ZBImControlPushItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.hangoutRoomId.c_str()];
    obj.userId = [NSString stringWithUTF8String:item.hangoutUserId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
    obj.control = item.control;
    
    NSMutableArray *nsManVideoUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.manVideoUrl.begin(); iter != item.manVideoUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManVideoUrl addObject:pullUrl];
    }
    obj.manVideoUrl = nsManVideoUrl;
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorControlManPushHangoutNotice:)]) {
                [delegate onRecvAnchorControlManPushHangoutNotice:obj];
            }
        }
    }
}

/**
 *  10.14.发送多人互动直播间文本消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendAnchorHangoutLiveChat:(SEQ_T)reqId success:(bool)success err:(ZBLCC_ERR_TYPE)err errMsg:(const string&)errMsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendAnchorHangoutLiveChat:success:err:errMsg:)]) {
                [delegate onSendAnchorHangoutLiveChat:reqId success:success err:err errMsg:nsErrMsg];
            }
        }
    }
}

/**
 *  10.15.接收直播间文本消息回调
 *
 *  @param item            接收直播间的文本消息
 *
 */
-(void)onRecvAnchorHangoutChatNotice:(const IMAnchorRecvHangoutChatItem&)item {
    IMRecvAnchorHangoutChatItemObject * obj = [[IMRecvAnchorHangoutChatItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.level = item.level;
    obj.fromId = [NSString stringWithUTF8String:item.fromId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.msg = [NSString stringWithUTF8String:item.msg.c_str()];
    obj.honorUrl = [NSString stringWithUTF8String:item.honorUrl.c_str()];
    
    NSMutableArray *nsManVideoUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.at.begin(); iter != item.at.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManVideoUrl addObject:pullUrl];
    }
    obj.at = nsManVideoUrl;
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorHangoutChatNotice:)]) {
                [delegate onRecvAnchorHangoutChatNotice:obj];
            }
        }
    }
}

#pragma mark - 节目
// ------------- 节目 -------------
/**
 *  11.1.接收节目开播通知接口 回调
 *
 *  @param item         节目信息
 *  @param msg          消息提示文字
 *
 */
- (void)onRecvAnchorProgramPlayNotice:(const IMAnchorProgramInfoItem&)item msg:(const string&)msg{
    IMAnchorProgramItemObject* obj = [[IMAnchorProgramItemObject alloc] init];
    obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.showTitle = [NSString stringWithUTF8String:item.showTitle.c_str()];
    obj.showIntroduce = [NSString stringWithUTF8String:item.showIntroduce.c_str()];
    obj.cover = [NSString stringWithUTF8String:item.cover.c_str()];
    obj.approveTime = item.approveTime;
    obj.startTime = item.startTime;
    obj.duration = item.duration;
    obj.leftSecToStart = item.leftSecToStart;
    obj.leftSecToEnter = item.leftSecToEnter;
    obj.price = item.price;
    obj.status = item.status;
    obj.ticketNum = item.ticketNum;
    obj.followNum = item.followNum;
    obj.isTicketFull = item.isTicketFull;
    
    NSString* strMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorProgramPlayNotice:msg:)]) {
                [delegate onRecvAnchorProgramPlayNotice:obj msg:strMsg];
            }
        }
    }
}

/**
 *  11.2.接收节目状态改变通知接口 回调
 *
 *  @param item         节目信息
 *
 */
- (void)onRecvAnchorChangeStatusNotice:(const IMAnchorProgramInfoItem&)item {
    IMAnchorProgramItemObject* obj = [[IMAnchorProgramItemObject alloc] init];
    obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.showTitle = [NSString stringWithUTF8String:item.showTitle.c_str()];
    obj.showIntroduce = [NSString stringWithUTF8String:item.showIntroduce.c_str()];
    obj.cover = [NSString stringWithUTF8String:item.cover.c_str()];
    obj.approveTime = item.approveTime;
    obj.startTime = item.startTime;
    obj.duration = item.duration;
    obj.leftSecToStart = item.leftSecToStart;
    obj.leftSecToEnter = item.leftSecToEnter;
    obj.price = item.price;
    obj.status = item.status;
    obj.ticketNum = item.ticketNum;
    obj.followNum = item.followNum;
    obj.isTicketFull = item.isTicketFull;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorChangeStatusNotice:)]) {
                [delegate onRecvAnchorChangeStatusNotice:obj];
            }
        }
    }
}

/**
 *  11.3.接收无操作的提示通知接口 回调
 *
 *  @param backgroundUrl     背景图url
 *  @param msg               描述
 *
 */
- (void)onRecvAnchorShowMsgNotice:(const string&)backgroundUrl msg:(const string&)msg {
    NSString* strBackgroundUrl = [NSString stringWithUTF8String:backgroundUrl.c_str()];
    NSString* strMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> delegate = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorShowMsgNotice:msg:)]) {
                [delegate onRecvAnchorShowMsgNotice:strBackgroundUrl msg:strMsg];
            }
        }
    }
}


@end
