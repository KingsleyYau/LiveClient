/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBImClient.h
 *   desc: 主播IM客户端实现类
 */

#pragma once

#include "IZBImClient.h"
#include "IZBTaskManager.h"
#include "IZBThreadHandler.h"
#include "ZBCounter.h"

#include <common/IAutoLock.h>

typedef list<IZBImClientListener*> ZBImClientListenerList;

class ZBImClient : public IZBImClient
                , private IZBTaskManagerListener
                , private IZBImClientListener
{
public:
	ZBImClient();
	virtual ~ZBImClient();

// ILiveChatClient接口函数
public:
	// 调用所有接口函数前需要先调用Init
	bool Init(const list<string>& urls) override;
    // 增加监听器
    void AddListener(IZBImClientListener* listener) override;
    // 移除监听器
    void RemoveListener(IZBImClientListener* listener) override;
	// 判断是否无效seq
	virtual bool IsInvalidReqId(SEQ_T reqId) override;
	// 获取seq
	virtual SEQ_T GetReqId() override;
    
    // --------- 登录/注销 ---------
	// 2.1.登录
	bool ZBLogin(const string& token, ZBPageNameType pageName) override;
	// 2.2.注销
    bool ZBLogout() override;
    // 获取login状态
    ZBLoginStatus ZBGetLoginStatus() override;
//
//    // --------- 直播间 ---------
    
    /**
     *  3.1.新建/进入公开直播间
     *
     *  @param reqId         请求序列号
     *  @param anchorId        主播ID
     *
     */
    bool ZBPublicRoomIn(SEQ_T reqId) override;
    /**
     *  3.2.主播进入指定直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    bool ZBRoomIn(SEQ_T reqId, const string& roomId) override;
    /**
     *  3.3.观众退出直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    bool ZBRoomOut(SEQ_T reqId, const string& roomId) override;



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
    bool ZBSendLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string> at) override;

    // ------------- 直播间礼物 -------------
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
    bool ZBSendGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) override;

    // ------------- 邀请私密直播 -------------
    /**
     *  9.1.主播发送立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param userId                主播ID
     *
     */
    bool ZBSendPrivateLiveInvite(SEQ_T reqId, const string& userIde) override;

    /**
     *  9.5.获取指定立即私密邀请信息
     *
     *  @param reqId            请求序列号
     *  @param invitationId     邀请ID
     *
     */
    bool ZBGetInviteInfo(SEQ_T reqId, const string& invitationId) override;
    
    // ------------- 多人互动直播间 -------------
    /**
     *  10.1.进入多人互动直播间
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    bool AnchorEnterHangoutRoom(SEQ_T reqId, const string& roomId) override;

    /**
     *  10.2.退出多人互动直播间
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    bool AnchorLeaveHangoutRoom(SEQ_T reqId, const string& roomId) override;

    /**
     *  10.11.发送多人互动直播间礼物消息接口
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
    bool SendAnchorHangoutGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate) override;

public:
	// 获取用户账号
	string GetUser() override;
    
// ITaskManagerListener接口函数
private:
	// 连接成功回调
	void OnConnect(bool success) override;
	// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	void OnDisconnect() override;
	// 断开连接或连接失败回调(listUnsentTask：未发送/未回复的task列表)
	void OnDisconnect(const ZBTaskList& list) override;
	// 已完成交互的task
	void OnTaskDone(IZBTask* task) override;

private:
	// 连接服务器
	bool ConnectServer();
	// 登录
	bool LoginProc();
	// 启动发送心跳包线程
	void HearbeatThreadStart();
	// 停止发送心跳包线程
	void HearbearThreadStop();

protected:
	static TH_RETURN_PARAM HearbeatThread(void* arg);
	void HearbeatProc();

private:
	bool			m_bInit;	// 初始化标志
	list<string>	m_svrIPs;	// 服务器ip列表
	string			m_svrIp;	// 当前连接的服务器IP
	unsigned int	m_svrPort;	// 服务器端口

	string			m_user;			// 用户名
	string			m_password;		// 密码
    ZBClientType      m_clientType;   // 客户端类型
    string          m_token;        // 直播系统不同服务器的统一验证身份标识
    ZBPageNameType    m_pageName;     // socket所在的页面
    
    IAutoLock*      m_loginStatusLock;  // 登录状态锁
    ZBLoginStatus     m_loginStatus;  // 登录状态

	ZBCounter			m_seqCounter;	// seq计数器

	IZBTaskManager*	m_taskManager;	// 任务管理器

	bool			m_isHearbeatThreadRun;	// 心跳线程运行标志
	IZBThreadHandler*		m_hearbeatThread;	// 心跳线程
	IAutoLock*		m_lastHearbeatTimeLock;	// 最后心跳时间锁
	long long		m_lastHearbeatTime;		// 最后心跳时间
    
    IAutoLock*		m_listenerListLock;		// 监听器锁
    ZBImClientListenerList m_listenerList;	// 监听器列表
    
private:
    // 2.1.客户端主动请求
    /**
     *  2.1.登录回调
     *
     *  @param err          结果类型
     *  @param errmsg       结果描述
     *  @param item         登录返回结构体
     */
    void OnZBLogin(ZBLCC_ERR_TYPE err, const string& errmsg, const ZBLoginReturnItem& item) override;
    
    void OnZBLogout(ZBLCC_ERR_TYPE err, const string& errmsg) override;

    /**
     *  2.4.用户被挤掉线回调
     *
     *  @param err         结果类型
     *  @param errmsg      结果描述
     */
    void OnZBKickOff(ZBLCC_ERR_TYPE err, const string& errmsg) override;
    
//    // ------------- 直播间处理(非消息) -------------
    
    /**
     *  3.1.新建/进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param item         直播间信息
     *
     */
    void OnZBPublicRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) override;
    /**
     *  3.2.主播进入指定直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *  @param item        直播间信息）
     *
     */
    void OnZBRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) override;

    /**
     *  3.3.主播退出直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err     结果类型
     *  @param errMsg      结果描述
     *
     */
    void OnZBRoomOut(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override;

    /**
     *  4.1.发送直播间文本消息回调
     *
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *
     */
    void OnZBSendLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override;

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
    void OnZBSendGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override;
    
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
    void OnZBSendPrivateLiveInvite(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId) override;
    
    
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
    void OnAnchorEnterHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const AnchorHangoutRoomItem& item, int expire) override;

    /**
     *  10.2.退出多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *
     */
    void OnAnchorLeaveHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override;

    /**
     *  10.11.发送多人互动直播间礼物消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *
     */
    virtual void OnSendAnchorHangoutGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override;

    
  
    // 服务端主动请求
    /**
     *  3.4.接收直播间关闭通知(观众)回调
     *
     *  @param roomId      直播间ID
     *
     */
    void OnZBRecvRoomCloseNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) override;
    
    /**
     *  3.5.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
     *
     *  @param roomId      直播间ID
     *  @param err     踢出原因错误码
     *  @param errMsg      踢出原因描述
     *
     */
    void OnZBRecvRoomKickoffNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) override;

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
     *  @param isHasTicket  是否已购票
     *
     */
    void OnZBRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum, bool isHasTicket) override;
    
    /**
     *  3.7.接收观众退出直播间通知回调
     *
     *  @param roomId      直播间ID
     *  @param userId      观众ID
     *  @param nickName    观众昵称
     *  @param photoUrl    观众头像url
     *  @param fansNum     观众人数
     *
     */
    void OnZBRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) override;
   
    /**
     *  3.8.接收关闭直播间倒数通知回调
     *
     *  @param roomId      直播间ID
     *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
     *  @param err         错误码
     *  @param errMsg      错误描述
     *
     */
    void OnZBRecvLeavingPublicRoomNotice(const string& roomId, int leftSeconds, ZBLCC_ERR_TYPE err, const string& errMsg) override;
    
    /**
     *  3.9.接收主播退出直播间通知回调
     *
     *  @param roomId       直播间ID
     *  @param anchorId     退出直播间的主播ID
     *
     */
    virtual void OnRecvAnchorLeaveRoomNotice(const string& roomId, const string& anchorId) override;

    
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
    void OnZBRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override;
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
     *  @param type        公告类型（0：普通，1：警告）
     *
     */
    void OnZBRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, ZBIMSystemType type) override;
    
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
    void OnZBRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string& honorUrl, int totalCredit) override;
    
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
    void OnZBRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override;
    
    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  7.1.接收直播间才艺点播邀请通知回调
     *
     *  @param talentRequestItem             才艺点播请求l
     *
     */
    void OnZBRecvTalentRequestNotice(const ZBTalentRequestItem talentRequestItem) override;
    
    
    // ------------- 直播间视频互动 -------------
    /**
     *  8.1.接收观众启动/关闭视频互动通知回调
     *
     *  @param Item            互动切换
     *
     */
    void OnZBRecvControlManPushNotice(const ZBControlPushItem item) override;

    /**
     *  7.3.接收立即私密邀请回复通知 回调
     *
     *  @param inviteId      邀请ID
     *  @param replyType     主播回复 （0:拒绝 1:同意）
     *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
     *  @param roomType      直播间类型
     *  @param userId        观众ID
     *  @param nickName      主播昵称
     *  @param avatarImg     主播头像
     */
    void OnZBRecvInstantInviteReplyNotice(const string& inviteId, ZBReplyType replyType ,const string& roomId, ZBRoomType roomType, const string& userId, const string& nickName, const string& avatarImg) override;
    
    /**
     *  9.3.接收立即私密邀请通知 回调
     *
     *  @param userId           观众ID
     *  @param nickName         观众昵称
     *  @param photoUrl         观众头像url
     *  @param invitationId     邀请ID
     
     *
     */
   void OnZBRecvInstantInviteUserNotice(const string& userId, const string& nickName, const string& photoUrl ,const string& invitationId) override;
  
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
    void OnZBRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds) override;
    
    
    /**
     *  9.5.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param item             立即私密邀请
     *
     */
    void OnZBGetInviteInfo(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBPrivateInviteItem& item) override;
    
    /**
     *  9.6.接收观众接受预约通知接口 回调
     *
     *  @param userId           观众ID
     *  @param nickName         观众昵称
     *  @param photoUrl         观众头像url
     *  @param invitationId     预约ID
     *  @param bookTime         预约时间（1970年起的秒数）
     */
    void OnZBRecvInvitationAcceptNotice(const string& userId, const string& nickName, const string& photoUrl, const string& invitationId, long bookTime) override;
    
    // ------------- 多人互动直播间 -------------
    /**
     *  10.3.接收观众邀请多人互动通知接口 回调
     *
     *  @param item         观众邀请多人互动信息
     *
     */
    void OnRecvAnchorInvitationHangoutNotice(const AnchorHangoutInviteItem& item) override;

    /**
     *  10.4.接收推荐好友通知接口 回调
     *
     *  @param item         主播端接收自己推荐好友给观众的信息
     *
     */
    void OnRecvAnchorRecommendHangoutNotice(const IMAnchorRecommendHangoutItem& item) override;

    /**
     *  10.5.接收敲门回复通知接口 回调
     *
     *  @param item         接收敲门回复信息
     *
     */
    void OnRecvAnchorDealKnockRequestNotice(const IMAnchorKnockRequestItem& item) override;

    /**
     *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
     *
     *  @param item         接收观众邀请其它主播加入多人互动信息
     *
     */
    void OnRecvAnchorOtherInviteNotice(const IMAnchorRecvOtherInviteItem& item) override;

    /**
     *  10.7.接收主播回复观众多人互动邀请通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    void OnRecvAnchorDealInviteNotice(const IMAnchorRecvDealInviteItem& item) override;

    /**
     *  10.8.观众端/主播端接收观众/主播进入多人互动直播间接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    void OnRecvAnchorEnterRoomNotice(const IMAnchorRecvEnterRoomItem& item) override;

    /**
     *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
     *
     *  @param item         接收观众/主播退出多人互动直播间信息
     *
     */
    void OnRecvAnchorLeaveRoomNotice(const IMAnchorRecvLeaveRoomItem& item) override;

    /**
     *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
     *
     *  @param roomId         直播间ID
     *  @param isAnchor       是否主播（0：否，1：是）
     *  @param userId         观众/主播ID
     *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
     *
     */
    void OnRecvAnchorChangeVideoUrl(const string& roomId, bool isAnchor, const string& userId, const list<string>& playUrl) override;


    /**
     *  10.12.接收多人互动直播间礼物通知接口 回调
     *
     *  @param item         接收多人互动直播间礼物信息
     *
     */
    void OnRecvAnchorGiftNotice(const IMAnchorRecvGiftItem& item) override;
    
    // ------------- 节目 -------------
    /**
     *  11.1.接收节目开播通知接口 回调
     *
     *  @param item         节目信息
     *  @param msg          消息提示文字
     *
     */
    void OnRecvAnchorProgramPlayNotice(const IMAnchorProgramInfoItem& item, const string& msg) override;
    
    /**
     *  11.2.接收节目状态改变通知接口 回调
     *
     *  @param item         节目信息
     *
     */
    void OnRecvAnchorChangeStatusNotice(const IMAnchorProgramInfoItem& item) override;
    
    /**
     *  11.3.接收无操作的提示通知接口 回调
     *
     *  @param backgroundUrl 背景图url
     *  @param msg           描述
     *
     */
    void OnRecvAnchorShowMsgNotice(const string& backgroundUrl, const string& msg) override;

};
