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
 *  3.1.观众进入直播间回调
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
 *
 */
- (void)onZBRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum;

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
 *  3.5.接收踢出直播间通知回调
 *
 *  @param roomId     直播间ID
 *  @param errType    踢出原因错误码
 *  @param errmsg     踢出原因描述
 *  @param credit     信用点
 *
 */
- (void)onZBRecvRoomKickoffNotice:(const string &)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

///**
// *  3.9.接收充值通知回调
// *
// *  @param roomId     直播间ID
// *  @param msg        充值提示
// *  @param credit     信用点
// *
// */
//- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit;
//
///**
// *  3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）回调
// *
// *  @param roomId     直播间ID
// *  @param credit     信用点
// *
// */
//- (void)onRecvCreditNotice:(const string &)roomId credit:(double)credit;
//
///**
// *  3.11.直播间开播通知 回调
// *
// *  @param roomId       直播间ID
// *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
// *
// */
//- (void)onRecvWaitStartOverNotice:(const StartOverRoomItem &)item;
//
///**
// *  3.12.接收观众／主播切换视频流通知接口 回调
// *
// *  @param roomId       房间ID
// *  @param isAnchor     是否是主播推流（1:是 0:否）
// *  @param playUrl      播放url
// *
// */
//- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const list<string> &)playUrl;
//

//
///**
// *  3.14.观众开始／结束视频互动接口 回调
// *
// *  @param success          操作是否成功
// *  @param reqId            请求序列号
// *  @param errMsg           结果描述
// *  @param manPushUrl       观众视频流url
// *
// */
//- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg manPushUrl:(const list<string> &)manPushUrl;


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
- (void)onZBRecvControlManPushNotice:(const ZBControlPushItem&)Item;



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
//
///**
// *  7.2.观众取消立即私密邀请 回调
// *
// *  @param success       操作是否成功
// *  @param reqId         请求序列号
// *  @param err           结果类型
// *  @param errMsg        结果描述
// *  @param roomId        直播间ID
// *
// */
//- (void)onSendCancelPrivateLiveInvite:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg roomId:(const string &)roomId;

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
//
///**
// *  7.5.接收主播预约私密邀请通知 回调
// *
// *  @param inviteId     邀请ID
// *  @param anchorId     主播ID
// *  @param nickName     主播昵称
// *  @param avatarImg    主播头像url
// *  @param msg          提示文字
// *
// */
//- (void)onRecvScheduledInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;
//
///**
// *  7.6.接收预约私密邀请回复通知 回调
// *
// *  @param item     预约私密邀请回复知结构体
// *
// */
//- (void)onRecvSendBookingReplyNotice:(const BookingReplyItem &)item;

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
    virtual void OnZBRecvEnterRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, const string &riderId, const string &riderName, const string &riderUrl, int fansNum) {
        if (nil != clientOC) {
            [clientOC onZBRecvEnterRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl riderId:riderId riderName:riderName riderUrl:riderUrl fansNum:fansNum];
        }
    }
    // 3.7.接收观众退出直播间通知
    virtual void OnZBRecvLeaveRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, int fansNum) {
        if (nil != clientOC) {
            [clientOC onZBRecvLeaveRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl fansNum:fansNum];
        }
    }

//    virtual void OnRecvRebateInfoNotice(const string &roomId, const RebateInfoItem &item) {
//        if (nil != clientOC) {
//            [clientOC onRecvRebateInfoNotice:roomId rebateInfo:item];
//        }
//    }
//
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

//    // 3.9.接收充值通知
//    virtual void OnRecvLackOfCreditNotice(const string &roomId, const string &msg, double credit) {
//        if (nil != clientOC) {
//            [clientOC onRecvLackOfCreditNotice:roomId msg:msg credit:credit];
//        }
//    }
//
//    // 3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）
//    virtual void OnRecvCreditNotice(const string &roomId, double credit) {
//        if (nil != clientOC) {
//            [clientOC onRecvCreditNotice:roomId credit:credit];
//        }
//    }
//
//    /**
//     *  3.11.直播间开播通知 回调
//     *
//     *  @param roomId       直播间ID
//     *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
//     *
//     */
//    virtual void OnRecvWaitStartOverNotice(const StartOverRoomItem &item) {
//        //        NSLog(@"ImClientCallback::OnRecvWaitStartOverNotice() roomId:%s leftSeconds;%d", roomId.c_str(), leftSeconds);
//        if (nil != clientOC) {
//            [clientOC onRecvWaitStartOverNotice:item];
//        }
//    }
//
//    /**
//     *  3.12.接收观众／主播切换视频流通知接口 回调
//     *
//     *  @param roomId       房间ID
//     *  @param isAnchor     是否是主播推流（1:是 0:否）
//     *  @param playUrl      播放url
//     *
//     */
//    virtual void OnRecvChangeVideoUrl(const string &roomId, bool isAnchor, const list<string> &playUrl) {
//        if (nil != clientOC) {
//            [clientOC onRecvChangeVideoUrl:roomId isAnchor:isAnchor playUrl:playUrl];
//        }
//    };
//
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

//    /**
//     *  3.14.观众开始／结束视频互动接口 回调
//     *
//     *  @param success          操作是否成功
//     *  @param reqId            请求序列号
//     *  @param errMsg           结果描述
//     *  @param manPushUrl       直播间信息
//     *
//     */
//    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const list<string> &manPushUrl) {
//        if (nil != clientOC) {
//            [clientOC onControlManPush:reqId success:success err:err errMsg:errMsg manPushUrl:manPushUrl];
//        }
//    };


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
    virtual void OnZBRecvControlManPushNotice(const ZBControlPushItem Item) {
        if (nil != clientOC) {
            [clientOC onZBRecvControlManPushNotice:Item];
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
    NSLog(@"ImClientOC::addDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<ZBIMLiveRoomManagerDelegate> item = (id<ZBIMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
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

- (BOOL)removeDelegate:(id<ZBIMLiveRoomManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    NSLog(@"ImClientOC::removeDelegate( delegate : %@ )", delegate);

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
        NSLog(@"ZBImClientOC::removeDelegate() fail, delegate:<%@>", delegate);
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
//
//- (BOOL)controlManPush:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId control:(IMControlType)control {
//    BOOL result = NO;
//    if (NULL != self.client) {
//
//        string strRoomId;
//        if (nil != roomId) {
//            strRoomId = [roomId UTF8String];
//        }
//
//        result = self.client->ControlManPush(reqId, strRoomId, control);
//    }
//    return result;
//}
//


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

//- (BOOL)sendToast:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
//    BOOL result = NO;
//    if (NULL != self.client) {
//
//        string strRoomId;
//        if (nil != roomId) {
//            strRoomId = [roomId UTF8String];
//        }
//
//        string strNickName;
//        if (nil != nickName) {
//            strNickName = [nickName UTF8String];
//        }
//
//        string strMsg;
//        if (nil != msg) {
//            strMsg = [msg UTF8String];
//        }
//
//        result = self.client->SendToast(reqId, strRoomId, strNickName, strMsg);
//    }
//    return result;
//}
//
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

//- (BOOL)sendCancelPrivateLiveInvite:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId {
//    BOOL result = NO;
//    if (NULL != self.client) {
//
//        string strInviteId;
//        if (nil != inviteId) {
//            strInviteId = [inviteId UTF8String];
//        }
//
//        result = self.client->SendCancelPrivateLiveInvite(reqId, strInviteId);
//    }
//
//    return result;
//}
//
//- (BOOL)sendInstantInviteUserReport:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId isShow:(BOOL)isShow {
//    BOOL result = NO;
//    if (NULL != self.client) {
//
//        string strInviteId;
//        if (nil != inviteId) {
//            strInviteId = [inviteId UTF8String];
//        }
//
//        result = self.client->SendInstantInviteUserReport(reqId, strInviteId, isShow);
//    }
//
//    return result;
//}
//
//- (BOOL)sendTalent:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId {
//    BOOL result = NO;
//    if (NULL != self.client) {
//
//        string strRoomId;
//        if (nil != roomId) {
//            strRoomId = [roomId UTF8String];
//        }
//
//        string strTalentId;
//        if (nil != talentId) {
//            strTalentId = [talentId UTF8String];
//        }
//
//        result = self.client->SendTalent(reqId, strRoomId, strTalentId);
//    }
//
//    return result;
//}
//
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
        NSMutableArray *nsManPushUrl = [NSMutableArray array];
        for (list<string>::const_iterator iter = item.pushUrl.begin(); iter != item.pushUrl.end(); iter++) {
            string strUrl = (*iter);
            NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
            [nsManPushUrl addObject:pushUrl];
        }
        obj.pushUrl = nsManPushUrl;
        obj.leftSeconds = item.leftSeconds;
        obj.maxFansiNum = item.maxFansiNum;
    
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

//- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const RoomInfoItem &)item {
//    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
//    ImLiveRoomObject *obj = [[ImLiveRoomObject alloc] init];
//    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
//    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
//    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
//    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
//    //NSString* nsManPushUrl = [NSString stringWithUTF8String:manPushUrl.c_str()];
//
//    NSMutableArray *nsVideoUrls = [NSMutableArray array];
//    for (list<string>::const_iterator iter = item.videoUrl.begin(); iter != item.videoUrl.end(); iter++) {
//        string nsVideoUrl = (*iter);
//        NSString *videoUrl = [NSString stringWithUTF8String:nsVideoUrl.c_str()];
//        [nsVideoUrls addObject:videoUrl];
//    }
//    obj.videoUrls = nsVideoUrls;
//    obj.roomType = item.roomType;
//    obj.credit = item.credit;
//    obj.usedVoucher = item.usedVoucher;
//    obj.fansNum = item.fansNum;
//    NSMutableArray *numArrayEmo = [NSMutableArray array];
//    for (list<int>::const_iterator iter = item.emoTypeList.begin(); iter != item.emoTypeList.end(); iter++) {
//        int num = (*iter);
//        NSNumber *numEmo = [NSNumber numberWithInt:num];
//        [numArrayEmo addObject:numEmo];
//    }
//    obj.emoTypeList = numArrayEmo;
//    obj.loveLevel = item.loveLevel;
//
//    RebateInfoObject *itemObject = [RebateInfoObject alloc];
//    itemObject.curCredit = item.rebateInfo.curCredit;
//    itemObject.curTime = item.rebateInfo.curTime;
//    itemObject.preCredit = item.rebateInfo.preCredit;
//    itemObject.preTime = item.rebateInfo.preTime;
//    obj.rebateInfo = itemObject;
//    obj.favorite = item.favorite;
//    obj.leftSeconds = item.leftSeconds;
//    obj.waitStart = item.waitStart;
//
//    NSMutableArray *nsManPushUrl = [NSMutableArray array];
//    for (list<string>::const_iterator iter = item.manPushUrl.begin(); iter != item.manPushUrl.end(); iter++) {
//        string strUrl = (*iter);
//        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
//        [nsManPushUrl addObject:pushUrl];
//    }
//    obj.manPushUrl = nsManPushUrl;
//    obj.roomPrice = item.roomPrice;
//    obj.manPushPrice = item.manPushPrice;
//    obj.maxFansiNum = item.maxFansiNum;
//    obj.manLevel = item.manlevel;
//    obj.honorId = [NSString stringWithUTF8String:item.honorId.c_str()];
//    obj.honorImg = [NSString stringWithUTF8String:item.honorImg.c_str()];
//    obj.popPrice = item.popPrice;
//    obj.useCoupon = item.useCoupon;
//    obj.shareLink = [NSString stringWithUTF8String:item.shareLink.c_str()];
//
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onPublicRoomIn:success:err:errMsg:item:)]) {
//                [delegate onPublicRoomIn:reqId success:success err:err errMsg:nsErrMsg item:obj];
//            }
//        }
//    }
//}
//
//- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg manPushUrl:(const list<string> &)manPushUrl {
//    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
//    NSMutableArray *nsManPushUrl = [NSMutableArray array];
//    for (list<string>::const_iterator iter = manPushUrl.begin(); iter != manPushUrl.end(); iter++) {
//        string strUrl = (*iter);
//        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
//        [nsManPushUrl addObject:pushUrl];
//    }
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onControlManPush:success:err:errMsg:manPushUrl:)]) {
//                [delegate onControlManPush:reqId success:success err:err errMsg:nsErrMsg manPushUrl:nsManPushUrl];
//            }
//        }
//    }
//}


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

- (void)onZBRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum{
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
            if ([delegate respondsToSelector:@selector(onZBRecvEnterRoomNotice:userId:nickName:photoUrl:riderId:riderName:riderUrl:fansNum:)]) {
                [delegate onZBRecvEnterRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl riderId:nsRiderId riderName:nsRiderName riderUrl:nsRiderUrl fansNum:fansNum];
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

//- (void)onRecvRebateInfoNotice:(const string &)roomId rebateInfo:(const RebateInfoItem &)rebateInfo {
//    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
//
//    RebateInfoObject *itemObject = [RebateInfoObject alloc];
//    itemObject.curCredit = rebateInfo.curCredit;
//    itemObject.curTime = rebateInfo.curTime;
//    itemObject.preCredit = rebateInfo.preCredit;
//    itemObject.preTime = rebateInfo.preTime;
//
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onRecvRebateInfoNotice:rebateInfo:)]) {
//                [delegate onRecvRebateInfoNotice:nsRoomId rebateInfo:itemObject];
//            }
//        }
//    }
//}
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

//- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit {
//    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
//    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
//
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onRecvLackOfCreditNotice:msg:credit:)]) {
//                [delegate onRecvLackOfCreditNotice:nsRoomId msg:nsMsg credit:credit];
//            }
//        }
//    }
//}
//
//- (void)onRecvCreditNotice:(const string &)roomId credit:(double)credit {
//    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
//
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onRecvCreditNotice:credit:)]) {
//                [delegate onRecvCreditNotice:nsRoomId credit:credit];
//            }
//        }
//    }
//}
//
//- (void)onRecvWaitStartOverNotice:(const StartOverRoomItem &)item {
//    ImStartOverRoomObject *obj = [[ImStartOverRoomObject alloc] init];
//    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
//    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
//    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
//    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
//    obj.leftSeconds = item.leftSeconds;
//    NSMutableArray *nsPlayUrl = [NSMutableArray array];
//    for (list<string>::const_iterator iter = item.playUrl.begin(); iter != item.playUrl.end(); iter++) {
//        string strUrl = (*iter);
//        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
//        [nsPlayUrl addObject:pushUrl];
//    }
//    obj.playUrl = nsPlayUrl;
//
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onRecvWaitStartOverNotice:)]) {
//                [delegate onRecvWaitStartOverNotice:obj];
//            }
//        }
//    }
//}
//
//- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const list<string> &)playUrl {
//    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
//    //NSString *nsPlayUrl = [NSString stringWithUTF8String:playUrl.c_str()];
//    NSMutableArray *nsPlayUrl = [NSMutableArray array];
//    for (list<string>::const_iterator iter = playUrl.begin(); iter != playUrl.end(); iter++) {
//        string strUrl = (*iter);
//        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
//        [nsPlayUrl addObject:pushUrl];
//    }
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onRecvChangeVideoUrl:isAnchor:playUrl:)]) {
//                [delegate onRecvChangeVideoUrl:nsRoomId isAnchor:isAnchor playUrl:nsPlayUrl];
//            }
//        }
//    }
//}
//
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
- (void)onZBRecvControlManPushNotice:(const ZBControlPushItem&)Item {
    ZBImControlPushItemObject * obj = [[ZBImControlPushItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:Item.roomId.c_str()];
    obj.userId = [NSString stringWithUTF8String:Item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:Item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:Item.avatarImg.c_str()];
    obj.control = Item.control;
    
    NSMutableArray *nsManVideoUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = Item.manVideoUrl.begin(); iter != Item.manVideoUrl.end(); iter++) {
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

@end
