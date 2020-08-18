/*
 * LSLiveChatJniIntToType.h
 *
 *  Created on: 2015-04-14
 *      Author: Samson.Fan
 * Description: 处理int/jint与枚举type之间的转换
 */

#include "ILSLiveChatClient.h"

// LSLIVECHAT_LCC_ERR_TYPE(处理结果) 转换
/**
 * warning： 新增错误类型，请在数组底部增加，否则可能由于上层越界或错误识别错误（多端同步问题）
 */
static const int LccErrTypeArray[] = {
		LSLIVECHAT_LCC_ERR_FAIL,			// 服务器返回失败结果
		LSLIVECHAT_LCC_ERR_SUCCESS,		// 成功

		// 服务器返回错误
		LSLIVECHAT_LCC_ERR_UNBINDINTER,			// 女士的翻译未将其绑定
		LSLIVECHAT_LCC_ERR_SIDEOFFLINE,			// 对方不在线（聊天）
		LSLIVECHAT_LCC_ERR_DUPLICATECHAT,			// 聊天状态已经建立
		LSLIVECHAT_LCC_ERR_NOMONEY,				// 帐号余额不足
		LSLIVECHAT_LCC_ERR_INVALIDUSER,			// 用户不存在（登录）
		LSLIVECHAT_LCC_ERR_TARGETNOTEXIST,			// 目标用户不存在
		LSLIVECHAT_LCC_ERR_INVAILDPWD,				// 密码错误（登录）
		LSLIVECHAT_LCC_ERR_NOTRANSORAGENTFOUND,	// 没有找到翻译或机构
		LSLIVECHAT_LCC_ERR_NOPERMISSION,			// 没有权限
		LSLIVECHAT_LCC_ERR_TRANSINFOCHANGE,		// 翻译信息改变
		LSLIVECHAT_LCC_ERR_CHATTARGETREJECT,		// 对方拒绝
		LSLIVECHAT_LCC_ERR_MAXBINDING,				// 超过最大连接数
		LSLIVECHAT_LCC_ERR_COMMANDREJECT,			// 请求被拒绝
		LSLIVECHAT_LCC_ERR_BLOCKUSER,				// 对方为黑名单用户（聊天）
		LSLIVECHAT_LCC_ERR_IDENTIFYCODE,			// 需要验证码
		LSLIVECHAT_LCC_ERR_SOCKETNOTEXIST,			// socket不存在
		LSLIVECHAT_LCC_ERR_EMOTIONERR,				// 高级表情异常（聊天）
		LSLIVECHAT_LCC_ERR_FREQUENCYEMOTION,		// 高级表情发送过快（聊天）
		LSLIVECHAT_LCC_ERR_WARNTIMES,				// 严重警告
		LSLIVECHAT_LCC_ERR_PHOTOERR,				// 图片异常（聊天）
		LSLIVECHAT_LCC_ERR_WOMANCHATLIMIT,			// 女士超过聊天上限
		LSLIVECHAT_LCC_ERR_FREQUENCYVOICE,			// 语音发送过快（聊天）
		LSLIVECHAT_LCC_ERR_MICVIDEO,				// 不允许发送视频
		LSLIVECHAT_LCC_ERR_VOICEERR,				// 语音异常
		LSLIVECHAT_LCC_ERR_NOSESSION,				// session错误
		LSLIVECHAT_LCC_ERR_FREQUENCYMAGICICON,		// 小高表发送过快
		LSLIVECHAT_LCC_ERR_MAGICICONERR,			// 小高表异常
		LSLIVECHAT_LCC_ERR_WOMANACTIVECHATLIMIT,	// 女士发送邀请过快
		LSLIVECHAT_LCC_ERR_SUBJECTEXCEPTION,		// 主题异常
		LSLIVECHAT_LCC_ERR_SUBJECTEXISTEXCEPTION,	// 主题存在异常
		LSLIVECHAT_LCC_ERR_SUBJECTNOTEXISTEXCEPTION,// 主题不存在异常
		LSLIVECHAT_LCC_ERR_CAMCHATSERVICEEXCEPTION,    // 视频聊天异常
        LSLIVECHAT_LCC_ERR_CAMSERVICEUNSTARTEXCEPTION, // 视频服务未启动异常
		LSLIVECHAT_LCC_ERR_NOCAMSERVICEEXCEPTION,      // 没有视频服务异常
		LSLIVECHAT_LCC_ERR_NORMAL_LOGICEXCEPTION,		// 普通逻辑异常

		// 客户端定义的错误
		LSLIVECHAT_LCC_ERR_PROTOCOLFAIL,	// 协议解析失败（服务器返回的格式不正确）
		LSLIVECHAT_LCC_ERR_CONNECTFAIL,	// 连接服务器失败/断开连接
		LSLIVECHAT_LCC_ERR_CHECKVERFAIL,	// 检测版本号失败（可能由于版本过低导致）
		LSLIVECHAT_LCC_ERR_LOGINFAIL,		// 登录失败
		LSLIVECHAT_LCC_ERR_SVRBREAK,		// 服务器踢下线
		LSLIVECHAT_LCC_ERR_SETOFFLINE,		// 不能把在线状态设为"离线"，"离线"请使用Logout()
};
LSLIVECHAT_LCC_ERR_TYPE IntToLccErrType(int value);
int LccErrTypeToInt(LSLIVECHAT_LCC_ERR_TYPE type);

// USER_SEX_TYPE(性别) 转换
static const int UserSexTypeArray[] = {
	USER_SEX_UNKNOW,	// 未知
	USER_SEX_FEMALE,	// 女士
	USER_SEX_MALE		// 男士
};
USER_SEX_TYPE IntToUserSexType(int value);
int UserSexTypeToInt(USER_SEX_TYPE type);

// CLIENT_TYPE 转换
static const int ClientTypeArray[] = {
		CLIENT_UNKNOW,	// 未知
		CLIENT_PC,		// PC端
		CLIENT_PC_JAVA,	// PC Java端
		CLIENT_PC_APP,	// PC app端
		CLIENT_PC_PAD,	// PC pad端
		CLIENT_ANDROID,	// Android客户端
		CLIENT_IPHONE,	// IPhone客户端
		CLIENT_IPAD,	// IPad客户端
		CLIENT_WEB		// Web端
};
CLIENT_TYPE IntToClientType(int value);
int ClientTypeToInt(CLIENT_TYPE type);

// USER_STATUS_TYPE(用户在线状态) 转换
static const int UserStatusTypeArray[] = {
	USTATUS_UNKNOW,				// 未知
	USTATUS_OFFLINE_OR_HIDDEN,	// 离线或隐身
	USTATUS_ONLINE,				// 在线
	USTATUS_HIDDEN,				// 隐身
};
USER_STATUS_TYPE IntToUserStatusType(int value);
int UserStatusTypeToInt(USER_STATUS_TYPE type);

// TRY_TICKET_EVENT(试聊事件) 转换
static const int TryTicketTypeArray[] = {
	TTE_UNKNOW,		// 未知
	TTE_NORMAL,		// 正常使用
	TTE_USED,		// 已使用券
	TTE_PAID,		// 已付费
	TTE_NOTICKET,	// 没有券
	TTE_OFFLINE		// 对方已离线
};
TRY_TICKET_EVENT IntToTryTicketEventType(int value);
int TryTicketEventTypeToInt(TRY_TICKET_EVENT type);

// TALK_MSG_TYPE(聊天消息类型) 转换
static const int TalkMsgTypeArray[] = {
	TMT_UNKNOW,			// 未知
	TMT_FREE,			// 免费
	TMT_CHARGE,			// 收费
	TMT_CHARGE_FREE,	// 试聊券
};
TALK_MSG_TYPE IntToTalkMsgType(int value);
int TalkMsgTypeToInt(TALK_MSG_TYPE type);

// TALK_EVENT_TYPE(聊天事件类型) 转换
static const int TalkEventTypeArray[] = {
	TET_UNKNOW,			// 未知
	TET_ENDTALK,		// 结束聊天
	TET_STARTCHARGE,	// 开始收费
	TET_STOPCHARGE,		// 暂停收费
	TET_NOMONEY,		// 余额不足
	TET_VIDEONOMONEY,	// 视频余额不足
	TET_TARGETNOTFOUND	// 目标不存在
};
TALK_EVENT_TYPE IntToTalkEventType(int value);
int TalkEventTypeToInt(TALK_EVENT_TYPE type);

// TALK_EMF_NOTICE_TYPE(邮件更新通知类型) 转换
static const int TalkEmfNoticeTypeArray[] = {
	TENT_UNKNOW,	// 未知
	TENT_EMF,		// EMF邮件
	TENT_ADMIRER	// Admirer邮件
};
TALK_EMF_NOTICE_TYPE IntToTalkEmfNoticeType(int value);
int TalkEmfNoticeTypeToInt(TALK_EMF_NOTICE_TYPE type);

// KICK_OFFLINE_TYPE(服务器踢下线类型) 转换
static const int KickOfflineTypeArray[] = {
	KOT_UNKNOW,			// 未知
	KOT_MAINTAIN,		// 服务器维护
	KOT_TIMEOUT,		// 心跳包超时
	KOT_OTHER_LOGIN		// 用户在其它地方登录
};
KICK_OFFLINE_TYPE IntToKickOfflineType(int value);
int KickOfflineTypeToInt(KICK_OFFLINE_TYPE type);

// MARRY_TYPE(婚姻类型) 转换
static const int MarryTypeArray[] = {
	MT_UNKNOW,			// 未知
	MT_NEVERMARRIED,	// 未婚
	MT_DIVORCED,		// 离婚
	MT_WIDOWED,			// 丧偶
	MT_SEPARATED,		// 分居
	MT_MARRIED,			// 已婚
};
MARRY_TYPE IntToMarryType(int value);
int MarryTypeToInt(MARRY_TYPE type);

// CHILDREN_TYPE(子女类型) 转换
static const int ChildrenTypeArray[] = {
	CT_UNKNOW,		// 未知
	CT_NO,			// 没有子女
	CT_YES,			// 有子女
};
CHILDREN_TYPE IntToChildrenType(int value);
int ChildrenTypeToInt(CHILDREN_TYPE type);

// USER_TYPE(用户类型) 转换
static const int UserTypeArray[] = {
	UT_UNKNOW,		// 未知
	UT_WOMAN,		// 女士
	UT_MAN,			// 男士
	UT_TRANS,		// 翻译
};
USER_TYPE IntToUserType(int value);
int UserTypeToInt(USER_TYPE type);

// AUTO_CHARGE_TYPE(自动充值类型) 转换
static const int AutoChargeArray[] = {
	AUTO_CHARGE_START,	// 开始自动充值
	AUTO_CHARGE_END,	// 结束自动充值
};
TAUTO_CHARGE_TYPE IntToAutoChargeType(int value);
int AutoChargeTypeToInt(TAUTO_CHARGE_TYPE type);

// USER_STATUS_PROTOCOL(用户在线) 转换
static const int UserStatusProtocolArray[] = {
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
USER_STATUS_PROTOCOL IntToUserStatusProtocol(int value);
int UserStatusProtocolToInt(USER_STATUS_PROTOCOL type);

// USER_CAM_STATUST_TYPE(用户CAM状态) 转换
static const int UserCamStatusTypeArray[] = {
	USTATUS_CAM_UNKNOW,     // 未知
	USTATUS_CAM_OFF,	// 关闭
	USTATUS_CAM_ON,	// 打开
};
USER_CAM_STATUS_TYPE IntToUserCamStatusType(int value);
int UserCamStatusTypeToInt(USER_CAM_STATUS_TYPE type);

// INVITE_TYPE(INVITE类型) 转换
static const int InviteTypeArray[] = {
	INVITE_TYPE_UNKNOW,		      // 未知
	INVITE_TYPE_CHAT,		     // livechat
	INVITE_TYPE_CAMSHARE,		 // camshare
};
INVITE_TYPE IntToInviteType(int value);
int InviteTypeToInt(INVITE_TYPE type);

// CamshareLadyInviteType(INVITE类型) 转换（女士端响应Camshare邀请）
static const int CamshareLadyInviteTypeArray[] = {
	CamshareLadyInviteType_UnKnow,		     // 未知
	CamshareLadyInviteType_Anwser,		     // 应答同意
	CamshareLadyInviteType_Cancel,		 	 // 拒绝
	CamshareLadyInviteType_SetLadyCamStatus  // 通知Cam状态
};
int CamshareLadyInviteTypeToInt(CamshareLadyInviteType type);
CamshareLadyInviteType IntToCamshareLadyInviteType(int value);

// CamshareInviteType(INVITE类型) 转换（女士端接收Camshare邀请）
static const int CamshareInviteTypeArray[] = {
	CamshareInviteType_UnKnow,		    	// 未知
	CamshareInviteType_Ask,		     		// 应答同意
	CamshareInviteType_Cancel,		 	 	// 拒绝
	CamshareInviteType_GetLadyCamStatus  	// 通知Cam状态
};
int CamshareInviteTypeToInt(CamshareInviteType type);
CamshareInviteType IntToCamshareInviteType(int value);

//Cam状态类型转换
static const int CamStatusTypeArray[] = {
	CAMSHARE_STATUS_UNAVALIABLE,	// 不可用
	CAMSHARE_STATUS_AVALIABLE,		// 可用
	CAMSHARE_STATUS_UNKNOW			// 未知
};
CAMSHARE_STATUS_TYPE IntToCamStatusType(int value);

//MAN_CONFERENCE_EVENT_TYPE(男士加入退出会议室事件)
static const int ManConferenceEventTypeArray[] = {
	MAN_CONFERENCE_EVENT_UNKNOW,	//未知
	MAN_CONFERENCE_EVENT_JOIN,		// 男士退出会议室
	MAN_CONFERENCE_EVENT_EXIT		// 男士进入会议室
};
int ManConferenceEventTypeToInt(MAN_CONFERENCE_EVENT_TYPE type);

//
static const int CamshareLadySoundTypeArray[] = {
	CamshareLadySoundType_On,	// 声音打开
	CamshareLadySoundType_Off	// 声音关闭
};
int CamshareLadySoundTypeToInt(CamshareLadySoundType type);

// 预付费邀请操作类型转换
SCHEDULEINVITE_TYPE IntToScheduleInviteType(int value);
int ScheduleInviteTypeToInt(SCHEDULEINVITE_TYPE type);
