/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: ImClient.h
 *   desc: IM客户端实现类
 */

#pragma once

#include "IImClient.h"
#include "ITaskManager.h"
#include "IThreadHandler.h"
#include "Counter.h"

#include <common/IAutoLock.h>

typedef list<IImClientListener*> ImClientListenerList;

class ImClient : public IImClient
                , private ITaskManagerListener
                , private IImClientListener
{
public:
	ImClient();
	virtual ~ImClient();

// ILiveChatClient接口函数
public:
	// 调用所有接口函数前需要先调用Init
	bool Init(const list<string>& urls) override;
    // 增加监听器
    void AddListener(IImClientListener* listener) override;
    // 移除监听器
    void RemoveListener(IImClientListener* listener) override;
	// 判断是否无效seq
	virtual bool IsInvalidReqId(SEQ_T reqId) override;
	// 获取seq
	virtual SEQ_T GetReqId() override;
    
    // --------- 登录/注销 ---------
	// 2.1.登录
	bool Login(const string& token, PageNameType pageName) override;
	// 2.2.注销
	bool Logout() override;
    // 获取login状态
    LoginStatus GetLoginStatus() override;
    
    // --------- 直播间 ---------
    /**
     *  3.1.观众进入直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    bool RoomIn(SEQ_T reqId, const string& roomId) override;
    /**
     *  3.2.观众退出直播间
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *
     */
    bool RoomOut(SEQ_T reqId, const string& roomId) override;
    
    /**
     *  3.13.观众进入公开直播间
     *
     *  @param reqId         请求序列号
     *  @param anchorId        主播ID
     *
     */
    bool PublicRoomIn(SEQ_T reqId, const string& anchorId) override;
    
    /**
     *  3.14.观众开始／结束视频互动
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *  @param control       视频操作（1:开始 2:关闭）
     *
     */
    bool ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) override;
    
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
    bool SendLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string> at) override;
    
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
    bool SendGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) override;

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
    bool SendToast(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg) override;
    
    
    // ------------- 邀请私密直播 -------------
    /**
     *  7.1.观众立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param userId                主播ID
     *  @param logId              主播邀请的记录ID（可无，则表示操作未《接收主播立即私密邀请通知》触发）
     *
     */
    bool SendPrivateLiveInvite(SEQ_T reqId, const string& userId, const string& logId, bool force) override;
    
    /**
     *  7.2.观众取消立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param inviteId              邀请ID
     *
     */
    bool SendCancelPrivateLiveInvite(SEQ_T reqId, const string& inviteId) override;
    
    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  8.1.发送直播间才艺点播邀请
     *
     *  @param reqId                 请求序列号
     *  @param roomId                直播间ID
     *  @param talentId              才艺点播ID
     *
     */
    bool SendTalent(SEQ_T reqId, const string& roomId, const string& talentId) override;
    
public:
	// 获取用户账号
	string GetUser() override;
    
// ITaskManagerListener接口函数
private:
	// 连接成功回调
	void OnConnect(bool success) override;
	// 连接失败回调(listUnsentTask：未发送/未回复的task列表)
	void OnDisconnect(const TaskList& list) override;
	// 已完成交互的task
	void OnTaskDone(ITask* task) override;

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
    ClientType      m_clientType;   // 客户端类型
    string          m_token;        // 直播系统不同服务器的统一验证身份标识
    PageNameType    m_pageName;     // socket所在的页面
    
    IAutoLock*      m_loginStatusLock;  // 登录状态锁
    LoginStatus     m_loginStatus;  // 登录状态

	Counter			m_seqCounter;	// seq计数器

	ITaskManager*	m_taskManager;	// 任务管理器

	bool			m_isHearbeatThreadRun;	// 心跳线程运行标志
	IThreadHandler*		m_hearbeatThread;	// 心跳线程
	IAutoLock*		m_lastHearbeatTimeLock;	// 最后心跳时间锁
	long long		m_lastHearbeatTime;		// 最后心跳时间
    
    IAutoLock*		m_listenerListLock;		// 监听器锁
    ImClientListenerList m_listenerList;	// 监听器列表
    
private:
    // 2.1.客户端主动请求
    /**
     *  2.1.登录回调
     *
     *  @param err          结果类型
     *  @param errmsg       结果描述
     *  @param item         登录返回结构体
     */
    void OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) override;
    
    void OnLogout(LCC_ERR_TYPE err, const string& errmsg) override;
    
    /**
     *  2.4.用户被挤掉线回调
     *
     *  @param err         结果类型
     *  @param errmsg      结果描述
     */
    void OnKickOff(LCC_ERR_TYPE err, const string& errmsg) override;
    
    // ------------- 直播间处理(非消息) -------------
    /**
     *  3.1.观众进入直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *  @param item        直播间信息）
     *
     */
    void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) override;
    
    /**
     *  3.2.观众退出直播间回调
     *
     *  @param success     操作是否成功
     *  @param reqId       请求序列号
     *  @param err     结果类型
     *  @param errMsg      结果描述
     *
     */
    void OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;
    
    /**
     *  4.1.发送直播间文本消息回调
     *
     *  @param reqId       请求序列号
     *  @param err         结果类型
     *  @param errMsg      结果描述
     *
     */
    void OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;
    
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
    void OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) override;
    
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
    void OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) override;
    
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
    void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId) override;
    
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
    void OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& roomId) override;

    /**
     *  8.1.发送直播间才艺点播邀请 回调
     *
     *  @param success           操作是否成功
     *  @param reqId             请求序列号
     *  @param err               结果类型
     *  @param errMsg            结果描述
     *
     */
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId) override;

    
    // 服务端主动请求
    /**
     *  3.3.接收直播间关闭通知(观众)回调
     *
     *  @param roomId      直播间ID
     *  @param userId      直播ID
     *  @param nickName    直播昵称
     *
     */
    void OnRecvRoomCloseNotice(const string& roomId, const string& userId, const string& nickName, LCC_ERR_TYPE err, const string& errMsg) override;
    
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
    void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum) override;
    
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
    void OnRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) override;
    
    /**
     *  3.6.接收返点通知回调
     *
     *  @param roomId      直播间ID
     *  @param item  返点信息
     *
     */
    void OnRecvRebateInfoNotice(const string& roomId, const RebateInfoItem& item) override;
    
    /**
     *  3.7.接收关闭直播间倒数通知回调
     *
     *  @param roomId      直播间ID
     *  @param err         错误码
     *  @param errMsg      错误描述 
     *
     */
    void OnRecvLeavingPublicRoomNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg) override;
    
    /**
     *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
     *
     *  @param roomId      直播间ID
     *  @param err     踢出原因错误码
     *  @param errMsg      踢出原因描述
     *  @param credit      信用点
     *
     */
    void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit) override;
    
    /**
     *  3.9.接收充值通知回调
     *
     *  @param roomId      直播间ID
     *  @param msg         充值提示
     *  @param credit      信用点
     *
     */
    void OnRecvLackOfCreditNotice(const string& roomId, const string& msg, double credit) override;
    
    /**
     *  3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）回调
     *
     *  @param roomId      直播间ID
     *  @param credit      信用点
     *
     */
    void OnRecvCreditNotice(const string& roomId, double credit) override;
    
    /**
     *  3.11.直播间开播通知 回调
     *
     *  @param roomId       直播间ID
     *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
     *
     */
    void OnRecvWaitStartOverNotice(const string& roomId, int leftSeconds) override;
    
    /**
     *  3.12.接收观众／主播切换视频流通知接口 回调
     *
     *  @param roomId       房间ID
     *  @param isAnchor     是否是主播推流（1:是 0:否）
     *  @param playUrl      播放url
     *
     */
    void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const string& playUrl) override;
    
    /**
     *  3.13.观众进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param item         直播间信息
     *
     */
    void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) override;
    
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       直播间信息
     *
     */
    void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override;
    
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
    void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) override;
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
     *
     */
    void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link) override;
    
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
    void OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) override;
    
    /**
     *  6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）回调
     *
     *  @param roomId               直播间ID
     *  @param fromId               发送方的用户ID
     *  @param nickName             发送方的昵称
     *  @param msg                  消息内容
     *
     */
    void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) override;

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
     */
    void OnRecvInstantInviteReplyNotice(const string& inviteId, ReplyType replyType ,const string& roomId, RoomType roomType, const string& anchorId, const string& nickName, const string& avatarImg, const string& msg) override;
    
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
    void OnRecvInstantInviteUserNotice(const string& logId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) override;
    
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
    void OnRecvScheduledInviteUserNotice(const string& inviteId, const string& anchorId ,const string& nickName, const string& avatarImg, const string& msg) override;

    /**
     *  7.6.接收预约私密邀请回复通知 回调
     *
     *  @param inviteId     邀请ID
     *  @param replyType    主播回复（0:拒绝 1:同意 2:超时）
     *
     */
    void OnRecvSendBookingReplyNotice(const string& inviteId, AnchorReplyType replyType) override;
    
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
    void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int leftSeconds) override;
    
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
    void OnRecvSendTalentNotice(const string& roomId, const string& talentInviteId, const string& talentId, const string& name, double credit, TalentStatus status) override;
    
    /**
     *  9.1.观众等级升级通知 回调
     *
     *  @param level           当前等级
     *
     */
    void OnRecvLevelUpNotice(int level) override;
    
    /**
     *  9.2.观众亲密度升级通知
     *
     *  @param loveLevel           当前等级
     *
     */
    void OnRecvLoveLevelUpNotice(int loveLevel) override;
    
    /**
     *  9.3.背包更新通知
     *
     *  @param item          新增的背包礼物
     *
     */
    void OnRecvBackpackUpdateNotice(const BackpackInfo& item) override;
};
