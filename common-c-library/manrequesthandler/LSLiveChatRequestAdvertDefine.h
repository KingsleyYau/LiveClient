/*
 * LSLiveChatRequestAdvertDefine.h
 *
 *  Created on: 2015-04-21
 *      Author: Samson.Fan
 * Description: 广告 协议接口定义
 */

#ifndef LSLIVECHATREQUESTADVERTDEFINE_H_
#define LSLIVECHATREQUESTADVERTDEFINE_H_

#include <string>
#include <list>

using namespace std;

/* ########################	广告相关 定义  ######################## */
/// ------------------- 请求参数定义 -------------------
#define ADVERT_REQUEST_DEVICEID		"deviceId"
#define ADVERT_REQUEST_ADVERTID		"advertId"
#define ADVERT_REQUEST_PUSHID		"pushId"
#define ADVERT_REQUEST_EMAIL		"email"
#define ADVERT_REQUEST_SHOWTIMES	"showtimes"
#define ADVERT_REQUEST_CLICKTIMES	"clicktimes"
#define ADVERT_REQUEST_FIRSTGOTTIME "first_gottime"
#define ADVERT_REQUEST_ADSPACEID    "adspaceId"
#define ADVERT_REQUEST_ADOVERVIEW   "ad_overview"

/// ------------------- 返回参数定义 -------------------
// 接口路径
// 查询浮窗广告
#define ADVERT_MAINADVERT_PATH		"/advert/mainadvertg"
// 查询女士列表广告
#define ADVERT_WOMANLISTADVERT_PATH	"/advert/womanlistadvert"
// 查询Push广告
#define ADVERT_PUSHADVERT_PATH		"/advert/pushadvert"
// 查询App推广广告
#define ADVERT_APP_PROMOTION_PATH	"/advert/pop_ad"
// 9.6.查询首页弹出公告
#define ADVERT_POP_NOTICE_PATH      "/advert/pop_notice"
// 9.7.查询意向信列表广告（已废弃）
#define ADVERT_ADMIRERLIST_PATH      "/advert/admirerlist_ad"
// 9.8.查询HTML5广告
#define ADVERT_HTLM5_PATH      "/advert/html5_ad"
// item
#define ADVERT_ADVERTID		"advertId"
#define ADVERT_IMAGE		"image"
#define ADVERT_WIDTH		"width"
#define ADVERT_HEIGHT		"height"
#define ADVERT_ADURL		"adurl"
#define ADVERT_OPENTYPE		"opentype"
#define ADVERT_ISSHOW		"isshow"
#define ADVERT_VALID		"valid"
#define ADVERT_PUSHID		"pushId"
#define ADVERT_MESSAGE		"message"

//App Promotion
#define ADVERT_ADOVERVIEW	"ad_overview"

// pop notice 的公告页面
#define ADVERT_NOTICEURL    "notice_url"
// pop notice 是否可关闭
#define ADVERT_CANCLOSE     "can_close"
//admirerlist html页面代码
#define ADVERT_HTMLCODE     "htmlcode"
//admirerlist 广告标题
#define ADVERT_ADVERTTITLE  "advertTitle"

// ------ 枚举定义 ------
// 广告URL打开方式
typedef enum {
	AD_OT_HIDE = 0,			// 隐藏打开
	AD_OT_SYSTEMBROWER = 1,	// 系统浏览器打开
	AD_OT_APPBROWER = 2,	// app内嵌浏览器打开
	AD_OT_UNKNOW,			// 未知
	AD_OT_BEGIN = AD_OT_HIDE,	// 有效起始值
	AD_OT_END = AD_OT_UNKNOW,	// 有效结束值
} AdvertOpenType;
inline AdvertOpenType GetAdvertOpenTypWithInt(int value) {
	return (AD_OT_BEGIN <= value && value < AD_OT_END ? (AdvertOpenType)value : AD_OT_UNKNOW);
}

typedef enum {
    AD_SPACE_TYPE_UNKNOW = 0,
    AD_SPACE_TYPE_A = 1,
    AD_SPACE_TYPE_B = 2,
    AD_SPACE_TYPE_C = 3,
    AD_SPACE_TYPE_BEGIN = AD_SPACE_TYPE_UNKNOW,
    AD_SPACE_TYPE_END = AD_SPACE_TYPE_C,
} AdvertSpaceType;

inline int GetAdvertSpaceTypeToInt(AdvertSpaceType type) {
    int result = 33;
    switch (type) {
        case AD_SPACE_TYPE_A:
            result = 33;
            break;
        case AD_SPACE_TYPE_B:
            result = 47;
            break;
        case AD_SPACE_TYPE_C:
            result = 48;
            break;
            
        default:
            break;
    }
    return result;
}

typedef enum {
    AD_HTML_SPACE_TYPE_UNKNOW = 0,
    AD_HTML_SPACE_TYPE_ANDROID_LOI = 1,
    AD_HTML_SPACE_TYPE_IOS_LOI = 2,
    AD_HTML_SPACE_TYPE_ANDROID_INVITE = 3,
    AD_HTML_SPACE_TYPE_IOS_INVITE = 4,
    AD_HTML_SPACE_TYPE_ANDROID_MAIN = 5,
    AD_HTML_SPACE_TYPE_IOS_MAIN = 6,
    AD_HTML_SPACE_TYPE_BEGIN = AD_HTML_SPACE_TYPE_UNKNOW,
    AD_HTML_SPACE_TYPE_END = AD_HTML_SPACE_TYPE_IOS_MAIN,
} AdvertHtmlSpaceType;

inline int GetAdvertHtmlSpaceTypeToInt(AdvertHtmlSpaceType type) {
    int result = 41;
    switch (type) {
        case AD_HTML_SPACE_TYPE_ANDROID_LOI:
            result = 51;
            break;
        case AD_HTML_SPACE_TYPE_IOS_LOI:
            result = 52;
            break;
        case AD_HTML_SPACE_TYPE_ANDROID_INVITE:
            result = 49;
            break;
        case AD_HTML_SPACE_TYPE_IOS_INVITE:
            result = 50;
            break;
        case AD_HTML_SPACE_TYPE_ANDROID_MAIN:
            result = 54;
            break;
        case AD_HTML_SPACE_TYPE_IOS_MAIN:
            result = 55;
            break;
            
        default:
            break;
    }
    return result;
}

#endif /* LSLIVECHATREQUESTADVERTDEFINE_H_ */
