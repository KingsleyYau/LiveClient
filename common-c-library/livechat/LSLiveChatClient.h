/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: LSLiveChatClient.h
 *   desc: LiveChat客户端实现类
 */

#pragma once

#include "ILSLiveChatClient.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatThreadHandler.h"
#include "LSLiveChatCounter.h"

#include <common/IAutoLock.h>

typedef list<ILSLiveChatClientListener*> LSLiveChatClientListenerList;

class CLSLiveChatClient : public ILSLiveChatClient
					  , private ILSLiveChatTaskManagerListener
                      , private ILSLiveChatClientListener
{
public:
	CLSLiveChatClient();
	virtual ~CLSLiveChatClient();

// ILSLiveChatClient接口函数
public:
	// 调用所有接口函数前需要先调用Init
	bool Init(const list<string>& svrIPs, unsigned int svrPort) override;
    // 增加监听器
    void AddListener(ILSLiveChatClientListener* listener) override;
    // 移除监听器
    void RemoveListener(ILSLiveChatClientListener* listener) override;
	// 判断是否无效seq
	bool IsInvalidSeq(int seq) override;
	// 登录
	bool Login(const string& user, const string& password, const string& deviceId, CLIENT_TYPE clientType, USER_SEX_TYPE sexType, AUTH_TYPE authType = AUTH_TYPE_SID) override;
	// 注销
	bool Logout() override;
	// 设置在线状态
	bool SetStatus(USER_STATUS_TYPE status) override;
	// 结束聊天
	bool EndTalk(const string& userId) override;
	// 获取用户在线状态
	bool GetUserStatus(const UserIdList& list) override;
	// 获取会话信息
	bool GetTalkInfo(const string& userId) override;
	// 获取会话信息(仅男士端使用)
	bool GetSessionInfo(const string& userId) override;
	// 上传票根
	bool UploadTicket(const string& userId, int ticket) override;
	// 通知对方女士正在编辑消息
	bool SendLadyEditingMsg(const string& userId) override;
	// 发送聊天消息
	bool SendTextMessage(const string& userId, const string& message, bool illegal, int ticket, INVITE_TYPE inviteType = INVITE_TYPE_CHAT) override;
	// 发送高级表情
	bool SendEmotion(const string& userId, const string& emotionId, int ticket) override;
	// 发送虚拟礼物
	bool SendVGift(const string& userId, const string& giftId, int ticket) override;
	// 获取语音发送验证码
	bool GetVoiceCode(const string& userId, int ticket) override;
	// 获取女士语音发送验证码
	bool GetLadyVoiceCode(const string& userId) override;
	// 发送语音
	bool SendVoice(const string& userId, const string& voiceId, int length, int ticket) override;
	// 使用试聊券
	bool UseTryTicket(const string& userId) override;
	// 获取邀请列表或在聊列表
	bool GetTalkList(int listType) override;
	// 发送图片
	bool SendPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket) override;
	// 女士发送图片
	bool SendLadyPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) override;
	// 显示图片
	bool ShowPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket) override;
	// 获取用户信息
	int GetUserInfo(const string& userId) override;
	// 获取多个用户信息
	int GetUsersInfo(const list<string>& userIdList) override;
	// 获取联系人/黑名单列表
	bool GetContactList(CONTACT_LIST_TYPE listType) override;
	// 上传客户端版本号
	bool UploadVer(const string& ver) override;
	// 获取被屏蔽女士列表
	bool GetBlockUsers() override;
	// 获取最近联系人列表
	bool GetRecentContactList() override;
	// 搜索在线男士
	bool SearchOnlineMan(int beginAge, int endAge) override;
	// 回复验证码
	bool ReplyIdentifyCode(string identifyCode) override;
	// 刷新验证码
	bool RefreshIdentifyCode() override;
	// 刷新邀请模板
	bool RefreshInviteTemplate() override;
	// 获取已扣费联系人列表
	bool GetFeeRecentContactList() override;
	// 获取女士聊天信息（包括在聊及邀请的男士列表等）
	bool GetLadyChatInfo() override;
	// 播放视频
	bool PlayVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charget, const string& videoDesc, int ticket) override;
	// 女士发送微视频
	bool SendLadyVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) override;
	// 获取女士择偶条件
	bool GetLadyCondition(const string& userId) override;
	// 获取女士自定义邀请模板
	bool GetLadyCustomTemplate(const string& userId) override;
	// 弹出女士自动邀请消息通知
	bool UploadPopLadyAutoInvite(const string& userId, const string& msg, const string& key) override;
	// 上传自动充值状态
	bool UploadAutoChargeStatus(bool isCharge) override;
	// 发送小高级表情
	bool SendMagicIcon(const string& userId, const string& iconId, int ticket) override;
	// 获取指定男/女士已购主题包
	bool GetPaidTheme(const string& userId) override;
	// 获取男/女士所有已购主题包
	bool GetAllPaidTheme() override;
	// 上传主题包列表版本号
	bool UploadThemeListVer(int themeVer) override;
	// 男士购买主题包
	bool ManFeeTheme(const string& userId, const string& themeId) override;
	// 男士应用主题包
	bool ManApplyTheme(const string& userId, const string& themeId) override;
	// 男/女士播放主题包动画
	bool PlayThemeMotion(const string& userId, const string& themeId) override;
	// 获取自动邀请状态（仅女士）
	bool GetAutoInviteMsgSwitchStatus() override;
	// 启动/关闭发送自动邀请消息（仅女士）
	bool SwitchAutoInviteMsg(bool isOpen) override;
	// 女士推荐男士购买主题包（仅女士）
	bool RecommendThemeToMan(const string& userId, const string& themeId) override;
    
	// 获取女士Cam状态
	int GetLadyCamStatus(const string& userId) override;
	// 发送CamShare邀请
	bool SendCamShareInvite(const string& userId, CamshareInviteType inviteType, int sessionId, const string& fromName) override;
	// 男士发起CamShare并开始扣费
	bool ApplyCamShare(const string& userId) override;
	// 女士接受男士Cam邀请
	bool LadyAcceptCamInvite(const string& userId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isOpenCam) override;
    // CamShare聊天扣费心跳
	bool CamShareHearbeat(const string& userId, const string& inviteId) override;
	// 批量获取女士端Cam状态
	bool GetUsersCamStatus(const UserIdList& list) override;
	// Camshare使用试聊券
	bool CamshareUseTryTicket(const string& targetId, const string& ticketId) override;
	// 女士端更新Camshare服务状态到服务器
	virtual bool SummitLadyCamStatus(CAMSHARE_STATUS_TYPE camStatus) override;
	// 女士端获取会话信息
	virtual bool GetSessionInfoWithMan(const string& targetId) override;
	// 女士端设置小助手Cam优先
	virtual bool SummitAutoInviteCamFirst(bool camFirst) override;
    // 发送邀请语
    virtual bool SendInviteMessage(const string& inUserId, const string& inMessage, const string& nickName) override;
    // 发送预约邀请
    virtual bool SendScheduleInvite(const LSLCScheduleInfoItem& item) override;
    
public:
	// 获取用户账号
	string GetUser() override;
    // 获取原始socket
    int GetSocket() override;
// ILSLiveChatTaskManagerListener接口函数
private:
	// 连接成功回调
	void OnConnect(bool success) override;
	// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	void OnDisconnect() override;
	// 断开连接或连接失败回调(listUnsentTask：未发送/未回复的task列表)
	void OnDisconnect(const TaskList& list) override;
	// 已完成交互的task
	void OnTaskDone(ILSLiveChatTask* task) override;

// 处理完成交互的task函数
private:
	void OnCheckVerTaskDone(ILSLiveChatTask* task);

private:
	// 连接服务器
	bool ConnectServer();
	// 检测版本号
	bool CheckVersionProc();
	// 登录
	bool LoginProc();
	// 上传设备ID
	bool UploadDeviceIdProc();
	// 上传设备类型
	bool UploadDeviceTypeProc();
	// 启动发送心跳包线程
	void HearbeatThreadStart();

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
	string			m_deviceId;		// 设备ID
	CLIENT_TYPE		m_clientType;	// 客户端类型
	USER_SEX_TYPE	m_sexType;		// 性别
	AUTH_TYPE		m_authType;		// 认证类型

	LSLiveChatCounter			m_seqCounter;	// seq计数器

	ILSLiveChatTaskManager*	m_taskManager;	// 任务管理器
//	ILSLiveChatClientListener*	m_listener;	// 监听器

	bool			m_isHearbeatThreadRun;	// 心跳线程运行标志
	ILSLiveChatThreadHandler*		m_hearbeatThread;	// 心跳线程
    
    IAutoLock* m_listenerListLock;
    LSLiveChatClientListenerList m_listenerList;
    
private:
    // 客户端主动请求
    void OnLogin(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnLogout(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetUserStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserStatusList& list) override;
    void OnGetTalkInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& invitedId, bool charge, unsigned int chatTime) override;
    void OnGetSessionInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const SessionInfoItem& sessionInfo) override;
    void OnSendTextMessage(const string& inUserId, const string& inMessage, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSendEmotion(const string& inUserId, const string& inEmotionId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSendVGift(const string& inUserId, const string& inGiftId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetVoiceCode(const string& inUserId, int ticket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& voiceCode) override;
    void OnSendVoice(const string& inUserId, const string& inVoiceId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnUseTryTicket(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent) override;
    void OnGetTalkList(int inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkListInfo& talkListInfo) override;
    void OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnSendLadyPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnShowPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) override;
    void OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList, const UserInfoList& userList) override;
    void OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& list) override;
    void OnGetBlockUsers(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& users) override;
    void OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
    void OnReplyIdentifyCode(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
    void OnGetFeeRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
    void OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& chattingList, const list<string>& chattingInviteIdList, const list<string>& missingList, const list<string>& missingInviteIdList) override;
    void OnPlayVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnSendLadyVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnGetLadyCondition(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LadyConditionItem& item) override;
    void OnGetLadyCustomTemplate(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const vector<string>& contents, const vector<bool>& flags) override;
    void OnSendMagicIcon(const string& inUserId, const string& inIconId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetPaidTheme(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeList) override;
    void OnGetAllPaidTheme(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeInfoList) override;
    void OnManFeeTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) override;
    void OnManApplyTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) override;
    void OnPlayThemeMotion(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool success) override;
    void OnGetAutoInviteMsgSwitchStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) override;
    void OnSwitchAutoInviteMsg(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) override;
    void OnRecommendThemeToMan(const string& inUserId, const string& inThemeId,LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetSessionInfoWithMan(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnUploadPopLadyAutoInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& msg, const string& key, const string& inviteId) override;

    void OnGetLadyCamStatus(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenCam) override;
    void OnSendCamShareInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnApplyCamShare(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isSuccess, const string& targetId) override;
    void OnLadyAcceptCamInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetUsersCamStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg,const UserCamStatusList& list) override;
    void OnCamshareUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& ticketId, const string& inviteId) override;
    void OnSummitLadyCamStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSummitAutoInviteCamFirst(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    // Alex, 发送邀请语
    void OnSendInviteMessage(const string& inUserId, const string& inMessage, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& inviteId, const string& nickName) override;
    // Alex, 发送预约邀请
    void OnSendScheduleInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LSLCScheduleInfoItem& item) override;
    
    // 服务器主动请求
    void OnRecvMessage(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message, INVITE_TYPE inviteType) override;
    void OnRecvEmotion(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& emotionId) override;
    void OnRecvVoice(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, TALK_MSG_TYPE msgType, const string& voiceId, const string& fileType, int timeLen) override;
    void OnRecvWarning(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message) override;
    void OnUpdateStatus(const string& userId, const string& server, CLIENT_TYPE clientType, USER_STATUS_TYPE statusType) override;
    void OnUpdateTicket(const string& fromId, int ticket) override;
    void OnRecvEditMsg(const string& fromId) override;
    void OnRecvTalkEvent(const string& userId, TALK_EVENT_TYPE eventType) override;
    void OnRecvTryTalkBegin(const string& toId, const string& fromId, int time) override;
    void OnRecvTryTalkEnd(const string& userId) override;
    void OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType) override;
    void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) override;
    void OnRecvPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) override;
    void OnRecvShowPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) override;
    void OnRecvLadyVoiceCode(const string& voiceCode) override;
    void OnRecvIdentifyCode(const unsigned char* data, long dataLen) override;
    void OnRecvVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) override;
    void OnRecvShowVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) override;
    void OnRecvAutoInviteMsg(const string& womanId, const string& manId, const string& key) override;
    void OnRecvAutoChargeResult(const string& manId, double money, TAUTO_CHARGE_TYPE type, bool result, const string& code, const string& msg) override;
    void OnRecvMagicIcon(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& iconId) override;
    void OnRecvThemeMotion(const string& themeId, const string& manId, const string& womanId) override;
    void OnRecvThemeRecommend(const string& themeId, const string& manId, const string& womanId) override;
    void OnAutoInviteStatusUpdate(bool isOpenStatus) override;
    void OnRecvAutoInviteNotify(const string& womanId,const string& manId,const string& message,const string& inviteId) override;
    void OnManApplyThemeNotify(const ThemeInfoItem& item) override;
    void OnManBuyThemeNotify(const ThemeInfoItem& item) override;
    void OnRecvManSessionInfo(const SessionInfoItem& sessionInfo) override;
    
    // Camshare协议
    void OnRecvLadyCamStatus(const string& userId, USER_STATUS_PROTOCOL statusId, const string& server, CLIENT_TYPE clientType, CamshareLadySoundType sound, const string& version) override;
    void OnRecvAcceptCamInvite(const string& fromId, const string& toId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isCamOpen) override;
    void OnRecvManCamShareInvite(const string& fromId, const string& toId, CamshareInviteType inviteType, int sessionId, const string& fromName) override;
    void OnRecvManCamShareStart(const string& manId, const string& womanId, const string& inviteId) override;
    void OnRecvCamHearbeatException(const string& exceptionName, LSLIVECHAT_LCC_ERR_TYPE err, const string& targetId) override;
    void OnRecvManJoinOrExitConference(MAN_CONFERENCE_EVENT_TYPE eventType, const string& fromId, const string& toId, const list<string>& userList)override;
    virtual void OnRecvScheduleInviteNotice(const LSLCScheduleInfoItem& item) override;
};
