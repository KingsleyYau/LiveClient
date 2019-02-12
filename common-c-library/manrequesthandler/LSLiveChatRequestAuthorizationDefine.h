/*
 * LSLiveChatRequestAuthorizationDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTAUTHORIZATIONDEFINE_H_
#define LSLIVECHATREQUESTAUTHORIZATIONDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	认证相关 模块  ######################## */

/* 字段 */

/* facebook */
#define AUTHORIZATION_FACEBOOK_TOKEN 	"ftoken"
#define AUTHORIZATION_BIRTHDAY			"birthday"

/* 注册 */
#define AUTHORIZATION_MAN_ID			"manid"
#define AUTHORIZATION_EMAIL 			"email"
#define AUTHORIZATION_PASSWORD 			"passwd1"
#define AUTHORIZATION_GENDER 			"gender"
#define AUTHORIZATION_FIRST_NAME 		"first_name"
#define AUTHORIZATION_LAST_NAME 		"last_name"
#define AUTHORIZATION_IS_REG 			"is_reg"
#define AUTHORIZATION_REG_STEP 			"reg_step"
#define AUTHORIZATION_COUNTRY 			"country"
#define AUTHORIZATION_BIRTHDAY_Y		"birthday_y"
#define AUTHORIZATION_BIRTHDAY_M 		"birthday_m"
#define AUTHORIZATION_BIRTHDAY_D 		"birthday_d"
#define AUTHORIZATION_WEEKLY_MAIL		"weeklymail"
#define AUTHORIZATION_MODEL 			"model"
#define AUTHORIZATION_DEVICEID 			"deviceId"
#define AUTHORIZATION_MANUFACTURER 		"manufacturer"
#define AUTHORIZATION_UTMREFERRER 		"utm_referrer"
#define AUTHORIZATION_LOGIN				"login"
#define AUTHORIZATION_ERRNO				"errno"
#define	AUTHORIZATION_ERRTEXT			"errtext"
#define AUTHORIZATION_PREVCODE			"prevcode"

/* 登录 */
#define AUTHORIZATION_PASSWORD2 		"password"
#define AUTHORIZATION_CHECKCODE			"checkcode"

#define AUTHORIZATION_VERSIONCODE		"versioncode"
#define AUTHORIZATION_FIRSTNAME 		"firstname"
#define AUTHORIZATION_LASTNAME 			"lastname"

#define AUTHORIZATION_PHOTOURL			"photoURL"
#define AUTHORIZATION_TELEPHONE			"telephone"
#define AUTHORIZATION_TELEPHONE_VERIFY	"telephone_verify"
#define AUTHORIZATION_TELEPHONE_CC		"telephone_cc"
#define AUTHORIZATION_SESSIONID			"sessionid"
#define AUTHORIZATION_GA_UID			"ga_uid"
#define AUTHORIZATION_CSMAIL_TICKETID	"csmail_ticketid"
#define AUTHORIZATION_EMAIL_UNVERIFIED  "email_unverified"
#define AUTHORIZATION_PHOTOSEND			"photosend"
#define AUTHORIZATION_PHOTORECEIVED		"photoreceived"
#define AUTHORIZATION_VIDEORECEIVED		"videoreceived"
#define AUTHORIZATION_LIVEENABLE        "live_enable"
#define AUTHORIZATION_PREMIT			"premit"

#define AUTHORIZATION_PERMISSION		"permission"
#define AUTHORIZATION_CAMSHARE		    "camshare"
#define AUTHORIZATION_LADYPROFILE		"ladyprofile"
#define AUTHORIZATION_LIVECHAT			"livechat"
#define AUTHORIZATION_LIVECHAT_INVITE	"livechat_invite"
#define AUTHORIZATION_ADMIRER			"admirer"
#define AUTHORIZATION_BPEMF				"bpemf"

#define AUTHORIZATION_RECHARGECREDIT	"recharge_credit"
#define AUTHORIZATION_GAACTIVITY		"ga_activity"
#define AUTHORIZATION_ADOVERVIEW		"ad_overview"
#define AUTHORIZATION_ADTIMESTAMP		"ad_timestamp"

/* 获取验证码 */
#define AUTHORIZATION_USECODE			"usecode"

/* 找回密码 */
#define AUTHORIZATION_SENDMAIL			"sendmail"

/* 手机短信验证 */
#define AUTHORIZATION_VERIFY_CODE		"verify_code"
#define AUTHORIZATION_V_TYPE			"v_type"
#define AUTHORIZATION_DEVICE_ID 		"device_id"

/* 固定电话获取认证短信 */
#define AUTHORIZATION_LANDLINE_CC		"landline_cc"
#define AUTHORIZATION_LANDLINE_AC		"landline_ac"
#define AUTHORIZATION_LANDLINE			"landline"

/* 获取token */
#define AUTHORIZATION_TOID              "toid"
#define AUTHORIZATION_CLIENT            "client"
#define AUTHORIZATION_URL               "url"

// item
#define VERIFY_CLIENT_WAP                "wap"
#define VERIFY_CLIENT_WEB                "web"
#define VERIFY_CLIENT_APP                "app"

/*提交App token 绑定*/
#define AUTHORIZATION_TOKEN_DEVICE_ID   "device_id"
#define AUTHORIZATION_TOKEN_ID          "token"
#define AUTHORIZATION_APP_ID            "app_id"

/* token登录认证 */
#define AUTHORIZATION_MEMBER_ID              "memberid"

/* 可登录的站点列表 */
#define AUTHORIZATION_DATALIST              "datalist"
#define AUTHORIZATION_SITE_ID               "siteid"
#define AUTHORIZATION_ISLIVE                "islive"

/* 字段  end*/

/* 接口路径定义 */

/**
 * 2.1.Facebook注册及登录
 */
#define FACEBOOK_LOGIN_PATH "/member/facebooklogin"

/**
 * 2.2.注册帐号
 */
#define REGISTER_PATH "/member/joincheck"

/**
 * 2.3.获取验证码
 */
#define CEHCKCODE_PATH "/member/checkcode"

/**
 * 2.4.登录
 */
#define LOGIN_PATH "/member/logincheck"

/**
 * 2.5.找回密码
 */
#define FINDPASSWORD_PATH "/member/find_pw"

/**
 * 2.6.手机获取认证短信
 */
#define GET_SMS_PATH "/member/sms_get"

/**
 * 2.7.手机短信认证
 */
#define VERIFY_SMS_PATH "/member/sms_verify"

/**
 * 2.8.固定电话获取认证短信
 */
#define GET_FIXED_PHONE_PATH "/member/sms_get"

/**
 * 2.9.固定电话获取认证短信
 */
#define VERIFY_FIXED_PHONE_PATH "/member/sms_verify/phonetype/2/"

/**
 * 2.10.获取token
 */
#define GET_WEBSITEURL_TOKEN_PATH "/member/websiteurl"


/**
 * 2.11. 添加App token
 */
#define SUMMIT_APP_TOKEN_PATH   "/member/add_token"

/**
 * 2.12. 销毁App token
 */
#define UNBIND_APP_TOKEN_PATH "/member/destroy_token"

/**
 * 2.13. 重新激活账号
 */
#define REACTIVATE_MEMBER_SHIP_PATH "/member/reactivate_membership"

/**
 * 2.14. token登录认证
 */
#define VERIFY_TOKEN_LOGIN_PATH "/member/dologin"

/**
 * 2.15. 可登录的站点列表
 */
#define GET_VALID_SITEID_PATH "/member/validsiteid"

/* 接口路径定义  end */

// 站点类型定义
typedef enum {
    VERIFY_CLIENT_TYPE_UNKOWN = 0,     // 未知
    VERIFY_CLIENT_TYPE_WAP = 1,      // msite端
    VERIFY_CLIENT_TYPE_WEB = 2,     // web端
    VERIFY_CLIENT_TYPE_APP = 3,      // app端
} VERIFY_CLIENT_TYPE;

static const char* GetVerifyClientType(VERIFY_CLIENT_TYPE clientType) {
    const char* verifyClinet = "";
    
    switch (clientType) {
        case VERIFY_CLIENT_TYPE_WAP:
            verifyClinet = VERIFY_CLIENT_WAP;
            break;
        case VERIFY_CLIENT_TYPE_WEB:
            verifyClinet = VERIFY_CLIENT_WEB;
            break;
        case VERIFY_CLIENT_TYPE_APP:
            verifyClinet = VERIFY_CLIENT_APP;
            break;
        case VERIFY_CLIENT_TYPE_UNKOWN:break;
    }
    return verifyClinet;
};

#endif /* REQUESTAUTHORIZATIONDEFINE_H_ */
