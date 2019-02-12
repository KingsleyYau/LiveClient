/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClient.h
 *   desc: IM客户端接口类
 *   注意不能在[客户端主动请求]回调函数里面再次调用接口
 */

#pragma once

#include "IImClientDef.h"

#include <common/CommonFunc.h>

#include <string>
#include <list>
#include <vector>
#include "item/RoomInfoItem.h"
#include "item/LoginReturnItem.h"
#include "item/StartOverRoomItem.h"
#include "item/BookingReplyItem.h"
#include "item/TalentReplyItem.h"
#include "item/IMRecommendHangoutItem.h"
#include "item/IMRecvDealInviteItem.h"
#include "item/IMHangoutRoomItem.h"
#include "item/IMRecvEnterRoomItem.h"
#include "item/IMRecvLeaveRoomItem.h"
#include "item/IMRecvHangoutGiftItem.h"
#include "item/IMKnockRequestItem.h"
#include "item/IMLackCreditHangoutItem.h"
#include "item/IMProgramItem.h"
#include "item/IMRecvHangoutChatItem.h"
#include "item/IMLoveLevelItem.h"
#include "item/IMPrivateMessageItem.h"
#include "item/IMInviteReplyItem.h"
#include "item/IMInviteErrItem.h"
#include "item/IMHangoutInviteItem.h"

using namespace std;

// 直播间观众结构体
typedef struct _tRoomTopFan {
    _tRoomTopFan() {
        userId = "";
        nickName = "";
        photoUrl = "";
    };
    
    _tRoomTopFan(const _tRoomTopFan& item) {
        userId = item.userId;
        nickName = item.nickName;
        photoUrl = item.photoUrl;
    }
    
    string userId;
    string nickName;
    string photoUrl;
} RoomTopFan;
// 直播间观众列表
typedef list<RoomTopFan> RoomTopFanList;

typedef struct _tGiftInfo {
    _tGiftInfo() {
        giftId = "";
        name = "";
        num = 0;
    };
    _tGiftInfo(const _tGiftInfo& item) {
        giftId = item.giftId;
        name = item.name;
        num = item.num;
    }
    
    string giftId;    // 礼物ID
    string name;      // 礼物名称
    int num;          // 礼物数量
} GiftInfo;

typedef struct _tVoucherInfo {
    _tVoucherInfo() {
        voucherId = "";
        photoUrl = "";
        desc = "";
    };
    _tVoucherInfo(const _tVoucherInfo& item) {
        voucherId = item.voucherId;
        photoUrl = item.photoUrl;
        desc = item.desc;
    }
    
    string voucherId;    // 试用劵ID
    string photoUrl;      // 试用劵图标url
    string desc;          // 试用劵描述
} VoucherInfo;

typedef struct _tRideInfo {
    _tRideInfo() {
        rideId = "";
        photoUrl = "";
        name = "";
    };
    _tRideInfo(const _tRideInfo& item) {
        rideId = item.rideId;
        photoUrl = item.photoUrl;
        name = item.name;
    }
    
    string rideId;        // 座驾ID
    string photoUrl;      // 座驾图片url
    string name;          // 座驾名称
} RideInfo;

typedef struct _tBackpackInfo {
    _tBackpackInfo() {
        
    };
    _tBackpackInfo(const _tBackpackInfo& item) {
        gift = item.gift;
        voucher = item.voucher;
        ride = item.ride;
    }
    
    GiftInfo     gift;        // 新增的背包礼物
    VoucherInfo voucher;      // 新增的试用劵
    RideInfo    ride;         // 新增的座驾
} BackpackInfo;

// IM客户端监听接口类
class IImClientListener
{
public:
	IImClientListener() {};
	virtual ~IImClientListener() {}

public:
	// ------------- 登录/注销 -------------
    /**
     *  2.1.登录回调
     *
     *  @param err          结果类型
     *  @param errmsg       结果描述
     *  @param item         登录返回结构体
     */
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) {}
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) {}
    /**
     *  2.4.用户被挤掉线回调
     *
     */
    virtual void OnKickOff(LCC_ERR_TYPE err, const string& errmsg) {}
    
    // ------------- 直播间处理(非消息) -------------
    /**
     *  3.1.观众进入直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *  @param item        直播间信息
     *  @param priv        权限
     *
     */
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) {};
    
    /**
     *  3.2.观众退出直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err     结果类型
     *  @param errMsg      结果描述
     *
     */
    virtual void OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    
    /**
     *  3.3.接收直播间关闭通知(观众)回调
     *
     *  @param roomId      直播间ID
     *  @param priv        权限
     *
     */
    virtual void OnRecvRoomCloseNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& priv) {};
    
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
     *  @param isHasTicket 是否已购票（false：否，ture：是）
     *
     */
    virtual void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum, const string& honorImg, bool isHasTicket) {};
    
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
    virtual void OnRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) {};
    
    /**
     *  3.6.接收返点通知回调
     *
     *  @param roomId      直播间ID
     *  @param item  返点信息
     *
     */
    virtual void OnRecvRebateInfoNotice(const string& roomId, const RebateInfoItem& item) {};
    
    /**
     *  3.7.接收关闭直播间倒数通知回调
     *
     *  @param roomId      直播间ID
     *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
     *  @param err         错误码
     *  @param errMsg      错误描述
     *  @param item        权限
     *
     */
    virtual void OnRecvLeavingPublicRoomNotice(const string& roomId, int leftSeconds, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& item) {};
    
    /**
     *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
     *
     *  @param roomId      直播间ID
     *  @param err     踢出原因错误码
     *  @param errMsg      踢出原因描述
     *  @param credit      信用点
     *  @param item        权限
     *
     */
    virtual void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit, const IMAuthorityItem& item) {};
    
    /**
     *  3.9.接收充值通知回调
     *
     *  @param roomId      直播间ID
     *  @param msg         充值提示
     *  @param credit      信用点
     *
     */
    virtual void OnRecvLackOfCreditNotice(const string& roomId, const string& msg, double credit) {};
    
    /**
     *  3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）回调
     *
     *  @param roomId      直播间ID
     *  @param credit      信用点
     *
     */
    virtual void OnRecvCreditNotice(const string& roomId, double credit) {};
    
    /**
     *  3.11.直播间开播通知 回调
     *
     *  @param item       直播间开播通知结构体
     *
     */
    virtual void OnRecvWaitStartOverNotice(const StartOverRoomItem& item) {};
    
    /**
     *  3.12.接收观众／主播切换视频流通知接口 回调
     *
     *  @param roomId       房间ID
     *  @param isAnchor     是否是主播推流（1:是 0:否）
     *  @param playUrl      播放url
     *  @param userId       主播/观众ID（可无，仅在多人互动直播间才存在）
     *
     */
    virtual void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const list<string>& playUrl, const string& userId = "") {};
    
    
    /**
     *  3.13.观众进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item         直播间信息
     *
     */
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) {};
    
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {};

    /**
     *  3.15.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param item             立即私密邀请
     *
     */
    virtual void OnGetInviteInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const PrivateInviteItem& item, const IMAuthorityItem& privItem) {};
    
    // ------------- 直播间处理(非消息) -------------
    /**
     *  4.1.发送直播间文本消息回调
     *
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *
     */
    virtual void OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    
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
    virtual void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {};
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息） （仅当type=0有效）
     *  @param type        公告类型（0：普通，1：警告）
     *
     */
    virtual void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, IMSystemType type) {};
    
    // ------------- 直播间礼物消息 -------------
    /**
     *  5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）回调
     *
     *  @param success       操作是否成功
     *  @param reqId         请求序列号
     *  @param err           结果类型
     *  @param errMsg        结果描述
     *  @param credit        信用点
     *  @param rebateCredit  返点
     *
     */
    virtual void OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) {};
    
    /**
     * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）回调
     *
     *  @param roomId               直播间ID
     *  @param fromId               发送方的用户ID
     *  @param nickName             发送方的昵称
     *  @param giftId               礼物ID
     *  @param giftNum              本次发送礼物的数量
     *  @param multi_click          是否连击礼物
     *  @param multi_click_start    连击起始数
     *  @param multi_click_end      连击结束数
     *  @param multi_click_id       连击ID，相同则表示是同一次连击
     *  @param honorUrl             勋章图片url
     *
     */
    virtual void OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string& honorUrl) {};

    // ------------- 直播间弹幕消息 -------------
    /**
     *  6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）回调
     *
     *  @param success       操作是否成功
     *  @param reqId         请求序列号
     *  @param err           结果类型
     *  @param errMsg        结果描述
     *  @param credit        信用点
     *  @param rebateCredit  返点
     *
     */
    virtual void OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) {};
    
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
    virtual void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {};

    // ------------- 邀请私密直播 -------------
    /**
     *  7.1.观众立即私密邀请 回调
     *
     *  @param success           操作是否成功
     *  @param reqId             请求序列号
     *  @param err               结果类型
     *  @param errMsg            结果描述
     *  @param invitationId      邀请ID
     *  @param timeOut           邀请的剩余有效时间
     *  @param roomId            直播间ID
     *
     */
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId, const IMInviteErrItem& item) {};
    
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
    virtual void OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& roomId) {};
    
    /**
     *  7.3.接收立即私密邀请回复通知 回调
     *
     *  @param replyItem      邀请ID
     *
     */
    virtual void OnRecvInstantInviteReplyNotice(const IMInviteReplyItem& replyItem) {};
    
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
    virtual void OnRecvInstantInviteUserNotice(const string& inviteId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) {};
    
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
    virtual void OnRecvScheduledInviteUserNotice(const string& inviteId, const string& anchorId ,const string& nickName, const string& avatarImg, const string& msg) {};
    
    /**
     *  7.6.接收预约私密邀请回复通知 回调
     *
     *  @param item     预约私密邀请回复知结构体
     *
     */
    virtual void OnRecvSendBookingReplyNotice(const BookingReplyItem& item) {};
    
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
    virtual void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds) {};
    
    /**
     *  7.8.观众端是否显示主播立即私密邀请 回调
     *
     *  @param success       操作是否成功
     *  @param reqId         请求序列号
     *  @param err           结果类型
     *  @param errMsg        结果描述
     *
     */
    virtual void OnSendInstantInviteUserReport(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};

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
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId, const string& talentId) {};
    
    /**
     *  8.2.接收直播间才艺点播回复通知 回调
     *
     *  @param item          才艺回复通知结构体
     *
     */
    virtual void OnRecvSendTalentNotice(const TalentReplyItem& item) {};
    
    /**
     *  8.3.接收直播间才艺点播提示公告通知 回调
     *
     *  @param roomId          直播间ID
     *  @param introduction    公告描述
     *
     */
    virtual void OnRecvTalentListNotice(const string& roomId, const string& introduction) {};
    
    // ------------- 公共 -------------
    /**
     *  9.1.观众等级升级通知 回调
     *
     *  @param level           当前等级
     *
     */
    virtual void OnRecvLevelUpNotice(int level) {};
    
    /**
     *  9.2.观众亲密度升级通知
     *
     *  @param loveLevelItem           观众亲密度升级信息
     *
     */
    virtual void OnRecvLoveLevelUpNotice(const IMLoveLevelItem& loveLevelItem) {};
    
    /**
     *  9.3.背包更新通知
     *
     *  @param item          新增的背包礼物
     *
     */
    virtual void OnRecvBackpackUpdateNotice(const BackpackInfo& item) {};
    
    /**
     *  9.4.观众勋章升级通知
     *
     *  @param honorId          勋章ID
     *  @param honorUrl         勋章图片url
     *
     */
    virtual void OnRecvGetHonorNotice(const string& honorId, const string& honorUrl) {};
    
     // ------------- 多人互动直播间 -------------
    /**
     *  10.1.接收主播推荐好友通知接口 回调
     *
     *  @param item         接收主播推荐好友通知
     *
     */
    virtual void OnRecvRecommendHangoutNotice(const IMRecommendHangoutItem& item) {};

    /**
     *  10.2.接收主播回复观众多人互动邀请通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    virtual void OnRecvDealInviteHangoutNotice(const IMRecvDealInviteItem& item) {};

    /**
     *  10.3.观众新建/进入多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item        进入多人互动直播间信息
     *
     */
    virtual void OnEnterHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const IMHangoutRoomItem& item) {};

    /**
     *  10.4.退出多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *
     */
    virtual void OnLeaveHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};

    /**
     *  10.5.接收观众/主播进入多人互动直播间通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    virtual void OnRecvEnterHangoutRoomNotice(const IMRecvEnterRoomItem& item) {};

    /**
     *  10.6.接收观众/主播退出多人互动直播间通知接口 回调
     *
     *  @param item         接收观众/主播退出多人互动直播间信息
     *
     */
    virtual void OnRecvLeaveHangoutRoomNotice(const IMRecvLeaveRoomItem& item) {};

    /**
     *  10.7.发送多人互动直播间礼物消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param credit           信用点（浮点型）（若小于0，则表示信用点不变）
     *
     */
    virtual void OnSendHangoutGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit) {};

    /**
     *  10.8.接收多人互动直播间礼物通知接口 回调
     *
     *  @param item         接收多人互动直播间礼物信息
     *
     */
    virtual void OnRecvHangoutGiftNotice(const IMRecvHangoutGiftItem& item) {};

    /**
     *  10.9.接收主播敲门通知接口 回调
     *
     *  @param item         接收主播发起的敲门信息
     *
     */
    virtual void OnRecvKnockRequestNotice(const IMKnockRequestItem& item) {};

    /**
     *  10.10.接收多人互动余额不足导致主播将要离开的通知接口 回调
     *
     *  @param item         观众账号余额不足信息
     *
     */
    virtual void OnRecvLackCreditHangoutNotice(const IMLackCreditHangoutItem& item) {};
    
    /**
     *  10.11.多人互动观众开始/结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    virtual void OnControlManPushHangout(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {};
    
    /**
     *  10.12.发送多人互动直播间文本消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *
     */
    virtual void OnSendHangoutLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    
    /**
     *  10.13.接收直播间文本消息接口 回调
     *
     *  @param item         接收直播间文本消息
     *
     */
    virtual void OnRecvHangoutChatNotice(const IMRecvHangoutChatItem& item) {};
    
    /**
     *  10.14.接收进入多人互动直播间倒数通知接口 回调
     *
     *  @param roomId         待进入的直播间ID
     *  @param anchorId       主播ID
     *  @param leftSecond     进入直播间的剩余秒数
     *
     */
    virtual void OnRecvAnchorCountDownEnterHangoutRoomNotice(const string& roomId, const string& anchorId, int leftSecond) {};
    
    /**
     *  10.15.接收主播Hang-out邀请通知接口 回调
     *
     *  @param item         Hang-out邀请通知信息
     *
     */
    virtual void OnRecvHandoutInviteNotice(const IMHangoutInviteItem& item) {};
    
    // ------------- 节目 -------------
    /**
     *  11.1.接收节目开播通知接口 回调
     *
     *  @param item         节目
     *  @param type         通知类型（1：已购票的开播通知，2：仅关注的开播通知）
     *  @param msg          消息提示文字
     *
     */
    virtual void OnRecvProgramPlayNotice(const IMProgramItem& item, IMProgramNoticeType type, const string& msg) {};
    
    /**
     *  11.2.接收节目已取消通知接口 回调
     *
     *  @param item         节目
     *
     */
    virtual void OnRecvCancelProgramNotice(const IMProgramItem& item) {};
    
    /**
     *  11.3.接收节目已退票通知接口 回调
     *
     *  @param item         节目
     *  @param leftCredit   当前余额
     *
     */
    virtual void OnRecvRetTicketNotice(const IMProgramItem& item, double leftCredit) {};
    
    // ------------- 私信 -------------
    /**
     *  12.1.发送私信文本消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param messageId        消息ID
     *  @param credit           信用点（浮点型）（可无，无或小于0，则表示信用点不变）
     *  @param toId             被发送者ID
     *  @param sendMsgId        发送时的假Id
     *
     */
    virtual void OnSendPrivateMessage(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int messageId, double credit, const string& toId, int sendMsgId) {};
    
    /**
     *  12.2.接收私信文本消息通知接口 回调
     *
     *  @param item         私信文本消息
     *
     */
    virtual void OnRecvPrivateMessageNotice(const IMPrivateMessageItem& item) {};
    
    // ------------- 信件 -------------
    /**
     *  13.1.接收意向信通知 接口 回调
     *
     *  @param anchorId         主播ID
     *  @param loiId            信件ID
     *
     */
    virtual void OnRecvLoiNotice(const string& anchorId, const string& loiId) {};
    
    /**
     *  13.2.接收意向信通知 接口 回调
     *
     *  @param anchorId         主播ID
     *  @param emfId            信件ID
     *
     */
    virtual void OnRecvEMFNotice(const string& anchorId, const string& emfId) {};
    
};

// IM客户端接口类
class IImClient
{
public:
    typedef enum _tLoginStatus{
        LOGINING,   // login中
        LOGINED,    // 已login
        LOGOUT,     // logout
    } LoginStatus;
    
public:
	static IImClient* CreateClient();
	static void ReleaseClient(IImClient* client);

public:
	IImClient(void) {};
	virtual ~IImClient(void) {};

public:
	// 调用所有接口函数前需要先调用Init
	virtual bool Init(const list<string>& urls) = 0;
    // 增加监听器
    virtual void AddListener(IImClientListener* listener) = 0;
    // 移除监听器
    virtual void RemoveListener(IImClientListener* listener) = 0;
	// 判断是否无效seq
	virtual bool IsInvalidReqId(SEQ_T reqId) = 0;
	// 获取reqId
	virtual SEQ_T GetReqId() = 0;
    
    // --------- 登录/注销 ---------
	// 2.1.登录
	virtual bool Login(const string& token, PageNameType pageName, LoginVerifyType type = LOGINVERIFYTYPE_TOKEN) = 0;
	// 2.2.注销
	virtual bool Logout() = 0;
    // 获取login状态
    virtual LoginStatus GetLoginStatus() = 0;
    
    // --------- 直播间 ---------
    /**
     *  3.1.观众进入直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    virtual bool RoomIn(SEQ_T reqId, const string& roomId) = 0;
    
    /**
     *  3.2.观众退出直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    virtual bool RoomOut(SEQ_T reqId, const string& roomId) = 0;
    
    /**
     *  3.13.观众进入公开直播间
     *
     *  @param reqId         请求序列号
     *  @param userId        主播ID
     *
     */
    virtual bool PublicRoomIn(SEQ_T reqId, const string& userId) = 0;
    
    /**
     *  3.14.观众开始／结束视频互动
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *  @param control       视频操作（1:开始 2:关闭）
     *
     */
    virtual bool ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) = 0;
    
    /**
     *  3.15.获取指定立即私密邀请信息
     *
     *  @param reqId            请求序列号
     *  @param invitationId     邀请ID
     *
     */
    virtual bool GetInviteInfo(SEQ_T reqId, const string& invitationId) = 0;
    
    // --------- 直播间文本消息 ---------
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
    virtual bool SendLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string> at) = 0;
        
    // ------------- 直播间点赞 -------------
    /**
     *  5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
     *
     *  @param reqId                    请求序列号
     *  @param roomId                   直播间ID
     *  @param nickName                 发送人昵称
     *  @param giftId                   礼物ID
     *  @param giftName                 礼物名称
     *  @param isBackPack               是否背包礼物
     *  @param giftNum                  本次发送礼物的数量
     *  @param multi_click              是否连击礼物
     *  @param multi_click_start        连击起始数
     *  @param multi_click_end          连击结束数
     *  @param multi_click_id           连击ID，相同则表示是同一次连击（生成方式：timestamp秒％10000）
     *
     */
    virtual bool SendGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) = 0;

    // ------------- 直播间弹幕消息 -------------
    /**
     *  6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
     *
     *  @param reqId                 请求序列号
     *  @param roomId                直播间ID
     *  @param nickName              发送人昵称
     *  @param msg                   消息内容
     *
     */
    virtual bool SendToast(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg) = 0;
    
    // ------------- 邀请私密直播 -------------
    /**
     *  7.1.观众立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param userId                主播ID
     *  @param logId              主播邀请的记录ID（可无，则表示操作未《接收主播立即私密邀请通知》触发）
     *
     */
    virtual bool SendPrivateLiveInvite(SEQ_T reqId, const string& userId, const string& logId, bool force) = 0;
    
    /**
     *  7.2.观众取消立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param inviteId              邀请ID
     *
     */
    virtual bool SendCancelPrivateLiveInvite(SEQ_T reqId, const string& inviteId) = 0;
    
    /**
     *  7.8.观众端是否显示主播立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param inviteId              邀请ID
     *  @param isshow                观众端是否弹出邀请（整型）（0：否，1：是）
     *
     */
    virtual bool SendInstantInviteUserReport(SEQ_T reqId, const string& inviteId, bool isShow) = 0;
    
    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  8.1.发送直播间才艺点播邀请
     *
     *  @param reqId                 请求序列号
     *  @param roomId                直播间ID
     *  @param talentId              才艺点播ID
     *
     */
    virtual bool SendTalent(SEQ_T reqId, const string& roomId, const string& talentId) = 0;
    
    // ------------- 多人互动 -------------
    /**
     *  10.3.观众新建/进入多人互动直播间接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    virtual bool EnterHangoutRoom(SEQ_T reqId, const string& roomId) = 0;
    
    /**
     *  10.4.退出多人互动直播间接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    virtual bool LeaveHangoutRoom(SEQ_T reqId, const string& roomId) = 0;
    
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
    virtual bool SendHangoutGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate)  = 0;
    
    /**
     *  10.11.多人互动观众开始/结束视频互动接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *  @param control          视频操作（IMCONTROLTYPE_START：开始 IMCONTROLTYPE_CLOSE：关闭）
     *
     */
    virtual bool ControlManPushHangout(SEQ_T reqId, const string& roomId, IMControlType control) = 0;

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
    virtual bool SendHangoutLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string>& at) = 0;
    /**
     *  12.1.发送私信文本消息接口
     *
     *  @param reqId            请求序列号
     *  @param toId             接收者ID
     *  @param content          消息内容
     *  @param sendMsgId        发送的假msgID
     *
     */
    virtual bool SendPrivateMessage(SEQ_T reqId, const string& toId, const string& content, int sendMsgId) = 0;
    
    
public:
	// 获取用户账号
	virtual string GetUser() = 0;
};
