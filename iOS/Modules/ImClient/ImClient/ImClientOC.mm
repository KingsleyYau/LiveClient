//
//  ImClientOC.m
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "ImClientOC.h"

#include "IImClient.h"

static ImClientOC *gClientOC = nil;
class ImClientCallback;

@interface ImClientOC () {
}

@property (nonatomic, assign) IImClient *client;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) ImClientCallback *imClientCallback;

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item        登录返回结构体
 */
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const LoginReturnItem &)item;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

/**
 *  2.4.用户被挤掉线回调
 *
 */
- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 直播间主动操作回调
/**
 *  3.1.观众进入直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param item        直播间信息
 *
 */

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const RoomInfoItem&)item;
/**
 *  3.2.观众退出直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 直播间接收操作回调
/**
 *  3.3.接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *  @param userId      直播ID
 *  @param nickName    直播昵称
 *
 */
- (void)onRecvRoomCloseNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

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
 *
 */
- (void)onRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum;

/**
 *  3.5.接收观众退出直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *
 */
- (void)onRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum;

/**
 *  3.6.接收返点通知回调
 *
 *  @param roomId      直播间ID
 *  @param rebateInfo  返点信息
 *
 */
- (void)onRecvRebateInfoNotice:(const string &)roomId rebateInfo:(const RebateInfoItem &)rebateInfo;

/**
 *  3.7.接收关闭直播间倒数通知回调
 *
 *  @param roomId      直播间ID
 *  @param err         错误码
 *  @param errMsg      倒数原因描述
 *
 */
- (void)onRecvLeavingPublicRoomNotice:(const string &)roomId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg;

/**
 *  3.8.接收踢出直播间通知回调
 *
 *  @param roomId     直播间ID
 *  @param errType    踢出原因错误码
 *  @param errmsg     踢出原因描述
 *  @param credit     信用点
 *
 */
- (void)onRecvRoomKickoffNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit;

/**
 *  3.9.接收充值通知回调
 *
 *  @param roomId     直播间ID
 *  @param msg        充值提示
 *  @param credit     信用点
 *
 */
- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit;

/**
 *  3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）回调
 *
 *  @param roomId     直播间ID
 *  @param credit     信用点
 *
 */
- (void)onRecvCreditNotice:(const string &)roomId credit:(double)credit;

/**
 *  3.11.直播间开播通知 回调
 *
 *  @param roomId       直播间ID
 *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
 *
 */
- (void)onRecvWaitStartOverNotice:(const string &)roomId leftSeconds:(int)leftSeconds;

/**
 *  3.12.接收观众／主播切换视频流通知接口 回调
 *
 *  @param roomId       房间ID
 *  @param isAnchor     是否是主播推流（1:是 0:否）
 *  @param playUrl      播放url
 *
 */
- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const string &)playUrl;

/**
 *  3.13.观众进入公开直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param item         直播间信息
 *
 */
- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const RoomInfoItem&)item;

/**
 *  3.14.观众开始／结束视频互动接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param manPushUrl       直播间信息
 *
 */
- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg manPushUrl:(const list<string>&)manPushUrl;

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
- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;
/**
 *  4.2.接收直播间文本消息通知回调
 *
 *  @param roomId      直播间ID
 *  @param level       发送方级别
 *  @param fromId      发送方的用户ID
 *  @param nickName    发送方的昵称
 *  @param msg         文本消息内容
 *
 */
- (void)onRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg;

/**
 *  4.3.接收直播间公告消息回调
 *
 *  @param roomId      直播间ID
 *  @param msg         公告消息内容
 *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
 *
 */
- (void)onRecvSendSystemNotice:(const string&)roomId msg:(const string&)msg link:(const string&)link;

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
- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;
/**
 *  5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param giftId               礼物ID
 *  @param giftNum              本次发送礼物的数量
 *  @param multi_click          是否连击礼物
 *  @param multi_click_start    连击起始数
 *  @param multi_click_end      连击结束数
 *  @param multi_click_id       连击ID相同则表示同一次连击
 *
 */
- (void)onRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id;

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
- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;
/**
 *  6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param msg                  消息内容
 *
 */
- (void)onRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg;

#pragma mark - 邀请私密直播
// ------------- 邀请私密直播 -------------
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
- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg invitationId:(const string &)invitationId timeOut:(int)timeOut roomId:(const string &)roomId;

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
- (void)onSendCancelPrivateLiveInvite:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg roomId:(const string &)roomId;

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
- (void)onRecvInstantInviteReplyNotice:(const string &)inviteId replyType:(ReplyType)replyType roomId:(const string &)roomId roomType:(RoomType)roomType anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

/**
 *  7.4.接收主播立即私密邀请通知 回调
 *
 *  @param logId     记录ID
 *  @param anchorId   主播ID
 *  @param nickName   主播昵称
 *  @param avatarImg   主播头像url
 *  @param msg   提示文字
 *
 */
- (void)onRecvInstantInviteUserNotice:(const string &)logId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

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
- (void)onRecvScheduledInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

/**
 *  7.6.接收预约私密邀请回复通知 回调
 *
 *  @param inviteId     邀请ID
 *  @param replyType    主播回复（0:拒绝 1:同意 2:超时）
 *
 */
- (void)onRecvSendBookingReplyNotice:(const string &)inviteId replyType:(AnchorReplyType)replyType;

/**
 *  7.7.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param photoUrl     对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
- (void)onRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl leftSeconds:(int)leftSeconds;

#pragma mark - 直播间才艺点播邀请
/**
 *  8.1.发送直播间才艺点播邀请 回调
 *
 *  @param success           操作是否成功
 *  @param reqId             请求序列号
 *  @param err               结果类型
 *  @param errMsg            结果描述
 *
 */
- (void)onSendTalent:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg talentInviteId:(const string &)talentInviteId;

/**
 *  8.2.接收直播间才艺点播回复通知 回调
 *
 *  @param roomId           直播间ID
 *  @param talentInviteId   才艺邀请ID
 *  @param talentId         才艺ID
 *  @param name             才艺名称
 *  @param credit           观众当前的信用点余额
 *  @param status           状态（1:已接受 2:拒绝）
 *
 */
- (void)onRecvSendTalentNotice:(const string &)roomId talentInviteId:(const string &)talentInviteId talentId:(const string &)talentId name:(const string &)name credit:(double)credit status:(TalentStatus)status;

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
 *  @param loveLevel           当前等级
 *
 */
- (void)onRecvLoveLevelUpNotice:(int)loveLevel;

/**
 *  9.3.背包更新通知
 *
 *  @param item          新增的背包礼物
 *
 */
- (void)onRecvBackpackUpdateNotice:(const BackpackInfo &)item;

@end

class ImClientCallback : public IImClientListener {
  public:
    ImClientCallback(ImClientOC *clientOC) {
        this->clientOC = clientOC;
    };
    virtual ~ImClientCallback(){};

  public:
    virtual void OnLogin(LCC_ERR_TYPE err, const string &errmsg, const LoginReturnItem& item) {
        //        NSLog(@"ImClientCallback::OnLogin() err:%d, errmsg:%s"
        //              , err, errmsg.c_str());
        if (nil != clientOC) {
            [clientOC onLogin:err errMsg:errmsg item:item];
        }
    }
    virtual void OnLogout(LCC_ERR_TYPE err, const string &errmsg) {
        //        NSLog(@"ImClientCallback::OnLogout() err:%d, errmsg:%s"
        //              , err, errmsg.c_str());
        if (nil != clientOC) {
            [clientOC onLogout:err errMsg:errmsg];
        }
    }
    virtual void OnKickOff(LCC_ERR_TYPE err, const string &errmsg) {
        //        NSLog(@"ImClientCallback::OnKickOff() "
        //              );
        if (nil != clientOC) {
            [clientOC onKickOff:err errMsg:errmsg];
        }
    }
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const RoomInfoItem& item) {
        //        NSLog(@"ImClientCallback::OnRoomIn() err:%d, errmsg:%s"
        //              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onRoomIn:success reqId:reqId errType:err errMsg:errMsg item:item];
        }
    }
    virtual void OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg) {
        //        NSLog(@"ImClientCallback::OnRoomOut() err:%d, errmsg:%s"
        //              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onRoomOut:success reqId:reqId errType:err errMsg:errMsg];
        }
    }

    // 4.1.发送直播间文本消息
    virtual void OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg) {
        //        NSLog(@"ImClientCallback::OnSendLiveChat() err:%d, errmsg:%s"
        //              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendLiveChat:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    virtual void OnRecvRoomCloseNotice(const string &roomId, const string &userId, const string &nickName, LCC_ERR_TYPE err, const string &errMsg) {
        //        NSLog(@"ImClientCallback::OnRecvRoomCloseNotice() roomId:%s, userId:%s, nickName:%s"
        //              , roomId.c_str(), userId.c_str(), nickName.c_str());
        if (nil != clientOC) {
            [clientOC onRecvRoomCloseNotice:roomId userId:userId nickName:nickName errType:err errMsg:errMsg];
        }
    }

    virtual void OnRecvEnterRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, const string &riderId, const string &riderName, const string &riderUrl, int fansNum) {
        //        NSLog(@"ImClientCallback::OnRecvEnterRoomNotice() roomId:%s, userId:%s, nickName:%s, photoUrl:%s riderId;%s ridername:%s riderUrl:%s fansNum:%d"
        //              , roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum);
        if (nil != clientOC) {
            [clientOC onRecvEnterRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl riderId:riderId riderName:riderName riderUrl:riderUrl fansNum:fansNum];
        }
    }
    virtual void OnRecvLeaveRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, int fansNum) {
        //        NSLog(@"ImClientCallback::OnRecvLeaveRoomNotice() roomId:%s, userId:%s, nickName:%s, photoUrl:%s fansNum:%d"
        //              , roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);
        if (nil != clientOC) {
            [clientOC onRecvLeaveRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl fansNum:fansNum];
        }
    }

    virtual void OnRecvRebateInfoNotice(const string &roomId, const RebateInfoItem &item) {
        //        NSLog(@"ImClientCallback::OnRecvRebateInfoNotice() roomId:%s"
        //              , roomId.c_str());
        if (nil != clientOC) {
            [clientOC onRecvRebateInfoNotice:roomId rebateInfo:item];
        }
    }

    // 3.7.接收关闭直播间倒数通知
    virtual void OnRecvLeavingPublicRoomNotice(const string &roomId, LCC_ERR_TYPE err, const string &errMsg) {
        //        NSLog(@"ImClientCallback::OnRecvLeavingPublicRoomNotice() roomId:%s err:%d errMsg:%s"
        //              , roomId.c_str(), err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onRecvLeavingPublicRoomNotice:roomId err:err errMsg:errMsg];
        }
    }

    virtual void OnRecvRoomKickoffNotice(const string &roomId, LCC_ERR_TYPE err, const string &errMsg, double credit) {
        //        NSLog(@"ImClientCallback::OnRecvRoomKickoffNotice() roomId:%s  err:%d, errmsg:%s credit:%f"
        //              , roomId.c_str(), err, errMsg.c_str(), credit);
        if (nil != clientOC) {
            [clientOC onRecvRoomKickoffNotice:roomId errType:err errMsg:errMsg credit:credit];
        }
    }

    // 3.9.接收充值通知
    virtual void OnRecvLackOfCreditNotice(const string &roomId, const string &msg, double credit) {
        //        NSLog(@"ImClientCallback::OnRecvLackOfCreditNotice() roomId:%s  msg:%s credit:%f"
        //              , roomId.c_str(), msg.c_str(), credit);
        if (nil != clientOC) {
            [clientOC onRecvLackOfCreditNotice:roomId msg:msg credit:credit];
        }
    }

    // 3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）
    virtual void OnRecvCreditNotice(const string &roomId, double credit) {
        //        NSLog(@"ImClientCallback::OnRecvCreditNotice() roomId:%s credit:%f"
        //              , roomId.c_str(), credit);
        if (nil != clientOC) {
            [clientOC onRecvCreditNotice:roomId credit:credit];
        }
    }

    /**
     *  3.11.直播间开播通知 回调
     *
     *  @param roomId       直播间ID
     *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
     *
     */
    virtual void OnRecvWatStartOverNotice(const string &roomId, int leftSeconds) {
        //        NSLog(@"ImClientCallback::OnRecvWaitStartOverNotice() roomId:%s leftSeconds;%d", roomId.c_str(), leftSeconds);
        if (nil != clientOC) {
            [clientOC onRecvWaitStartOverNotice:roomId leftSeconds:leftSeconds];
        }
    }

    /**
     *  3.12.接收观众／主播切换视频流通知接口 回调
     *
     *  @param roomId       房间ID
     *  @param isAnchor     是否是主播推流（1:是 0:否）
     *  @param playUrl      播放url
     *
     */
    virtual void OnRecvChangeVideoUrl(const string &roomId, bool isAnchor, const string &playUrl) {
        //        NSLog(@"ImClientCallback::OnRecvChangeVideoUrl() roomId:%s isAnchor:%d playUrl:%s", roomId.c_str(), isAnchor, playUrl.c_str());
        if (nil != clientOC) {
            [clientOC onRecvChangeVideoUrl:roomId isAnchor:isAnchor playUrl:playUrl];
        }
    };
    
    /**
     *  3.13.观众进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param item         直播间信息
     *
     */
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) {
        if (nil != clientOC) {
            [clientOC onPublicRoomIn:reqId success:success err:err errMsg:errMsg item:item];
        }
    }
    
    virtual void OnRecvSendChatNotice(const string &roomId, int level, const string &fromId, const string &nickName, const string &msg) {
        //        NSLog(@"OnRecvSendChatNotice() roomId:%s, level:%d ,fromId:%s, nickName:%s, msg:%s"
        //              , roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str());
        if (nil != clientOC) {
            [clientOC onRecvSendChatNotice:roomId level:level fromId:fromId nickName:nickName msg:msg];
        }
    }
    
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       直播间信息
     *
     */
    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {
        if (nil != clientOC) {
            [clientOC onControlManPush:reqId success:success err:err errMsg:errMsg manPushUrl:manPushUrl];
        }
    };
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
     *
     */
    virtual void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link) {
        if (nil != clientOC) {
            [clientOC onRecvSendSystemNotice:roomId msg:msg link:link];
        }
    }

    // ------------- 直播间点赞 -------------
    // 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, double credit, double rebateCredit) {
        //        NSLog(@"ImClientCallback::OnSendGift() err:%d, errmsg:%s"
        //              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendGift:success reqId:reqId errType:err errMsg:errMsg credit:credit rebateCredit:rebateCredit];
        }
    }

    // 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnRecvSendGiftNotice(const string &roomId, const string &fromId, const string &nickName, const string &giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
        //        NSLog(@"ImClientCallback::OnRecvSendGiftNotice()");
        if (nil != clientOC) {
            [clientOC onRecvSendGiftNotice:roomId fromId:fromId nickName:nickName giftId:giftId giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
        }
    }

    // ------------- 直播间弹幕消息 -------------
    // 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual void OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, double credit, double rebateCredit) {
        //        NSLog(@"ImClientCallback::OnSendToast() err:%d, errmsg:%s"
        //              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendToast:success reqId:reqId errType:err errMsg:errMsg credit:credit rebateCredit:rebateCredit];
        }
    }
    // 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnRecvSendToastNotice(const string &roomId, const string &fromId, const string &nickName, const string &msg) {
        //        NSLog(@"ImClientCallback::OnRecvRoomToastNotice()");
        if (nil != clientOC) {
            [clientOC onRecvSendToastNotice:roomId fromId:fromId nickName:nickName msg:msg];
        }
    }

    // ------------- 邀请私密直播 -------------
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
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &invitationId, int timeOut, const string &roomId) {
        //        NSLog(@"ImClientCallback::OnSendPrivateLiveInvite()");
        if (nil != clientOC) {
            [clientOC onSendPrivateLiveInvite:success reqId:reqId err:err errMsg:errMsg invitationId:invitationId timeOut:timeOut roomId:roomId];
        }
    }

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
    virtual void OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &roomId) {
        //        NSLog(@"ImClientCallback::OnSendCancelPrivateLiveInvite()");
        if (nil != clientOC) {
            [clientOC onSendCancelPrivateLiveInvite:success reqId:reqId err:err errMsg:errMsg roomId:roomId];
        }
    }

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
    virtual void OnRecvInstantInviteReplyNotice(const string &inviteId, ReplyType replyType, const string &roomId, RoomType roomType, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) {
        //        NSLog(@"ImClientCallback::OnRecvInstantInviteReplyNotice");
        if (nil != clientOC) {
            [clientOC onRecvInstantInviteReplyNotice:inviteId replyType:replyType roomId:roomId roomType:roomType anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

    /**
     *  7.4.接收主播立即私密邀请通知 回调
     *
     *  @param logId     记录ID
     *  @param anchorId   主播ID
     *  @param nickName   主播昵称
     *  @param avatarImg   主播头像url
     *  @param msg   提示文字
     *
     */
    virtual void onRecvInstantInviteUserNotice(const string &logId, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) {
        //        NSLog(@"ImClientCallback::OnRecvInstantInviteUserNotice");
        if (nil != clientOC) {
            [clientOC onRecvInstantInviteUserNotice:logId anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

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
    virtual void OnRecvScheduledInviteUserNotice(const string &inviteId, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) {
        //        NSLog(@"ImClientCallback::OnRecvScheduledInviteUserNotice");
        if (nil != clientOC) {
            [clientOC onRecvScheduledInviteUserNotice:inviteId anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

    /**
     *  7.6.接收预约私密邀请回复通知 回调
     *
     *  @param inviteId     邀请ID
     *  @param replyType    主播回复（0:拒绝 1:同意 2:超时）
     *
     */
    virtual void OnRecvSendBookingReplyNotice(const string &inviteId, AnchorReplyType replyType) {
        //        NSLog(@"ImClientCallback::OnRecvSendBookingReplyNotice");
        if (nil != clientOC) {
            [clientOC onRecvSendBookingReplyNotice:inviteId replyType:replyType];
        }
    }

    /**
     *  7.7.接收预约开始倒数通知 回调
     *
     *  @param roomId       直播间ID
     *  @param userId       对端ID
     *  @param nickName     对端昵称
     *  @param photoUrl     对端头像url
     *  @param leftSeconds  倒数时间（秒）
     *
     */
    virtual void OnRecvBookingNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, int leftSeconds) {
        //        NSLog(@"ImClientCallback::OnRecvSendBookingReplyNotice() roomId:%s userId:%s nickName:%s photoUrl:%s leftSeconds:%d", roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), leftSeconds);
        if (nil != clientOC) {
            [clientOC onRecvBookingNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl leftSeconds:leftSeconds];
        }
    }
    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  8.1.发送直播间才艺点播邀请 回调
     *
     *  @param success           操作是否成功
     *  @param reqId             请求序列号
     *  @param err               结果类型
     *  @param errMsg            结果描述
     *
     */
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &talentInviteId) {
        //        NSLog(@"ImClientCallback::OnSendTalent() reqId:%d success:%d err:%d errMsg:%s", reqId, success, err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendTalent:reqId success:success err:err errMsg:errMsg talentInviteId:talentInviteId];
        }
    }

    /**
     *  8.2.接收直播间才艺点播回复通知 回调
     *
     *  @param roomId           直播间ID
     *  @param talentInviteId   才艺邀请ID
     *  @param talentId         才艺ID
     *  @param name             才艺名称
     *  @param credit           观众当前的信用点余额
     *  @param status           状态（1:已接受 2:拒绝）
     *
     */
    virtual void OnRecvSendTalentNotice(const string &roomId, const string &talentInviteId, const string &talentId, const string &name, double credit, TalentStatus status) {
        //        NSLog(@"ImClientCallback::OnRecvSendTalentNotice() roomId:%s talentInviteId:%s talentId:%s name:%s credit:%f status:%d", roomId.c_str(), talentInviteId.c_str(), talentId.c_str(), name.c_str(), credit, status);
        if (nil != clientOC) {
            [clientOC onRecvSendTalentNotice:roomId talentInviteId:talentInviteId talentId:talentId name:name credit:credit status:status];
        }
    }

    // ------------- 公共 -------------
    /**
     *  9.1.观众等级升级通知 回调
     *
     *  @param level           当前等级
     *
     */
    virtual void OnRecvLevelUpNotice(int level) {
        //        NSLog(@"ImClientCallback::OnRecvLevelUpNotice() level:%d", level);
        if (nil != clientOC) {
            [clientOC onRecvLevelUpNotice:level];
        }
    }

    /**
     *  9.2.观众亲密度升级通知
     *
     *  @param loveLevel           当前等级
     *
     */
    virtual void OnRecvLoveLevelUpNotice(int loveLevel) {
        //        NSLog(@"ImClientCallback::OnRecvLoveLevelUpNotice() loveLevel:%d", loveLevel);
        if (nil != clientOC) {
            [clientOC onRecvLoveLevelUpNotice:loveLevel];
        }
    }

    /**
     *  9.3.背包更新通知
     *
     *  @param item          新增的背包礼物
     *
     */
    virtual void OnRecvBackpackUpdateNotice(const BackpackInfo &item) {
        //        NSLog(@"ImClientCallback::OnRecvBackpackUpdateNotice()");
        if (nil != clientOC) {
            [clientOC onRecvBackpackUpdateNotice:item];
        }
    }

  private:
    __weak typeof(ImClientOC *) clientOC;
};

@implementation ImClientOC

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
        self.client = IImClient::CreateClient();
        self.imClientCallback = new ImClientCallback(self);
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

        IImClient::ReleaseClient(self.client);
        self.client = NULL;
    }
}

- (BOOL)addDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> item = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"ImClientOC::addDelegate() add again, delegate:<%@>", delegate);
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

- (BOOL)removeDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> item = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    // log
    if (!result) {
        NSLog(@"ImClientOC::removeDelegate() fail, delegate:<%@>", delegate);
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

- (BOOL)login:(NSString *_Nonnull)token pageName:(PageNameType)pageName {
    BOOL result = NO;
    if (NULL != self.client) {

        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }

        result = self.client->Login(strToken, pageName);
    }
    return result;
}

- (BOOL)logout {
    BOOL result = NO;
    if (NULL != self.client) {
        result = self.client->Logout();
    }
    return result;
}

- (BOOL)roomIn:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->RoomIn(reqId, strRoomId);
    }
    return result;
}

- (BOOL)roomOut:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->RoomOut(reqId, strRoomId);
    }
    return result;
}


- (BOOL)publicRoomIn:(SEQ_T)reqId anchorId:(NSString *_Nonnull)anchorId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strAnchorId;
        if (nil != anchorId) {
            strAnchorId = [anchorId UTF8String];
        }
        
        result = self.client->PublicRoomIn(reqId, strAnchorId);
    }
    return result;
}

-(BOOL)controlManPush:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId control:(IMControlType)control {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->ControlManPush(reqId, strRoomId, control);
    }
    return result;
}

- (BOOL)sendLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
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

        result = self.client->SendLiveChat(reqId, strRoomId, strName, strMsg, strAts);
    }
    return result;
}


- (BOOL)sendGift:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id
{
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

        result = self.client->SendGift(reqId, strRoomId, strNickName, strGiftId, strGiftName, isBackPack, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    }
    return result;
}

- (BOOL)sendToast:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg
{
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

        string strMsg;
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }

        result = self.client->SendToast(reqId, strRoomId, strNickName, strMsg);
    }
    return result;
}

- (BOOL)sendPrivateLiveInvite:(SEQ_T)reqId userId:(NSString *)userId logId:(NSString *)logId force:(BOOL)force
{
    BOOL result = NO;
    if (NULL != self.client) {

        string strUserId;
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }
        string strLogId;
        if (nil != userId) {
            strLogId = [logId UTF8String];
        }

        result = self.client->SendPrivateLiveInvite(reqId, strUserId, strLogId, force);
    }

    return result;
}

- (BOOL)sendCancelPrivateLiveInvite:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strInviteId;
        if (nil != inviteId) {
            strInviteId = [inviteId UTF8String];
        }

        result = self.client->SendCancelPrivateLiveInvite(reqId, strInviteId);
    }

    return result;
}

- (BOOL)sendTalent:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        string strTalentId;
        if (nil != talentId) {
            strTalentId = [talentId UTF8String];
        }

        result = self.client->SendTalent(reqId, strRoomId, strTalentId);
    }

    return result;
}

#pragma mark - 登录/注销回调

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const LoginReturnItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ImLoginReturnObject* obj = [[ImLoginReturnObject alloc] init];
    NSMutableArray *nsRoomList = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.roomList.begin(); iter != item.roomList.end(); iter++) {
        string strRoomId = (*iter);
        NSString *nsRoomId = [NSString stringWithUTF8String:strRoomId.c_str()];
        [nsRoomList addObject:nsRoomId];
    }
    obj.roomList = nsRoomList;
    
    NSMutableArray *nsInviteList = [NSMutableArray array];
    for (InviteList::const_iterator iter = item.inviteList.begin(); iter != item.inviteList.end(); iter++) {
        ImInviteIdItemObject* inviteIdItem = [[ImInviteIdItemObject alloc] init];
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
    for (ScheduleRoomList::const_iterator iter = item.scheduleRoomList.begin(); iter != item.scheduleRoomList.end(); iter++) {
        ImScheduleRoomObject* scheduleRoom = [[ImScheduleRoomObject alloc] init];
        scheduleRoom.anchorImg = [NSString stringWithUTF8String:(*iter).anchorImg.c_str()];
        scheduleRoom.anchorCoverImg = [NSString stringWithUTF8String:(*iter).anchorCoverImg.c_str()];
        scheduleRoom.canEnterTime = (*iter).canEnterTime;
        scheduleRoom.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
        [nsScheduleRoomList addObject:scheduleRoom];
    }
    obj.scheduleRoomList = nsScheduleRoomList;
    
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onLogin:errMsg:item:)]) {
                [delegate onLogin:errType errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onLogout:errMsg:)]) {
                [delegate onLogout:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onKickOff:errMsg:)]) {
                [delegate onKickOff:errType errMsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 直播间主动操作回调

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const RoomInfoItem&)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ImLiveRoomObject* obj = [[ImLiveRoomObject alloc] init];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    //NSString* nsManPushUrl = [NSString stringWithUTF8String:manPushUrl.c_str()];
    
    NSMutableArray *nsVideoUrls = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.videoUrl.begin(); iter != item.videoUrl.end(); iter++) {
        string nsVideoUrl = (*iter);
        NSString *videoUrl = [NSString stringWithUTF8String:nsVideoUrl.c_str()];
        [nsVideoUrls addObject:videoUrl];
    }
    obj.videoUrls = nsVideoUrls;
    obj.roomType = item.roomType;
    obj.credit = item.credit;
    obj.usedVoucher = item.usedVoucher;
    obj.fansNum = item.fansNum;
    NSMutableArray *numArrayEmo = [NSMutableArray array];
    for (list<int>::const_iterator iter = item.emoTypeList.begin(); iter != item.emoTypeList.end(); iter++) {
        int num = (*iter);
        NSNumber *numEmo = [NSNumber numberWithInt:num];
        [numArrayEmo addObject:numEmo];
    }
    obj.emoTypeList = numArrayEmo;
    obj.loveLevel = item.loveLevel;
    
    RebateInfoObject *itemObject = [RebateInfoObject alloc];
    itemObject.curCredit = item.rebateInfo.curCredit;
    itemObject.curTime = item.rebateInfo.curTime;
    itemObject.preCredit = item.rebateInfo.preCredit;
    itemObject.preTime = item.rebateInfo.preTime;
    obj.rebateInfo = itemObject;
    obj.favorite = item.favorite;
    obj.leftSeconds = item.leftSeconds;
    obj.waitStart = item.waitStart;
    
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.manPushUrl.begin(); iter != item.manPushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    obj.manPushUrl = nsManPushUrl;
    obj.roomPrice = item.roomPrice;
    obj.manPushPrice = item.manPushPrice;
    obj.maxFansiNum = item.maxFansiNum;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRoomIn:reqId:errType:errMsg:item:)]) {
                [delegate onRoomIn:success reqId:reqId errType:errType errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRoomOut:reqId:errType:errMsg:)]) {
                [delegate onRoomOut:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const RoomInfoItem&)item {
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    ImLiveRoomObject* obj = [[ImLiveRoomObject alloc] init];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    //NSString* nsManPushUrl = [NSString stringWithUTF8String:manPushUrl.c_str()];
    
    NSMutableArray *nsVideoUrls = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.videoUrl.begin(); iter != item.videoUrl.end(); iter++) {
        string nsVideoUrl = (*iter);
        NSString *videoUrl = [NSString stringWithUTF8String:nsVideoUrl.c_str()];
        [nsVideoUrls addObject:videoUrl];
    }
    obj.videoUrls = nsVideoUrls;
    obj.roomType = item.roomType;
    obj.credit = item.credit;
    obj.usedVoucher = item.usedVoucher;
    obj.fansNum = item.fansNum;
    NSMutableArray *numArrayEmo = [NSMutableArray array];
    for (list<int>::const_iterator iter = item.emoTypeList.begin(); iter != item.emoTypeList.end(); iter++) {
        int num = (*iter);
        NSNumber *numEmo = [NSNumber numberWithInt:num];
        [numArrayEmo addObject:numEmo];
    }
    obj.emoTypeList = numArrayEmo;
    obj.loveLevel = item.loveLevel;
    
    RebateInfoObject *itemObject = [RebateInfoObject alloc];
    itemObject.curCredit = item.rebateInfo.curCredit;
    itemObject.curTime = item.rebateInfo.curTime;
    itemObject.preCredit = item.rebateInfo.preCredit;
    itemObject.preTime = item.rebateInfo.preTime;
    obj.rebateInfo = itemObject;
    obj.favorite = item.favorite;
    obj.leftSeconds = item.leftSeconds;
    obj.waitStart = item.waitStart;
    
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.manPushUrl.begin(); iter != item.manPushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    obj.manPushUrl = nsManPushUrl;
    obj.roomPrice = item.roomPrice;
    obj.manPushPrice = item.manPushPrice;
    obj.maxFansiNum = item.maxFansiNum;


    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onPublicRoomIn:success:err:errMsg:item:)]) {
                [delegate onPublicRoomIn:reqId success:success err:err errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg manPushUrl:(const list<string>&)manPushUrl {
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = manPushUrl.begin(); iter != manPushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onControlManPush:success:err:errMsg:manPushUrl:)]) {
                [delegate onControlManPush:reqId success:success err:err errMsg:nsErrMsg manPushUrl:nsManPushUrl];
            }
        }
    }
}

#pragma mark - 直播间接收操作回调

- (void)onRecvRoomCloseNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomCloseNotice:userId:nickName:errType:errMsg:)] ) {
                [delegate onRecvRoomCloseNotice:nsRoomId userId:nsUserId nickName:nsNickName errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    NSString *nsRiderId = [NSString stringWithUTF8String:riderId.c_str()];
    NSString *nsRiderName = [NSString stringWithUTF8String:riderName.c_str()];
    NSString *nsRiderUrl = [NSString stringWithUTF8String:riderUrl.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEnterRoomNotice:userId:nickName:photoUrl:riderId:riderName:riderUrl:fansNum:)]) {
                [delegate onRecvEnterRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl riderId:nsRiderId riderName:nsRiderName riderUrl:nsRiderUrl fansNum:fansNum];
            }
        }
    }
}

- (void)onRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLeaveRoomNotice:userId:nickName:photoUrl:fansNum:)]) {
                [delegate onRecvLeaveRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl fansNum:fansNum];
            }
        }
    }
}

- (void)onRecvRebateInfoNotice:(const string &)roomId rebateInfo:(const RebateInfoItem &)rebateInfo {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];

    RebateInfoObject *itemObject = [RebateInfoObject alloc];
    itemObject.curCredit = rebateInfo.curCredit;
    itemObject.curTime = rebateInfo.curTime;
    itemObject.preCredit = rebateInfo.preCredit;
    itemObject.preTime = rebateInfo.preTime;

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRebateInfoNotice:rebateInfo:)]) {
                [delegate onRecvRebateInfoNotice:nsRoomId rebateInfo:itemObject];
            }
        }
    }
}

- (void)onRecvLeavingPublicRoomNotice:(const string &)roomId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLeavingPublicRoomNotice:err:errMsg:)]) {
                [delegate onRecvLeavingPublicRoomNotice:nsRoomId err:err errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvRoomKickoffNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRoomKickoffNotice:errType:errMsg:credit:)]) {
                [delegate onRecvRoomKickoffNotice:nsRoomId errType:errType errmsg:nsErrMsg credit:credit];
            }
        }
    }
}

- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLackOfCreditNotice:msg:credit:)]) {
                [delegate onRecvLackOfCreditNotice:nsRoomId msg:nsMsg credit:credit];
            }
        }
    }
}

- (void)onRecvCreditNotice:(const string &)roomId credit:(double)credit {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCreditNotice:credit:)]) {
                [delegate onRecvCreditNotice:nsRoomId credit:credit];
            }
        }
    }
}

- (void)onRecvWaitStartOverNotice:(const string &)roomId leftSeconds:(int)leftSeconds {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvWaitStartOverNotice:leftSeconds:)]) {
                [delegate onRecvWaitStartOverNotice:nsRoomId leftSeconds:leftSeconds];
            }
        }
    }
}

- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const string &)playUrl {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsPlayUrl = [NSString stringWithUTF8String:playUrl.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvChangeVideoUrl:isAnchor:playUrl:)]) {
                [delegate onRecvChangeVideoUrl:nsRoomId isAnchor:isAnchor playUrl:nsPlayUrl];
            }
        }
    }
}

#pragma mark - 直播间文本消息信息
- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendLiveChat:reqId:errType:errMsg:)]) {
                [delegate onSendLiveChat:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendChatNotice:level:fromId:nickName:msg:)]) {
                [delegate onRecvSendChatNotice:nsRoomId level:level fromId:nsFromId nickName:nsNickName msg:nsMsg];
            }
        }
    }
}


- (void)onRecvSendSystemNotice:(const string&)roomId msg:(const string&)msg link:(const string&)link {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsLink = [NSString stringWithUTF8String:link.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendSystemNotice:msg:link:)]) {
                [delegate onRecvSendSystemNotice:nsRoomId msg:nsMsg link:nsLink];
            }
        }
    }
}

#pragma mark - 直播间礼物消息操作回调

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendGift:reqId:errType:errMsg:credit:rebateCredit:)]) {
                [delegate onSendGift:success reqId:reqId errType:errType errMsg:nsErrMsg credit:credit rebateCredit:rebateCredit];
            }
        }
    }
}

- (void)onRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsGigtId = [NSString stringWithUTF8String:giftId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendGiftNotice:fromId:nickName:giftId:giftNum:multi_click:multi_click_start:multi_click_end:multi_click_id:)]) {
                [delegate onRecvSendGiftNotice:nsRoomId fromId:nsFromId nickName:nsNickName giftId:nsGigtId giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            }
        }
    }
}

#pragma mark - 直播间弹幕消息操作回调

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendToast:reqId:errType:errMsg:credit:rebateCredit:)]) {
                [delegate onSendToast:success reqId:reqId errType:errType errMsg:nsErrMsg credit:credit rebateCredit:rebateCredit];
            }
        }
    }
}

- (void)onRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendToastNotice:fromId:nickName:msg:)]) {
                [delegate onRecvSendToastNotice:nsRoomId fromId:nsFromId nickName:nsNickName msg:nsMsg];
            }
        }
    }
}

#pragma mark - 邀请私密直播

// ------------- 邀请私密直播 -------------

- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg invitationId:(const string &)invitationId timeOut:(int)timeOut roomId:(const string &)roomId {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString *nsInvitationId = [NSString stringWithUTF8String:invitationId.c_str()];
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendPrivateLiveInvite:reqId:err:errMsg:invitationId:timeOut:roomId:)]) {
                [delegate onSendPrivateLiveInvite:success reqId:reqId err:err errMsg:nsErrMsg invitationId:nsInvitationId timeOut:timeOut roomId:nsRoomId];
            }
        }
    }
}

- (void)onSendCancelPrivateLiveInvite:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg roomId:(const string &)roomId {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendCancelPrivateLiveInvite:reqId:err:errMsg:roomId:)]) {
                [delegate onSendCancelPrivateLiveInvite:success reqId:reqId err:err errMsg:nsErrMsg roomId:nsRoomId];
            }
        }
    }
}

- (void)onRecvInstantInviteReplyNotice:(const string &)inviteId replyType:(ReplyType)replyType roomId:(const string &)roomId roomType:(RoomType)roomType anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg {
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvInstantInviteReplyNotice:replyType:roomId:roomType:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvInstantInviteReplyNotice:nsInviteId replyType:replyType roomId:nsRoomId roomType:roomType anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
            }
        }
    }
}

- (void)onRecvInstantInviteUserNotice:(const string &)logId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg {
    NSString *nsLogId = [NSString stringWithUTF8String:logId.c_str()];
    NSString *nsAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvInstantInviteUserNotice:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvInstantInviteUserNotice:nsLogId anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
            }
        }
    }
}

- (void)onRecvScheduledInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;
{
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvScheduledInviteUserNotice:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvScheduledInviteUserNotice:nsInviteId anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
            }
        }
    }
}

- (void)onRecvSendBookingReplyNotice:(const string &)inviteId replyType:(AnchorReplyType)replyType {
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendBookingReplyNotice:replyType:)]) {
                [delegate onRecvSendBookingReplyNotice:nsInviteId replyType:replyType];
            }
        }
    }
}

- (void)onRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl leftSeconds:(int)leftSeconds {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvBookingNotice:userId:nickName:photoUrl:leftSeconds:)]) {
                [delegate onRecvBookingNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl leftSeconds:leftSeconds];
            }
        }
    }

}

#pragma mark - 直播间才艺点播邀请
- (void)onSendTalent:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg talentInviteId:(const string&)talentInviteId{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString* nsTalentInviteId = [NSString stringWithUTF8String:talentInviteId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendTalent:success:err:errMsg:talentInviteId:)] ) {
                [delegate onSendTalent:reqId success:success err:err errMsg:nsErrMsg talentInviteId:nsTalentInviteId];
            }
        }
    }
}

- (void)onRecvSendTalentNotice:(const string&)roomId talentInviteId:(const string&)talentInviteId talentId:(const string&)talentId name:(const string&)name credit:(double) credit status:(TalentStatus)status {
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsTalentInviteId = [NSString stringWithUTF8String:talentInviteId.c_str()];
    NSString* nsTalentId = [NSString stringWithUTF8String:talentId.c_str()];
    NSString* nsName = [NSString stringWithUTF8String:name.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvSendTalentNotice:talentInviteId:talentId:name:credit:status:)] ) {
                [delegate onRecvSendTalentNotice:nsRoomId talentInviteId:nsTalentInviteId talentId:nsTalentId name:nsName credit:credit status:status];
            }
        }
    }
}

#pragma mark - 公共
- (void)onRecvLevelUpNotice:(int)level {
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvLevelUpNotice:)] ) {
                [delegate onRecvLevelUpNotice:level];
            }
        }
    }
}

- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvLoveLevelUpNotice:)] ) {
                [delegate onRecvLoveLevelUpNotice:loveLevel];
            }
        }
    }
}

- (void)onRecvBackpackUpdateNotice:(const BackpackInfo&)item {
    
    BackpackInfoObject* itemObject = [[BackpackInfoObject alloc] init];
    GiftInfoObject* gift = [[GiftInfoObject alloc] init];
    gift.giftId = [NSString stringWithUTF8String:item.gift.giftId.c_str()];
    gift.name = [NSString stringWithUTF8String:item.gift.name.c_str()];
    gift.num = item.gift.num;
    itemObject.gift = gift;
    VoucherInfoObject* voucher = [[VoucherInfoObject alloc] init];
    voucher.voucherId = [NSString stringWithUTF8String:item.voucher.voucherId.c_str()];
    voucher.photoUrl = [NSString stringWithUTF8String:item.voucher.photoUrl.c_str()];
    voucher.desc = [NSString stringWithUTF8String:item.voucher.desc.c_str()];
    itemObject.voucher = voucher;
    RideInfoObject* ride = [[RideInfoObject alloc] init];
    ride.rideId = [NSString stringWithUTF8String:item.ride.rideId.c_str()];
    ride.photoUrl = [NSString stringWithUTF8String:item.ride.photoUrl.c_str()];
    ride.name = [NSString stringWithUTF8String:item.ride.name.c_str()];
    itemObject.ride = ride;
    
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvBackpackUpdateNotice:)] ) {
                [delegate onRecvBackpackUpdateNotice:itemObject];
            }
        }
    }
}

@end
