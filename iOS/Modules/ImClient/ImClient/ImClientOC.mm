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
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const LoginReturnItem &)item;

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 直播间主动操作回调
- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const RoomInfoItem &)item;

- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 直播间接收操作回调
- (void)onRecvRoomCloseNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

- (void)onRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum honorImg:(const string &)honorImg isHasTicket:(BOOL)isHasTicket;

- (void)onRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum;

- (void)onRecvRebateInfoNotice:(const string &)roomId rebateInfo:(const RebateInfoItem &)rebateInfo;

- (void)onRecvLeavingPublicRoomNotice:(const string &)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg;

- (void)onRecvRoomKickoffNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit;

- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit;

- (void)onRecvCreditNotice:(const string &)roomId credit:(double)credit;

- (void)onRecvWaitStartOverNotice:(const StartOverRoomItem &)item;

- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const list<string> &)playUrl userId:(const string &)userId;

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const RoomInfoItem &)item;

- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg manPushUrl:(const list<string> &)manPushUrl;

- (void)onGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const PrivateInviteItem &)item;

#pragma mark - 直播间文本消息信息

- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

- (void)onRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl;

- (void)onRecvSendSystemNotice:(const string &)roomId msg:(const string &)msg link:(const string &)link type:(IMSystemType)type;

#pragma mark - 直播间礼物消息操作回调
- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;

- (void)onRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftName:(const string &)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(const string &)honorUrl;

#pragma mark - 直播间弹幕消息操作回调
- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit;

- (void)onRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl;

#pragma mark - 邀请私密直播
- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg invitationId:(const string &)invitationId timeOut:(int)timeOut roomId:(const string &)roomId;

- (void)onSendCancelPrivateLiveInvite:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg roomId:(const string &)roomId;

- (void)onRecvInstantInviteReplyNotice:(const string &)inviteId replyType:(ReplyType)replyType roomId:(const string &)roomId roomType:(RoomType)roomType anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

- (void)onRecvInstantInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

- (void)onRecvScheduledInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg;

- (void)onRecvSendBookingReplyNotice:(const BookingReplyItem &)item;

- (void)onRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg leftSeconds:(int)leftSeconds;

- (void)onSendInstantInviteUserReport:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg;

#pragma mark - 直播间才艺点播邀请
- (void)onSendTalent:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg talentInviteId:(const string &)talentInviteId talentId:(const string &)talentId;

- (void)onRecvSendTalentNotice:(const TalentReplyItem &)item;

- (void)onRecvTalentListNotice:(const string&)roomId introduction:(const string&)introduction;

#pragma mark - 公共

- (void)onRecvLevelUpNotice:(int)level;

- (void)onRecvLoveLevelUpNotice:(const IMLoveLevelItem &)loveLevel;

- (void)onRecvBackpackUpdateNotice:(const BackpackInfo &)item;

- (void)onRecvGetHonorNotice:(const string &)honorId honorUrl:(const string &)honorUrl;

// ------------- 多人互动直播间 -------------

- (void)onRecvRecommendHangoutNotice:(const IMRecommendHangoutItem&)item;

- (void)onRecvDealInviteHangoutNotice:(const IMRecvDealInviteItem&)item;

- (void)onEnterHangoutRoom:(SEQ_T)reqId succes:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const IMHangoutRoomItem&)item;

- (void)onLeaveHangoutRoom:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg;

- (void)onRecvEnterHangoutRoomNotice:(const IMRecvEnterRoomItem&)item;

- (void)onRecvLeaveHangoutRoomNotice:(const IMRecvLeaveRoomItem&)item;

- (void)onSendHangoutGift:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg credit:(double)credit;

- (void)onRecvHangoutGiftNotice:(const IMRecvHangoutGiftItem&)item;

- (void)onRecvKnockRequestNotice:(const IMKnockRequestItem&)item;

- (void)onRecvLackCreditHangoutNotice:(const IMLackCreditHangoutItem&)item;

- (void)onControlManPushHangout:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg manPushUrl:(const list<string>&)manPushUrl;

- (void)onSendHangoutLiveChat:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg;

- (void)onRecvHangoutChatNotice:(const IMRecvHangoutChatItem&)item;

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(const string&)roomId anchorId:(const string&)anchorId leftSecond:(int)leftSecond;

// ------------- 节目 -------------

- (void)onRecvProgramPlayNotice:(const IMProgramItem&)item type:(IMProgramNoticeType)type msg:(const string&)msg;

- (void)onRecvCancelProgramNotice:(const IMProgramItem&)item;

- (void)onRecvRetTicketNotice:(const IMProgramItem&)item leftCredit:(double)leftCredit;

// ------------- 信件 -------------
- (void)onRecvLoiNotice:(const string&)anchorId loiId:(const string&)loiId;
- (void)onRecvEMFNotice:(const string&)anchorId emfId:(const string&)emfId;

@end

class ImClientCallback : public IImClientListener {
  public:
    ImClientCallback(ImClientOC *clientOC) {
        this->clientOC = clientOC;
    };
    virtual ~ImClientCallback(){};

  public:
    virtual void OnLogin(LCC_ERR_TYPE err, const string &errmsg, const LoginReturnItem &item) override {
        if (nil != clientOC) {
            [clientOC onLogin:err errMsg:errmsg item:item];
            
        }
    }
    virtual void OnLogout(LCC_ERR_TYPE err, const string &errmsg) override {
        if (nil != clientOC) {
            [clientOC onLogout:err errMsg:errmsg];
        }
    }
    virtual void OnKickOff(LCC_ERR_TYPE err, const string &errmsg) override {
        if (nil != clientOC) {
            [clientOC onKickOff:err errMsg:errmsg];
        }
    }
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const RoomInfoItem &item) override {
        if (nil != clientOC) {
            [clientOC onRoomIn:success reqId:reqId errType:err errMsg:errMsg item:item];
        }
    }
    virtual void OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg) override {
        if (nil != clientOC) {
            [clientOC onRoomOut:success reqId:reqId errType:err errMsg:errMsg];
        }
    }

    virtual void OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg) override {
        if (nil != clientOC) {
            [clientOC onSendLiveChat:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    virtual void OnRecvRoomCloseNotice(const string &roomId, LCC_ERR_TYPE err, const string &errMsg) override {
        if (nil != clientOC) {
            [clientOC onRecvRoomCloseNotice:roomId errType:err errMsg:errMsg];
        }
    }

    virtual void OnRecvEnterRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, const string &riderId, const string &riderName, const string &riderUrl, int fansNum, const string &honorImg, bool isHasTicket) override {
        if (nil != clientOC) {
            [clientOC onRecvEnterRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl riderId:riderId riderName:riderName riderUrl:riderUrl fansNum:fansNum honorImg:honorImg isHasTicket:isHasTicket];
        }
    }
    virtual void OnRecvLeaveRoomNotice(const string &roomId, const string &userId, const string &nickName, const string &photoUrl, int fansNum) override {
        if (nil != clientOC) {
            [clientOC onRecvLeaveRoomNotice:roomId userId:userId nickName:nickName photoUrl:photoUrl fansNum:fansNum];
        }
    }

    virtual void OnRecvRebateInfoNotice(const string &roomId, const RebateInfoItem &item) override {
        if (nil != clientOC) {
            [clientOC onRecvRebateInfoNotice:roomId rebateInfo:item];
        }
    }

    virtual void OnRecvLeavingPublicRoomNotice(const string &roomId, int leftSeconds, LCC_ERR_TYPE err, const string &errMsg) override {
        if (nil != clientOC) {
            [clientOC onRecvLeavingPublicRoomNotice:roomId leftSeconds:leftSeconds err:err errMsg:errMsg];
        }
    }

    virtual void OnRecvRoomKickoffNotice(const string &roomId, LCC_ERR_TYPE err, const string &errMsg, double credit) override {
        if (nil != clientOC) {
            [clientOC onRecvRoomKickoffNotice:roomId errType:err errMsg:errMsg credit:credit];
        }
    }

    virtual void OnRecvLackOfCreditNotice(const string &roomId, const string &msg, double credit) override {
        if (nil != clientOC) {
            [clientOC onRecvLackOfCreditNotice:roomId msg:msg credit:credit];
        }
    }

    virtual void OnRecvCreditNotice(const string &roomId, double credit) override {
        if (nil != clientOC) {
            [clientOC onRecvCreditNotice:roomId credit:credit];
        }
    }

    virtual void OnRecvWaitStartOverNotice(const StartOverRoomItem &item) override {
        //        NSLog(@"ImClientCallback::OnRecvWaitStartOverNotice() roomId:%s leftSeconds;%d", roomId.c_str(), leftSeconds);
        if (nil != clientOC) {
            [clientOC onRecvWaitStartOverNotice:item];
        }
    }

    virtual void OnRecvChangeVideoUrl(const string &roomId, bool isAnchor, const list<string> &playUrl, const string& userId) override {
        if (nil != clientOC) {
            [clientOC onRecvChangeVideoUrl:roomId isAnchor:isAnchor playUrl:playUrl userId:userId];
        }
    };
    
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const RoomInfoItem &item) override {
        if (nil != clientOC) {
            [clientOC onPublicRoomIn:reqId success:success err:err errMsg:errMsg item:item];
        }
    }

    virtual void OnRecvSendChatNotice(const string &roomId, int level, const string &fromId, const string &nickName, const string &msg, const string &honorUrl) override {
        if (nil != clientOC) {
            [clientOC onRecvSendChatNotice:roomId level:level fromId:fromId nickName:nickName msg:msg honorUrl:honorUrl];
        }
    }

    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const list<string> &manPushUrl) override {
        if (nil != clientOC) {
            [clientOC onControlManPush:reqId success:success err:err errMsg:errMsg manPushUrl:manPushUrl];
        }
    };

    virtual void OnGetInviteInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const PrivateInviteItem &item) override {
        if (nil != clientOC) {
            [clientOC onGetInviteInfo:reqId success:success err:err errMsg:errMsg item:item];
        }
    };

    virtual void OnRecvSendSystemNotice(const string &roomId, const string &msg, const string &link, IMSystemType type) override {
        if (nil != clientOC) {
            [clientOC onRecvSendSystemNotice:roomId msg:msg link:link type:type];
        }
    }

    // ------------- 直播间点赞 -------------
    virtual void OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, double credit, double rebateCredit) override {
        if (nil != clientOC) {
            [clientOC onSendGift:success reqId:reqId errType:err errMsg:errMsg credit:credit rebateCredit:rebateCredit];
        }
    }

    virtual void OnRecvSendGiftNotice(const string &roomId, const string &fromId, const string &nickName, const string &giftId, const string &giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string &honorUrl) override {
        if (nil != clientOC) {
            [clientOC onRecvSendGiftNotice:roomId fromId:fromId nickName:nickName giftId:giftId giftName:giftName giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id honorUrl:honorUrl];
        }
    }

    // ------------- 直播间弹幕消息 -------------
    virtual void OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, double credit, double rebateCredit) override {
        if (nil != clientOC) {
            [clientOC onSendToast:success reqId:reqId errType:err errMsg:errMsg credit:credit rebateCredit:rebateCredit];
        }
    }

    virtual void OnRecvSendToastNotice(const string &roomId, const string &fromId, const string &nickName, const string &msg, const string &honorUrl) override {
        if (nil != clientOC) {
            [clientOC onRecvSendToastNotice:roomId fromId:fromId nickName:nickName msg:msg honorUrl:honorUrl];
        }
    }

    // ------------- 邀请私密直播 -------------
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &invitationId, int timeOut, const string &roomId) override {
        if (nil != clientOC) {
            [clientOC onSendPrivateLiveInvite:success reqId:reqId err:err errMsg:errMsg invitationId:invitationId timeOut:timeOut roomId:roomId];
        }
    }

    virtual void OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &roomId) override {
        if (nil != clientOC) {
            [clientOC onSendCancelPrivateLiveInvite:success reqId:reqId err:err errMsg:errMsg roomId:roomId];
        }
    }

    virtual void OnRecvInstantInviteReplyNotice(const string &inviteId, ReplyType replyType, const string &roomId, RoomType roomType, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) override {
        if (nil != clientOC) {
            [clientOC onRecvInstantInviteReplyNotice:inviteId replyType:replyType roomId:roomId roomType:roomType anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

    virtual void OnRecvInstantInviteUserNotice(const string &inviteId, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) override {
        if (nil != clientOC) {
            [clientOC onRecvInstantInviteUserNotice:inviteId anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

    virtual void OnRecvScheduledInviteUserNotice(const string &inviteId, const string &anchorId, const string &nickName, const string &avatarImg, const string &msg) override {
        if (nil != clientOC) {
            [clientOC onRecvScheduledInviteUserNotice:inviteId anchorId:anchorId nickName:nickName avatarImg:avatarImg msg:msg];
        }
    }

    virtual void OnRecvSendBookingReplyNotice(const BookingReplyItem &item) override {
        if (nil != clientOC) {
            [clientOC onRecvSendBookingReplyNotice:item];
        }
    }

    virtual void OnRecvBookingNotice(const string &roomId, const string &userId, const string &nickName, const string &avatarImg, int leftSeconds) override {
        if (nil != clientOC) {
            [clientOC onRecvBookingNotice:roomId userId:userId nickName:nickName avatarImg:avatarImg leftSeconds:leftSeconds];
        }
    }
    
    virtual void OnSendInstantInviteUserReport(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override {
        if (nil != clientOC) {
            [clientOC onSendInstantInviteUserReport:success reqId:reqId err:err errMsg:errMsg];
        }
    }
    // ------------- 直播间才艺点播邀请 -------------
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string &errMsg, const string &talentInviteId, const string &talentId) override {
        if (nil != clientOC) {
            [clientOC onSendTalent:reqId success:success err:err errMsg:errMsg talentInviteId:talentInviteId talentId:talentId];
        }
    }

    virtual void OnRecvSendTalentNotice(const TalentReplyItem &item) override {
        if (nil != clientOC) {
            [clientOC onRecvSendTalentNotice:item];
        }
    }
    
    virtual void OnRecvTalentListNotice(const string& roomId, const string& introduction) override{
        if (nil != clientOC) {
            [clientOC onRecvTalentListNotice:roomId introduction:introduction];
        }
    }

    // ------------- 公共 -------------

    virtual void OnRecvLevelUpNotice(int level) override {
        if (nil != clientOC) {
            [clientOC onRecvLevelUpNotice:level];
        }
    }

    virtual void OnRecvLoveLevelUpNotice(const IMLoveLevelItem& loveLevelItem) override {
        if (nil != clientOC) {
            [clientOC onRecvLoveLevelUpNotice:loveLevelItem];
        }
    }

    virtual void OnRecvBackpackUpdateNotice(const BackpackInfo &item) override {
        if (nil != clientOC) {
            [clientOC onRecvBackpackUpdateNotice:item];
        }
    }
    
    virtual void OnRecvGetHonorNotice(const string& honorId, const string& honorUrl) override {
        if (nil != clientOC) {
            [clientOC onRecvGetHonorNotice:honorId honorUrl:honorUrl];
        }
    }
    
    // ------------- 多人互动直播间 -------------
    virtual void OnRecvRecommendHangoutNotice(const IMRecommendHangoutItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvRecommendHangoutNotice:item];
        }
    }

    virtual void OnRecvDealInviteHangoutNotice(const IMRecvDealInviteItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvDealInviteHangoutNotice:item];
        }
    }

    virtual void OnEnterHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const IMHangoutRoomItem& item) override {
        if (nil != clientOC) {
            [clientOC onEnterHangoutRoom:reqId succes:success err:err errMsg:errMsg item:item];
        }
    }

    virtual void OnLeaveHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override {
        if (nil != clientOC) {
            [clientOC onLeaveHangoutRoom:reqId success:success err:err errMsg:errMsg];
        }
    }

    virtual void OnRecvEnterHangoutRoomNotice(const IMRecvEnterRoomItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvEnterHangoutRoomNotice:item];
        }
    }

    virtual void OnRecvLeaveHangoutRoomNotice(const IMRecvLeaveRoomItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvLeaveHangoutRoomNotice:item];
        }
    }

    virtual void OnSendHangoutGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit) override {
        if (nil != clientOC) {
            [clientOC onSendHangoutGift:reqId success:success err:err errMsg:errMsg credit:credit];
        }
    }

    virtual void OnRecvHangoutGiftNotice(const IMRecvHangoutGiftItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvHangoutGiftNotice:item];
        }
    }

    virtual void OnRecvKnockRequestNotice(const IMKnockRequestItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvKnockRequestNotice:item];
        }
    }

    virtual void OnRecvLackCreditHangoutNotice(const IMLackCreditHangoutItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvLackCreditHangoutNotice:item];
        }
    }
    
    virtual void OnControlManPushHangout(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override {
        if (nil != clientOC) {
            [clientOC onControlManPushHangout:reqId success:success err:err errMsg:errMsg manPushUrl:manPushUrl];
        }
    }
    
    virtual void OnSendHangoutLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override {
        if (nil != clientOC) {
            [clientOC onSendHangoutLiveChat:reqId success:success err:err errMsg:errMsg];
        }
    }
    
    virtual void OnRecvHangoutChatNotice(const IMRecvHangoutChatItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvHangoutChatNotice:item];
        }
    }
    
    virtual void OnRecvAnchorCountDownEnterHangoutRoomNotice(const string& roomId, const string& anchorId, int leftSecond) override {
        if (nil != clientOC) {
            [clientOC onRecvAnchorCountDownEnterHangoutRoomNotice:roomId anchorId:anchorId leftSecond:leftSecond];
        }
    }

    // ------------- 节目 -------------
    virtual void OnRecvProgramPlayNotice(const IMProgramItem& item, IMProgramNoticeType type, const string& msg) override {
        if (nil != clientOC) {
            [clientOC onRecvProgramPlayNotice:item type:type msg:msg];
        }
    }

    virtual void OnRecvCancelProgramNotice(const IMProgramItem& item) override {
        if (nil != clientOC) {
            [clientOC onRecvCancelProgramNotice:item];
        }
    }

    virtual void OnRecvRetTicketNotice(const IMProgramItem& item, double leftCredit) override {
        if (nil != clientOC) {
            [clientOC onRecvRetTicketNotice:item leftCredit:leftCredit];
        }
    }
    
   // ------------- 信件 -------------
   virtual void OnRecvLoiNotice(const string& anchorId, const string& loiId) override {
       if (nil != clientOC) {
           [clientOC onRecvLoiNotice:anchorId loiId:loiId];
       }
   }
    
    virtual void OnRecvEMFNotice(const string& anchorId, const string& emfId) override {
        if (nil != clientOC) {
            [clientOC onRecvEMFNotice:anchorId emfId:emfId];
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
    NSLog(@"ImClientOC::addDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
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

    NSLog(@"ImClientOC::removeDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
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

        string strToken = "";
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

        string strRoomId = "";
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

        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->RoomOut(reqId, strRoomId);
    }
    return result;
}

- (BOOL)publicRoomIn:(SEQ_T)reqId userId:(NSString *_Nonnull)userId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strUserId = "";
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }

        result = self.client->PublicRoomIn(reqId, strUserId);
    }
    return result;
}

- (BOOL)controlManPush:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId control:(IMControlType)control {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->ControlManPush(reqId, strRoomId, control);
    }
    return result;
}

- (BOOL)getInviteInfo:(SEQ_T)reqId invitationId:(NSString *_Nonnull)invitationId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strInvitationId = "";
        if (nil != invitationId) {
            strInvitationId = [invitationId UTF8String];
        }

        result = self.client->GetInviteInfo(reqId, strInvitationId);
    }
    return result;
}

- (BOOL)sendLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strName = "";
        if (nil != nickName) {
            strName = [nickName UTF8String];
        }
        string strMsg = "";
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

- (BOOL)sendGift:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
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

        string strGiftId = "";
        if (nil != giftId) {
            strGiftId = [giftId UTF8String];
        }

        string strGiftName = "";
        if (nil != giftName) {
            strGiftName = [giftName UTF8String];
        }

        result = self.client->SendGift(reqId, strRoomId, strNickName, strGiftId, strGiftName, isBackPack, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    }
    return result;
}

- (BOOL)sendToast:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
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

        string strMsg = "";
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }

        result = self.client->SendToast(reqId, strRoomId, strNickName, strMsg);
    }
    return result;
}

- (BOOL)sendPrivateLiveInvite:(SEQ_T)reqId userId:(NSString *)userId logId:(NSString *)logId force:(BOOL)force {
    BOOL result = NO;
    if (NULL != self.client) {

        string strUserId = "";
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }
        string strLogId = "";
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

        string strInviteId = "";
        if (nil != inviteId) {
            strInviteId = [inviteId UTF8String];
        }

        result = self.client->SendCancelPrivateLiveInvite(reqId, strInviteId);
    }

    return result;
}

- (BOOL)sendInstantInviteUserReport:(SEQ_T)reqId inviteId:(NSString *_Nonnull)inviteId isShow:(BOOL)isShow {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strInviteId = "";
        if (nil != inviteId) {
            strInviteId = [inviteId UTF8String];
        }
        
        result = self.client->SendInstantInviteUserReport(reqId, strInviteId, isShow);
    }
    
    return result;
}

- (BOOL)sendTalent:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId {
    BOOL result = NO;
    if (NULL != self.client) {

        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        string strTalentId = "";
        if (nil != talentId) {
            strTalentId = [talentId UTF8String];
        }

        result = self.client->SendTalent(reqId, strRoomId, strTalentId);
    }

    return result;
}

// ------------- 多人互动 -------------
- (BOOL)enterHangoutRoom:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->EnterHangoutRoom(reqId, strRoomId);
    }
    
    return result;
}

- (BOOL)leaveHangoutRoom:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId {
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->LeaveHangoutRoom(reqId, strRoomId);
    }
    
    return result;
}

- (BOOL)sendHangoutGift:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName toUid:(NSString* _Nonnull)toUid giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate{
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
        
        result = self.client->SendHangoutGift(reqId, strRoomId, strNickName, strToUid, strGiftId, strGiftName, isBackPack, giftNum, isMultiClick, multiClickStart, multiClickEnd, multiClickId, isPrivate);
    }
    return result;
}

- (BOOL)controlManPushHangout:(SEQ_T)reqId roomId:(NSString* _Nonnull)roomId control:(IMControlType)control {
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }

        result = self.client->ControlManPushHangout(reqId, strRoomId, control);
    }
    return result;
}

- (BOOL)SendHangoutLiveChat:(SEQ_T)reqId roomId:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    BOOL result = NO;
    if (NULL != self.client) {
        string strRoomId = "";
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strName = "";
        if (nil != nickName) {
            strName = [nickName UTF8String];
        }
        string strMsg = "";
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }
        
        list<string> strAts;
        for (NSString *strId in at) {
            if (nil != strId) {
                strAts.push_back([strId UTF8String]);
            }
        }
        
        result = self.client->SendHangoutLiveChat(reqId, strRoomId, strName, strMsg, strAts);
    }
    return result;
}

#pragma mark - 登录/注销回调

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const LoginReturnItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ImLoginReturnObject *obj = [[ImLoginReturnObject alloc] init];
    NSMutableArray *nsRoomList = [NSMutableArray array];
    for (LSLoginRoomList::const_iterator iter = item.roomList.begin(); iter != item.roomList.end(); iter++) {
        ImLoginRoomObject *roomItem = [[ImLoginRoomObject alloc] init];
        roomItem.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
        roomItem.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
        roomItem.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
        [nsRoomList addObject:roomItem];
    }
    obj.roomList = nsRoomList;

    NSMutableArray *nsInviteList = [NSMutableArray array];
    for (InviteList::const_iterator iter = item.inviteList.begin(); iter != item.inviteList.end(); iter++) {
        ImInviteIdItemObject *inviteIdItem = [[ImInviteIdItemObject alloc] init];
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
        ImScheduleRoomObject *scheduleRoom = [[ImScheduleRoomObject alloc] init];
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
    
    NSMutableArray *nsOngoingShowList = [NSMutableArray array];
    for (OngoingShowList::const_iterator iter = item.ongoingShowList.begin(); iter != item.ongoingShowList.end(); iter++) {
        IMOngoingShowItemObject *OngoingShow= [[IMOngoingShowItemObject alloc] init];
        IMProgramItemObject* programObj = [[IMProgramItemObject alloc] init];
        programObj.showLiveId = [NSString stringWithUTF8String:(*iter).showInfo.showLiveId.c_str()];
        programObj.anchorId = [NSString stringWithUTF8String:(*iter).showInfo.anchorId.c_str()];
        programObj.anchorNickName = [NSString stringWithUTF8String:(*iter).showInfo.anchorNickName.c_str()];
        programObj.anchorAvatar = [NSString stringWithUTF8String:(*iter).showInfo.anchorAvatar.c_str()];
        programObj.showTitle = [NSString stringWithUTF8String:(*iter).showInfo.showTitle.c_str()];
        programObj.showIntroduce = [NSString stringWithUTF8String:(*iter).showInfo.showIntroduce.c_str()];
        programObj.cover = [NSString stringWithUTF8String:(*iter).showInfo.cover.c_str()];
        programObj.approveTime = (*iter).showInfo.approveTime;
        programObj.startTime = (*iter).showInfo.startTime;
        programObj.duration = (*iter).showInfo.duration;
        programObj.leftSecToStart = (*iter).showInfo.leftSecToStart;
        programObj.leftSecToEnter = (*iter).showInfo.leftSecToEnter;
        programObj.price = (*iter).showInfo.price;
        programObj.status = (*iter).showInfo.status;
        programObj.ticketStatus = (*iter).showInfo.ticketStatus;
        programObj.isHasFollow = (*iter).showInfo.isHasFollow;
        programObj.isTicketFull = (*iter).showInfo.isTicketFull;
        OngoingShow.showInfo = programObj;
        OngoingShow.type = (*iter).type;
        OngoingShow.msg = [NSString stringWithUTF8String:(*iter).msg.c_str()];
        [nsOngoingShowList addObject:OngoingShow];
    }
    obj.ongoingShowList = nsOngoingShowList;
    

    @synchronized(self) {
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
    @synchronized(self) {
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
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onKickOff:errMsg:)]) {
                [delegate onKickOff:errType errMsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 直播间主动操作回调

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(const RoomInfoItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    ImLiveRoomObject *obj = [[ImLiveRoomObject alloc] init];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
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
    obj.manLevel = item.manlevel;
    obj.honorId = [NSString stringWithUTF8String:item.honorId.c_str()];
    obj.honorImg = [NSString stringWithUTF8String:item.honorImg.c_str()];
    obj.popPrice = item.popPrice;
    obj.useCoupon = item.useCoupon;
    obj.shareLink = @"";
    obj.liveShowType = item.liveShowType;
    obj.isHasTalent = item.isHasTalent;
    @synchronized(self) {
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
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRoomOut:reqId:errType:errMsg:)]) {
                [delegate onRoomOut:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const RoomInfoItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    ImLiveRoomObject *obj = [[ImLiveRoomObject alloc] init];
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
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
    obj.manLevel = item.manlevel;
    obj.honorId = [NSString stringWithUTF8String:item.honorId.c_str()];
    obj.honorImg = [NSString stringWithUTF8String:item.honorImg.c_str()];
    obj.popPrice = item.popPrice;
    obj.useCoupon = item.useCoupon;
    obj.shareLink = [NSString stringWithUTF8String:item.shareLink.c_str()];
    obj.liveShowType = item.liveShowType;
    obj.isHasTalent = NO;

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onPublicRoomIn:success:err:errMsg:item:)]) {
                [delegate onPublicRoomIn:reqId success:success err:err errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg manPushUrl:(const list<string> &)manPushUrl {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = manPushUrl.begin(); iter != manPushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onControlManPush:success:err:errMsg:manPushUrl:)]) {
                [delegate onControlManPush:reqId success:success err:err errMsg:nsErrMsg manPushUrl:nsManPushUrl];
            }
        }
    }
}

- (void)onGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg item:(const PrivateInviteItem &)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    ImInviteIdItemObject *obj = [[ImInviteIdItemObject alloc] init];
    ImInviteIdItemObject *inviteIdItem = [[ImInviteIdItemObject alloc] init];
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
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetInviteInfo:success:err:errMsg:item:)]) {
                [delegate onGetInviteInfo:reqId success:success err:err errMsg:nsErrMsg item:obj];
            }
        }
    }
}

#pragma mark - 直播间接收操作回调

- (void)onRecvRoomCloseNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRoomCloseNotice:errType:errMsg:)]) {
                [delegate onRecvRoomCloseNotice:nsRoomId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvEnterRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl riderId:(const string &)riderId riderName:(const string &)riderName riderUrl:(const string &)riderUrl fansNum:(int)fansNum honorImg:(const string &)honorImg isHasTicket:(BOOL)isHasTicket{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    NSString *nsRiderId = [NSString stringWithUTF8String:riderId.c_str()];
    NSString *nsRiderName = [NSString stringWithUTF8String:riderName.c_str()];
    NSString *nsRiderUrl = [NSString stringWithUTF8String:riderUrl.c_str()];
    NSString *nsHonorImg = [NSString stringWithUTF8String:honorImg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEnterRoomNotice:userId:nickName:photoUrl:riderId:riderName:riderUrl:fansNum:honorImg:isHasTicket:)]) {
                [delegate onRecvEnterRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl riderId:nsRiderId riderName:nsRiderName riderUrl:nsRiderUrl fansNum:fansNum honorImg:nsHonorImg isHasTicket:isHasTicket];
            }
        }
    }
}

- (void)onRecvLeaveRoomNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName photoUrl:(const string &)photoUrl fansNum:(int)fansNum {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    @synchronized(self) {
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

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRebateInfoNotice:rebateInfo:)]) {
                [delegate onRecvRebateInfoNotice:nsRoomId rebateInfo:itemObject];
            }
        }
    }
}

- (void)onRecvLeavingPublicRoomNotice:(const string &)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLeavingPublicRoomNotice:leftSeconds:err:errMsg:)]) {
                [delegate onRecvLeavingPublicRoomNotice:nsRoomId leftSeconds:leftSeconds err:err errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvRoomKickoffNotice:(const string &)roomId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRoomKickoffNotice:errType:errmsg:credit:)]) {
                [delegate onRecvRoomKickoffNotice:nsRoomId errType:errType errmsg:nsErrMsg credit:credit];
            }
        }
    }
}

- (void)onRecvLackOfCreditNotice:(const string &)roomId msg:(const string &)msg credit:(double)credit {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];

    @synchronized(self) {
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

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCreditNotice:credit:)]) {
                [delegate onRecvCreditNotice:nsRoomId credit:credit];
            }
        }
    }
}

- (void)onRecvWaitStartOverNotice:(const StartOverRoomItem &)item {
    ImStartOverRoomObject *obj = [[ImStartOverRoomObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
    obj.leftSeconds = item.leftSeconds;
    NSMutableArray *nsPlayUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.playUrl.begin(); iter != item.playUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsPlayUrl addObject:pushUrl];
    }
    obj.playUrl = nsPlayUrl;

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvWaitStartOverNotice:)]) {
                [delegate onRecvWaitStartOverNotice:obj];
            }
        }
    }
}

- (void)onRecvChangeVideoUrl:(const string &)roomId isAnchor:(bool)isAnchor playUrl:(const list<string> &)playUrl userId:(const string &)userId {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray *nsPlayUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = playUrl.begin(); iter != playUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsPlayUrl addObject:pushUrl];
    }
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvChangeVideoUrl:isAnchor:playUrl:userId:)]) {
                [delegate onRecvChangeVideoUrl:nsRoomId isAnchor:isAnchor playUrl:nsPlayUrl userId:nsUserId];
            }
        }
    }
}

#pragma mark - 直播间文本消息信息
- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendLiveChat:reqId:errType:errMsg:)]) {
                [delegate onSendLiveChat:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvSendChatNotice:(const string &)roomId level:(int)level fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg  honorUrl:(const string &)honorUrl{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendChatNotice:level:fromId:nickName:msg:honorUrl:)]) {
                [delegate onRecvSendChatNotice:nsRoomId level:level fromId:nsFromId nickName:nsNickName msg:nsMsg honorUrl:nsHonorUrl];
            }
        }
    }
}

- (void)onRecvSendSystemNotice:(const string &)roomId msg:(const string &)msg link:(const string &)link type:(IMSystemType)type{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsLink = [NSString stringWithUTF8String:link.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendSystemNotice:msg:link:type:)]) {
                [delegate onRecvSendSystemNotice:nsRoomId msg:nsMsg link:nsLink type:type];
            }
        }
    }
}

#pragma mark - 直播间礼物消息操作回调

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendGift:reqId:errType:errMsg:credit:rebateCredit:)]) {
                [delegate onSendGift:success reqId:reqId errType:errType errMsg:nsErrMsg credit:credit rebateCredit:rebateCredit];
            }
        }
    }
}

- (void)onRecvSendGiftNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName giftId:(const string &)giftId giftName:(const string &)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(const string &)honorUrl;
{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsGigtId = [NSString stringWithUTF8String:giftId.c_str()];
    NSString *nsGigtName = [NSString stringWithUTF8String:giftName.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendGiftNotice:fromId:nickName:giftId:giftName:giftNum:multi_click:multi_click_start:multi_click_end:multi_click_id:honorUrl:)]) {
                [delegate onRecvSendGiftNotice:nsRoomId fromId:nsFromId nickName:nsNickName giftId:nsGigtId giftName:nsGigtName giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id honorUrl:nsHonorUrl];
            }
        }
    }
}

#pragma mark - 直播间弹幕消息操作回调

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendToast:reqId:errType:errMsg:credit:rebateCredit:)]) {
                [delegate onSendToast:success reqId:reqId errType:errType errMsg:nsErrMsg credit:credit rebateCredit:rebateCredit];
            }
        }
    }
}

- (void)onRecvSendToastNotice:(const string &)roomId fromId:(const string &)fromId nickName:(const string &)nickName msg:(const string &)msg honorUrl:(const string &)honorUrl{
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    NSString *nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendToastNotice:fromId:nickName:msg:honorUrl:)]) {
                [delegate onRecvSendToastNotice:nsRoomId fromId:nsFromId nickName:nsNickName msg:nsMsg honorUrl:nsHonorUrl];
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
    @synchronized(self) {
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
    @synchronized(self) {
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
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvInstantInviteReplyNotice:replyType:roomId:roomType:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvInstantInviteReplyNotice:nsInviteId replyType:replyType roomId:nsRoomId roomType:roomType anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
            }
        }
    }
}

- (void)onRecvInstantInviteUserNotice:(const string &)inviteId anchorId:(const string &)anchorId nickName:(const string &)nickName avatarImg:(const string &)avatarImg msg:(const string &)msg {
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    NSString *nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvInstantInviteUserNotice:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvInstantInviteUserNotice:nsInviteId anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
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
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvScheduledInviteUserNotice:anchorId:nickName:avatarImg:msg:)]) {
                [delegate onRecvScheduledInviteUserNotice:nsInviteId anchorId:nsAnchorId nickName:nsNickName avatarImg:nsAvatarImg msg:nsMsg];
            }
        }
    }
}

- (void)onRecvSendBookingReplyNotice:(const BookingReplyItem &)item {
    ImBookingReplyObject *obj = [[ImBookingReplyObject alloc] init];
    obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
    obj.replyType = item.replyType;
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
    obj.msg = [NSString stringWithUTF8String:item.msg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSendBookingReplyNotice:)]) {
                [delegate onRecvSendBookingReplyNotice:obj];
            }
        }
    }
}

- (void)onRecvBookingNotice:(const string &)roomId userId:(const string &)userId nickName:(const string &)nickName avatarImg:(const string &)avatarImg leftSeconds:(int)leftSeconds {
    NSString *nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString *nsAvatarImg = [NSString stringWithUTF8String:avatarImg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvBookingNotice:userId:nickName:avatarImg:leftSeconds:)]) {
                [delegate onRecvBookingNotice:nsRoomId userId:nsUserId nickName:nsNickName avatarImg:nsAvatarImg leftSeconds:leftSeconds];
            }
        }
    }

}

- (void)onSendInstantInviteUserReport:(bool)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(const string &)errMsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendInstantInviteUserReport:reqId:err:errMsg:)]) {
                [delegate onSendInstantInviteUserReport:success reqId:reqId err:err errMsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 直播间才艺点播邀请
- (void)onSendTalent:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg talentInviteId:(const string&)talentInviteId talentId:(const string &)talentId{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString* nsTalentInviteId = [NSString stringWithUTF8String:talentInviteId.c_str()];
    NSString* nsTalentId = [NSString stringWithUTF8String:talentId.c_str()];
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendTalent:success:err:errMsg:talentInviteId:talentId:)] ) {
                [delegate onSendTalent:reqId success:success err:err errMsg:nsErrMsg talentInviteId:nsTalentInviteId talentId:nsTalentId];
            }
        }
    }
}

- (void)onRecvSendTalentNotice:(const TalentReplyItem&)item {
    ImTalentReplyObject* obj = [[ImTalentReplyObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.talentInviteId = [NSString stringWithUTF8String:item.talentInviteId.c_str()];
    obj.talentId = [NSString stringWithUTF8String:item.talentId.c_str()];
    obj.name = [NSString stringWithUTF8String:item.name.c_str()];
    obj.credit = item.credit;
    obj.status = item.status;
    obj.rebateCredit = item.rebateCredit;
    obj.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
    obj.giftName = [NSString stringWithUTF8String:item.giftName.c_str()];
    obj.giftNum = item.giftNum;
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvSendTalentNotice:)] ) {
                [delegate onRecvSendTalentNotice:obj];
            }
        }
    }
}

- (void)onRecvTalentListNotice:(const string&)roomId introduction:(const string&)introduction {
    NSString* strRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* strIntroduction = [NSString stringWithUTF8String:introduction.c_str()];
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvTalentPromptNotice:introduction:)] ) {
                [delegate onRecvTalentPromptNotice:strRoomId introduction:strIntroduction];
            }
        }
    }
}

#pragma mark - 公共
- (void)onRecvLevelUpNotice:(int)level {
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvLevelUpNotice:)] ) {
                [delegate onRecvLevelUpNotice:level];
            }
        }
    }
}

- (void)onRecvLoveLevelUpNotice:(const IMLoveLevelItem &)loveLevel {
    
    IMLoveLevelItemObject* itemObject = [[IMLoveLevelItemObject alloc] init];
    itemObject.loveLevel = loveLevel.loveLevel;
    itemObject.anchorId = [NSString stringWithUTF8String:loveLevel.anchorId.c_str()];
    itemObject.anchorName = [NSString stringWithUTF8String:loveLevel.anchorName.c_str()];
    
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvLoveLevelUpNotice:)] ) {
                [delegate onRecvLoveLevelUpNotice:itemObject];
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
    
    @synchronized(self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvBackpackUpdateNotice:)] ) {
                [delegate onRecvBackpackUpdateNotice:itemObject];
            }
        }
    }
}

- (void)onRecvGetHonorNotice:(const string &)honorId honorUrl:(const string &)honorUrl {
    NSString * nsHonorId = [NSString stringWithUTF8String:honorId.c_str()];
    NSString * nsHonorUrl = [NSString stringWithUTF8String:honorUrl.c_str()];
    @synchronized (self) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvGetHonorNotice:honorUrl:)] ) {
                [delegate onRecvGetHonorNotice:nsHonorId honorUrl:nsHonorUrl];
            }
        }
    }
}

// ------------- 多人互动直播间 -------------
- (void)onRecvRecommendHangoutNotice:(const IMRecommendHangoutItem&)item {
    IMRecommendHangoutItemObject* obj = [[IMRecommendHangoutItemObject alloc] init];
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
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRecommendHangoutNotice:)]) {
                [delegate onRecvRecommendHangoutNotice:obj];
            }
        }
    }

}

- (void)onRecvDealInviteHangoutNotice:(const IMRecvDealInviteItem&)item {
    IMRecvDealInviteItemObject* obj = [[IMRecvDealInviteItemObject alloc] init];
    obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.type = item.type;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvDealInviteHangoutNotice:)]) {
                [delegate onRecvDealInviteHangoutNotice:obj];
            }
        }
    }
}

- (void)onEnterHangoutRoom:(SEQ_T)reqId succes:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg item:(const IMHangoutRoomItem&)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    IMHangoutRoomItemObject *obj = [[IMHangoutRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.roomType = item.roomType;
    obj.manLevel = item.manLevel;
    obj.manPushPrice = item.manPushPrice;
    obj.credit = item.credit;
    NSMutableArray *nsPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.pushUrl.begin(); iter != item.pushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pullUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsPushUrl addObject:pullUrl];
    }
    obj.pushUrl = nsPushUrl;

    NSMutableArray *nsOtherAnchorList = [NSMutableArray array];
    for (IMOtherAnchorItemList::const_iterator iter = item.otherAnchorList.begin(); iter != item.otherAnchorList.end(); iter++) {
        IMLivingAnchorItemObject *otherObject = [[IMLivingAnchorItemObject alloc] init];
        otherObject.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
        otherObject.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
        otherObject.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
        otherObject.anchorStatus = (*iter).anchorStatus;
        otherObject.inviteId = [NSString stringWithUTF8String:(*iter).inviteId.c_str()];
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
    for (RecvGiftList::const_iterator iter = item.buyforList.begin(); iter != item.buyforList.end(); iter++) {
        IMRecvGiftItemObject *buyforObj = [[IMRecvGiftItemObject alloc] init];
        buyforObj.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
        NSMutableArray *nsNumList = [NSMutableArray array];
        for (GiftNumList::const_iterator iter1 = (*iter).buyforList.begin(); iter1 != (*iter).buyforList.end(); iter1++) {
            IMGiftNumItemObject *numObj = [[IMGiftNumItemObject alloc] init];
            numObj.giftId = [NSString stringWithUTF8String:(*iter1).giftId.c_str()];
            numObj.giftNum = (*iter1).giftNum;
            [nsNumList addObject:numObj];
           
        }
         buyforObj.buyforList = nsNumList;
        [nsBuyforList addObject:buyforObj];
    }
    obj.buyforList = nsBuyforList;


    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onEnterHangoutRoom:succes:err:errMsg:item:)]) {
                [delegate onEnterHangoutRoom:reqId succes:success err:err errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onLeaveHangoutRoom:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onLeaveHangoutRoom:success:err:errMsg:)]) {
                [delegate onLeaveHangoutRoom:reqId success:success err:err errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvEnterHangoutRoomNotice:(const IMRecvEnterRoomItem&)item {
    IMRecvEnterRoomItemObject* obj = [[IMRecvEnterRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.isAnchor = item.isAnchor;
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    IMUserInfoItemObject *userInfo = [[IMUserInfoItemObject alloc] init];
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
    for (GiftNumList::const_iterator iter1 = item.bugForList.begin(); iter1 != item.bugForList.end(); iter1++) {
        IMGiftNumItemObject *numObj = [[IMGiftNumItemObject alloc] init];
        numObj.giftId = [NSString stringWithUTF8String:(*iter1).giftId.c_str()];
        numObj.giftNum = numObj.giftNum;
        [nsNumList addObject:numObj];
    }
    obj.bugForList = nsNumList;

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEnterHangoutRoomNotice:)]) {
                [delegate onRecvEnterHangoutRoomNotice:obj];
            }
        }
    }
}

- (void)onRecvLeaveHangoutRoomNotice:(const IMRecvLeaveRoomItem&)item {
    IMRecvLeaveRoomItemObject* obj = [[IMRecvLeaveRoomItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.isAnchor = item.isAnchor;
    obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.errNo = item.errNo;
    obj.errMsg = [NSString stringWithUTF8String:item.errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLeaveHangoutRoomNotice:)]) {
                [delegate onRecvLeaveHangoutRoomNotice:obj];
            }
        }
    }
}

- (void)onSendHangoutGift:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg credit:(double)credit{
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendHangoutGift:success:err:errMsg:credit:)]) {
                [delegate onSendHangoutGift:reqId success:success err:err errMsg:nsErrMsg credit:credit];
            }
        }
    }
}

- (void)onRecvHangoutGiftNotice:(const IMRecvHangoutGiftItem&)item {
    IMRecvHangoutGiftItemObject* obj = [[IMRecvHangoutGiftItemObject alloc] init];
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
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvHangoutGiftNotice:)]) {
                [delegate onRecvHangoutGiftNotice:obj];
            }
        }
    }
}

- (void)onRecvKnockRequestNotice:(const IMKnockRequestItem&)item {
    IMKnockRequestItemObject* obj = [[IMKnockRequestItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    obj.age = item.age;
    obj.country = [NSString stringWithUTF8String:item.country.c_str()];
    obj.knockId = [NSString stringWithUTF8String:item.knockId.c_str()];
    obj.expire = item.expire;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvKnockRequestNotice:)]) {
                [delegate onRecvKnockRequestNotice:obj];
            }
        }
    }
}

- (void)onRecvLackCreditHangoutNotice:(const IMLackCreditHangoutItem&)item {
    IMLackCreditHangoutItemObject* obj = [[IMLackCreditHangoutItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item.avatarImg.c_str()];
    obj.errNo = item.errNo;
    obj.errMsg = [NSString stringWithUTF8String:item.errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLackCreditHangoutNotice:)]) {
                [delegate onRecvLackCreditHangoutNotice:obj];
            }
        }
    }
}

- (void)onControlManPushHangout:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg manPushUrl:(const list<string>&)manPushUrl {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = manPushUrl.begin(); iter != manPushUrl.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onControlManPushHangout:success:err:errMsg:manPushUrl:)]) {
                [delegate onControlManPushHangout:reqId success:success err:err errMsg:nsErrMsg manPushUrl:nsManPushUrl];
            }
        }
    }
}

- (void)onSendHangoutLiveChat:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(const string&)errMsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendHangoutLiveChat:success:err:errMsg:)]) {
                [delegate onSendHangoutLiveChat:reqId success:success err:err errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvHangoutChatNotice:(const IMRecvHangoutChatItem&)item {
    IMRecvHangoutChatItemObject* obj = [[IMRecvHangoutChatItemObject alloc] init];
    obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
    obj.level = item.level;
    obj.fromId = [NSString stringWithUTF8String:item.fromId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
    obj.msg = [NSString stringWithUTF8String:item.msg.c_str()];
    obj.honorUrl = [NSString stringWithUTF8String:item.honorUrl.c_str()];
    NSMutableArray *nsManPushUrl = [NSMutableArray array];
    for (list<string>::const_iterator iter = item.at.begin(); iter != item.at.end(); iter++) {
        string strUrl = (*iter);
        NSString *pushUrl = [NSString stringWithUTF8String:strUrl.c_str()];
        [nsManPushUrl addObject:pushUrl];
    }
    obj.at = nsManPushUrl;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvHangoutChatNotice:)]) {
                [delegate onRecvHangoutChatNotice:obj];
            }
        }
    }
}

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(const string&)roomId anchorId:(const string&)anchorId leftSecond:(int)leftSecond {
    
    NSString* strRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* strAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAnchorCountDownEnterHangoutRoomNotice:anchorId:leftSecond:)]) {
                [delegate onRecvAnchorCountDownEnterHangoutRoomNotice:strRoomId anchorId:strAnchorId leftSecond:leftSecond];
            }
        }
    }
    
}

// ------------- 节目 -------------
- (void)onRecvProgramPlayNotice:(const IMProgramItem&)item type:(IMProgramNoticeType)type msg:(const string &)msg{
    IMProgramItemObject* obj = [[IMProgramItemObject alloc] init];
    obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.anchorNickName = [NSString stringWithUTF8String:item.anchorNickName.c_str()];
    obj.anchorAvatar = [NSString stringWithUTF8String:item.anchorAvatar.c_str()];
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
    obj.ticketStatus = item.ticketStatus;
    obj.isHasFollow = item.isHasFollow;
    obj.isTicketFull = item.isTicketFull;
    
    NSString* strMsg = [NSString stringWithUTF8String:msg.c_str()];
    
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvProgramPlayNotice:type:msg:)]) {
                [delegate onRecvProgramPlayNotice:obj type:type msg:strMsg];
            }
        }
    }
}

- (void)onRecvCancelProgramNotice:(const IMProgramItem&)item {
    IMProgramItemObject* obj = [[IMProgramItemObject alloc] init];
    obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.anchorNickName = [NSString stringWithUTF8String:item.anchorNickName.c_str()];
    obj.anchorAvatar = [NSString stringWithUTF8String:item.anchorAvatar.c_str()];
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
    obj.ticketStatus = item.ticketStatus;
    obj.isHasFollow = item.isHasFollow;
    obj.isTicketFull = item.isTicketFull;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCancelProgramNotice:)]) {
                [delegate onRecvCancelProgramNotice:obj];
            }
        }
    }
}

- (void)onRecvRetTicketNotice:(const IMProgramItem&)item leftCredit:(double)leftCredit {
    IMProgramItemObject* obj = [[IMProgramItemObject alloc] init];
    obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.anchorNickName = [NSString stringWithUTF8String:item.anchorNickName.c_str()];
    obj.anchorAvatar = [NSString stringWithUTF8String:item.anchorAvatar.c_str()];
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
    obj.ticketStatus = item.ticketStatus;
    obj.isHasFollow = item.isHasFollow;
    obj.isTicketFull = item.isTicketFull;
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvRetTicketNotice:leftCredit:)]) {
                [delegate onRecvRetTicketNotice:obj leftCredit:leftCredit];
            }
        }
    }
}

- (void)onRecvLoiNotice:(const string&)anchorId loiId:(const string&)loiId {
    NSString* strAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString* strLoiId = [NSString stringWithUTF8String:loiId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLoiNotice:loiId:)]) {
                [delegate onRecvLoiNotice:strAnchorId loiId:strLoiId];
            }
        }
    }
}

- (void)onRecvEMFNotice:(const string&)anchorId emfId:(const string&)emfId {
    NSString* strAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
    NSString* strEmfId = [NSString stringWithUTF8String:emfId.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEMFNotice:emfId:)]) {
                [delegate onRecvEMFNotice:strAnchorId emfId:strEmfId];
            }
        }
    }
}

@end
