/*
 * LSLiveChatRequestOtherDefine.h
 *
 *  Created on: 2015-3-13
 *      Author: Samson.Fan
 * Description: 其它协议
 */

#ifndef LSLIVECHATREQUESTOTHERDEFINE_H_
#define LSLIVECHATREQUESTOTHERDEFINE_H_

/* ########################	其它相关接口  ######################## */
/// ------------------- 请求参数定义 -------------------
#define OTHER_REQUEST_ACTION		"action"
#define OTHER_REQUEST_WOMANID		"womanid"
#define OTHER_REQUEST_CURRVER		"currVersion"
#define OTHER_REQUEST_MODEL			"model"
#define OTHER_REQUEST_MANUFACT		"manufacturer"
#define OTHER_REQUEST_OS			"os"
#define OTHER_REQUEST_RELEASE		"release"
#define OTHER_REQUEST_SDK			"sdk"
#define OTHER_REQUEST_DENSITY		"density"
#define OTHER_REQUEST_DENSITYDPI	"densityDpi"
#define OTHER_REQUEST_WIDTH			"width"
#define OTHER_REQUEST_HEIGHT		"height"
#define OTHER_REQUEST_DATA			"data"
#define OTHER_REQUEST_VERCODE		"versionCode"
#define OTHER_REQUEST_VERNAME		"versionName"
#define OTHER_REQUEST_PHONETYPE		"PhoneType"
#define OTHER_REQUEST_NETWORKTYPE	"NetworkType"
#define OTHER_REQUEST_LANGUAGE		"language"
#define OTHER_REQUEST_COUNTRY		"country"
#define OTHER_REQUEST_SITEID		"siteid"
#define OTHER_REQUEST_ACTION		"action"
#define OTHER_REQUEST_NUMBER		"line1Number"
#define OTHER_REQUEST_DEVICEID		"deviceId"
#define OTHER_REQUEST_SIMOPTNAME	"SimOperatorName"
#define OTHER_REQUEST_SIMOPT		"SimOperator"
#define OTHER_REQUEST_SIMCOUNTRYISO	"SimCountryIso"
#define OTHER_REQUEST_SIMSTATE		"SimState"
#define OTHER_REQUEST_SITEID		"siteid"
#define OTHER_REQUEST_APP_ID        "app_id"
/// ------------------- 返回参数定义 -------------------
// 查询高级表情配置
#define OTHER_EMOTIONCONFIG_PATH	"/member/emotionconfig"
// item
#define OTHER_EMOTIONCONFIG_VERSION		"face_senior_version"
#define OTHER_EMOTIONCONFIG_FSPATH		"face_senior_path"
#define OTHER_EMOTIONCONFIG_TYPELIST	"face_senior_typelist"
#define OTHER_EMOTIONCONFIG_TOFLAG		"toflag"
#define OTHER_EMOTIONCONFIG_TYPEID		"typeid"
#define OTHER_EMOTIONCONFIG_TYPENAME	"typename"
#define OTHER_EMOTIONCONFIG_TAGSLIST	"face_senior_tagslist"
#define OTHER_EMOTIONCONFIG_TAGSID		"tagsid"
#define OTHER_EMOTIONCONFIG_TAGSNAME	"tagsname"
#define OTHER_EMOTIONCONFIG_FORMANLIST	"face_senior_forman"
#define OTHER_EMOTIONCONFIG_FILENAME	"filename"
#define OTHER_EMOTIONCONFIG_PRICE		"price"
#define OTHER_EMOTIONCONFIG_ISNEW		"isnew"
#define OTHER_EMOTIONCONFIG_ISSALE		"issale"
#define OTHER_EMOTIONCONFIG_SORTID		"sortid"
#define OTHER_EMOTIONCONFIG_TITLE		"title"
#define OTHER_EMOTIONCONFIG_FORLADYLIST	"face_senior_forlady"

// 男士会员统计
#define OTHER_GETCOUNT_PATH			"/member/get_count"
// item
#define OTHER_GETCOUNT_MONEY			"money"
#define OTHER_GETCOUNT_COUPON			"coupon"
#define OTHER_GETCOUNT_INTEGRAL			"integral"
#define OTHER_GETCOUNT_REGSTEP			"regstep"
#define OTHER_GETCOUNT_ALLOWALBUM		"allowalbum"
#define OTHER_GETCOUNT_ADMIRERUR		"admirer_ur"

// 收集手机硬件信息
#define OTHER_PHONEINFO_PATH		"/other/phoneinfo"
// item

// 查询是否可对某女士使用积分
#define OTHER_INTEGRALCHECK_PATH	"/member/integral_check"
// item
#define OTHER_INTEGRALCHECK_INTEGRAL	"integral"

// 检查客户端更新
#define OTHER_VERSIONCHECK_PATH		"/other/versioncheck"
// item
#define OTHER_VERSIONCHECK_VERCODE		"versionCode"
#define OTHER_VERSIONCHECK_VERNAME		"versionName"
#define OTHER_VERSIONCHECK_VERDESC		"versionDesc"
#define OTHER_VERSIONCHECK_FORCEUPDATE  "forceUpdate"
#define OTHER_VERSIONCHECK_URL			"url"
#define OTHER_VERSIONCHECK_STOREURL		"store_url"
#define OTHER_VERSIONCHECK_PUBTIME		"pubtime"
#define OTHER_VERSIONCHECK_CHECKTIME	"checktime"

// 同步配置
#define OTHER_SYNCONFIG_PATH		"/other/syn_config"
// item
#define OTHER_SYNCONFIG_CL				"0"
#define OTHER_SYNCONFIG_IDA				"1"
#define OTHER_SYNCONFIG_CD				"4"
#define OTHER_SYNCONFIG_LA				"5"
#define OTHER_SYNCONFIG_AD				"6"
#define OTHER_SYNCONFIG_LIVE            "41"
#define OTHER_SYNCONFIG_HOST			"socket_host"
#define OTHER_SYNCONFIG_HOST_DOMAIN		"socket_host_domain"
#define OTHER_SYNCONFIG_PROXYHOST		"socket_proxy_host"
#define OTHER_SYNCONFIG_PORT			"socket_port"
#define OTHER_SYNCONFIG_MINCHAT			"min_balance_for_chat"
#define OTHER_SYNCONFIG_MINCAMSHARE		"min_balance_for_camshare"
#define OTHER_SYNCONFIG_MINEMF			"min_balance_for_emf"
#define OTHER_SYNCONFIG_COUNTRYLIST		"country_list"
#define OTHER_SYNCONFIG_PUBLICCONFIG	"x"
#define OTHER_SYNCONFIG_VGVER			"db_version"
#define OTHER_SYNCONFIG_APKVERCODE		"apk_version_code"
#define OTHER_SYNCONFIG_APKVERNAME		"apk_version_name"
#define OTHER_SYNCONFIG_APKVERDESC		"apk_version_desc"
#define OTHER_SYNCONFIG_APKFORCEUPDATE	"apk_force_update"
#define OTHER_SYNCONFIG_FACEBOOK_ENABLE	"facebook_enable"
#define OTHER_SYNCONFIG_CHATSCENE_ENABLE	"chatscene_enable"
#define OTHER_SYNCONFIG_APKVERIFY		"apk_file_verify"
#define OTHER_SYNCONFIG_APKVERURL		"apk_version_url"
#define OTHER_SYNCONFIG_CHATVOICEURL	"chat_voice_hosturl"
#define OTHER_SYNCONFIG_CAMSHAREHOST	"camshare_host"
#define OTHER_SYNCONFIG_ADDCREDITSURL	"addcredits_url"
#define OTHER_SYNCONFIG_ADDCREDITS2URL	"addcredits2_url"
#define OTHER_SYNCONFIG_STOREURL		"store_url"
#define OTHER_SYNCONFIG_IPCOUNTRY		"ipcountry"
#define OTHER_SYNCONFIG_GCMPROJECTID	"gcm_projectId"
#define OTHER_SYNCONFIG_IOSVERCODE		"ios_version_code"
#define OTHER_SYNCONFIG_IOSVERNAME		"ios_version_name"
#define OTHER_SYNCONFIG_IOSFORCEUPDATE	"ios_force_update"
#define OTHER_SYNCONFIG_IOSSTOREURL     "ios_store_url"
#define OTHER_SYNCONFIG_CAMSHAREHEARTBEATCYCLE	"camshare_heartbeat_cycle"
#define OTHER_SYNCONFIG_ISAVALIABLE		"is_available"
#define OTHER_SYNCONFIG_GOTOSITEID		"goto_siteid"
#define OTHER_SYNCONFIG_FOLLOWFACEBOOK  "follow_facebook"
#define OTHER_SYNCONFIG_LIVEHOST        "live_host"

// 收集移动设备的地理位置
#define OTHER_PHONELOCATION_PATH	"/other/phone_location"
// item

// 查询站点当前在线人数
#define OTHER_ONLINECOUNT_PATH		"/other/onlinecount"
// item
#define OTHER_ONLINECOUNT_SITEID		"siteid"
#define OTHER_ONLINECOUNT_ONLINECOUNT	"onlinecount"

// 提交crash dump文件
#define OTHER_UPLOAD_CRASH_PATH		"/other/crash_file"
#define OTHER_UPLOAD_CRASH_DEVICEID		"deviceId"
#define OTHER_UPLOAD_CRASH_CRASHFILE	"crashfile"

// 提交APP安装记录
#define OTHER_INSTALLLOGS_PATH		"/other/install_logs"
#define OTHER_INSTALLLOGS_DEVICEID		"deviceId"
#define OTHER_INSTALLLOGS_INSTALLTIME	"installtime"
#define OTHER_INSTALLLOGS_SUBMITTIME	"submittime"
#define OTHER_INSTALLLOGS_VERSIONCODE	"versionCode"
#define OTHER_INSTALLLOGS_MODEL			"model"
#define OTHER_INSTALLLOGS_MANUFACTURER	"manufacturer"
#define OTHER_INSTALLLOGS_OS			"os"
#define OTHER_INSTALLLOGS_RELEASE		"release"
#define OTHER_INSTALLLOGS_SDK			"sdk"
#define OTHER_INSTALLLOGS_WIDTH			"width"
#define OTHER_INSTALLLOGS_HEIGHT		"height"
#define OTHER_INSTALLLOGS_UTMREFERRER	"utm_referrer"
#define OTHER_INSTALLLOGS_CHECKCODE		"checkcode"
#define OTHER_INSTALLLOGS_CHECKINFO		"checkinfo"

#define OTHER_GETLEFTCREDIT_PATH    "/share/v1/getLeftCredit"
#define OTHER_GETLEFTCREDIT_CREDIT  "credit"
#define OTHER_GETLEFTCREDIT_COUPON  "coupon"

#define OTHER_UPLOADMANPHOTO_PATH    "/api/?act=uploadChatImg"
#define OTHER_UPLOADMANPHOTO_FILE    "file"
#define OTHER_UPLOADMANPHOTO_URL    "url"
#define OTHER_UPLOADMANPHOTO_MD5    "md5"

#include <string>
using namespace std;

// ------ 枚举定义 ------
// action(新用户类型)
static const char* OTHER_ACTION_TYPE[] =
{
	"1",	// 新安装（SETUP）
	"2",	// 新用户（NEWUSER）
};

// 站点类型定义
typedef enum {
	OTHER_SITE_ALL = 0,		// All
	OTHER_SITE_CL = 1,		// ChnLove
	OTHER_SITE_IDA = 2,		// iDateAsia
	OTHER_SITE_CD = 4,		// CharmingDate
	OTHER_SITE_LA = 8,		// LatamDate
	OTHER_SITE_AD = 16,		// AsiaDear
    OTHER_SITE_LIVE = 32,   // CharmLive
	OTHER_SITE_UNKNOW = OTHER_SITE_ALL,	// Unknow
} OTHER_SITE_TYPE;

static const char* GetSiteId(OTHER_SITE_TYPE siteType) {
	const char* siteId = "";

	switch (siteType) {
	case OTHER_SITE_CL:
		siteId = OTHER_SYNCONFIG_CL;
		break;
	case OTHER_SITE_IDA:
		siteId = OTHER_SYNCONFIG_IDA;
		break;
	case OTHER_SITE_CD:
		siteId = OTHER_SYNCONFIG_CD;
		break;
	case OTHER_SITE_LA:
		siteId = OTHER_SYNCONFIG_LA;
		break;
	case OTHER_SITE_AD:
		siteId = OTHER_SYNCONFIG_AD;
		break;
    case OTHER_SITE_LIVE:
        siteId = OTHER_SYNCONFIG_LIVE;
        break;
    case OTHER_SITE_ALL:break;
	}
	return siteId;
};

static OTHER_SITE_TYPE GetSiteTypeByServerSiteId(const string& siteId){
	OTHER_SITE_TYPE siteType = OTHER_SITE_UNKNOW;
	if(siteId == OTHER_SYNCONFIG_CL){
		siteType = OTHER_SITE_CL;
	}else if(siteId == OTHER_SYNCONFIG_IDA){
		siteType = OTHER_SITE_IDA;
	}else if(siteId == OTHER_SYNCONFIG_CD){
		siteType = OTHER_SITE_CD;
	}else if(siteId == OTHER_SYNCONFIG_LA){
		siteType = OTHER_SITE_LA;
	}else if(siteId == OTHER_SYNCONFIG_AD){
		siteType = OTHER_SITE_AD;
    }else if(siteId == OTHER_SYNCONFIG_LIVE){
        siteType = OTHER_SITE_LIVE;
    }
	return siteType;
}

// ------ 特殊字符定义 ------
// 代理host列表(socket_proxy_host)分隔符
#define OTHER_PROXYHOST_DELIMITER		","
// 国家列表(country_list)分隔符
#define OTHER_COUNTRYLIST_DELIMITER		","
// 站点分隔符
#define OTHER_SITE_DELIMITER			","

#endif /* REQUESTOTHERDEFINE_H_ */
