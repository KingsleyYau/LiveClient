/*
 * ZBHttpLoginProtocol.h
 *
 *  Created on: 2018-2-26
 *      Author: Alex.shum
 *      Des: 主播端的接口宏
 */

#ifndef ZBHTTPLOGINPROTOCOL_H_
#define ZBHTTPLOGINPROTOCOL_H_

#include "ZBHttpRequestDefine.h"


/* ########################	登录相关 模块  ######################## */

// ------ 枚举定义 ------

/* 2.1.登录 */
/* 接口路径  */
#define LADYLOGIN_PATH 		"/login/v1/ladyLogin"

/**
 * 请求
 */
#define LADYLOGIN_SN                "sn"
#define LADYLOGIN_PASSWORD			"password"
#define LADYLOGIN_CODE              "code"
#define LADYLOGIN_DEVICEID		    "deviceid"
#define LADYLOGIN_MODEL		        "model"
#define LADYLOGIN_MANUFACTURER		"manufacturer"

/**
 * 返回
 */
#define LADYLOGIN_USERID		    "userid"
#define LADYLOGIN_TOKEN             "token"
#define LADYLOGIN_NICKNAME          "nickname"
#define LADYLOGIN_PHOTOURL 			"photourl"



/* 2.2.上传tokenid接口 */
/* 接口路径 */
#define UPDATETOKENID_PATH                   "/lady/v1/update_tokenid"

/**
 * 请求
 */
#define UPDATETOKENID_TOKENID                "tokenid"

/* 2.3.获取验证码 */
/* 接口路径 */
#define GETVERIFICATIONCODE_PATH                   "/login/v1/getVerificationCode"

/* ########################	直播间 模块  ######################## */

/* 3.1.获取直播间观众列表 */
/* 接口路径 */
#define LIVEFANSLIST_PATH             "/share/v1/liveFansList"

/**
 * 请求
 */
#define LIVEFANSLIST_LIVEROOM_ID               "live_room_id"
#define LIVEFANSLIST_START                     "start"
#define LIVEFANSLIST_STEP                      "step"

/**
 * 返回
 */
#define LIVEFANSLIST_USERID                 "userid"
#define LIVEFANSLIST_NICKNAME               "nickname"
#define LIVEFANSLIST_PHOTOURL               "photourl"
#define LIVEFANSLIST_MOUNTID                "mountid"
#define LIVEFANSLIST_MOUNTNAME              "mountname"
#define LIVEFANSLIST_MOUNTURL               "mounturl"
#define LIVEFANSLIST_LEVEL                  "level"

/* 3.2.获取指定观众信息 */
/* 接口路径 */
#define GETNEWFANSBASEINFO_PATH             "/share/v1/getNewFansBaseInfo"

/**
 * 请求
 */
#define GETNEWFANSBASEINFO_USERID           "userid"
/**
 * 返回
 */
#define GETNEWFANSBASEINFO_NICKNAME             "nickname"
#define GETNEWFANSBASEINFO_PHOTOURL             "photourl"
#define GETNEWFANSBASEINFO_RIDERID              "riderid"
#define GETNEWFANSBASEINFO_RIDERNAME            "ridername"
#define GETNEWFANSBASEINFO_RIDERURL             "riderurl"
#define GETNEWFANSBASEINFO_LEVEL                "level"

/* 3.3.获取礼物列表 */
/* 接口路径 */
#define GETALLGIFTLIST_PATH          "/share/v1/getAllGiftList"

/**
 *  返回
 */

#define GETALLGIFTLIST_LIST                  "list"

#define GETALLGIFTLIST_LIST_ID                "id"
#define GETALLGIFTLIST_LIST_NAME              "name"
#define GETALLGIFTLIST_LIST_SMALLIMGURL       "small_imgurl"
#define GETALLGIFTLIST_LIST_MIDDLEIMGURL      "middle_imgurl"
#define GETALLGIFTLIST_LIST_BIGIMGURL         "big_imgurl"
#define GETALLGIFTLIST_LIST_SRCFLASEURL       "src_flashurl"
#define GETALLGIFTLIST_LIST_SRCWEBPURL        "src_webpurl"
#define GETALLGIFTLIST_LIST_CREDIT            "credit"
#define GETALLGIFTLIST_LIST_MULTI_CLICK       "multi_click"
#define GETALLGIFTLIST_LIST_TYPE              "type"
#define GETALLGIFTLIST_LIST_LEVEL             "level"
#define GETALLGIFTLIST_LIST_LOVELEVEL         "love_level"
#define GETALLGIFTLIST_LIST_SENDNUMLIST       "send_num_list"
#define GETALLGIFTLIST_LIST_SENDNUMLIST_NUM        "num"
#define GETALLGIFTLIST_LIST_UPDATE_TIME       "updatetime"
#define GETALLGIFTLIST_LISTPLAY_TIME         "play_time"

/* 3.4.获取背包礼物列表 */
/* 接口路径 */
#define GIFTLIST_PATH                  "/lady/v1/giftlist"

/**
 * 请求
 */
#define GIFTLIST_ROOMID             "room_id"

/**
 *  返回
 */
#define GIFTLIST_LIST                  "list"
#define GIFTLIST_LIST_GIFTID                  "gift_id"
#define GIFTLIST_LIST_GIFTNUM                 "gift_num"

/* 3.5.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示） */
/* 接口路径 */
#define GETGIFTDETAIL_PATH                  "/share/v1/getGiftDetail"

/**
 *  请求
 */
#define GETGIFTDETAIL_GIFTID                 "gift_id"

/* 3.6.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表） */
/* 接口路径 */
#define GETEMOTICONLIST_PATH             "/share/v1/getEmoticonList"

/**
 *  返回
 */

#define GETEMOTICONLIST_LIST                  "list"
#define GETEMOTICONLIST_LIST_EMOTYPE                  "type"
#define GETEMOTICONLIST_LIST_NAME                     "name"
#define GETEMOTICONLIST_LIST_ERRMSG                   "errmsg"
#define GETEMOTICONLIST_LIST_EMOURL                   "emo_url"
#define GETEMOTICONLIST_LIST_EMOLIST                  "emo_list"
#define GETEMOTICONLIST_LIST_EMOLIST_ID                           "id"
#define GETEMOTICONLIST_LIST_EMOLIST_EMOSIGN                      "emo_sign"
#define GETEMOTICONLIST_LIST_EMOLIST_EMOURL                       "emo_url"
#define GETEMOTICONLIST_LIST_EMOLIST_EMOTYPE                      "emo_type"
#define GETEMOTICONLIST_LIST_EMOLIST_EMOICONURL                   "emo_icon_url"

/* 3.7.主播回复才艺点播邀请 */
/* 接口路径 */
#define DEALTALENTREQUEST_PATH             "/lady/v1/dealTalentRequest"

/**
 *  请求
 */
#define DEALTALENTREQUEST_TALENTINVITEID      "talent_inviteid"
#define DEALTALENTREQUEST_STATU               "status"

/* 3.8.设置主播公开直播间自动邀请状态 */
/* 接口路径 */
#define SETAUTOPUSH_PATH             "/share/v1/setAutoPush"

/**
 *  请求
 */
#define SETAUTOPUSH_STATUS      "status"


/* ########################    预约私密 模块  ######################## */
/* 4.1.观众待处理的预约邀请列表 */
/* 接口路径 */
#define MANHANDLEBOOKINGLIST_PATH                  "/share/v1/getAppScheduleList"

/**
 *  请求
 */
#define MANHANDLEBOOKINGLIST_TAG                      "tag"
#define MANHANDLEBOOKINGLIST_START                    "start"
#define MANHANDLEBOOKINGLIST_STEP                     "step"

/**
 *  返回
 */
#define MANHANDLEBOOKINGLIST_TOTAL                   "total"
#define MANHANDLEBOOLINGLIST_NOREADCOUNT             "no_read_count"
#define MANHANDLEBOOKINGLIST_LIST                    "list"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID                   "inviteid"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID                           "toid"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID                         "fromid"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL               "opposite_photourl"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME               "opposite_nickname"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_READ                           "read"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY                       "intimacy"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE                      "reply_type"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME                       "book_time"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID                         "gift_id"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME                       "gift_name"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL                  "gift_big_imgurl"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL                "gift_small_imgurl"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM                        "gift_num"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME                      "valid_time"
#define MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID                         "roomid"

/* 4.2.主播接受预约邀请 */
/* 接口路径 */
#define ACCEPTSCHEDULEDINVITE_PATH                  "/lady/v1/acceptScheduledInvite"

/**
 *  请求
 */
#define ACCEPTSCHEDULEDINVITE_INVITEID                 "invite_id"

/* 4.3.主播拒绝预约邀请 */
/* 接口路径 */
#define REJECTSCHEDULEDULEDINVITE_PATH                  "/lady/v1/rejectScheduledInvite"

/**
 *  请求
 */
#define REJECTSCHEDULEDULEDINVITE_INVITEID     "invite_id"

/* 4.4.获取预约邀请未读或待处理数量 */
/* 接口路径 */
#define GETSCHEDULELISTNOREADNUM_PATH                  "/share/v1/getScheduleListNoReadNum"

/**
 *  返回
 */
#define GETSCHEDULELISTNOREADNUM_TOTALNOREADNUM          "total_no_read_num"
#define GETSCHEDULELISTNOREADNUM_PENDINGNOREADNUM        "pending_no_read_num"
#define GETSCHEDULELISTNOREADNUM_SCHEDULEDNOREADNUM      "scheduled_no_read_num"
#define GETSCHEDULELISTNOREADNUM_HISTORYNOREADNUM        "history_no_read_num"

/* 4.5.获取已确认的预约数 */
/* 接口路径 */
#define GETSCHEDULEDACCEPTNUM_PATH                  "/lady/v1/getScheduledAcceptNum"

/**
 *  返回
 */
#define GETSCHEDULEDACCEPTNUM_SCHEDULEDNUM          "scheduled_num"

/* 4.6.主播接受立即私密邀请 */
/* 接口路径 */
#define ACCEPTINSTANCEINVITE_PATH                 "/lady/v1/acceptInstanceInvite"

/**
 *  请求
 */
#define ACCEPTINSTANCEINVITE_INVITEID          "invite_id"

/**
 *  返回
 */
#define ACCEPTINSTANCEINVITE_ROOMID          "room_id"
#define ACCEPTINSTANCEINVITE_ROOMTYPE        "room_type"

/* 4.7.主播拒绝立即私密邀请 */
/* 接口路径 */
#define REJECTINSTANCEINVITE_PATH                 "/lady/v1/rejectInstanceInvite"

/**
 *  请求
 */
#define REJECTINSTANCEINVITE_INVITEID          "invite_id"
#define REJECTINSTANCEINVITE_REJECTREASON      "reject_reason"

/* 4.8.主播取消已发的立即私密邀请 */
/* 接口路径 */
#define CANCELINSTANTINVITEUSER_PATH                 "/lady/v1/cancelInstantInviteUser"

/**
 *  请求
 */
#define CANCELINSTANTINVITEUSER_INVITEID          "invite_id"

/* 4.9.设置直播间为开始倒数 */
/* 接口路径 */
#define SETROOMCOUNTDOWN_PATH                 "/lady/v1/setRoomCountDown"

/**
 *  请求
 */
#define SETROOMCOUNTDOWN_ROOMID          "roomid"



/* 5.1.同步配置 */
/* 接口路径 */
#define GETCONFIG_PATH                       "/lady/v1/getconfig"

/**
 * 返回
 */
#define GETCONFIG_IMSVR_URL                      "imsvr_url"
#define GETCONFIG_HTTPSVR_URL                    "httpsvr_url"
#define GETCONFIG_ME_PAGE_URL                    "me_page_url"
#define GETCONFIG_MAN_PAGE_URL                   "man_page_url"
#define GETCONFIG_MINAVAILABLEVER                "min_available_ver"
#define GETCONFIG_MINAVAILABLEMSG                "min_available_msg"
#define GETCONFIG_NEWEST_VER                     "newest_ver"
#define GETCONFIG_NEWEST_MSG                     "newest_msg"
#define GETCONFIG_DOWNLOADAPPURL_MSG             "download_app_url"
#define GETCONFIG_SVRLIST                        "svr_list"
#define GETCONFIG_SVRLIST_SVRID                                  "svrid"
#define GETCONFIG_SVRLIST_TURL                                   "turl"

/* 5.2.获取收入信息 */
/* 接口路径 */
#define GETTODAYCREDIT_PATH                       "/share/v1/getTodayCredit"

/**
 * 返回
 */
#define GETTODAYCREDIT_MONTHCREDIT                      "month_credit"
#define GETTODAYCREDIT_MONTHBCCOMPLETED                 "month_bc_completed"
#define GETTODAYCREDIT_MONTHBCTARGET                    "month_bc_target"
#define GETTODAYCREDIT_MONTHBCPROGRESS                  "month_bc_progress"

/* 5.3.提交流媒体服务器测速结果 */
/* 接口路径 */
#define SUBMITSERVERVELOMETER_PATH                              "/share/v1/t"

/**
 *  请求
 */
#define SUBMITSERVERVELOMETER_SID                          "sid"
#define SUBMITSERVERVELOMETER_RES                          "res"

/* 5.4.提交crash dump文件 */
/* 接口路径 */
#define UPLOADCRASHDUMP_PATH                                 "/lady/v1/uploadCrashDump"

/**
 *  请求
 */
#define UPLOADCRASHDUMP_DEVICEID                          "deviceid"
#define UPLOADCRASHDUMP_CRASHFILE                         "crashfile"


#endif /* ZBHTTPLOGINPROTOCOL_H_ */
