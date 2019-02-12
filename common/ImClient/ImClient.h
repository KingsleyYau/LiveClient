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
	bool Login(const string& token, PageNameType pageName, LoginVerifyType type = LOGINVERIFYTYPE_TOKEN) override;
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
    bool PublicRoomIn(SEQ_T reqId, const string& userId) override;
    
    /**
     *  3.14.观众开始／结束视频互动
     *
     *  @param reqId         请求序列号
     *  @param roomId        直播间ID
     *  @param control       视频操作（1:开始 2:关闭）
     *
     */
    bool ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) override;
    
    /**
     *  3.15.获取指定立即私密邀请信息
     *
     *  @param reqId            请求序列号
     *  @param invitationId     邀请ID
     *
     */
    bool GetInviteInfo(SEQ_T reqId, const string& invitationId) override;
    
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
    
    /**
     *  7.8.观众端是否显示主播立即私密邀请
     *
     *  @param reqId                 请求序列号
     *  @param inviteId              邀请ID
     *  @param isshow                观众端是否弹出邀请（整型）（0：否，1：是）
     *
     */
    bool SendInstantInviteUserReport(SEQ_T reqId, const string& inviteId, bool isShow) override;
    
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
    
    // ------------- 多人互动 -------------
    /**
     *  10.3.观众新建/进入多人互动直播间接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    bool EnterHangoutRoom(SEQ_T reqId, const string& roomId) override;

    /**
     *  10.4.退出多人互动直播间接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *
     */
    bool LeaveHangoutRoom(SEQ_T reqId, const string& roomId) override;

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
    bool SendHangoutGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate)  override;
    
    /**
     *  10.11.多人互动观众开始/结束视频互动接口
     *
     *  @param reqId            请求序列号
     *  @param roomId           直播间ID
     *  @param control          视频操作（IMCONTROLTYPE_START：开始 IMCONTROLTYPE_CLOSE：关闭）
     *
     */
    bool ControlManPushHangout(SEQ_T reqId, const string& roomId, IMControlType control) override;
    
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
    bool SendHangoutLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string>& at) override;
    
    /**
     *  12.1.发送私信文本消息接口
     *
     *  @param reqId            请求序列号
     *  @param toId             接收者ID
     *  @param content          消息内容
     *  @param sendMsgId        发送时的假Id
     *
     */
    bool SendPrivateMessage(SEQ_T reqId, const string& toId, const string& content, int sendMsgId) override;
    
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
    LoginVerifyType m_type;         // 验证类型（LOGINVERIFYTYPE_TOKEN：token，LOGINVERIFYTYPE_COOKICE：cookice）（整型）
    
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
    void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) override;
    
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
    void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId, const IMInviteErrItem& item) override;
    
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
     *  7.8.观众端是否显示主播立即私密邀请 回调
     *
     *  @param success       操作是否成功
     *  @param reqId         请求序列号
     *  @param err           结果类型
     *  @param errMsg        结果描述
     *
     */
     void OnSendInstantInviteUserReport(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;

    /**
     *  8.1.发送直播间才艺点播邀请 回调
     *
     *  @param success           操作是否成功
     *  @param reqId             请求序列号
     *  @param err               结果类型
     *  @param errMsg            结果描述
     *
     */
    void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId, const string& talentId) override;
    
    /**
     *  10.3.观众新建/进入多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item        进入多人互动直播间信息
     *
     */
    void OnEnterHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const IMHangoutRoomItem& item) override;

    /**
     *  10.4.退出多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *
     */
    void OnLeaveHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;


    /**
     *  10.7.发送多人互动直播间礼物消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param credit           信用点（浮点型）（若小于0，则表示信用点不变）
     *
     */
    void OnSendHangoutGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit) override;

    /**
     *  10.11.多人互动观众开始/结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    void OnControlManPushHangout(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override;

    /**
     *  10.12.发送多人互动直播间文本消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *
     */
    void OnSendHangoutLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;
    
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
    void OnSendPrivateMessage(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int messageId, double credit, const string& toId, int sendMsgId) override;
    // 服务端主动请求
    /**
     *  3.3.接收直播间关闭通知(观众)回调
     *
     *  @param roomId      直播间ID
     *
     */
    void OnRecvRoomCloseNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& priv) override;
    
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
     *
     */
    void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum, const string& honorImg, bool isHasTicket) override;
    
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
     *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
     *  @param err         错误码
     *  @param errMsg      错误描述 
     *
     */
    void OnRecvLeavingPublicRoomNotice(const string& roomId, int leftSeconds, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& item) override;
    
    /**
     *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
     *
     *  @param roomId      直播间ID
     *  @param err     踢出原因错误码
     *  @param errMsg      踢出原因描述
     *  @param credit      信用点
     *
     */
    void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit, const IMAuthorityItem& item) override;
    
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
    void OnRecvWaitStartOverNotice(const StartOverRoomItem& item) override;
    
    /**
     *  3.12.接收观众／主播切换视频流通知接口 回调
     *
     *  @param roomId       房间ID
     *  @param isAnchor     是否是主播推流（1:是 0:否）
     *  @param playUrl      播放url
     *  @param userId       主播/观众ID（可无，仅在多人互动直播间才存在）
     *
     */
    void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const list<string>& playUrl, const string& userId = "") override;
    
    
    /**
     *  3.13.观众进入公开直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param item         直播间信息
     *
     */
    void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) override;
    
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override;
    
    /**
     *  3.15.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param item             立即私密邀请
     *
     */
    void OnGetInviteInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const PrivateInviteItem& item, const IMAuthorityItem& privItem) override;
    
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
    void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override;
    
    /**
     *  4.3.接收直播间公告消息回调
     *
     *  @param roomId      直播间ID
     *  @param msg         公告消息内容
     *  @param link        公告链接（可无，无则表示不是带链接的公告消息）
     *  @param type        公告类型（0：普通，1：警告）
     *
     */
    void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, IMSystemType type) override;
    
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
    void OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string& honorUrl) override;
    
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
    void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override;

    /**
     *  7.3.接收立即私密邀请回复通知 回调
     *
     *  @param replyItem      邀请ID
     */
    void OnRecvInstantInviteReplyNotice(const IMInviteReplyItem& replyItem) override;
    
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
    void OnRecvInstantInviteUserNotice(const string& inviteId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) override;
    
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
     *  @param item     预约私密邀请回复知结构体
     *
     */
    void OnRecvSendBookingReplyNotice(const BookingReplyItem& item) override;
    
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
    void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds) override;
    
    /**
     *  8.2.接收直播间才艺点播回复通知 回调
     *
     *  @param item          才艺回复通知结构体
     *
     */
    void OnRecvSendTalentNotice(const TalentReplyItem& item) override;
    
    /**
     *  8.2.接收直播间才艺点播回复通知 回调
     *
     *  @param roomId          直播间ID
     *  @param introduction    公告描述
     *
     */
    void OnRecvTalentListNotice(const string& roomId, const string& introduction) override;
    
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
     *  @param loveLevelItem           观众亲密度升级信息
     *
     */
    void OnRecvLoveLevelUpNotice(const IMLoveLevelItem& loveLevelItem) override;
    
    /**
     *  9.3.背包更新通知
     *
     *  @param item          新增的背包礼物
     *
     */
    void OnRecvBackpackUpdateNotice(const BackpackInfo& item) override;
    
    /**
     *  9.4.观众勋章升级通知
     *
     *  @param honorId          勋章ID
     *  @param honorUrl         勋章图片url
     *
     */
    void OnRecvGetHonorNotice(const string& honorId, const string& honorUrl) override;
    
    // ------------- 多人互动直播间 -------------
    /**
     *  10.1.接收主播推荐好友通知接口 回调
     *
     *  @param item         接收主播推荐好友通知
     *
     */
    void OnRecvRecommendHangoutNotice(const IMRecommendHangoutItem& item) override;

    /**
     *  10.2.接收主播回复观众多人互动邀请通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    void OnRecvDealInviteHangoutNotice(const IMRecvDealInviteItem& item) override;

    /**
     *  10.5.接收观众/主播进入多人互动直播间通知接口 回调
     *
     *  @param item         接收主播回复观众多人互动邀请信息
     *
     */
    void OnRecvEnterHangoutRoomNotice(const IMRecvEnterRoomItem& item) override;

    /**
     *  10.6.接收观众/主播退出多人互动直播间通知接口 回调
     *
     *  @param item         接收观众/主播退出多人互动直播间信息
     *
     */
    void OnRecvLeaveHangoutRoomNotice(const IMRecvLeaveRoomItem& item) override;

    /**
     *  10.8.接收多人互动直播间礼物通知接口 回调
     *
     *  @param item         接收多人互动直播间礼物信息
     *
     */
    void OnRecvHangoutGiftNotice(const IMRecvHangoutGiftItem& item) override;

    /**
     *  10.9.接收主播敲门通知接口 回调
     *
     *  @param item         接收主播发起的敲门信息
     *
     */
    void OnRecvKnockRequestNotice(const IMKnockRequestItem& item) override;

    /**
     *  10.10.接收多人互动余额不足导致主播将要离开的通知接口 回调
     *
     *  @param item         观众账号余额不足信息
     *
     */
    void OnRecvLackCreditHangoutNotice(const IMLackCreditHangoutItem& item) override;
    
    /**
     *  10.13.接收直播间文本消息接口 回调
     *
     *  @param item         接收直播间文本消息
     *
     */
    void OnRecvHangoutChatNotice(const IMRecvHangoutChatItem& item) override;
    
    /**
     *  10.14.接收进入多人互动直播间倒数通知接口 回调
     *
     *  @param roomId         待进入的直播间ID
     *  @param anchorId       主播ID
     *  @param leftSecond     进入直播间的剩余秒数
     *
     */
    void OnRecvAnchorCountDownEnterHangoutRoomNotice(const string& roomId, const string& anchorId, int leftSecond) override;
    
    /**
     *  10.15.接收主播Hang-out邀请通知接口 回调
     *
     *  @param item         Hang-out邀请通知信息
     *
     */
    void OnRecvHandoutInviteNotice(const IMHangoutInviteItem& item) override;

    // ------------- 节目 -------------
    /**
     *  11.1.节目开播通知接口 回调
     *
     *  @param item         节目
     *  @param type         通知类型（1：已购票的开播通知，2：仅关注的开播通知）
     *  @param msg          消息提示文字
     *
     */
    void OnRecvProgramPlayNotice(const IMProgramItem& item, IMProgramNoticeType type, const string& msg) override;
    
    /**
     *  11.2.节目取消通知接口 回调
     *
     *  @param item         节目
     *
     */
    void OnRecvCancelProgramNotice(const IMProgramItem& item) override;
    
    /**
     *  11.3.接收节目已退票通知接口 回调
     *
     *  @param item         节目
     *  @param leftCredit   当前余额
     *
     */
    void OnRecvRetTicketNotice(const IMProgramItem& item, double leftCredit) override;
    
    /**
     *  12.2.接收私信文本消息通知接口 回调
     *
     *  @param item         私信文本消息
     *
     */
    void OnRecvPrivateMessageNotice(const IMPrivateMessageItem& item) override;
    
    // ------------- 信件 -------------
    /**
     *  13.1.接收意向信通知 接口 回调
     *
     *  @param anchorId         主播ID
     *  @param loiId            信件ID
     *
     */
    void OnRecvLoiNotice(const string& anchorId, const string& loiId) override;
    
    /**
     *  13.2.接收意向信通知 接口 回调
     *
     *  @param anchorId         主播ID
     *  @param emfId            信件ID
     *
     */
    void OnRecvEMFNotice(const string& anchorId, const string& emfId) override;
    
};
