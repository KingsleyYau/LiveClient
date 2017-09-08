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
     *
     */
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) {};
    
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
     *  @param userId      直播ID
     *  @param nickName    直播昵称
     *
     */
    virtual void OnRecvRoomCloseNotice(const string& roomId, const string& userId, const string& nickName, LCC_ERR_TYPE err, const string& errMsg) {};
    
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
    virtual void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum) {};
    
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
     *  @param err         错误码
     *  @param errMsg      错误描述
     *
     */
    virtual void OnRecvLeavingPublicRoomNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg) {};
    
    /**
     *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
     *
     *  @param roomId      直播间ID
     *  @param err     踢出原因错误码
     *  @param errMsg      踢出原因描述
     *  @param credit      信用点
     *
     */
    virtual void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit) {};
    
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
     *  @param roomId       直播间ID
     *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
     *
     */
    virtual void OnRecvWaitStartOverNotice(const string& roomId, int leftSeconds) {};
    
    /**
     *  3.12.接收观众／主播切换视频流通知接口 回调
     *
     *  @param roomId       房间ID
     *  @param isAnchor     是否是主播推流（1:是 0:否）
     *  @param playUrl      播放url
     *
     */
    virtual void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const string& playUrl) {};
    
    /**
     *  3.13.观众进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item         直播间信息
     *
     */
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) {};
    
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       直播间信息
     *
     */
    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {};
    
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
     *
     */
    virtual void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) {};
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
     *
     */
    virtual void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link) {};
    
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
     *
     */
    virtual void OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {};

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
     *
     */
    virtual void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) {};

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
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId) {};
    
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
    virtual void OnRecvInstantInviteReplyNotice(const string& inviteId, ReplyType replyType ,const string& roomId, RoomType roomType, const string& anchorId, const string& nickName, const string& avatarImg, const string& msg) {};
    
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
    virtual void OnRecvInstantInviteUserNotice(const string& logId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) {};
    
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
     *  @param inviteId     邀请ID
     *  @param replyType    主播回复（0:拒绝 1:同意 2:超时）
     *
     */
    virtual void OnRecvSendBookingReplyNotice(const string& inviteId, AnchorReplyType replyType) {};
    
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
    virtual void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int leftSeconds) {};

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
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId) {};
    
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
    virtual void OnRecvSendTalentNotice(const string& roomId, const string& talentInviteId, const string& talentId, const string& name, double credit, TalentStatus status) {};
    
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
     *  @param loveLevel           当前等级
     *
     */
    virtual void OnRecvLoveLevelUpNotice(int loveLevel) {};
    
    /**
     *  9.3.背包更新通知
     *
     *  @param item          新增的背包礼物
     *
     */
    virtual void OnRecvBackpackUpdateNotice(const BackpackInfo& item) {};
    
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
	virtual bool Login(const string& token, PageNameType pageName) = 0;
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
     *  @param anchorId        主播ID
     *
     */
    virtual bool PublicRoomIn(SEQ_T reqId, const string& anchorId) = 0;
    
    /**
     *  3.14.观众开始／结束视频互动
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *  @param control       视频操作（1:开始 2:关闭）
     *
     */
    virtual bool ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) = 0;
    
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
    
public:
	// 获取用户账号
	virtual string GetUser() = 0;
};
