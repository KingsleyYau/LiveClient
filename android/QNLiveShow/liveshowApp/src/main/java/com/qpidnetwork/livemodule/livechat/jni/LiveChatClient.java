package com.qpidnetwork.livemodule.livechat.jni;

/**
 * LiveChat客户端
 * @author Samson Fan
 */
public class LiveChatClient {
	static {
		try {
			System.loadLibrary("lslivechat-interface");
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 客户端类型
	 */
	public enum ClientType {
		CLIENT_UNKNOW,	// 未知
		CLIENT_PC,		// PC端
		CLIENT_PC_JAVA,	// PC Java端
		CLIENT_PC_APP,	// PC app端
		CLIENT_PC_PAD,	// PC pad端
		CLIENT_ANDROID,	// Android客户端
		CLIENT_IPHONE,	// IPhone客户端
		CLIENT_IPAD,	// IPad客户端
		CLIENT_WEB,		// Web端
	}
	
	/**
	 * 用户性别
	 */
	public enum UserSexType{
		USER_SEX_UNKNOW,	// 未知
		USER_SEX_FEMALE,	// 女士
		USER_SEX_MALE,		// 男士
	}
	
	/**
	 * 用户在线状态
	 */
	public enum UserStatusType {
		USTATUS_UNKNOW,				// 未知
		USTATUS_OFFLINE_OR_HIDDEN,	// 离线或隐身
		USTATUS_ONLINE,		// 在线
		USTATUS_HIDDEN, //隐身
	}
	
	/**
	 * 用户Cam状态
	 */
	public enum UserCamStatusType {
		USTATUS_CAM_UNKNOW,	// 未知
		USTATUS_CAM_OFF,	// 关闭
		USTATUS_CAM_ON,	// 打开

	}
	
	/**
	 * 用户Invite状态
	 */
	public enum InviteStatusType {
		INVITE_TYPE_UNKNOW,		      // 未知
		INVITE_TYPE_CHAT,		     // livechat
		INVITE_TYPE_CAMSHARE,		 // camshare
	}
	
	/**
	 * 用户cam状态
	 */
	public enum UserStatusProtocol{
		USTATUSPRO_UNKNOW,                // 未知
		USTATUSPRO_OFFLINE_OR_HIDDEN,	  // 离线/隐身
		USTATUSPRO_ONLINE,				  // 在线
		USTATUSPRO_HIDDEN,				  // 隐身
		USTATUSPRO_BIND,				  // 绑定翻译
		USTATUSPRO_UNBIND,				  // 没有绑定翻译
		USTATUSPRO_VIDEOOPEN,			  // 视频开放
		USTATUSPRO_VIDEOCLOSE,			  // 视频关闭
		USTATUSPRO_CAMOPEN,               // Cam打开
		USTATUSPRO_CAMCLOSE,              // Cam关闭
	};
	
	/**
	 * 男士Camshare邀请类型
	 */
	public enum CamshareInviteType{
		CamshareInviteType_UnKnow,		    	// 未知
		CamshareInviteType_Ask,		     		// 应答同意
		CamshareInviteType_Cancel,		 	 	// 拒绝
		CamshareInviteType_GetLadyCamStatus  	// 通知Cam状态
	};
	
	/**
	 * 女士回男士Camshare邀请类型
	 */
	public enum CamshareLadyInviteType{
		CamshareLadyInviteType_UnKnow,		     // 未知
		CamshareLadyInviteType_Anwser,		     // 应答同意
		CamshareLadyInviteType_Cancel,		 	 // 拒绝
		CamshareLadyInviteType_SetLadyCamStatus  // 通知Cam状态
	};
	
	/**
	 * Camshare状态中声音开关
	 */
	public enum CamshareLadySoundType{
	    CamshareLadySoundType_On,				//声音开
	    CamshareLadySoundType_Off				//声音关
	};
	
	/**
	 * 设置日志目录
	 * @param directory		日志目录
	 */
	static public native void SetLogDirectory(String directory);
	
	/**
	 * 初始化
	 * @param ips	LiveChat服务器ip列表
	 * @param port	LiveChat服务器端口
	 * @return
	 */
	static public native boolean Init(LiveChatClientListener listener, String[] ips, int port);
	
	/**
	 * 连接服务器并登录
	 * @param user			用户名
	 * @param password		php登录成功的session
	 * @param deviceId		设备ID
	 * @param clientType	客户端类型
	 * @param sexType		性别
	 * @return
	 */
	static public boolean Login(String user, String password, String deviceId, ClientType clientType, UserSexType sexType) {
		return Login(user, password, deviceId, clientType.ordinal(), sexType.ordinal());
	}
	static protected native boolean Login(String user, String password, String deviceId, int clientType, int sexType);
	
	/**
	 * 注销并断开连接
	 * @return
	 */
	static public native boolean Logout();
	
	/**
	 * 设置在线状态 
	 * @param statusType	在线状态
	 * @return
	 */
	static public boolean SetStatus(UserStatusType statusType) {
		return SetStatus(statusType.ordinal());
	}
	static protected native boolean SetStatus(int statusType);
	
	/**
	 * 结束聊天会话
	 * @param userId	对方用户ID
	 * @return
	 */
	static public native boolean EndTalk(String userId);
	
	/**
	 * 获取用户在线状态
	 * @param userIds	用户ID数组
	 * @return
	 */
	static public native boolean GetUserStatus(String[] userIds);
	
	/**
	 * 获取会话信息
	 * @param userId	对方用户ID
	 * @return
	 */
	static public native boolean GetTalkInfo(String userId);
	
	/**
	 * 获取会话信息(仅男士端使用)
	 * @param userId	对方用户ID
	 * @return
	 */
	static public native boolean GetSessionInfo(String userId);
	
	/**
	 * 更新票根
	 * @param userId	对方用户ID
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean UploadTicket(String userId, int ticket);
	
	/**
	 * 发送文本消息
	 * @param userId	对方用户ID
	 * @param message	聊天文本消息
	 * @param illegal	是否触犯风控
	 * @param ticket	票根
	 * @return
	 */
	public static boolean SendMessage(String userId, String message, boolean illegal, int ticket, InviteStatusType inviteType){
		boolean isSuccess = false;
		if(inviteType != InviteStatusType.INVITE_TYPE_UNKNOW){
			isSuccess = SendMessage(userId, message, illegal, ticket, inviteType.ordinal());
		}
		return isSuccess;
	}
	
	static public native boolean SendMessage(String userId, String message, boolean illegal, int ticket, int inviteType);
	
	/**
	 * 发送高级表情
	 * @param userId	对方用户ID
	 * @param emotionId	高级表情ID
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean SendEmotion(String userId, String emotionId, int ticket);
	
	/**
	 * 发送虚拟礼物
	 * @param userId	对方用户ID
	 * @param giftId	虚拟礼物ID
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean SendVGift(String userId, String giftId, int ticket);
	
	/**
	 * 获取语音发送验证码
	 * @param userId	对方用户ID
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean GetVoiceCode(String userId, int ticket);
	
	/**
	 * 发送语音消息
	 * @param userId	对方用户ID
	 * @param voiceId	语音ID
	 * @param length	语音时长
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean SendVoice(String userId, String voiceId, int length, int ticket);
	
	/**
	 * 发小高级表情
	 * @param userId	对方用户ID
	 * @param magicIconId	小高级表情ID
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean SendMagicIcon(String userId, String magicIconId, int ticket);
	
	/**
	 * 使用试聊券
	 * @param userId	对方用户ID
	 * @return
	 */
	static public native boolean UseTryTicket(String userId);
	
	// GetTalkList列表类型定义
	/**
	 * 在聊列表
	 */
	static public final int TalkListChating = 1;
	/**
	 * 在聊已暂停列表
	 */
	static public final int TalkListPause = 2;
	/**
	 * 女士邀请列表
	 */
	static public final int TalkListWomanInvite = 4;
	/**
	 * 男士邀请列表
	 */
	static public final int TalkListManInvite = 8;
	/**
	 * 获取邀请/在聊列表
	 * @param talkList	需要获取的列表类型
	 * @return
	 */
	static public native boolean GetTalkList(int talkList);
	
	/**
	 * 发送图片消息
	 * @param userId	对方用户ID
	 * @param inviteId	邀请ID
	 * @param photoId	图片ID
	 * @param sendId	图片发送ID
	 * @param charget	是否已扣费
	 * @param photoDesc	图片描述
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean SendPhoto(String userId, String inviteId, String photoId, String sendId, boolean charget, String photoDesc, int ticket);
	
	/**
	 * 显示图片
	 * @param userId	对方用户ID
	 * @param inviteId	邀请ID
	 * @param photoId	图片ID
	 * @param sendId	图片发送ID
	 * @param charget	是否已扣费
	 * @param photoDesc	图片描述
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean ShowPhoto(String userId, String inviteId, String photoId, String sendId, boolean charget, String photoDesc, int ticket);
	
	/**
	 * 播放微视频
	 * @param userId	对方用户ID
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @param sendId	发送ID
	 * @param charget	是否已付费
	 * @param videoDesc	视频描述
	 * @param ticket	票根
	 * @return
	 */
	static public native boolean PlayVideo(String userId, String inviteId, String videoId, String sendId, boolean charget, String videoDesc, int ticket);
	
	/**
	 * 获取用户信息
	 * @param userId	对方用户ID
	 * @return
	 */
	static public native boolean GetUserInfo(String userId);
	
	/**
	 * 批量获取用户信息
	 * @param userIds	对方用户ID列表
	 * @return
	 */
	static public native boolean GetUsersInfo(String[] userIds);
	
	/**
	 * 获取黑名单列表
	 * @return
	 */
	static public native boolean GetBlockList();
	
	/**
	 * 获取LiveChat联系人列表
	 * @return
	 */
	static public native boolean GetContactList();
	
	/**
	 * 上传客户端版本号
	 * @param ver	客户端版本号
	 * @return
	 */
	static public native boolean UploadVer(String ver);
	
	/**
	 * 获取被屏蔽女士列表
	 * @return
	 */
	static public native boolean GetBlockUsers();
	
	/**
	 * 获取女士择偶条件
	 * @param userId	女士ID
	 * @return
	 */
	static public native boolean GetLadyCondition(String userId);
	
	/**
	 * 获取女士自定义邀请模板
	 * @param userId	女士ID
	 * @return
	 */
	static public native boolean GetLadyCustomTemplate(String userId);
	
	/**
	 * 上传弹出女士自动邀请消息
	 * @param userId	女士ID
	 * @param msg		消息内容
	 * @param key		验证码
	 * @return
	 */
	static public native boolean UploadPopLadyAutoInvite(String userId, String msg, String key);
	
	/**
	 * 上传自动充值状态
	 * @param isCharge	是否自动充值
	 * @return
	 */
	static public native boolean UploadAutoChargeStatus(boolean isCharge);
	
	/**
	 * 获取指定男/女士的已购主题包
	 * @param userId
	 * @return
	 */
	static public native boolean GetPaidTheme(String userId);
	
	/**
	 * 获取所有已购主题包
	 * @return
	 */
	static public native boolean GetAllPaidTheme();
	
	/**
	 * 上传主题包列表版本号
	 * @param themeVer
	 * @return
	 */
	static public native boolean UploadThemeListVer(int themeVer);
	
	/**
	 * 男士购买主题包
	 * @param userId
	 * @param themeId
	 * @return
	 */
	static public native boolean ManFeeTheme(String userId, String themeId);
	
	/**
	 * 男士应用主题包
	 * @param userId
	 * @param themeId
	 * @return
	 */
	static public native boolean ManApplyTheme(String userId, String themeId);
	
	/**
	 * 播放主题包动画
	 * @param userId
	 * @param themeId
	 * @return
	 */
	static public native boolean PlayThemeMotion(String userId, String themeId);
	
	/**
	 * 获取女士Cam是否打开
	 * @param womanId 女士ID
	 * @return
	 */
	static public native boolean GetLadyCamStatus(String womanId);

	/**
	 * 发送CamShare邀请
	 * @param userId   CamShare对象Id
	 * @param msg      CamShare邀请信息
	 * @return
	 */
	static public boolean SendCamShareInvite(String userId, CamshareInviteType inviteType, int sessionId, String fromName){
		return SendCamShareInvite(userId, inviteType.ordinal(), sessionId, fromName);
	}
	static public native boolean SendCamShareInvite(String userId, int inviteType, int sessionId, String fromName);

	/**
	 * 男士发起CamShare并开始扣费
	 * @param userId   CamShare对象Id
	 * @return
	 */
	static public native boolean ApplyCamShare(String userId);

	/**
	 * CamShare开始聊天扣费心跳
	 * @param userId     CamShare对象Id
	 * @param inviteId   CamShare会话Id
	 * @return
	 */
	static public native boolean CamShareHearbeat(String userId, String inviteId);

	/**
	 * 批量获取女士端Cam状态
	 * @param userIds     用户Id（多个用“，”分割）
	 * @return
	 */
	static public native boolean GetUsersCamStatus(String[] userIds);
	
	/**
	 * Camshare使用试聊券
	 * @param targetId
	 * @param ticketId
	 * @return
	 */
	static public native boolean CamshareUseTryTicket(String targetId, String ticketId);

	/**
	 * 发送邀请语
	 * @param userId		聊天对象ID
	 * @param InviteMsg		邀请语
	 * @param nickName		聊天对象昵称
	 * @return
	 */
	static public native boolean SendInviteMessage(String userId, String InviteMsg, String nickName);
	
}
