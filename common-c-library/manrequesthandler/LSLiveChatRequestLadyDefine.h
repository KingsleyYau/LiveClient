/*
 * LSLiveChatRequestLadyDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTLADYDEFINE_H_
#define LSLIVECHATREQUESTLADYDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	女士相关 模块  ######################## */

/* 字段 */

/* 4.1.获取匹配女士条件 */
#define LADY_AGE_RANGE_FROM 	"age1"
#define LADY_AGE_RANGE_TO 		"age2"
#define LADY_M_MARRY			"m_marry"
#define LADY_M_CHILDREN			"m_children"
#define LADY_M_EDUCATION		"m_education"

/* 4.3.条件查询女士列表 */
#define LADY_QUERY_TYPE 		"queryType"
#define LADY_WOMAN_ID 			"womanid"
#define LADY_WEIGHT 			"weight"
#define LADY_HEIGHT 			"height"
#define LADY_COUNTRY 			"country"
#define LADY_ORDERBY			"orderby"
#define LADY_DEVICEID			"deviceId"
#define LADY_PROVINCE			"province"
#define LADY_ISONLINE 			"isonline"
#define LADY_FIRST_NAME 		"firstname"
#define LADY_AGE 				"age"
#define LADY_PHOTO_URL 			"photoURL"
#define LADY_PHOTO_BIG_URL 		"photoBigURL"
#define LADY_ONLINE_STATUS		"online_status"
#define LADY_GENDER             "gender"        // 用于假服务器
#define LADY_CAN_CAM            "camStatus"
#define LADY_ISFAVORITE         "isfavorite"

/* 4.4.查询女士详细信息 */
#define LADY_ZODIAC				"zodiac"
#define LADY_SMOKE				"smoke"
#define LADY_DRINK				"drink"
#define LADY_ENGLISH			"english"
#define LADY_RELIGION			"religion"
#define LADY_EDUCATION			"education"
#define LADY_PROFESSION			"profession"
#define LADY_CHILDREN			"children"
#define LADY_MARRY				"marry"
#define LADY_RESUME				"jj_en"
#define LADY_ISONLINE			"isonline"
#define LADY_ISFAVORITE			"isfavorite"
#define LADY_LAST_UPDATE		"last_update"
#define LADY_SHOW_LOVECALL		"show_lovecall"

#define LADY_MIN_PHOTO_URL 		"photoMinURL"

#define LADY_PHOTOURLLIST		"photoUrlList"
#define LADY_THUMBURLLIST		"thumbUrlList"

#define LADY_VIDEOURLLIST		"videoUrlList"
#define LADY_VIDEO_ID			"id"
#define LADY_VIDEO_THUMB		"thumb"
#define LADY_VIDEO_TIME			"time"
#define LADY_VIDEO_PHOTO		"photo"

#define LADY_PHOTOLOCKNUM       "photoLockNum"

/* 4.7.获取女士Direct Call TokenID */
#define LADY_LOVECALLID			"lovecallid"
#define LADY_LC_CENTERNUMBER	"lc_centernumber"

/* 4.8.获取最近联系人列表 */
#define LADY_VIDEOCOUNT			"videocount"
#define LADY_LASTTIME			"lasttime"

/* 4.9.删除最近联系人 */
#define REMOVE_CONTACT_WOMANID      "womanid"

/* 4.10.查询女士标签列表 */
#define LADY_SIGNID				"signid"
#define LADY_SIGNNAME			"name"
#define LADY_SIGNCOLOR			"color"
#define LADY_ISSIGNED			"issigned"

/* 5.13.获取收藏女士列表 */
#define FAVORITE_PAGEINDEX          "pageIndex"
#define FAVORITE_PAGESIZE           "pageSize"
#define FAVORITE_WOMANNAME          "womanname"
#define FAVORITE_WOMANID            "womanid"
#define FAVORITE_FIRSTNAME          "firstname"
#define FAVORITE_AGE                "age"
#define FAVORITE_PHOTOURL           "photoURL"
#define FAVORITE_PHOTOBIGURL        "photoBigURL"
#define FAVORITE_LASTTIME           "lasttime"
#define FAVORITE_CAMSTATUS          "camStatus"
#define FAVORITE_ONLINE             "online"


/* 字段  end*/

/* 接口路径定义 */

/**
 * 4.1.获取匹配女士条件
 */
#define QUERY_LADY_MATCH_PATH "/member/get_criteria"

/**
 * 4.2.保存匹配女士条件
 */
#define SAVE_LADY_MATCH_PATH "/member/save_criteria"
/**
 * 4.3.条件查询女士列表
 */
#define QUERY_LADY_LIST_PATH "/member/search"

/**
 * 4.4.查询女士详细信息
 */
#define QUERY_LADY_DETAIL_PATH "/member/profile"

/**
 * 4.5.收藏女士
 */
#define ADD_FAVORITES_LADY_PATH "/member/addtofav"

/**
 * 4.6.收藏女士
 */
#define REMOVE_FAVORITES_LADY_PATH "/member/deletefav"

/**
 * 4.7.获取女士Direct Call TokenID
 */
#define QUERY_DIRECT_CALL_LADY_PATH "/member/lovecall_generate_id"

/**
 * 4.8.获取最近联系人列表（ver3.0起）
 */
#define QUERY_RECENTCONTACT_PATH "/member/recentcontact"

/**
 * 4.9.删除最近联系人（ver3.0.3起）
 */
#define QUERY_REMOVECONTACT_PATH "/member/deletecontact"

/**
 * 4.10.查询女士标签列表（ver3.0起）
 */
#define QUERY_SIGNLIST_PATH "/member/signlist"

/**
 * 4.11.提交女士标签（ver3.0起）
 */
#define QUERY_UPLOADSIGN_PATH "/member/uploadsign"

/**
 * 4.12.举报女士
 */
#define REPORT_LADY_PATH "/member/report_lady"

/**
 * 5.13.获取收藏女士列表
 */
#define GET_FAVORITE_LIST_PATH "/member/favoritelist"

/* 接口路径定义  end */

// 返回的女士列表在线状态
typedef enum {
	LADY_ONLINE = 1,	// 在线
	LADY_HIDDEN = 2,	// 隐身
	LADY_OFFLINE = 3,	// 离线
	LADY_OSTATUS_BEGIN = LADY_ONLINE,	// 枚举起始
	LADY_OSTATUS_END = LADY_OFFLINE,	// 枚举结束
	LADY_OSTATUS_DEFAULT = LADY_OFFLINE	// 默认值
} LadyOnlineStatus;

// 请求的女士列表在线状态
typedef enum {
    RequestLady_Default = -1,   // 默认
    RequestLady_Offline = 0,    // 离线
    RequestLady_Online = 1      // 在线
} RequestLadyOnlineStatus;

// 性别类型定义(LADY_GENDER)
static const char* LadyGenderProtocol[] = {
    "",     // 不限
    "M",    // 男
    "F",    // 女
};
typedef enum {
    LADY_GENDER_DEFAULT,    // 不限
    LADY_GENDER_MALE,       // 男
    LADY_GENDER_FEMALE,     // 女
} LadyGenderType;

// 搜索女士在线状态
typedef enum {
   FINDLADYONLINETYPE_NOLIMIT = 0, // 不限
   FINDLADYONLINETYPE_Online = 1   // 在线
} FindLadyOnLineType;

#endif /* LSLIVECHATREQUESTLADYDEFINE_H_ */
