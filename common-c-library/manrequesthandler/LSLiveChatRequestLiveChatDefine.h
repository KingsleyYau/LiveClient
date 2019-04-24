/*
 * LSLiveChatRequestLiveChatDefine.h.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTLIVECHATDEFINE_H_
#define LSLIVECHATREQUESTLIVECHATDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	女士相关 模块  ######################## */

/* 公共字段 */
#define LIVECHAT_INFO					"info"
#define LIVECHAT_STATUS                 "status"

/* 5.1.查询是否符合试聊条件 */
#define LIVECHAT_WOMAN_ID 				"womanid"
#define LIVECHAT_SERVICE_TYPE           "servertype"
#define LIVECHAT_LC_FREETRIAL 			"lc_freetrial"
typedef enum {
	CouponStatus_Used       = -1,	// 已聊过(-1)
	CouponStatus_None       = 0,	// 不能使用(0)
	CouponStatus_Yes        = 1,	// 可以使用(1)
	CouponStatus_Started    = 2,	// 已开始使用(2)
	CouponStatus_Promotion  = 3,	// 促销(3)
} CouponStatus;
#define LIVECHAT_TRYCHAT_FREETRIAL		"ticketnum"
#define LIVECHAT_TRYCHAT_REFUNDFLAG		"refundflag"
#define LIVECHAT_TRYCHAT_FESTIVALID		"festivalid"
#define LIVECHAT_TRYCHAT_TIME			"time"
#define LIVECHAT_TRYCHAT_COUPONID		"couponid"
#define LIVECHAT_TRYCHAT_ENDDATE		"enddate"


/* 5.3.获取虚拟礼物列表 */
#define LIVECHAT_SESSIONID				"user_sid"
#define LIVECHAT_USER_ID				"user_id"

#define LIVECHAT_VIRTUALGIFT_TOTAL		"virtualgift_total"
#define LIVECHAT_VIRTUALGIFT_PATH		"virtualgift_path"
#define LIVECHAT_VIRTUALGIFT_VERSION	"virtualgift_version"
#define LIVECHAT_VIRTUALGIFT_FORMAN		"virtualgift_forman"
#define LIVECHAT_LIST					"list"
#define LIVECHAT_VGID					"vgid"
#define LIVECHAT_TITLE					"title"
#define LIVECHAT_PRICE					"price"

/* 5.4.查询聊天记录 */
#define LIVECHAT_INVITEID				"inviteid"
#define LIVECHAT_DBTIME					"dbtime"
#define LIVECHAT_INVITEMSG				"invitemsg"
#define LIVECHAT_TOFLAG					"toflag"
#define LIVECHAT_MSG 					"msg"
#define LIVECHAT_MSG_TR 				"msg_tr"
#define LIVECHAT_ADDDATE				"adddate"
#define LIVECHAT_MSGTYPE				"msgtype"
#define LIVECHAT_VOICEID_DELIMIT		"-"			// 语音ID分隔符
// video参数的分隔符
#define LIVECHAT_VIDEO_DELIMIT	"|||"
// img参数的分隔符
#define LIVECHAT_PHOTO_DELIMIT	"|||"
// 是否已扣费值定义
#define LIVECHAT_CHARGE_YES			"1"			// 是
#define LIVECHAT_CHARGE_NO			"0"			// 否

// 5.5.批量查询聊天记录
#define LIVECHAT_INVITEIDS				"inviteids"

// 5.6.发送私密照片
#define LIVECHAT_TARGETID				"targetid"
#define LIVECHAT_PHOTOID				"photoid"
#define LIVECHAT_SENDID					"sendId"
#define LIVECHAT_SENDMODE				"mode"
#define LIVECHAT_PHOTOFILE				"photofile"

// 5.8.获取对方私密照片
#define LIVECHAT_TOFLAG					"toflag"
#define LIVECHAT_PHOTOSIZE				"size"
#define LIVECHAT_PHOTOMODE				"mode"

// 6.11.发送虚拟礼物
#define LIVECHAT_SENDGIFT_VG_ID 		"vg_id"
#define LIVECHAT_SENDGIFT_DEVICE_ID		"device_id"
#define LIVECHAT_SENDGIFT_CHAT_ID 		"chat_id"
#define LIVECHAT_SENDGIFT_USE_TYPE 		"use_type"
#define LIVECHAT_SENDGIFT_USER_SID 		"user_sid"
#define LIVECHAT_SENDGIFT_USER_ID 		"user_id"

/* 字段  end*/

/* 接口路径定义 */

/**
 * 12.7.查询是否符合试聊条件
 */
#define CHECK_COUPON_PATH "/pman/livechat/setStatus/?action=check_ticket"

/**
 * 12.8.使用试聊券
 */
#define USE_COUPON_PATH "/pman/livechat/setStatus/?action=use_ticket"

/**
 * 5.3.获取虚拟礼物列表
 */
#define QUERY_CHAT_VIRTUAL_GIFT_PATH "/livechat/setstatus.php?action=get_virtualgift_list&vg_type=mtw&"

/**
 * 12.1.查询聊天记录
 */
//#define QUERY_CHAT_RECORD_PATH "/member/maninvitemsg"
#define QUERY_CHAT_RECORD_PATH "/pman/livechat/setStatus/?action=maninvitemsg"

/**
 * 12.2.批量查询聊天记录
 */
//#define QUERY_CHAT_RECORD_MUTI_PATH "/member/maninvitemsgbatch"
#define QUERY_CHAT_RECORD_MUTI_PATH "/pman/livechat/setStatus/?action=maninvitemsgbatch"

/**
 * 12.9.发送私密照片
 */
#define LC_SENDPHOTO_PATH	"/pman/livechat/setStatus/?action=man_send_photo"

/**
 * 12.10.付费获取私密照片
 */
#define LC_PHOTOFEE_PATH	"/pman/livechat/setStatus/?action=man_get_photoview"

/**
 * 12.11.检查私密照片是否已付费
 */
#define LC_CHECKPHOTO_PATH	"/pman/livechat/setStatus/?action=man_get_photofee"

/**
 * 12.12.获取对方私密照片
 */
#define LC_GETPHOTO_PATH	"/pman/livechat/setStatus/?action=load_private_photo"

/** 
 * 12.3.上传语音文件
 */
#define LC_UPLOADVOICE_PATH	"/livechat/voice?r=%s"
#define LC_UPLOADVOICE_SUBPATH	"/livechat/voice?"
#define LC_UPLOADVOICE_INVITEID		"iv"
#define LC_UPLOADVOICE_SEX			"s"
#define LC_UPLOADVOICE_SEX_WOMAN		"0"
#define LC_UPLOADVOICE_SEX_MAN			"1"
#define LC_UPLOADVOICE_MINEID		"mid"
#define LC_UPLOADVOICE_WOMANID		"wid"
#define LC_UPLOADVOICE_FILETYPE		"type"
#define LC_UPLOADVOICE_VOICELENGTH	"l"
#define LC_UPLOADVOICE_SITEID		"dt"

/**
 * 12.4.获取语音文件
 */
#define LC_PLAYVOICE_PATH	"/livechat/play?r=%s&t=%s&a=wp"
#define LC_PLAYVOICE_SUBPATH	"/livechat/play?"

/**
 * 6.11.发送虚拟礼物
 */
#define LC_SENDGIFT_PATH	"/livechat/setstatus.php?action=virtualgift_credit"

/* 接口路径定义  end */

// 聊天记录协议发出类型
typedef enum {
	LRT_RECV = 0,		// 接收
	LRT_SEND = 1,		// 发送
} LIVECHAT_RECODE_TOFLAG;

// 聊天记录协议消息类型
typedef enum {
	LRPM_TEXT = 0,		// 文本消息
	LRPM_INVITE = 1,	// 邀请消息（文本）
	LRPM_COUPON = 3,	// 优惠券（文本）
	LRPM_WARNING = 2,	// 警告消息
	LRPM_EMOTION = 4,	// 高级表情消息
	LRPM_AUTO_INVITE = 6,// 自动邀请（文本）
	LRPM_VOICE = 7,		// 语音消息
	LRPM_PHOTO = 8,		// 图片消息
	LRPM_VIDEO = 9,		// 微视频
	LRPM_MAGIC_ICON = 10, // Magic Icon
	LIPM_INVITE_ASSISTANT = 11, // 小助手
	LIPM_THEME = 12, // 主题
	LIPM_CAMSHARE_MESSAGE = 13, // CamShare
	LIPM_CAMSHARE_HEART = 14, // CamShare心跳
} LIVECHAT_RECORD_PROTOCOL_MSGTYPE;
// 聊天记录消息内部定义类型
typedef enum {
	LRM_UNKNOW = -1,
	LRM_TEXT = 0,
	LRM_INVITE,
	LRM_WARNING,
	LRM_EMOTION,
	LRM_VOICE,
	LRM_PHOTO,
	LRM_VIDEO,
	LRM_MAGIC_ICON,
} LIVECHAT_RECORD_MSGTYPE;

// 发送私密照片类型
typedef enum {
	SMT_FROMPHOTOALBUM = 1,		// 从相册发送
	SMT_FROMPHOTOFILE = 2,		// 上传文件流
} SENDPHOTO_MODE_TYPE;

// 获取类型
typedef enum {
	GTT_WOMANGETMAN = 0,		// 主播获取男士
	GTT_MANGETWOMAN = 1,		// 男士获取男士
	GTT_WOMANGETSELF = 2,		// 男士获取自己
	GTT_MANGETSELF = 3,			// 男士获取自己
} GETPHOTO_TOFLAG_TYPE;

// 照片尺寸
static const char* GETPHOTO_PHOTOSIZE_PROTOCOL[] = {
	"l",	// 大
	"m",	// 中
	"s",	// 小
	"o",	// 原始
};
typedef enum {
	GPT_LARGE = 0,	// 大
	GPT_MIDDLE,		// 中
	GPT_SMALL,		// 小
	GPT_ORIGINAL	// 原始
} GETPHOTO_PHOTOSIZE_TYPE;

// 照片清晰度类型
typedef enum {
	GMT_FUZZY = 0,		// 模糊
	GMT_CLEAR = 1,		// 清晰
} GETPHOTO_PHOTOMODE_TYPE;

static const char* USET_TYPE_ARRAY[] = {
		"emf",
		"chat"
};

/* ######################## 12.13.获取最近已看微视频列表（http post）（New）  ######################## */
/* 接口路径  */
#define LC_RECENT_VIDEO_PATH 	"/pman/livechat/setStatus/?action=viewed_short_video_recent"

/**
 * 请求
 */
#define	LC_RECENT_VIDEO_TARGETID		"targetid"
#define	LC_RECENT_VIDEO_USER_SID		"user_sid"
#define	LC_RECENT_VIDEO_USER_ID			"user_id"

/**
 * 返回
 */
#define	LC_RECENT_VIDEO_VIDEO				"video"
#define	LC_RECENT_VIDEO_LIST				"videolist"

#define	LC_RECENT_VIDEO_VIDEOID				"videoid"
#define	LC_RECENT_VIDEO_TITLE				"title"
#define	LC_RECENT_VIDEO_INVITEID			"inviteid"
#define	LC_RECENT_VIDEO_VIDEO_URL			"video_url"
#define LC_RECENT_VIDEO_VIDEO_COVER         "video_cover"

/* ########################	12.14.获取微视频图片（http get）（New）  ######################## */
/* 接口路径  */
#define LC_GET_VIDEO_PHOTO_PATH 	"/pman/livechat/setStatus/?action=view_short_video_photo"

/**
 * 请求
 */
#define	LC_GET_VIDEO_PHOTO_USER_SID			"user_sid"
#define	LC_GET_VIDEO_PHOTO_USER_ID			"user_id"
#define	LC_GET_VIDEO_PHOTO_TARGETID			"targetid"
#define	LC_GET_VIDEO_PHOTO_VIDEOID			"videoid"
#define	LC_GET_VIDEO_PHOTO_SIZE				"size"

// 视频图片类型
typedef enum {
	VPT_DEFAULT,		// 默认尺寸
	VPT_BIG				// 大图
} VIDEO_PHOTO_TYPE;

/* ######################## 12.15.	获取微视频文件URL（http post）（New）  ######################## */
/* 接口路径  */
#define LC_GET_VIDEO_PATH 	"/pman/livechat/setStatus/?action=view_short_video"

/**
 * 请求
 */
#define	LC_GET_VIDEO_USER_SID		"user_sid"
#define	LC_GET_VIDEO_USER_ID		"user_id"
#define	LC_GET_VIDEO_TARGETID		"targetid"
#define	LC_GET_VIDEO_VIDEOID		"videoid"
#define	LC_GET_VIDEO_INVITEID		"inviteid"
#define	LC_GET_VIDEO_TOFLAG			"toflag"
#define	LC_GET_VIDEO_SENDID			"sendid"

/**
 * 返回
 */
#define	LC_GET_VIDEO_VIDEO_URL		"video_url"

// 客户端类型
typedef enum {
	GVCT_WOMAN = 0,	// 女士端
	GVCT_MAN = 1,	// 男士端
} GETVIDEO_CLIENT_TYPE;

/* ######################## 12.5.查询小高级表情配置（http post）  ######################## */
/* 接口路径  */
#define LC_GET_MAGICICON_CONFIG_PATH 	"/pman/livechat/setStatus/?action=magicicon_list"

/**
 * 返回
 */
#define	LC_GET_MAGICICON_CONFIG_BASE_PATH		"path"
#define	LC_GET_MAGICICON_CONFIG_MAXUPDATETIME	"maxupdatetime"
#define	LC_GET_MAGICICON_CONFIG_DATA		    "data"
#define	LC_GET_MAGICICON_CONFIG_TYPELIST		"typelist"
#define	LC_GET_MAGICICON_CONFIG_LIST		    "list"
#define	LC_GET_MAGICICON_CONFIG_ID		        "id"
#define	LC_GET_MAGICICON_CONFIG_TITLE		    "title"
#define	LC_GET_MAGICICON_CONFIG_PRICE		    "price"
#define	LC_GET_MAGICICON_CONFIG_HOTFLAG		    "hotflag"
#define	LC_GET_MAGICICON_CONFIG_TYPEID		    "typeid"
#define	LC_GET_MAGICICON_CONFIG_UPDATETIME		"updatetime"

/* ######################## 6.16.开聊自动买点（http post）  ######################## */
/* 接口路径  */
#define LC_CHAT_RECHARGE_PATH 	"/livechat/setstatus.php?action=chat_recharge"

/**
 * 请求
 */
#define	LC_CHAT_RECHARGE_WOMAN_ID	"womanId"
#define LC_CHAT_RECHARGE_USER_SID   "user_sid"
#define LC_CHAT_RECHARGE_USER_ID    "user_id"

/**
 * 返回
 */
#define	LC_CHAT_RECHARGE_CREDITS		"credits"

/* ######################## 6.17.查询主题配置（http post）  ######################## */
/* 接口路径  */
#define LC_GET_THEME_CONFIG_PATH 	"/livechat/setstatus.php?action=scene_config"

/**
 * 请求
 */
#define LC_GET_THEME_CONFIG_USER_SID   "user_sid"
#define LC_GET_THEME_CONFIG_USER_ID    "user_id"

/**
 * 返回
 */
#define	LC_GET_THEME_CONFIG_THEME_VERSION		"theme_version"
#define	LC_GET_THEME_CONFIG_THEME_PATH			"theme_path"

#define	LC_GET_THEME_CONFIG_THEME_TYPELIST		"theme_typelist"
#define	LC_GET_THEME_CONFIG_THEME_LIST			"list"
#define	LC_GET_THEME_CONFIG_THEME_TYPEID		"typeid"
#define	LC_GET_THEME_CONFIG_THEME_TYPENAME		"typename"

#define	LC_GET_THEME_CONFIG_THEME_TAGLIST		"theme_tagslist"
#define	LC_GET_THEME_CONFIG_THEME_TAGSID		"tagsid"
#define	LC_GET_THEME_CONFIG_THEME_TAGSNAME		"tagsname"
#define	LC_GET_THEME_CONFIG_THEME_FORMAN		"theme_forman"

#define	LC_GET_THEME_CONFIG_THEME_ID			"themeid"
#define	LC_GET_THEME_CONFIG_THEME_PRICE			"price"
#define	LC_GET_THEME_CONFIG_THEME_ISNEW			"isnew"
#define	LC_GET_THEME_CONFIG_THEME_ISSALE		"issale"
#define	LC_GET_THEME_CONFIG_THEME_TITLE			"title"
#define	LC_GET_THEME_CONFIG_THEME_VALIDSECOND	"validsecond"
#define	LC_GET_THEME_CONFIG_THEME_ISBASE		"isbase"
#define	LC_GET_THEME_CONFIG_THEME_DESCRIPT		"discript"

/* ######################## 6.18.获取指定主题（http post）  ######################## */
/* 接口路径  */
#define LC_GET_THEME_DETAIL_PATH 	"/livechat/setstatus.php?action=scene_hide_config"

/**
 * 请求
 */
#define LC_GET_THEME_DETAIL_THEMEIDS   "themeids"
#define LC_GET_THEME_DETAIL_USER_SID   "user_sid"
#define LC_GET_THEME_DETAIL_USER_ID    "user_id"

/**
 * 返回
 */

/* ######################## 12.6.检测功能是否开通（http post）  ######################## */

// 设备类型
typedef enum {
	CHAT_TEXT = 1002,
	CHAT_VIDEO = 1004,
	CHAT_EMOTION = 1006,
	CHAT_TRYTIKET = 1008,
	CHAT_GAME = 1010,
	CHAT_VOICE = 1012,
	CHAT_MAGICICON = 1014,
	CHAT_PRIVATEPHOTO = 1016,
	CHAT_SHORTVIDEO = 1018,
} FOUNCTION_TYPE;

// DEVICE_TYPE(设备类型) 转换
static const int FunctionsArray[] = {
		CHAT_TEXT,
		CHAT_VIDEO,
		CHAT_EMOTION,
		CHAT_TRYTIKET,
		CHAT_GAME,
		CHAT_VOICE,
		CHAT_MAGICICON,
		CHAT_PRIVATEPHOTO,
		CHAT_SHORTVIDEO
};

/* 接口路径  */
#define LC_CHECK_FUNCTIONS_PATH 	"/pman/livechat/setStatus/?action=function_check"

/**
 * 请求
 */
#define	LC_CHECK_FUNCTIONS_FOUNCTIONID	"functionid"
#define LC_CHECK_FUNCTIONS_DEVICETYPE  "devicetype"
#define LC_CHECK_FUNCTIONS_VERSIONCODE "versioncode"
#define LC_CHECK_FUNCTIONS_USER_SID    "user_sid"
#define LC_CHECK_FUNCTIONS_USERID      "user_id"

/**
 * 返回
 */
#define	LC_CHECK_FUNCTIONS_DATA		"data"

#endif /* LIVECHATREQUESTLIVECHATDEFINE_H_ */
