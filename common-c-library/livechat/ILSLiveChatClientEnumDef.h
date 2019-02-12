/*
 * author: Alex
 *   date: 2018-11-9
 *   file: ILSLiveChatClientEnumDef.h
 *   desc: 将枚举类型和其他类型分开（方便ios的编译，防止混编出问题）
 */

#pragma once

#include <ProtocolCommon/DeviceTypeDef.h>

#define LSUNKNOW_DEVICE_TYPE_ORIGINAL -99999999

// 处理结果
typedef enum {
	LSLIVECHAT_LCC_ERR_SUCCESS					= 0,		// 成功
	LSLIVECHAT_LCC_ERR_FAIL					= -10000,	// 服务器返回失败结果
	
	// 服务器返回错误
	LSLIVECHAT_LCC_ERR_UNBINDINTER				= -1,		// 女士的翻译未将其绑定
	LSLIVECHAT_LCC_ERR_SIDEOFFLINE				= -2,		// 对方不在线（聊天）
	LSLIVECHAT_LCC_ERR_DUPLICATECHAT			= -3,		// 聊天状态已经建立
	LSLIVECHAT_LCC_ERR_NOMONEY					= -4,		// 帐号余额不足
	LSLIVECHAT_LCC_ERR_INVALIDUSER				= -5,		// 用户不存在（登录）
	LSLIVECHAT_LCC_ERR_TARGETNOTEXIST			= -6,		// 目标用户不存在
	LSLIVECHAT_LCC_ERR_INVAILDPWD				= -7,		// 密码错误（登录）
	LSLIVECHAT_LCC_ERR_NOTRANSORAGENTFOUND		= -8,		// 没有找到翻译或机构
	LSLIVECHAT_LCC_ERR_NOPERMISSION			= -9,		// 没有权限
	LSLIVECHAT_LCC_ERR_TRANSINFOCHANGE			= -10,		// 翻译信息改变
	LSLIVECHAT_LCC_ERR_CHATTARGETREJECT		= -11,		// 对方拒绝
	LSLIVECHAT_LCC_ERR_MAXBINDING				= -12,		// 超过最大连接数
	LSLIVECHAT_LCC_ERR_COMMANDREJECT			= -13,		// 请求被拒绝
	LSLIVECHAT_LCC_ERR_BLOCKUSER				= -14,		// 对方为黑名单用户（聊天）
	LSLIVECHAT_LCC_ERR_IDENTIFYCODE			= -15,		// 需要验证码
	LSLIVECHAT_LCC_ERR_SOCKETNOTEXIST			= -16,		// socket不存在
	LSLIVECHAT_LCC_ERR_EMOTIONERR				= -17,		// 高级表情异常（聊天）
	LSLIVECHAT_LCC_ERR_FREQUENCYEMOTION		= -18,		// 高级表情发送过快（聊天）
	LSLIVECHAT_LCC_ERR_WARNTIMES				= -19,		// 严重警告
	LSLIVECHAT_LCC_ERR_PHOTOERR				= -20,		// 图片异常（聊天）
	LSLIVECHAT_LCC_ERR_WOMANCHATLIMIT			= -21,		// 女士超过聊天上限
	LSLIVECHAT_LCC_ERR_FREQUENCYVOICE			= -22,		// 语音发送过快（聊天）
	LSLIVECHAT_LCC_ERR_MICVIDEO				= -23,		// 不允许发送视频
	LSLIVECHAT_LCC_ERR_VOICEERR				= -24,		// 语音异常
	LSLIVECHAT_LCC_ERR_NOSESSION				= -25,		// session错误
	LSLIVECHAT_LCC_ERR_FREQUENCYMAGICICON		= -26,		// 小高表发送过快
	LSLIVECHAT_LCC_ERR_MAGICICONERR			= -27,		// 小高表异常
	LSLIVECHAT_LCC_ERR_WOMANACTIVECHATLIMIT	= -28,		// 女士发送邀请过快
	LSLIVECHAT_LCC_ERR_SUBJECTEXCEPTION		= -29,		// 主题异常
	LSLIVECHAT_LCC_ERR_SUBJECTEXISTEXCEPTION	= -30,		// 主题存在异常
	LSLIVECHAT_LCC_ERR_SUBJECTNOTEXISTEXCEPTION= -31,		// 主题不存在异常
	LSLIVECHAT_LCC_ERR_CAMCHATSERVICEEXCEPTION     = -32,  // 视频聊天异常
    LSLIVECHAT_LCC_ERR_CAMSERVICEUNSTARTEXCEPTION  = -33,  // 视频服务未启动异常
    LSLIVECHAT_LCC_ERR_NOCAMSERVICEEXCEPTION       = -34,  // 没有视频服务异常
    LSLIVECHAT_LCC_ERR_NORMAL_LOGICEXCEPTION       = -99,	// 普通逻辑异常
    
	// 客户端定义的错误
	LSLIVECHAT_LCC_ERR_PROTOCOLFAIL        = -10001,	// 协议解析失败（服务器返回的格式不正确）
	LSLIVECHAT_LCC_ERR_CONNECTFAIL         = -10002,	// 连接服务器失败/断开连接
	LSLIVECHAT_LCC_ERR_CHECKVERFAIL        = -10003,	// 检测版本号失败（可能由于版本过低导致）
	LSLIVECHAT_LCC_ERR_LOGINFAIL           = -10004,	// 登录失败
	LSLIVECHAT_LCC_ERR_SVRBREAK            = -10005,	// 服务器踢下线
	LSLIVECHAT_LCC_ERR_SETOFFLINE          = -10006,	// 不能把在线状态设为"离线"，"离线"请使用Logout()
    LSLIVECHAT_LCC_ERR_INVITETIMEOUT       = -10007,   // Camshare邀请已经取消
    LSLIVECHAT_LCC_ERR_NOVIDEOTIMEOUT      = -10008,   // Camshare没有收到视频流超时
    LSLIVECHAT_LCC_ERR_BACKGROUNDTIMEOUT   = -10009    // Camshare后台超时
    
} LSLIVECHAT_LCC_ERR_TYPE;

// 认证类型
typedef enum {
	AUTH_TYPE_SID = 0,		// sid认证
	AUTH_TYPE_PWD = 1,		// 密码认证
} AUTH_TYPE;

// 用户性别
typedef enum {
	USER_SEX_FEMALE	= 0,	// 女士
	USER_SEX_MALE	= 1,	// 男士
	USER_SEX_UNKNOW,		// 未知
	USER_SEX_BEGIN	= USER_SEX_FEMALE,	// 有效范围起始值
	USER_SEX_END	= USER_SEX_UNKNOW,	// 有效范围结束值
} USER_SEX_TYPE;
// int 转换 USER_SEX_TYPE
inline USER_SEX_TYPE GetUserSexType(int value) {
	return USER_SEX_BEGIN <= value && value < USER_SEX_UNKNOW ? (USER_SEX_TYPE)value : USER_SEX_UNKNOW;
}

// 客户端类型
typedef enum {
	CLIENT_PC		= 0,	// PC端
	CLIENT_PC_JAVA	= 1,	// PC Java端
	CLIENT_PC_APP	= 2,	// PC app端
	CLIENT_PC_PAD	= 3,	// PC pad端
	CLIENT_ANDROID	= 5,	// Android客户端
	CLIENT_IPHONE	= 6,	// IPhone客户端
	CLIENT_IPAD		= 7,	// IPad客户端
	CLIENT_WEB		= 8,	// Web端
	CLIENT_UNKNOW,			// 未知
	CLIENT_BEGIN = CLIENT_PC,	// 有效范围起始值
	CLIENT_END = CLIENT_UNKNOW,	// 有效范围结束值
} CLIENT_TYPE;
// int 转换 CLIENT_TYPE
inline CLIENT_TYPE GetClientType(int value) {
	return CLIENT_BEGIN <= value && value < CLIENT_END ? (CLIENT_TYPE)value : CLIENT_UNKNOW;
}
// CLIENT_TYPE 转换 TDEVICE_TYPE
inline TDEVICE_TYPE GetDeviceTypeWithClientType(CLIENT_TYPE clientType) {
    TDEVICE_TYPE deviceType = DEVICE_TYPE_UNKNOW;
    switch (clientType) {
    case CLIENT_PC:
        deviceType = DEVICE_TYPE_APP_PC;
        break;
    case CLIENT_PC_JAVA:
        deviceType = DEVICE_TYPE_WAP;
        break;
    case CLIENT_PC_APP:
        deviceType = DEVICE_TYPE_WAP_ANDROID;
        break;
    case CLIENT_PC_PAD:
        deviceType = DEVICE_TYPE_APP_IPAD;
        break;
    case CLIENT_ANDROID:
        deviceType = DEVICE_TYPE_APP_ANDROID;
        break;
    case CLIENT_IPHONE:
        deviceType = DEVICE_TYPE_APP_IPHONE;
        break;
    case CLIENT_IPAD:
        deviceType = DEVICE_TYPE_APP_IPAD;
        break;
    case CLIENT_WEB:
        deviceType = DEVICE_TYPE_WEB;
        break;
    default:
        break;
    }
    return deviceType;
}

// 用户在线状态
typedef enum {
	USTATUSPRO_OFFLINE_OR_HIDDEN	= 0,	// 离线/隐身
	USTATUSPRO_ONLINE	= 1,				// 在线
	USTATUSPRO_HIDDEN	= 2,				// 隐身
	USTATUSPRO_BIND = 3,					// 绑定翻译
	USTATUSPRO_UNBIND = 4,					// 没有绑定翻译
	USTATUSPRO_VIDEOOPEN = 5,				// 视频开放
	USTATUSPRO_VIDEOCLOSE = 6,				// 视频关闭
	USTATUSPRO_CAMOPEN = 7,                 // Cam打开
	USTATUSPRO_CAMCLOSE = 8,                // Cam关闭
	USTATUSPRO_UNKNOW,			// 未知
	USTATUSPRO_BEGIN = USTATUSPRO_OFFLINE_OR_HIDDEN,	// 有效范围起始值
	USTATUSPRO_END = USTATUSPRO_UNKNOW,	// 有效范围结束值
} USER_STATUS_PROTOCOL;
// int 转换 USER_STATUS_PROTOCOL
inline USER_STATUS_PROTOCOL GetUserStatusProtocol(int value) {
	return USTATUSPRO_BEGIN <= value && value < USTATUSPRO_END ? (USER_STATUS_PROTOCOL)value : USTATUSPRO_UNKNOW;
}
typedef enum {
	USTATUS_OFFLINE_OR_HIDDEN	= 0,	// 离线/隐身
	USTATUS_ONLINE	= 1,				// 在线
	USTATUS_HIDDEN	= 2,				// 隐身
	USTATUS_UNKNOW,			// 未知
	USTATUS_BEGIN = USTATUS_OFFLINE_OR_HIDDEN,	// 有效范围起始值
	USTATUS_END = USTATUS_UNKNOW,	// 有效范围结束值
} USER_STATUS_TYPE;
// int 转换 USER_STATUS_TYPE
inline USER_STATUS_TYPE GetUserStatusType(int value) {
	USER_STATUS_TYPE statusType = USTATUS_UNKNOW;
	switch (value)
	{
	case USTATUSPRO_OFFLINE_OR_HIDDEN:
	case USTATUSPRO_ONLINE:
	case USTATUSPRO_HIDDEN:
		statusType = (USER_STATUS_TYPE)value;
		break;
	case USTATUSPRO_BIND:
	case USTATUSPRO_VIDEOOPEN:
	case USTATUSPRO_VIDEOCLOSE:
	case USTATUSPRO_CAMOPEN:
    case USTATUSPRO_CAMCLOSE:
		statusType = USTATUS_ONLINE;
		break;
	case USTATUSPRO_UNBIND:
		statusType = USTATUS_OFFLINE_OR_HIDDEN;
		break;
	}
	return statusType;
}

// 试聊事件
typedef enum {
	TTE_NORMAL		= 0,	// 正常使用
	TTE_USED		= 1,	// 已使用券
	TTE_PAID		= 2,	// 已付费
	TTE_NOTICKET	= 3,	// 没有券
	TTE_OFFLINE		= 4,	// 对方已离线
	TTE_UNKNOW,				// 未知
	TTE_BEGIN = TTE_NORMAL,	// 有效范围起始值
	TTE_END = TTE_UNKNOW,	// 有效范围结束值
} TRY_TICKET_EVENT;
// int 转换 TRY_TICKET_EVENT
inline TRY_TICKET_EVENT GetTryTicketEvent(int value) {
	return TTE_BEGIN <= value && value < TTE_END ? (TRY_TICKET_EVENT)value : TTE_UNKNOW;
}

// 聊天消息类型
typedef enum {
	TMT_FREE		= 0,		// 免费
	TMT_CHARGE		= 1,		// 收费
	TMT_FREE1		= 2,		// 免费1(已废弃)
	TMT_FREE2		= 3,		// 免费2(已废弃)
	TMT_FREE3		= 4,		// 免费3(已废弃)
	TMT_CHARGE_FREE	= 5,		// 试聊券
	TMT_UNKNOW,				// 未知
	TMT_BEGIN = TMT_FREE,	// 有效范围起始值
	TMT_END = TMT_UNKNOW,	// 有效范围结束值
} TALK_MSG_TYPE;
// int 转换 TALK_MSG_TYPE
inline TALK_MSG_TYPE GetTalkMsgType(int value) {
	TALK_MSG_TYPE msgType = TMT_BEGIN <= value && value < TMT_END ? (TALK_MSG_TYPE)value : TMT_UNKNOW;
	if (TMT_FREE1 == msgType
		|| TMT_FREE2 == msgType
		|| TMT_FREE3 == msgType)
	{
		// 把已废弃的免费类型转换为TMT_FREE
		msgType = TMT_FREE;
	}
	return msgType;
}

// 邀请消息类型
typedef enum {
	INVITE_TYPE_CHAT		= 0,		     // livechat
	INVITE_TYPE_CAMSHARE    = 1,		     // camshare
	INVITE_TYPE_UNKNOW,				        // 未知
	INVITE_TYPE_BEGIN = INVITE_TYPE_CHAT,	// 有效范围起始值
	INVITE_TYPE_END = INVITE_TYPE_UNKNOW,	// 有效范围结束值
} INVITE_TYPE;
// int 转换 TALK_MSG_TYPE
inline INVITE_TYPE GetInviteType(int value) {
	INVITE_TYPE msgType = INVITE_TYPE_BEGIN <= value && value < INVITE_TYPE_END ? (INVITE_TYPE)value : INVITE_TYPE_UNKNOW;
	return msgType;
}

// 聊天事件类型
typedef enum {
	TET_ENDTALK			= 0,	// 结束聊天
	TET_STARTCHARGE		= 1,	// 开始收费
	TET_STOPCHARGE		= 2,	// 暂停收费
	TET_NOMONEY			= 3,	// 余额不足
	TET_VIDEONOMONEY	= 4,	// 视频余额不足
	TET_TARGETNOTFOUND	= 5,	// 目标不存在
	TET_UNKNOW,					// 未知
	TET_BEGIN = TET_ENDTALK,	// 有效范围起始值
	TET_END = TET_UNKNOW,		// 有效范围结束值
} TALK_EVENT_TYPE;
// int 转换 TALK_EVENT_TYPE
inline TALK_EVENT_TYPE GetTalkEventType(int value) {
	return TET_BEGIN <= value && value < TET_END ? (TALK_EVENT_TYPE)value : TET_UNKNOW;
}

// 邮件更新通知类型
typedef enum {
	TENT_EMF		= 0,	// EMF邮件
	TENT_ADMIRER	= 1,	// Admirer邮件
	TENT_UNKNOW,			// 未知
	TENT_BEGIN = TENT_EMF,	// 有效范围起始值
	TENT_END = TENT_UNKNOW,	// 有效范围结束值
} TALK_EMF_NOTICE_TYPE;
// int 转换 TALK_EMF_NOTICE_TYPE
inline TALK_EMF_NOTICE_TYPE GetTalkEmfNoticeType(int value) {
	return TENT_BEGIN <= value && value < TENT_END ? (TALK_EMF_NOTICE_TYPE)value : TENT_UNKNOW;
}

// 服务器踢下线类型
typedef enum {
	KOT_UNKNOW		= -1,	// 未知
	KOT_MAINTAIN	= 1,	// 服务器维护
	KOT_TIMEOUT		= 2,	// 心跳包超时
	KOT_OTHER_LOGIN	= 4,	// 用户在其它地方登录
} KICK_OFFLINE_TYPE;

// 婚姻类型
typedef enum {
	MT_UNKNOW = 0,			// 未知
	MT_NEVERMARRIED = 1,	// 从来未婚
	MT_DIVORCED = 2,		// 离婚
	MT_WIDOWED = 3,			// 丧偶
	MT_SEPARATED = 4,		// 分居
	MT_MARRIED = 5,			// 已婚
	MT_BEGIN = MT_UNKNOW,	// 有效范围起始值
	MT_END = MT_MARRIED,	// 有效范围结束值
} MARRY_TYPE;
// int 转换 MARRY_TYPE
inline MARRY_TYPE GetMarryType(int value) {
	return MT_BEGIN <= value && value < MT_END ? (MARRY_TYPE)value : MT_UNKNOW;
}

// 子女类型
typedef enum {
	CT_NO = 0,		// 没有子女
	CT_YES = 1,		// 有子女
	CT_UNKNOW,		// 未知
} CHILDREN_TYPE;

// 用户类型
typedef enum {
	UT_WOMAN = 0,		// 女士
	UT_MAN = 1,			// 男士
	UT_TRANS = 2,		// 翻译
	UT_UNKNOW,			// 未知
	UT_BEGIN = UT_WOMAN,	// 有效范围起始值
	UT_END = UT_UNKNOW,		// 有效范围结束值
} USER_TYPE;
// int 转换 USER_TYPE
inline USER_TYPE GetUserType(int value) {
	return UT_BEGIN <= value && value < UT_END ? (USER_TYPE)value : UT_UNKNOW;
}

// 邀请/在聊session列表item
typedef enum TalkSessionServiceType {
    TalkSessionServiceType_Unknow = -1,
    TalkSessionServiceType_Livechat = 0,
    TalkSessionServiceType_Camshare = 1,
    TalkSessionServiceType_Count = TalkSessionServiceType_Camshare + 1
}TalkSessionServiceType;


// 请求邀请/在聊列表类型
typedef enum {
	TALK_LIST_CHATING = 1,		// 在聊列表
	TALK_LIST_PAUSE = 2,		// 在聊已暂停列表
	TALK_LIST_WOMAN_INVITE = 4,	// 女士邀请列表
	TALK_LIST_MAN_INVITE = 8,	// 男士邀请列表
} TALK_LIST_TYPE;

// 请求联系人/黑名单列表类型
typedef enum {
	CONTACT_LIST_BLOCK = 1,		// 黑名单列表
	CONTACT_LIST_CONTACT = 2,	// 联系人列表
} CONTACT_LIST_TYPE;


// 设备类型
typedef enum {
	AUTO_CHARGE_START = 0,			// 开始充值
	AUTO_CHARGE_END = 1,			// 完成充值
} TAUTO_CHARGE_TYPE;
// int 转换 TALK_MSG_TYPE
inline TAUTO_CHARGE_TYPE GetAutoChargeType(int value) {
	TAUTO_CHARGE_TYPE type = (AUTO_CHARGE_START <= value && value <= AUTO_CHARGE_END ? (TAUTO_CHARGE_TYPE)value : AUTO_CHARGE_START);
	return type;
}

#define CamshareInviteTypeKey "rType"
#define CamshareInviteTypeSessionIdKey "camSessionId"
#define CamshareInviteTypeFromNameKey "fromName"
// Camshare邀请类型
typedef enum CamshareInviteType {
    CamshareInviteType_UnKnow = -1,
    CamshareInviteType_Ask = 0,
    CamshareInviteType_Cancel = 1,
    CamshareInviteType_GetLadyCamStatus = 2,
    CamshareInviteType_Count
} CamshareInviteType;

// Camshare邀请类型(女士端接受邀请)
typedef enum CamshareLadyInviteType {
    CamshareLadyInviteType_UnKnow = -1,            	//未知
    CamshareLadyInviteType_Anwser = 0,				//应答
    CamshareLadyInviteType_Cancel = 1,				//拒绝
    CamshareLadyInviteType_SetLadyCamStatus = 3,    //Cam状态更新
    CamshareLadyInviteType_Count                    //有效值结束标志
} CamshareLadyInviteType;

// 女士用户Cam状态类型
typedef enum {
	USTATUS_CAM_OFF	= 0,	// 关闭
	USTATUS_CAM_ON	= 1,	// 打开
	USTATUS_CAM_UNKNOW = 2,	// 未知
} USER_CAM_STATUS_TYPE;


typedef enum CamshareLadySoundType {
    CamshareLadySoundType_On = 0,
    CamshareLadySoundType_Off = 1,
} CamshareLadySoundType;

// Cam 服务状态是否可用
typedef enum {
	CAMSHARE_STATUS_UNAVALIABLE	= 0,	// 不可用
	CAMSHARE_STATUS_AVALIABLE	= 1,	// 可用
	CAMSHARE_STATUS_UNKNOW,		// 未知
	CAMSHARE_STATUS_BEGIN	= CAMSHARE_STATUS_UNAVALIABLE,	// 有效范围起始值
	CAMSHARE_STATUS_END	= CAMSHARE_STATUS_UNKNOW,	// 有效范围结束值
} CAMSHARE_STATUS_TYPE;
// int 转换 CAMSHARE_STATUS_TYPE
inline CAMSHARE_STATUS_TYPE GetCamshareStatusType(int value) {
	return CAMSHARE_STATUS_BEGIN <= value && value < CAMSHARE_STATUS_END ? (CAMSHARE_STATUS_TYPE)value : CAMSHARE_STATUS_UNKNOW;
}

// camshare男士退出或加入会议室
typedef enum {
	MAN_CONFERENCE_EVENT_JOIN	= 0,	// 男士退出会议室
	MAN_CONFERENCE_EVENT_EXIT	= 1,	// 男士进入会议室
	MAN_CONFERENCE_EVENT_UNKNOW,		// 未知
	MAN_CONFERENCE_EVENT_BEGIN	= MAN_CONFERENCE_EVENT_JOIN,	// 有效范围起始值
	MAN_CONFERENCE_EVENT_END	= MAN_CONFERENCE_EVENT_UNKNOW,	// 有效范围结束值
} MAN_CONFERENCE_EVENT_TYPE;
// int 转换 MAN_CONFERENCE_EVENT_TYPE
inline MAN_CONFERENCE_EVENT_TYPE GetConferenceEventType(int value) {
	return USER_SEX_BEGIN <= value && value < MAN_CONFERENCE_EVENT_END ? (MAN_CONFERENCE_EVENT_TYPE)value : MAN_CONFERENCE_EVENT_UNKNOW;
}

// 聊天邀请风控类型
typedef enum {
    LIVECHATINVITE_RISK_NOLIMIT     = 0,    // 不作任何限制
    LIVECHATINVITE_RISK_LIMITSEND   = 1,    // 限制发送信息
    LIVECHATINVITE_RISK_LIMITREV    = 2,    // 限制接受邀请
    LIVECHATINVITE_RISK_LIMITALL    = 3,    // 收发全部限制
    LIVECHATINVITE_RISK_BEGIN       = LIVECHATINVITE_RISK_NOLIMIT,    // 有效范围起始值
    LIVECHATINVITE_RISK_END         = LIVECHATINVITE_RISK_LIMITALL,    // 有效范围结束值
} LIVECHATINVITE_RISK_TYPE;
// int 转换 LIVECHATINVITE_RISK_TYPE
inline LIVECHATINVITE_RISK_TYPE GetliveChatInviteRiskType(int value) {
    return LIVECHATINVITE_RISK_BEGIN <= value && value <= LIVECHATINVITE_RISK_END ? (LIVECHATINVITE_RISK_TYPE)value : LIVECHATINVITE_RISK_NOLIMIT;
}

