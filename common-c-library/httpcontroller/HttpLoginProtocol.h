/*
 * RequestAuthorizationDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef REQUESTAUTHORIZATIONDEFINE_H_
#define REQUESTAUTHORIZATIONDEFINE_H_

#include "HttpRequestDefine.h"


/* 公共部分 */
/* http请求头 */
#define PUBLIC_DEV_TYPE                 "dev-type"
#define PUBLIC_VER                      "ver"
#define PUBLIC_CONTENT_TYPE             "content-type"
/* ########################	登录相关 模块  ######################## */

/* 注册公共部分 */
/**
 * 注册公共部分请求
 */
#define REGISTER_PHONENO              "phoneno"
#define REGISTER_AREANO               "areano"


/* 2.1.验证手机是否已注册 */
/* 接口路径  */
#define REGISTER_CHECK_PHONE_PATH     "/register/v1/check_phone_no"

/**
 * 返回
 */
#define REGISER_REGISERED              "registered"

/* 2.2.获取手机注册短信验证码 */
/* 接口路径  */
#define REGISTER_GET_SMSCODE          "/register/v1/get_sms_code"

/* 2.3.手机注册 */
/* 接口路径  */
#define REGISTER_PHOEN_REGISTER      "/register/v1/phone_register"

/**
 * 请求
 */
#define REGISTER_CHECKCODE         "checkcode"
#define REGISTER_PASSWORD          "password"
#define REGISTER_DEVICEID          "deviceid"
#define REGISTER_MODEL             "model"
#define REGISTER_MANUFACTURER      "manufacturer"




// ------ 枚举定义 ------
// action(新用户类型)
static const char* OTHER_LOGIN_TYPE[] =
{
    "0",	// 手机登录
    "1",	// 邮箱登录
};

/* 2.4.登录 */
/* 接口路径  */
#define STREAMLOGIN_PATH "/member/v1/login"

/**
 * 请求
 */
#define LOGIN_TYPE			    "type"
#define LOGIN_PHONENO			"phoneno"
#define LOGIN_ARENO			    "areano"
#define LOGIN_PASSWORD			"password"
#define LOGIN_DEVICEID		    "deviceid"
#define LOGIN_MODEL		        "model"
#define LOGIN_MANUFACTURER		"manufacturer"
#define LOGIN_AUTOLOGIN         "autologin"

/**
 * 返回
 */
#define LOGIN_USERID		    "userid"
#define LOGIN_TOKEN             "token"
#define LOGIN_NICKNAME          "nickname"
#define LOGIN_LEVEL 			"level"
#define LOGIN_COUNTRY           "country"
#define LOGIN_PHOTOURL			"photourl"
#define LOGIN_SIGN              "sign"
#define LOGIN_ANCHOR			"anchor"
#define LOGIN_MODIFYINFO        "modifyinfo"



/* 2.5.注销 */
/* 接口路径 */
#define LOGOUT_PATH                   "/member/v1/logout"

/**
 * 请求
 */
#define LOGOUT_TOKEN                 "token"

/* 2.6.注销 */
/* 接口路径 */
#define UPDATE_TOKENID_PATH                   "/member/v1/update_tokenid"

/**
 * 请求
 */
#define UPDATE_TOKEN                 "token"
#define UPDATE_TOKENID                "tokenid"


/* ########################	直播间 模块  ######################## */
/* 直播间公共部分 */
/**
 * 直播间公共部分请求
 */
#define LIVEROOM_PUBLIC_TOKEN               "token"
#define LIVEROOM_PUBLIC_START               "start"
#define LIVEROOM_PUBLIC_STEP                "step"
#define LIVEROOM_PUBLIC_PHOTOID             "photoid"
#define LIVEROOM_PUBLIC_GIFTID              "id"

/**
 * 直播间公共部分返回
 */
#define LIVEROOM_PUBLIC_ID                 "roomid"
#define LIVEROOM_PUBLIC_URL                "roomurl"

/* 3.1.新建直播间 */
/* 接口路径 */
#define LIVEROOM_CREATE             "/liveroom/v1/createroom"

/**
 * 请求
 */
#define LIVEROOM_NAME               "roomname"
#define LIVEROOM_PHOTOID            "roomphotoid"


/* 3.2.获取本人正在直播的直播间信息 */
/* 接口路径 */
#define LIVEROOM_CHECK             "/liveroom/v1/checkroom"

/* 3.3.关闭直播间 */
/* 接口路径 */
#define LIVEROOM_CLOSE             "/liveroom/v1/closeroom"


/* 3.4.获取直播间观众头像列表（限定数量） */
/* 接口路径 */
#define LIVEROOM_FANSLIST             "/liveroom/v1/roomfanslist"

/**
 * 返回
 */
#define LIVEROOM_VIEWER_USERID             "userid"
#define LIVEROOM_VIEWER_NICK_NAME          "nickname"
#define LIVEROOM_VIEWER_PHOTO_URL          "photourl"

/* 3.5.获取直播间所有观众头像列表 */
/* 接口路径 */
#define LIVEROOM_MORE_FANSLIST             "/liveroom/v1/moreroomfanslist"

/* 3.6.获取Hot列表 */
/* 接口路径 */
#define LIVEROOM_HOT             "/liveroom/v1/hot"


/**
 * 返回
 */
#define LIVEROOM_HOT_USERID               "userid"
#define LIVEROOM_HOT_NICKNAME             "nickname"
#define LIVEROOM_HOT_PHOTOURL             "photourl"
#define LIVEROOM_HOT_ROOMID               "roomid"
#define LIVEROOM_HOT_ROOMNAME             "roomname"
#define LIVEROOM_HOT_ROOMPHOTOURL         "roomphotourl"
#define LIVEROOM_HOT_STATUS               "status"
#define LIVEROOM_HOT_FANSNUM              "fansnum"
#define LIVEROOM_HOT_COUNTRY              "country"

/* 3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表) */
/* 接口路径 */
#define LIVEROOM_GETALLGIFTLIST             "/liveroom/v1/getAllGiftList"

/**
 *  返回
 */

#define LIVEROOM_GIFTNAME              "name"
#define LIVEROOM_GIFTSMALLIMGURL       "smallimgurl"
#define LIVEROOM_GIFTIMGURL            "imgurl"
#define LIVEROOM_GIFTSRCURL            "srcurl"
#define LIVEROOM_GIFTCOINS             "coins"
#define LIVEROOM_GIFTMULTI_CLICK       "multi_click"
#define LIVEROOM_GIFTTYPE              "type"
#define LIVEROOM_GIFTUPDATE_TIME       "update_time"

/* 3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表） */
/* 接口路径 */
#define LIVEROOM_GETGIFTLISTBYUSERID             "/liveroom/v1/getGiftListByUserid"

/* 3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示） */
/* 接口路径 */
#define LIVEROOM_GETGiftDetail                  "/liveroom/v1/getGiftDetail"

/**
 *  请求
 */
#define LIVEROOM_GiftID                        "giftid"


/* 3.10.获取开播封面图列表 */
/* 接口路径 */
#define LIVEROOM_GETPHOTOLIST             "/liveroom/v1/getRoomPhotoList"

/**
 *  返回
 */
#define LIVEROOM_PHOTOLIST_PHOTOURL           "photourl"
#define LIVEROOM_PHOTOLIST_STATUS             "status"
#define LIVEROOM_PHOTOLIST_INUSE              "in_use"

/* 3.11.添加开播封面图（用于主播添加开播封面图） */
/* 接口路径 */
#define LIVEROOM_ADDROOMPHOTO             "/liveroom/v1/addRoomPhoto"

/* 3.12.设置默认使用封面图（用于主播设置默认的封面图） */
/* 接口路径 */
#define LIVEROOM_SETUSINGROOMPHOTO         "/liveroom/v1/setUsingRoomPhoto"

/* 3.13.删除开播封面图（用于主播删除开播封面图） */
/* 接口路径 */
#define LIVEROOM_DELROOMPHOTO             "/liveroom/v1/delRoomPhoto"

/* ########################	个人信息 模块  ######################## */
/* 个人信息公共部分 */
/**
 * 个人信息公共部分请求
 */
#define LIVEROOM_PUBLIC_PERSONAL_TOKEN               "token"
#define LIVEROOM_PUBLIC_PERSONAL_PHOTOURL            "photourl"
#define LIVEROOM_PUBLIC_PERSONAL_NICKNAME            "nickname"
#define LIVEROOM_PUBLIC_PERSONAL_GENDER              "gender"
#define LIVEROOM_PUBLIC_PERSONAL_BIRTHDAY            "birthday"
#define LIVEROOM_PUBLIC_PERSONAL_PHOTOID             "photoid"


/* 4.1.获取用户头像 */
/* 接口路径 */
#define LIVEROOM_PERSONAL_USERPHOTO                  "/liveroom/v1/getuserphoto"

/**
 * 请求
 */
#define LIVEROOM_PERSONAL_USERID                    "userid"
#define LIVEROOM_PERSONAL_PHOTOTYPE                 "phototype"


/* 4.2.获取可编辑的本人资料 */
/* 接口路径 */
#define LIVEROOM_GET_MODIFY_INFO                   "/liveroom/v1/getmodifyinfo"

/* 4.3.提交本人资料 */
/* 接口路径 */
#define LIVEROOM_SET_MODIFY_INFO                   "/liveroom/v1/setmodifyinfo"

/* ########################	其它 模块  ######################## */

/* 5.1.同步配置 */
/* 接口路径 */
#define LIVEROOM_GET_CONFIG                       "/liveroom/v1/getconfig"

/**
 * 返回
 */
#define LIVEROOM_IMSVR_IP                       "imsvr_ip"
#define LIVEROOM_IMSVR_PORT                     "imsvr_port"
#define LIVEROOM_HTTPSVR_IP                     "httpsvr_ip"
#define LIVEROOM_HTTPSVR_PORT                   "httpsvr_port"
#define LIVEROOM_UPLOADSVR_IP                   "uploadsvr_ip"
#define LIVEROOM_UPLOADSVR_PORT                 "uploadsvr_port"

/* 5.2.上传图片 */
/* 接口路径 */
#define LIVEROOM_UPLOADIMG                      "/api/user/uploadImg"
/**
 * 请求
 */
#define LIVEROOM_UPLOAD_TOKEN                   "token"
#define LIVEROOM_UPLOAD_TYPE                    "type"
#define LIVEROOM_UPLOAD_IMAGE                   "img1"
/**
 * 返回
 */
#define LIVEROOM_UPLOAD_ID                      "id"
#define LIVEROOM_UPLOAD_URL                     "url"

#endif /* REQUESTAUTHORIZATIONDEFINE_H_ */
