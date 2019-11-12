package com.qpidnetwork.livemodule.livechat.jni;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadySoundType;


/**
 * LiveChat回调接口类
 * @author Samson Fan
 */
public abstract class LiveChatClientListener {
	
	/**
	 * 处理结果类型
	 */
	public enum LiveChatErrType {
		Fail,		// 服务器返回失败结果
		Success,	// 成功
		
		// 服务器返回错误
		UnbindInterpreter,		// 女士的翻译未将其绑定
		SideOffile,				// 对方不在线（聊天）
		DuplicateChat,			// 聊天状态已经建立
		NoMoney,				// 帐号余额不足
		InvalidUser,			// 用户不存在（登录）
		TargetNotExist,			// 目标用户不存在
		InvalidPassword,		// 密码错误（登录）
		NoTransOrAgentFound,	// 没有找到翻译或机构
		NoPermission,			// 没有权限
		TransInfoChange,		// 翻译信息改变
		ChatTargetReject,		// 对方拒绝
		MaxBinding,				// 超过最大连接数
		CommandReject,			// 请求被拒绝
		BlockUser,				// 对方为黑名单用户（聊天）
		IdentifyCode,			// 需要验证码
		SocketNotExist,			// socket不存在
		EmotionError,			// 高级表情异常（聊天）
		FrequencyEmotion,		// 高级表情发送过快（聊天）
		WarnTimes,				// 严重警告
		PhotoError,				// 图片异常（聊天）
		WomanChatLimit,			// 女士聊天上限
		FrequencyVoice,			// 语音发送过快（聊天）
		MicVideo,				// 不允许发送视频
		VoiceError,				// 语音异常（聊天）
		NoSession,				// session错误
		FrequencyMagicIcon,		// 小高表发送过快
		MagicIconError,			// 小高表异常
		WomanActiveChatLimit,	// 女士发送邀请过快
		SubjectException,		//主题异常
		SubjectExistException,  //主题存在异常
		SubjectNotExistException,//主题不存在异常
		CamChatServiceException, //视频聊天异常
		CamServiceUnStartException,//视频服务未启动异常
		NoCamServiceException,   //	没有视频服务异常
		NormalLogicException,	// 普通逻辑异常
		
		// 客户端定义的错误
		ProtocolError,			// 协议解析失败（服务器返回的格式不正确）
		ConnectFail,			// 连接服务器失败/断开连接
		CheckVerFail,			// 检测版本号失败（可能由于版本过低导致）
		LoginFail,				// 登录失败
		ServerBreak,			// 服务器踢下线
		CanNotSetOffline,		// 不能把在线状态设为"离线"，"离线"请使用Logout()
		NotSupportedFunction,   // 对方不支持该功能
	};
	
	/**
	 * 登录回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public abstract void OnLogin(LiveChatErrType errType, String errmsg);
	public void OnLogin(int errType, String errmsg) {
		OnLogin(LiveChatErrType.values()[errType], errmsg);
	}
	
	/**
	 * 注销/断线回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public abstract void OnLogout(LiveChatErrType errType, String errmsg);
	public void OnLogout(int errType, String errmsg) {
		OnLogout(LiveChatErrType.values()[errType], errmsg);
	}
	
	/**
	 * 设置在线状态回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public abstract void OnSetStatus(LiveChatErrType errType, String errmsg);
	public void OnSetStatus(int errType, String errmsg) {
		OnSetStatus(LiveChatErrType.values()[errType], errmsg);
	}
	
	/**
	 * 结束聊天会话回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 */
	public abstract void OnEndTalk(LiveChatErrType errType, String errmsg, String userId);
	public void OnEndTalk(int errType, String errmsg, String userId) {
		OnEndTalk(LiveChatErrType.values()[errType], errmsg, userId);
	}
	
	/**
	 * 获取用户在线状态回调
	 * @param errType			处理结果类型
	 * @param errmsg			处理结果描述
	 * @param userStatusArray	用户在线状态数组
	 */
	public abstract void OnGetUserStatus(LiveChatErrType errType, String errmsg, LiveChatUserStatus[] userStatusArray);
	public void OnGetUserStatus(int errType, String errmsg, LiveChatUserStatus[] userStatusArray) {
		OnGetUserStatus(LiveChatErrType.values()[errType], errmsg, userStatusArray);
	}
	
	/**
	 * 获取聊天会话信息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param invitedId	邀请ID
	 * @param charget	是否已付费
	 * @param chatTime	聊天时长
	 */
	public abstract void OnGetTalkInfo(LiveChatErrType errType, String errmsg, String userId, String invitedId, boolean charget, int chatTime);
	public void OnGetTalkInfo(int errType, String errmsg, String userId, String invitedId, boolean charget, int chatTime) {
		OnGetTalkInfo(LiveChatErrType.values()[errType], errmsg, userId, invitedId, charget, chatTime);
	}
	
	/**
	 * 获取聊天会话信息回调(CMD 55)
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param item
	 */
	public abstract void OnGetSessionInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item);
	public void OnGetSessionInfo(int errType, String errmsg, String userId, LiveChatSessionInfoItem item) {
		OnGetSessionInfo(LiveChatErrType.values()[errType], errmsg, userId, item);
	}
	
	/**
	 * 发送聊天文本消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param message	消息内容
	 * @param ticket	票根
	 */
	public abstract void OnSendMessage(LiveChatErrType errType, String errmsg, String userId, String message, int ticket);
	public void OnSendMessage(int errType, String errmsg, String userId, String message, int ticket) {
		OnSendMessage(LiveChatErrType.values()[errType], errmsg, userId, message, ticket);
	}

	/**
	 * 发送高级表情消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param emotionId	高级表情ID
	 * @param ticket	票根
	 */
	public abstract void OnSendEmotion(LiveChatErrType errType, String errmsg, String userId, String emotionId, int ticket);
	public void OnSendEmotion(int errType, String errmsg, String userId, String emotionId, int ticket) {
		OnSendEmotion(LiveChatErrType.values()[errType], errmsg, userId, emotionId, ticket);
	}

	/**
	 * 发送虚拟礼物回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param giftId	虚拟礼物ID
	 */
	public abstract void OnSendVGift(LiveChatErrType errType, String errmsg, String userId, String giftId, int ticket);
	public void OnSendVGift(int errType, String errmsg, String userId, String giftId, int ticket) {
		OnSendVGift(LiveChatErrType.values()[errType], errmsg, userId, giftId, ticket);
	}
	
	/**
	 * 获取发送语音验证码回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param voiceCode	语音ID
	 */
	public abstract void OnGetVoiceCode(LiveChatErrType errType, String errmsg, String userId, int ticket, String voiceCode);
	public void OnGetVoiceCode(int errType, String errmsg, String userId, int ticket, String voiceCode) {
		OnGetVoiceCode(LiveChatErrType.values()[errType], errmsg, userId, ticket, voiceCode);
	}

	/**
	 * 发送语音回调 
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param voiceId	语音ID
	 */
	public abstract void OnSendVoice(LiveChatErrType errType, String errmsg, String userId, String voiceId, int ticket);
	public void OnSendVoice(int errType, String errmsg, String userId, String voiceId, int ticket) {
		OnSendVoice(LiveChatErrType.values()[errType], errmsg, userId, voiceId, ticket);
	}
	
	/**
	 * 发送小高级表情消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param magicIconId 小高级表情ID
	 * @param ticket	票根
	 */
	public abstract void OnSendMagicIcon(LiveChatErrType errType, String errmsg, String userId, String magicIconId, int ticket);
	public void OnSendMagicIcon(int errType, String errmsg, String userId, String magicIconId, int ticket) {
		OnSendMagicIcon(LiveChatErrType.values()[errType], errmsg, userId, magicIconId, ticket);
	}

	/**
	 * 试聊事件定义
	 */
	public enum TryTicketEventType {
		Unknow,		// 未知
		Normal,		// 正常使用
		Used,		// 已使用券
		Paid,		// 已付费
		NoTicket,	// 没有券
		Offline,	// 对方已离线
	}
	
	/**
	 * 使用试聊券回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param eventType	试聊券使用情况
	 */
	public abstract void OnUseTryTicket(LiveChatErrType errType, String errmsg, String userId, TryTicketEventType eventType);
	public void OnUseTryTicket(int errType, String errmsg, String userId, int eventType) {
		OnUseTryTicket(LiveChatErrType.values()[errType], errmsg, userId, TryTicketEventType.values()[eventType]);
	}
	
	/**
	 * 获取邀请/在聊列表回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param listType	请求列表类型
	 * @param info		请求结果
	 */
	public abstract void OnGetTalkList(LiveChatErrType errType, String errmsg, int listType, LiveChatTalkListInfo info);
	public void OnGetTalkList(int errType, String errmsg, int listType, LiveChatTalkListInfo info) {
		OnGetTalkList(LiveChatErrType.values()[errType], errmsg, listType, info);
	}

	/**
	 * 发送图片回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public abstract void OnSendPhoto(LiveChatErrType errType, String errmsg, int ticket);
	public void OnSendPhoto(int errType, String errmsg, int ticket) {
		OnSendPhoto(LiveChatErrType.values()[errType], errmsg, ticket);
	}
	
	/**
	 * 显示图片回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param ticket	票根
	 */
	public abstract void OnShowPhoto(LiveChatErrType errType, String errmsg, int ticket);
	public void OnShowPhoto(int errType, String errmsg, int ticket) {
		OnShowPhoto(LiveChatErrType.values()[errType], errmsg, ticket);
	}
	
	/**
	 * 播放微视频
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param ticket	票根
	 */
	public abstract void OnPlayVideo(LiveChatErrType errType, String errmsg, int ticket);
	public void OnPlayVideo(int errType, String errmsg, int ticket) {
		OnPlayVideo(LiveChatErrType.values()[errType], errmsg, ticket);
	}
	
	/**
	 * 获取用户信息
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param item		用户信息item
	 */
	public abstract void OnGetUserInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item);
	public void OnGetUserInfo(int errType, String errmsg, String userId, LiveChatTalkUserListItem item) {
		OnGetUserInfo(LiveChatErrType.values()[errType], errmsg, userId, item);
	}
	
	/**
	 * 批量获取用户信息
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public abstract void OnGetUsersInfo(LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] userInfoList);
	public void OnGetUsersInfo(int errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] userInfoList) {
		OnGetUsersInfo(LiveChatErrType.values()[errType], errmsg, userIds, userInfoList);
	}
	
	/**
	 * 获取黑名单列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param list		黑名单列表
	 */
	public abstract void OnGetBlockList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list);
	public void OnGetBlockList(int errType, String errmsg, LiveChatTalkUserListItem[] list) {
		OnGetBlockList(LiveChatErrType.values()[errType], errmsg, list);
	}
	
	/**
	 * 获取LiveChat联系人列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param list		联系人列表
	 */
	public abstract void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list);
	public void OnGetContactList(int errType, String errmsg, LiveChatTalkUserListItem[] list) {
		OnGetContactList(LiveChatErrType.values()[errType], errmsg, list);
	}
	
	/**
	 * 获取被屏蔽女士列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param usersId	被屏蔽女士列表
	 */
	public abstract void OnGetBlockUsers(LiveChatErrType errType, String errmsg, String[] usersId);
	public void OnGetBlockUsers(int errType, String errmsg, String[] usersId) {
		OnGetBlockUsers(LiveChatErrType.values()[errType], errmsg, usersId);
	}
	
	/**
	 * 获取女士择偶条件回调
	 * @param condition	女士择偶条件
	 */
	public abstract void OnGetLadyCondition(LiveChatErrType errType, String errmsg, String womanId, LiveChatLadyCondition condition);
	public void OnGetLadyCondition(int errType, String errmsg, String womanId, LiveChatLadyCondition condition) {
		OnGetLadyCondition(LiveChatErrType.values()[errType], errmsg, womanId, condition);
	}
	
	/**
	 * 获取女士自定义邀请模板
	 * @param womanId	女士ID
	 * @param contents	自定义邀请模板内容
	 * @param flags		自定义邀请模板是否可用
	 */
	public abstract void OnGetLadyCustomTemplate(LiveChatErrType errType, String errmsg, String womanId, String[] contents, boolean[] flags);
	public void OnGetLadyCustomTemplate(int errType, String errmsg, String womanId, String[] contents, boolean[] flags) {
		OnGetLadyCustomTemplate(LiveChatErrType.values()[errType], errmsg, womanId, contents, flags);
	}

	/**
	 * 上传弹出女士自动邀请消息
	 * @param InviteId		邀请ID
	 */
	public abstract void OnUploadPopLadyAutoInvite(LiveChatErrType errType, String errmsg, String womanId, String msgId, String key, String InviteId);
	public void OnUploadPopLadyAutoInvite(int errType, String errmsg, String womanId, String msgId, String key, String InviteId) {
		OnUploadPopLadyAutoInvite(LiveChatErrType.values()[errType], errmsg, womanId, msgId, key, InviteId);
	}
	
	/**
	 * 获取指定男/女士的已购主题包
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param paidThemeList
	 */
	public abstract void OnGetPaidTheme(LiveChatErrType errType, String errmsg, String userId, LCPaidThemeInfo[] paidThemeList);
	public void OnGetPaidTheme(int errType, String errmsg, String userId,  LCPaidThemeInfo[] paidThemeList) {
		OnGetPaidTheme(LiveChatErrType.values()[errType], errmsg, userId, paidThemeList);
	}
	
	/**
	 * 获取所有已购主题包
	 * @param errType
	 * @param errmsg
	 * @param paidThemeList
	 */
	public abstract void OnGetAllPaidTheme(LiveChatErrType errType, String errmsg, LCPaidThemeInfo[] paidThemeList);
	public void OnGetAllPaidTheme(int errType, String errmsg, LCPaidThemeInfo[] paidThemeList) {
		OnGetAllPaidTheme(LiveChatErrType.values()[errType], errmsg, paidThemeList);
	}
	
	/**
	 * 男士购买主题包
	 * @param errType
	 * @param errmsg
	 * @param paidThemeInfo
	 */
	public abstract void OnManFeeTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo);
	public void OnManFeeTheme(int errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo) {
		OnManFeeTheme(LiveChatErrType.values()[errType], womanId, themeId, errmsg, paidThemeInfo);
	}
	
	/**
	 * 男士应用主题包
	 * @param errType
	 * @param errmsg
	 * @param paidThemeInfo
	 */
	public abstract void OnManApplyTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo);
	public void OnManApplyTheme(int errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo) {
		OnManApplyTheme(LiveChatErrType.values()[errType], womanId, themeId, errmsg, paidThemeInfo);
	}
	
	/**
	 * 播放主题包动画
	 * @param errType
	 * @param errmsg
	 */
	public abstract void OnPlayThemeMotion(LiveChatErrType errType, String errmsg, String womanId, String themeId);
	public void OnPlayThemeMotion(int errType, String errmsg, String womanId, String themeId) {
		OnPlayThemeMotion(LiveChatErrType.values()[errType], errmsg, womanId, themeId);
	}
	
	/**
	 * 获取女士Cam是否打开回调
	 * @param errType
	 * @param errmsg
	 * @param womanId              女士ID
	 * @param isCam                Cam的状态（ture： 打开 ， false：关闭）
	 */
	public abstract void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg, String womanId, boolean isCam);
	public void OnGetLadyCamStatus(int errType, String errmsg, String womanId, boolean isCam) {
		OnGetLadyCamStatus(LiveChatErrType.values()[errType], errmsg, womanId, isCam);	
	}
	
	/**
	 * 发送CamShare邀请回调
	 * @param errType
	 * @param errmsg

	 */
	public abstract void OnSendCamShareInvite(LiveChatErrType errType, String errmsg, String userId);
	public void OnSendCamShareInvite(int errType, String errmsg, String userId) {
		OnSendCamShareInvite(LiveChatErrType.values()[errType], errmsg, userId);	
	}
	
	/**
	 * 男士发起CamShare并开始扣费回调
	 * @param errType
	 * @param errmsg
	 * @param userId               CamShare对象Id
	 * @param inviteId             邀请会话Id
	 */
	public abstract void OnApplyCamShare(LiveChatErrType errType, String errmsg, String userId, String inviteId);
	public void OnApplyCamShare(int errType, String errmsg, String userId, String inviteId) {
		OnApplyCamShare(LiveChatErrType.values()[errType], errmsg, userId, inviteId);	
	}
	
	/**
	 * 批量获取女士端Cam状态回调
	 * @param errType
	 * @param errmsg
	 */
	public abstract void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg, LiveChatUserCamStatus[] userIds);
	public void OnGetUsersCamStatus(int errType, String errmsg, LiveChatUserCamStatus[] userIds) {
		OnGetUsersCamStatus(LiveChatErrType.values()[errType], errmsg, userIds);	
	}
	
	public abstract void OnCamshareUseTryTicket(LiveChatErrType errType, String errmsg, String userId, String ticketId, String inviteId);
	public void OnCamshareUseTryTicket(int errType, String errmsg, String userId, String ticketId, String inviteId) {
		OnCamshareUseTryTicket(LiveChatErrType.values()[errType], errmsg, userId, ticketId, inviteId);	
	}
	
	/**
	 * 聊天消息类型
	 */
	public enum TalkMsgType {
		TMT_UNKNOW,			// 未知
		TMT_FREE,			// 免费
		TMT_CHARGE,			// 收费
		TMT_CHARGE_FREE,	// 试聊券
	}
	
	/**
	 * 接收聊天文本消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param message	消息内容
	 */
	public abstract void OnRecvMessage(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, TalkMsgType msgType, String message, LiveChatClient.InviteStatusType inviteType);
	public void OnRecvMessage(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, int msgType, String message, int inviteType) {
		OnRecvMessage(toId, fromId, fromName, inviteId, charget, ticket, TalkMsgType.values()[msgType], message, LiveChatClient.InviteStatusType.values()[inviteType]);
	}
	
	
	/**
	 * 接收高级表情消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param emotionId	高级表情ID
	 */
	public abstract void OnRecvEmotion(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, TalkMsgType msgType, String emotionId);
	public void OnRecvEmotion(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, int msgType, String emotionId) {
		OnRecvEmotion(toId, fromId, fromName, inviteId, charget, ticket, TalkMsgType.values()[msgType], emotionId);
	}
	
	/**
	 * 接收语音消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param msgType	聊天消息类型
	 * @param voiceId	语音ID
	 */
	public abstract void OnRecvVoice(String toId, String fromId, String fromName, String inviteId, boolean charget, TalkMsgType msgType, String voiceId, String fileType, int timeLen);
	public void OnRecvVoice(String toId, String fromId, String fromName, String inviteId, boolean charget, int msgType, String voiceId, String fileType, int timeLen) {
		OnRecvVoice(toId, fromId, fromName, inviteId, charget, TalkMsgType.values()[msgType], voiceId, fileType, timeLen);
	}
	
	/**
	 * 接收小高级表情消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param magicIconId 小高级表情ID
	 */
	public abstract void OnRecvMagicIcon(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, TalkMsgType msgType, String magicIconId);
	public void OnRecvMagicIcon(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, int msgType, String magicIconId) {
		OnRecvMagicIcon(toId, fromId, fromName, inviteId, charget, ticket, TalkMsgType.values()[msgType], magicIconId);
	}
	
	/**
	 * 接收警告消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param message	消息内容
	 */
	public abstract void OnRecvWarning(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, TalkMsgType msgType, String message);
	public void OnRecvWarning(String toId, String fromId, String fromName, String inviteId, boolean charget, int ticket, int msgType, String message) {
		OnRecvWarning(toId, fromId, fromName, inviteId, charget, ticket, TalkMsgType.values()[msgType], message);
	}
	
	/**
	 * 接收图片消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param photoId	图片ID
	 * @param sendId	图片发送ID
	 * @param charget	是否已付费
	 * @param photoDesc	图片描述
	 * @param ticket	票根
	 */
	public abstract void OnRecvPhoto(String toId, String fromId, String fromName, String inviteId, String photoId, String sendId, boolean charget, String photoDesc, int ticket);
	
	/**
	 * 接收微视频消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @param sendId	发送ID
	 * @param charget	是否已付费
	 * @param videoDesc	视频描述
	 * @param ticket	票根
	 */
	public abstract void OnRecvVideo(String toId, String fromId, String fromName, String inviteId, String videoId, String sendId, boolean charget, String videoDesc, int ticket);

	/**
	 * 接收更新在线状态消息回调
	 * @param userId
	 * @param server
	 * @param clientType
	 * @param statusType
	 */
	public abstract void OnUpdateStatus(String userId, String server, LiveChatClient.ClientType clientType, LiveChatClient.UserStatusType statusType);
	public void OnUpdateStatus(String userId, String server, int clientType, int statusType) {
		OnUpdateStatus(userId, server, LiveChatClient.ClientType.values()[clientType], LiveChatClient.UserStatusType.values()[statusType]);
	}

	/**
	 * 接收更新票根消息回调
	 * @param fromId	发送者ID
	 * @param ticket	票根
	 */
	public abstract void OnUpdateTicket(String fromId, int ticket);

	/**
	 * 接收用户正在编辑消息回调 
	 * @param fromId	用户ID
	 */
	public abstract void OnRecvEditMsg(String fromId);

	/**
	 * 聊天事件类型
	 */
	public enum TalkEventType {
		Unknow,			// 未知
		EndTalk,		// 结束聊天
		StartCharge,	// 开始收费
		StopCharge,		// 暂停收费
		NoMoney,		// 余额不足
		VideoNoMoney,	// 视频余额不足
		TargetNotFound,	// 目标不存在
	}
	
	/**
	 * 接收聊天事件消息回调
	 * @param userId	聊天对象ID
	 * @param eventType	聊天事件
	 */
	public abstract void OnRecvTalkEvent(String userId, TalkEventType eventType);
	public void OnRecvTalkEvent(String userId, int eventType) {
		OnRecvTalkEvent(userId, TalkEventType.values()[eventType]);
	}
	
	/**
	 * 接收试聊开始消息回调
	 * @param toId		接收者ID
	 * @param fromId	发起者ID
	 * @param time		试聊时长
	 */
	public abstract void OnRecvTryTalkBegin(String toId, String fromId, int time);
	
	/**
	 * 接收试聊结束消息回调
	 * @param userId	聊天对象ID
	 */
	public abstract void OnRecvTryTalkEnd(String userId);
	
	/**
	 * 邮件类型
	 */
	public enum TalkEmfNoticeType {
		Unknow,		// 未知
		EMF,		// EMF
		Admirer,	// 意向信
	}
	
	/**
	 * 接收邮件更新消息回调
	 * @param fromId		发送者ID
	 * @param noticeType	邮件类型
	 */
	public abstract void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType);
	public void OnRecvEMFNotice(String fromId, int noticeType) {
		OnRecvEMFNotice(fromId, TalkEmfNoticeType.values()[noticeType]);
	}

	/**
	 * 被踢下线类型
	 */
	public enum KickOfflineType {
		Unknow,		// 未知
		Maintain,	// 服务器维护退出通知
		Timeout,	// 心跳包超时
		OtherLogin,	// 用户在其它地方登录
	}
	
	/**
	 * 接收被踢下线消息回调
	 * @param kickType	被踢下线原因
	 */
	public abstract void OnRecvKickOffline(KickOfflineType kickType);
	public void OnRecvKickOffline(int kickType) {
		OnRecvKickOffline(KickOfflineType.values()[kickType]);
	}
	
	/**
	 * 接收自动邀请消息回调
	 * @param womanId	女士ID
	 * @param manId		男士ID
	 * @param key		验证码
	 */
	public abstract void OnRecvAutoInviteMsg(String womanId, String manId, String key);
	
	/**
	 * 自动充值状态
	 */
	public enum AutoChargeType {
		Start,	// 开始自动充值
		End,	// 完成自动充值
	}
	/**
	 * 接收自动充值状态回调 
	 * @param manId		男士ID
	 * @param money		当前余额
	 * @param type		自动充值状态
	 * @param result	自动充值结果
	 * @param code		自动充值结果状态码
	 * @param msg		自动充值结果状态码描述
	 */
	public abstract void OnRecvAutoChargeResult(String manId, double money, AutoChargeType type, boolean result, String code, String msg);
	public void OnRecvAutoChargeResult(String manId, double money, int type, boolean result, String code, String msg) {
		OnRecvAutoChargeResult(manId, money, AutoChargeType.values()[type], result, code, msg);
	}
	
	/**
	 * 播放主题包动画通知
	 * @param themeId
	 * @param manId
	 * @param womanId
	 */
	public abstract void OnRecvThemeMotion(String themeId, String manId, String womanId);
	
	/**
	 * 女士推荐男士购买主题包通知
	 * @param themeId
	 * @param manId
	 * @param womanId
	 */
	public abstract void OnRecvThemeRecommend(String themeId, String manId, String womanId);
	
	/**
	 * 女士Cam状态改变通知
	 * @param userId                // 女士ID
	 * @param statuType				// 状态类型（0：下线，1：上线，2：隐藏，3：绑定，4：解开，5：视频开放，6：视频关闭，7：Cam打开，8：Cam关闭）
	 * @param server				// 服务器名称
	 * @param ClientType			// 客户端类型
	 * @param version				// 客户端版本号
	 */
	public abstract void OnRecvLadyCamStatus(String userId, LiveChatClient.UserStatusProtocol statuType, String server, LiveChatClient.ClientType ClientType, CamshareLadySoundType soundType, String version);
	public void OnRecvLadyCamStatus(String userId, int statuType, String server, int ClientType, int sound, String version){
		OnRecvLadyCamStatus(userId, LiveChatClient.UserStatusProtocol.values()[statuType] , server, LiveChatClient.ClientType.values()[ClientType], CamshareLadySoundType.values()[sound], version);
	}
		
	/**
	 * 女士接受邀请通知
	 * @param fromId            // 消息发送者
	 * @param toId				// 消息接收者
	 * @param isCam				// Cam是否打开（布尔）
	 */
	public abstract void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam);
	public void OnRecvAcceptCamInvite(String fromId, String toId, int inviteType, int sessionId, String fromName, boolean isCam){
		OnRecvAcceptCamInvite(fromId, toId, CamshareLadyInviteType.values()[inviteType], sessionId, fromName, isCam);
	}
	
	/**
	 * 收到心跳包异常通知
	 * @param errMsg
	 * @param errType
	 * @param targetId
	 */
	public abstract void OnRecvCamHearbeatException(String errMsg, LiveChatErrType errType, String targetId);
	public void OnRecvCamHearbeatException(String errMsg, int errType, String targetId) {
		OnRecvCamHearbeatException(errMsg , LiveChatErrType.values()[errType], targetId);
	}

	/**
	 * 发送邀请语回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param inviteMsg	邀请语
	 * @param nickName		聊天对象昵称
	 */
	public abstract void OnSendInviteMessage(LiveChatErrType errType, String errmsg, String userId, String inviteMsg, String inviteId, String nickName);
	public void OnSendInviteMessage(int errType, String errmsg, String userId, String inviteMsg, String inviteId, String nickName) {
		OnSendInviteMessage(LiveChatErrType.values()[errType], errmsg, userId, inviteMsg, inviteId, nickName);
	}
	
}
