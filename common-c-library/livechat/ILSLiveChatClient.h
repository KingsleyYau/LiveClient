/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: ILSLiveChatClient.h
 *   desc: LSLiveChat客户端接口类
 *   注意不能在[客户端主动请求]回调函数里面再次调用接口
 */

#pragma once

#include "ILSLiveChatClientDef.h"

// LiveChat客户端监听接口类
class ILSLiveChatClientListener
{
public:
	ILSLiveChatClientListener() {};
	virtual ~ILSLiveChatClientListener() {}

public:
	// 客户端主动请求
	// 回调函数的参数在 err 之前的为请求参数，在 errmsg 之后为返回参数
	virtual void OnLogin(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnLogout(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg){}
	virtual void OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetUserStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserStatusList& list) {}
	virtual void OnGetTalkInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& invitedId, bool charge, unsigned int chatTime) {}
	virtual void OnGetSessionInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const SessionInfoItem& sessionInfo) {}
	virtual void OnSendTextMessage(const string& inUserId, const string& inMessage, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnSendEmotion(const string& inUserId, const string& inEmotionId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnSendVGift(const string& inUserId, const string& inGiftId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetVoiceCode(const string& inUserId, int ticket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& voiceCode) {}
	virtual void OnSendVoice(const string& inUserId, const string& inVoiceId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnUseTryTicket(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent) {}
	virtual void OnGetTalkList(int inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkListInfo& talkListInfo) {}
	virtual void OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {}
	virtual void OnSendLadyPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {}
	virtual void OnShowPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {}
	virtual void OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) {}
	virtual void OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList, const UserInfoList& userList) {}
	virtual void OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& list) {}
	virtual void OnGetBlockUsers(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& users) {}
	virtual void OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {}
	virtual void OnReplyIdentifyCode(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {}
	virtual void OnGetFeeRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {}
	virtual void OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& chattingList, const list<string>& chattingInviteIdList, const list<string>& missingList, const list<string>& missingInviteIdList) {}
	virtual void OnPlayVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {}
	virtual void OnSendLadyVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {}
	virtual void OnGetLadyCondition(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LadyConditionItem& item) {}
	virtual void OnGetLadyCustomTemplate(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const vector<string>& contents, const vector<bool>& flags) {}
	virtual void OnSendMagicIcon(const string& inUserId, const string& inIconId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetPaidTheme(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeList) {}
	virtual void OnGetAllPaidTheme(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeInfoList) {}
	virtual void OnManFeeTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) {}
	virtual void OnManApplyTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) {}
	virtual void OnPlayThemeMotion(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool success) {}
	virtual void OnGetAutoInviteMsgSwitchStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) {}
	virtual void OnSwitchAutoInviteMsg(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) {}
	virtual void OnRecommendThemeToMan(const string& inUserId, const string& inThemeId,LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetSessionInfoWithMan(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
    virtual void OnUploadPopLadyAutoInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& msg, const string& key, const string& inviteId) {}
    
    // Camshare专用
	virtual void OnGetLadyCamStatus(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenCam) {}
	virtual void OnSendCamShareInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnApplyCamShare(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isSuccess, const string& inviteId) {}
	virtual void OnLadyAcceptCamInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnGetUsersCamStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg,const UserCamStatusList& list) {}
	virtual void OnCamshareUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& ticketId, const string& inviteId) {}
	virtual void OnSummitLadyCamStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}
	virtual void OnSummitAutoInviteCamFirst(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {}

	// 服务器主动请求
	virtual void OnRecvMessage(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message, INVITE_TYPE inviteType) {}
	virtual void OnRecvEmotion(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& emotionId) {}
	virtual void OnRecvVoice(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, TALK_MSG_TYPE msgType, const string& voiceId, const string& fileType, int timeLen) {}
	virtual void OnRecvWarning(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message) {}
	virtual void OnUpdateStatus(const string& userId, const string& server, CLIENT_TYPE clientType, USER_STATUS_TYPE statusType) {}
	virtual void OnUpdateTicket(const string& fromId, int ticket) {}
	virtual void OnRecvEditMsg(const string& fromId) {}
	virtual void OnRecvTalkEvent(const string& userId, TALK_EVENT_TYPE eventType) {}
	virtual void OnRecvTryTalkBegin(const string& toId, const string& fromId, int time) {}
	virtual void OnRecvTryTalkEnd(const string& userId) {}
	virtual void OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType) {}
	virtual void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) {}
	virtual void OnRecvPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) {}
	virtual void OnRecvShowPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) {}
	virtual void OnRecvLadyVoiceCode(const string& voiceCode) {}
	virtual void OnRecvIdentifyCode(const unsigned char* data, long dataLen) {}
	virtual void OnRecvVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) {}
	virtual void OnRecvShowVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) {}
	virtual void OnRecvAutoInviteMsg(const string& womanId, const string& manId, const string& key) {}
	virtual void OnRecvAutoChargeResult(const string& manId, double money, TAUTO_CHARGE_TYPE type, bool result, const string& code, const string& msg) {}
	virtual void OnRecvMagicIcon(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& iconId) {}
	virtual void OnRecvThemeMotion(const string& themeId, const string& manId, const string& womanId) {}
	virtual void OnRecvThemeRecommend(const string& themeId, const string& manId, const string& womanId) {}
	virtual void OnAutoInviteStatusUpdate(bool isOpenStatus) {}
	virtual void OnRecvAutoInviteNotify(const string& womanId,const string& manId,const string& message,const string& inviteId) {}
	virtual void OnManApplyThemeNotify(const ThemeInfoItem& item) {}
	virtual void OnManBuyThemeNotify(const ThemeInfoItem& item) {}
	virtual void OnRecvManSessionInfo(const SessionInfoItem& sessionInfo) {}
	
    // Camshare专用
    virtual void OnRecvLadyCamStatus(const string& userId, USER_STATUS_PROTOCOL statusId, const string& server, CLIENT_TYPE clientType, CamshareLadySoundType sound, const string& version) {}
	virtual void OnRecvAcceptCamInvite(const string& fromId, const string& toId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isCamOpen) {}
	virtual void OnRecvManCamShareInvite(const string& fromId, const string& toId, CamshareInviteType inviteType, int sessionId, const string& fromName) {}
	virtual void OnRecvManCamShareStart(const string& manId, const string& womanId, const string& inviteId) {}
	virtual void OnRecvCamHearbeatException(const string& exceptionName, LSLIVECHAT_LCC_ERR_TYPE err, const string& targetId) {}
	virtual void OnRecvManJoinOrExitConference(MAN_CONFERENCE_EVENT_TYPE eventType, const string& fromId, const string& toId, const list<string>& userList) {}
};

// LiveChat客户端接口类
class ILSLiveChatClient
{
public:
	static ILSLiveChatClient* CreateClient();
	static void ReleaseClient(ILSLiveChatClient* client);

public:
	ILSLiveChatClient(void) {};
	virtual ~ILSLiveChatClient(void) {};

public:
	// 调用所有接口函数前需要先调用Init
	virtual bool Init(const list<string>& svrIPs, unsigned int svrPort) = 0;
    // 增加监听器
    virtual void AddListener(ILSLiveChatClientListener* listener) = 0;
    // 移除监听器
    virtual void RemoveListener(ILSLiveChatClientListener* listener) = 0;
	// 判断是否无效seq
	virtual bool IsInvalidSeq(int seq) = 0;
	// 登录
	virtual bool Login(const string& user, const string& password, const string& deviceId, CLIENT_TYPE clientType, USER_SEX_TYPE sexType, AUTH_TYPE authType = AUTH_TYPE_SID) = 0;
	// 注销
	virtual bool Logout() = 0;
	virtual bool SetStatus(USER_STATUS_TYPE status) = 0;
	// 结束聊天
	virtual bool EndTalk(const string& userId) = 0;
	// 获取用户在线状态
	virtual bool GetUserStatus(const UserIdList& list) = 0;
	// 获取会话信息
	virtual bool GetTalkInfo(const string& userId) = 0;
	// 获取会话信息(仅男士端使用)
	virtual bool GetSessionInfo(const string& userId) = 0;
	// 上传票根
	virtual bool UploadTicket(const string& userId, int ticket) = 0;
	// 通知对方女士正在编辑消息
	virtual bool SendLadyEditingMsg(const string& userId) = 0;
	// 发送聊天消息
	virtual bool SendTextMessage(const string& userId, const string& message, bool illegal, int ticket, INVITE_TYPE inviteType = INVITE_TYPE_CHAT) = 0;
	// 发送高级表情
	virtual bool SendEmotion(const string& userId, const string& emotionId, int ticket) = 0;
	// 发送虚拟礼物
	virtual bool SendVGift(const string& userId, const string& giftId, int ticket) = 0;
	// 获取语音发送验证码
	virtual bool GetVoiceCode(const string& userId, int ticket) = 0;
	// 获取女士语音发送验证码
	virtual bool GetLadyVoiceCode(const string& userId) = 0;
	// 发送语音
	virtual bool SendVoice(const string& userId, const string& voiceId, int length, int ticket) = 0;
	// 使用试聊券
	virtual bool UseTryTicket(const string& userId) = 0;
	// 获取邀请列表或在聊列表
	virtual bool GetTalkList(int listType) = 0;
	// 发送图片
	virtual bool SendPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) = 0;
	// 女士发送图片
	virtual bool SendLadyPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) = 0;
	// 显示图片
	virtual bool ShowPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) = 0;
	// 获取用户信息
	virtual int GetUserInfo(const string& userId) = 0;
	// 获取多个用户信息(返回seq)
	virtual int GetUsersInfo(const list<string>& userIdList) = 0;
	// 获取联系人/黑名单列表
	virtual bool GetContactList(CONTACT_LIST_TYPE listType) = 0;
	// 上传客户端版本号
	virtual bool UploadVer(const string& ver) = 0;
	// 获取被屏蔽女士列表
	virtual bool GetBlockUsers() = 0;
	// 获取最近联系人列表
	virtual bool GetRecentContactList() = 0;
	// 搜索在线男士
	virtual bool SearchOnlineMan(int beginAge, int endAge) = 0;
	// 回复验证码
	virtual bool ReplyIdentifyCode(string identifyCode) = 0;
	// 刷新验证码
	virtual bool RefreshIdentifyCode() = 0;
	// 刷新邀请模板
	virtual bool RefreshInviteTemplate() = 0;
    // 获取已扣费联系人列表
	virtual bool GetFeeRecentContactList() = 0;
	// 获取女士聊天信息（包括在聊及邀请的男士列表等）
	virtual bool GetLadyChatInfo() = 0;
	// 播放视频
	virtual bool PlayVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charget, const string& videoDesc, int ticket) = 0;
	// 女士发送微视频
	virtual bool SendLadyVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) = 0;
	// 获取女士择偶条件
	virtual bool GetLadyCondition(const string& userId) = 0;
	// 获取女士自定义邀请模板
	virtual bool GetLadyCustomTemplate(const string& userId) = 0;
	// 弹出女士自动邀请消息通知
	virtual bool UploadPopLadyAutoInvite(const string& userId, const string& msg, const string& key) = 0;
	// 上传自动充值状态
	virtual bool UploadAutoChargeStatus(bool isCharge) = 0;
	// 发送小高级表情
	virtual bool SendMagicIcon(const string& userId, const string& iconId, int ticket) = 0;
	// 获取指定男/女士已购主题包
	virtual bool GetPaidTheme(const string& userId) = 0;
	// 获取男/女士所有已购主题包
	virtual bool GetAllPaidTheme() = 0;
	// 上传主题包列表版本号
	virtual bool UploadThemeListVer(int themeVer) = 0;
	// 男士购买主题包
	virtual bool ManFeeTheme(const string& userId, const string& themeId) = 0;
	// 男士应用主题包
	virtual bool ManApplyTheme(const string& userId, const string& themeId) = 0;
	// 男/女士播放主题包动画
	virtual bool PlayThemeMotion(const string& userId, const string& themeId) = 0;
	// 获取自动邀请状态（仅女士）
	virtual bool GetAutoInviteMsgSwitchStatus() = 0;
	// 启动/关闭发送自动邀请消息（仅女士）
	virtual bool SwitchAutoInviteMsg(bool isOpen) = 0;
	// 女士推荐男士购买主题包（仅女士）
	virtual bool RecommendThemeToMan(const string& userId, const string& themeId) = 0;

	// 获取女士Cam状态(仅男士端)
	virtual int GetLadyCamStatus(const string& userId) = 0;
	// 发送CamShare邀请
	virtual bool SendCamShareInvite(const string& userId, CamshareInviteType inviteType, int sessionId, const string& fromName) = 0;
	// 男士发起CamShare并开始扣费（仅男士端）
	virtual bool ApplyCamShare(const string& userId) = 0;
	// 女士接受男士Cam邀请（仅女士端）
	virtual bool LadyAcceptCamInvite(const string& userId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isOpenCam) = 0;
	 // CamShare聊天扣费心跳
	virtual bool CamShareHearbeat(const string& userId, const string& inviteId)= 0;
	// 批量获取女士端Cam状态（仅男士端）
	virtual bool GetUsersCamStatus(const UserIdList& list) = 0;
	// Camshare使用试聊券
	virtual bool CamshareUseTryTicket(const string& targetId, const string& ticketId)= 0;
	// 女士端更新Camshare服务状态到服务器
	virtual bool SummitLadyCamStatus(CAMSHARE_STATUS_TYPE camStatus) = 0;
	// 女士端获取会话信息
	virtual bool GetSessionInfoWithMan(const string& targetId) = 0;
	// 女士端设置小助手Cam优先
	virtual bool SummitAutoInviteCamFirst(bool camFirst) = 0;
public:
	// 获取用户账号
	virtual string GetUser() = 0;
    // 获取原始socket
    virtual int GetSocket() = 0;
};
