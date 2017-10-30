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

// ------ 枚举定义 ------

/* 2.1.登录 */
/* 接口路径  */
#define STREAMLOGIN_PATH 		"/login/v1/mobileLogin"

/**
 * 请求
 */
#define LOGIN_MANID             "manid"
#define LOGIN_USERSID			"user_sid"
#define LOGIN_DEVICEID		    "deviceid"
#define LOGIN_MODEL		        "model"
#define LOGIN_MANUFACTURER		"manufacturer"

/**
 * 返回
 */
#define LOGIN_USERID		    "userid"
#define LOGIN_TOKEN             "token"
#define LOGIN_NICKNAME          "nickname"
#define LOGIN_LEVEL 			"level"
#define LOGIN_EXPERIENCE        "experience"
#define LOGIN_PHOTOURL			"photourl"
#define LOGIN_ISPUSHAD          "is_push_ad"
#define LOGIN_SVRLIST           "svr_list"
#define LOGIN_SVRLIST_SVRID                 "svrid"
#define LOGIN_SVRLIST_TURL                  "turl"
#define LOGIN_USERTYPE          "user_type"


/* 2.2.注销 */
/* 接口路径 */
#define LOGOUT_PATH                   "/man/v1/logout"


/* 2.3.上传tokenid接口 */
/* 接口路径 */
#define UPDATE_TOKENID_PATH                   "/man/v1/update_tokenid"

/**
 * 请求
 */
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

/* 3.1.获取Hot列表 */
/* 接口路径 */
#define LIVEROOM_GETANCHORLIST             "/manList/v1/getAnchorList"

/**
 * 请求
 */
#define LIVEROOM_HOT_HASWATCH               "has_watch"

/**
 * 返回
 */
#define LIVEROOM_HOT_USERID               "userid"
#define LIVEROOM_HOT_NICKNAME             "nickname"
#define LIVEROOM_HOT_PHOTOURL             "photourl"
#define LIVEROOM_HOT_ONLINESTATUS         "online_status"
#define LIVEROOM_HOT_ROOMPHOTOURL         "room_photourl"
#define LIVEROOM_HOT_ROOMTYPE             "room_type"
#define LIVEROOM_HOT_INTEREST             "interest"
#define LIVEROOM_HOT_ANCHORTYPE           "anchor_type"

/* 3.2.获取Follow列表 */
/* 接口路径 */
#define LIVEROOM_GETFOLLOWLIST             "/manList/v1/getFollowList"

/**
 * 返回
 */
#define LIVEROOM_FOLLOW_USERID               "userid"
#define LIVEROOM_FOLLOW_NICKNAME             "nickname"
#define LIVEROOM_FOLLOW_PHOTOURL             "photourl"
#define LIVEROOM_FOLLOW_ONLINESTATUS         "online_status"
#define LIVEROOM_FOLLOW_ROOMPHOTOURL         "room_photourl"
#define LIVEROOM_FOLLOW_ROOMTYPE             "room_type"
#define LIVEROOM_FOLLOW_LOVELEVEL            "love_level"
#define LIVEROOM_FOLLOW_ADDDATE              "add_date"
#define LIVEROOM_FOLLOW_INTEREST             "interest"
#define LIVEROOM_FOLLOW_ANCHORTYPE           "anchor_type"

/* 3.3.获取本人有效直播间或邀请信息(已废弃) */
/* 接口路径 */
#define LIVEROOM_CHECKROOM             "/man/v1/getroominfo"

/**
 * 返回
 */
#define LIVEROOM_CHECKROOM_ROOMLIST      "roomlist"
#define LIVEROOM_CHECKROOM_ROOMLIST_ROOMID        "roomid"
#define LIVEROOM_CHECKROOM_ROOMLIST_ROOMURL       "roomurl"
#define LIVEROOM_CHECKROOM_INVITELIST    "invitelist"
#define LIVEROOM_CHECKROOM_INVITELIST_INVITATIONID          "invitation_id"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEID            "opposite_id"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITENICKNAME      "opposite_nickname"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEPHOTOURL      "opposite_photourl"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITELEVEL         "opposite_level"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEAGE           "opposite_age"
#define LIVEROOM_CHECKROOM_INVITELIST_OPPOSITECOUNTRY       "opposite_country"
#define LIVEROOM_CHECKROOM_INVITELIST_READ                  "read"
#define LIVEROOM_CHECKROOM_INVITELIST_INVITIME              "invi_time"
#define LIVEROOM_CHECKROOM_INVITELIST_REPLYTYPE             "reply_type"
#define LIVEROOM_CHECKROOM_INVITELIST_VALIDTIME             "valid_time"
#define LIVEROOM_CHECKROOM_INVITELIST_ROOMID                "roomid"

/* 3.4.获取直播间观众头像列表 */
/* 接口路径 */
#define LIVEROOM_LIVEFANSLIST             "/share/v1/liveFansList"

/**
 * 请求
 */
#define LIVEROOM_LIVEFANSLIST_LIVEROOMID                "live_room_id"
#define LIVEROOM_LIVEFANSLIST_START                     "start"
#define LIVEROOM_LIVEFANSLIST_STEP                      "step"

/**
 * 返回
 */
#define LIVEROOM_FANS_USERID             "userid"
#define LIVEROOM_FANS_NICK_NAME          "nickname"
#define LIVEROOM_FANS_PHOTO_URL          "photourl"
#define LIVEROOM_FANS_MOUNTID            "mountid"
#define LIVEROOM_FANS_MOUNTURL           "mounturl"
#define LIVEROOM_FANS_LEVEL              "level"


/* 3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表) */
/* 接口路径 */
#define LIVEROOM_GETALLGIFTLIST          "/share/v1/getAllGiftList"



/**
 *  返回
 */

#define LIVEROOM_GIFT_LIST                  "list"

#define LIVEROOM_GIFTINFO_ID                "id"
#define LIVEROOM_GIFTINFO_NAME              "name"
#define LIVEROOM_GIFTINFO_SMALLIMGURL       "small_imgurl"
#define LIVEROOM_GIFTINFO_MIDDLEIMGURL      "middle_imgurl"
#define LIVEROOM_GIFTINFO_BIGIMGURL         "big_imgurl"
#define LIVEROOM_GIFTINFO_SRCFLASEURL       "src_flashurl"
#define LIVEROOM_GIFTINFO_SRCWEBPURL        "src_webpurl"
#define LIVEROOM_GIFTINFO_CREDIT            "credit"
#define LIVEROOM_GIFTINFO_MULTI_CLICK       "multi_click"
#define LIVEROOM_GIFTINFO_TYPE              "type"
#define LIVEROOM_GIFTINFO_LEVEL             "level"
#define LIVEROOM_GIFTINFO_LOVELEVEL         "love_level"
#define LIVEROOM_GIFTINFO_SENDNUMLIST       "send_num_list"
#define LIVEROOM_GIFTINFO_SENDNUMLIST_NUM        "num"
#define LIVEROOM_GIFTINFO_UPDATE_TIME       "updatetime"
#define LIVEROOM_GIFTINFO_PLAY_TIME         "play_time"



/* 3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物） */
/* 接口路径 */
#define LIVEROOM_GETGIFTLISTBYUSERID             "/share/v1/getGiftListByUserid"

/**
 *  返回
 */

#define LIVEROOM_GETGIFTLISTBYUSERID_LIST                  "list"
#define LIVEROOM_GETGIFTLISTBYUSERID_ID                             "id"
#define LIVEROOM_GETGIFTLISTBYUSERID_ISHOW                          "is_show"
#define LIVEROOM_GETGIFTLISTBYUSERID_ISPROMO                        "is_promo"

/* 3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示） */
/* 接口路径 */
#define LIVEROOM_GETGiftDetail                  "/share/v1/getGiftDetail"

/**
 *  请求
 */
#define LIVEROOM_GiftID                        "gift_id"

/* 3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表） */
/* 接口路径 */
#define LIVEROOM_GETEMOTICONLIST             "/share/v1/getEmoticonList"

/**
 *  返回
 */

#define LIVEROOM_EMOTICON_LIST                  "list"
#define LIVEROOM_EMOTICON_LIST_EMOTYPE                  "type"
#define LIVEROOM_EMOTICON_LIST_NAME                     "name"
#define LIVEROOM_EMOTICON_LIST_ERRMSG                   "errmsg"
#define LIVEROOM_EMOTICON_LIST_EMOURL                   "emo_url"
#define LIVEROOM_EMOTICON_LIST_EMOLIST                  "emo_list"
#define LIVEROOM_EMOTICON_LIST_EMOLIST_ID                           "id"
#define LIVEROOM_EMOTICON_LIST_EMOLIST_EMOSIGN                      "emo_sign"
#define LIVEROOM_EMOTICON_LIST_EMOLIST_EMOURL                       "emo_url"
#define LIVEROOM_EMOTICON_LIST_EMOLIST_EMOTYPE                      "emo_type"
#define LIVEROOM_EMOTICON_LIST_EMOLIST_EMOICONURL                   "emo_icon_url"

/* 3.9.获取指定立即私密邀请信息 （已废弃）*/
/* 接口路径 */
#define LIVEROOM_GETINVITEINFO             "/imMan/v1/getInviteInfo"

/**
 *  请求
 */
#define LIVEROOM_INVITE_INVITATIONID                     "invitation_id"

/**
 *  返回
 */

#define LIVEROOM_INVITE_INVITE                  "invite"

/* 3.10.获取才艺点播列表 */
/* 接口路径 */
#define LIVEROOM_GETTALENTLIST             "/share/v1/getTalentList"

/**
 *  请求
 */
#define LIVEROOM_GETTALENTLIST_ROOMID      "roomid"

/**
 *  返回
 */

#define LIVEROOM_GETTALENTLIST_LIST        "list"
#define LIVEROOM_GETTALENTLIST_LIST_ID               "id"
#define LIVEROOM_GETTALENTLIST_LIST_NAME             "name"
#define LIVEROOM_GETTALENTLIST_LIST_CREDIT           "credit"

/* 3.11.获取才艺点播邀请状态 */
/* 接口路径 */
#define LIVEROOM_GETTALENTSTATUS             "/share/v1/getTalentStatus"

/**
 *  请求
 */
#define LIVEROOM_GETTALENTSTATUS_ROOMID              "roomid"
#define LIVEROOM_GETTALENTSTATUS_TALENTINVITEID      "talent_inviteid"

/**
 *  返回
 */
#define LIVEROOM_GETTALENTSTATUS_RETURNTALENTINVITEID      "talent_inviteid"
#define LIVEROOM_GETTALENTSTATUS_TALENTID                   "talentid"
#define LIVEROOM_GETTALENTSTATUS_NAME                       "name"
#define LIVEROOM_GETTALENTSTATUS_CREDIT                     "credit"
#define LIVEROOM_GETTALENTSTATUS_STATUS                     "status"

/* 3.12.获取指定观众信息 */
/* 接口路径 */
#define LIVEROOM_GETNEWFANSBASEINFO             "/share/v1/getNewFansBaseInfo"

/**
 *  请求
 */
#define LIVEROOM_GETNEWFANSBASEINFO_USERID              "userid"

/**
 *  返回
 */
#define LIVEROOM_GETNEWFANSBASEINFO_NICKNAME            "nickname"
#define LIVEROOM_GETNEWFANSBASEINFO_PHOTOURL            "photourl"
#define LIVEROOM_GETNEWFANSBASEINFO_RIDERID             "riderid"
#define LIVEROOM_GETNEWFANSBASEINFO_RIDERNAME           "ridername"
#define LIVEROOM_GETNEWFANSBASEINFO_RIDERURL            "riderurl"

/* 3.13.观众开始／结束视频互动（废弃） */
/* 接口路径 */
#define LIVEROOM_CONTROLMANPUSH             "/share/v1/controlManPush"

/**
 *  请求
 */
#define LIVEROOM_CONTROLMANPUSH_ROOMID             "roomid"
#define LIVEROOM_CONTROLMANPUSH_CONTROL            "control"

/**
 *  返回
 */
#define LIVEROOM_GETNEWFANSBASEINFO_MANPUSHURL      "man_push_url"

/* 3.14.获取推荐主播列表 */
/* 接口路径 */
#define LIVEROOM_GETPROMOANCHORLIST             "/manList/v1/getPromoAnchorList"

/**
 *  请求
 */
#define LIVEROOM_GETPROMOANCHORLIST_NUMBER              "number"
#define LIVEROOM_GETPROMOANCHORLIST_TYPE                "type"
#define LIVEROOM_GETPROMOANCHORLIST_USERID              "userid"

/**
 *  返回
 */
#define LIVEROOM_GETPROMOANCHORLIST_LIST                "list"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_USERID                 "userid"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_NICKNAME               "nickname"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_PHOTOURL               "photourl"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_ONLINESTATUS           "online_status"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_ROOMPHOTOURL           "room_photourl"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_ROOMTYPE               "room_type"
#define LIVEROOM_GETPROMOANCHORLIST_LIST_INTEREST               "interest"

/* ########################	背包 模块  ######################## */
/* 4.1.观众待处理的预约邀请列表 */
/* 接口路径 */
#define LIVEROOM_MANHANDLEBOOKINGLIST                  "/share/v1/getScheduleList"

/**
 *  请求
 */
#define LIVEROOM_MANHANDLEBOOKINGLIST_TAG                      "tag"
#define LIVEROOM_MANHANDLEBOOKINGLIST_START                    "start"
#define LIVEROOM_MANHANDLEBOOKINGLIST_STEP                     "step"

/**
 *  返回
 */
#define LIVEROOM_MANHANDLEBOOKINGLIST_TOTAL                   "total"
#define LIVEROOM_MANHANDLEBOOLINGLIST_NOREADCOUNT             "no_read_count"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST                    "list"
#define LIVEROOM_MANHANDLEBOOLINGLEST_LIST_BOOKING                  "booking"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID                   "invitation_id"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID                           "toid"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID                         "fromid"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL               "opposite_photourl"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME               "opposite_nickname"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_READ                           "read"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY                       "intimacy"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE                      "reply_type"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME                       "book_time"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID                         "gift_id"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME                       "gift_name"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL                  "gift_big_imgurl"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL                "gift_small_imgurl"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM                        "gift_num"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME                      "valid_time"
#define LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID                         "roomid"

/* 4.2.观众处理预约邀请 */
/* 接口路径 */
#define LIVEROOM_HANDLEBOOKING                  "/manList/v1/handleBooking"

/**
 *  请求
 */
#define LIVEROOM_HANDLEBOOKINGT_INVITATIONID                 "invitation_id"
#define LIVEROOM_HANDLEBOOKINGT_ISCONFIRM                    "is_confirm"

/* 4.3.取消预约邀请 */
/* 接口路径 */
#define LIVEROOM_SENDCANCELPRIVATELIVEINVITE                  "/man/v1/cancelPrivateRequest"

/**
 *  请求
 */
#define LIVEROOM_SENDCANCELPRIVATELIVEINVITE_INVITATIONID     "invitation_id"

/* 4.4.获取预约邀请未读或待处理数量 */
/* 接口路径 */
#define LIVEROOM_MANBOOKINGUNREADUNHANDKENUM                  "/share/v1/getScheduleListNoReadNum"

/**
 *  返回
 */
#define LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_TOTALNOREADNUM          "total_no_read_num"
#define LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_PENDINGNOREADNUM        "pending_no_read_num"
#define LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_SCHEDULEDNOREADNUM      "scheduled_no_read_num"
#define LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HISTORYNOREADNUM        "history_no_read_num"

/* 4.5.获取新建预约邀请信息 */
/* 接口路径 */
#define LIVEROOM_GETCREATEBOOKINGINFO                  "/man/v1/getCreateBookingInfo"

/**
 *  请求
 */
#define LIVEROOM_GETCREATEBOOKINGINFO_USERID     "userid"

/**
 *  返回
 */
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKDEPOSIT           "book_deposit"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME              "book_time"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIMEID                   "time_id"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIME                     "time"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_STATUS                   "status"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT              "book_gift"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST                 "gift_list"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTID                      "giftid"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_SENDNUMLIST                 "send_num_list"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_NUM                              "num"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_ISDEFAULT                        "is_default"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKPHONE             "book_phone"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKPHONE_COUNTRY                 "country"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKPHONE_AREACODE                "area_code"
#define LIVEROOM_GETCREATEBOOKINGINFO_BOOKPHONE_PHONENO                 "phone_no"

/* 4.6.新建预约邀请 */
/* 接口路径 */
#define LIVEROOM_SENDBOOKINGREQUEST                  "/man/v1/sendBookingRequest"

/**
 *  请求
 */
#define LIVEROOM_SENDBOOKINGREQUEST_USERID          "userid"
#define LIVEROOM_SENDBOOKINGREQUEST_TIMEID          "time_id"
#define LIVEROOM_SENDBOOKINGREQUEST_BOOKTIME        "book_time"
#define LIVEROOM_SENDBOOKINGREQUEST_GIFTID          "giftid"
#define LIVEROOM_SENDBOOKINGREQUEST_GIFTNUM         "gift_num"
#define LIVEROOM_SENDBOOKINGREQUEST_NEEDSMS         "need_sms"

/* 4.7.观众处理立即私密邀请 */
/* 接口路径 */
#define LIVEROOM_ACCEPTINSTACEINVITE                  "/man/v1/acceptInstanceInvite"

/**
 *  请求
 */
#define LIVEROOM_ACCEPTINSTACEINVITE_INVITEID          "invite_id"
#define LIVEROOM_ACCEPTINSTACEINVITE_ISCONFIRM         "is_confirm"

/**
 *  返回
 */
#define LIVEROOM_ACCEPTINSTACEINVITE_ROOMID          "room_id"
#define LIVEROOM_ACCEPTINSTACEINVITE_ROOMTYPE        "room_type"

/* ########################	背包 模块  ######################## */
/* 5.1.获取背包礼物列表 */
/* 接口路径 */
#define LIVEROOM_BACKPACK_GIFTLIST                  "/share/v1/giftlist"

/**
 *  返回
 */
#define LIVEROOM_BACKPACK_GIFT_LIST                  "list"
#define LIVEROOM_BACKPACK_GIFT_LIST_GIFTID                  "giftid"
#define LIVEROOM_BACKPACK_GIFT_LIST_NUM                     "num"
#define LIVEROOM_BACKPACK_GIFT_LIST_GRANTEDDATE             "granted_date"
#define LIVEROOM_BACKPACK_GIFT_LIST_EXPDATE                 "exp_date"
#define LIVEROOM_BACKPACK_GIFT_LIST_READ                    "read"
#define LIVEROOM_BACKPACK_GIFT_TOTALCOUNT             "total_count"

/* 5.2.获取试用劵列表 */
/* 接口路径 */
#define LIVEROOM_VOUCHERLIST                  "/share/v1/voucherList"

/**
 *  返回
 */
#define LIVEROOM_VOUCHERLIST_LIST                  "list"
#define LIVEROOM_VOUCHERLIST_LIST_ID                        "id"
#define LIVEROOM_VOUCHERLIST_LIST_PHOTOURL                  "photourl"
#define LIVEROOM_VOUCHERLIST_LIST_DESC                      "desc"
#define LIVEROOM_VOUCHERLIST_LIST_USEROOMTYPE               "use_room_type"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORTYPE                "anchor_type"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORID                  "anchor_id"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORNICKNAME            "anchor_nickname"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORPHOTORUL            "anchor_photourl"
#define LIVEROOM_VOUCHERLIST_LIST_GRANTEDDATE               "granted_date"
#define LIVEROOM_VOUCHERLIST_LIST_EXPDATE                   "exp_date"
#define LIVEROOM_VOUCHERLIST_LIST_READ                      "read"
#define LIVEROOM_VOUCHERLIST_TOTALCOUNT              "total_count"

/* 5.3.获取座驾列表 */
/* 接口路径 */
#define LIVEROOM_RIDELIST                  "/share/v1/rideList"

/**
 *  返回
 */
#define LIVEROOM_RIDELIST_LIST                  "list"
#define LIVEROOM_RIDELIST_LIST_ID                       "id"
#define LIVEROOM_RIDELIST_LIST_PHOTOURL                 "photourl"
#define LIVEROOM_RIDELIST_LIST_NAME                     "name"
#define LIVEROOM_RIDELIST_LIST_GRANTEDDATE              "granted_date"
#define LIVEROOM_RIDELIST_LIST_EXPDATE                  "exp_date"
#define LIVEROOM_RIDELIST_LIST_READ                     "read"
#define LIVEROOM_RIDELIST_LIST_ISUSE                    "is_use"
#define LIVEROOM_RIDELIST_TOTALCOUNT            "total_count"

/* 5.4.使用／取消座驾 */
/* 接口路径 */
#define LIVEROOM_SETRIDE                  "/share/v1/setRide"

/**
 *  请求
 */
#define LIVEROOM_SETRIDE_RIDEID          "rideid"

/* 5.5.获取背包未读数量 */
/* 接口路径 */
#define LIVEROOM_GETBACKPACKUNREADNUM                  "/share/v1/getBackpackUnreadNum"

/**
 *  返回
 */
#define LIVEROOM_GETBACKPACKUNREADNUM_TOTAL                          "total"
#define LIVEROOM_GETBACKPACKUNREADNUM_VOUCHERUNREADNUM               "voucher_unread_num"
#define LIVEROOM_GETBACKPACKUNREADNUM_GIFTUNREADNUM                  "gift_unread_num"
#define LIVEROOM_GETBACKPACKUNREADNUM_RIDEUNREADNUM                  "ride_unread_num"


/* ########################	其它 模块  ######################## */

/* 6.1.同步配置 */
/* 接口路径 */
#define LIVEROOM_GET_CONFIG                       "/share/v1/getconfig"

/**
 * 返回
 */
#define LIVEROOM_IMSVR_URL                       "imsvr_url"
#define LIVEROOM_HTTPSVR_URL                     "httpsvr_url"
#define LIVEROOM_ADDCREDITS_URL                 "addcredits_url"

/* 6.2.获取账号余额 */
/* 接口路径 */
#define LIVEROOM_GET_LEFTCREDIT                       "/share/v1/getLeftCredit"

/**
 * 返回
 */
#define LIVEROOM_GETCREDIT_CREDIT                 "credit"

/* 6.3.添加／取消收藏 */
/* 接口路径 */
#define LIVEROOM_SETFAVORITE                       "/share/v1/setFavorite"

/**
 *  请求
 */
#define LIVEROOM_SETFAVORITE_USERID                       "userid"
#define LIVEROOM_SETFAVORITE_ROOMID                       "roomid"
#define LIVEROOM_SETFAVORITE_ISFAV                        "is_fav"


/* 6.4.获取QN广告列表 */
/* 接口路径 */
#define LIVEROOM_GETADANCHORLIST                        "/manList/v1/getAdAnchorList"

/**
 *  请求
 */
#define LIVEROOM_GETADANCHORLIST_NUMBER                 "number"

/* 6.5.关闭QN广告列表 */
/* 接口路径 */
#define LIVEROOM_CLOSEADANCHORLIST                        "/manList/v1/closeAdAnchorList"

/* 6.6.获取手机验证码 */
/* 接口路径 */
#define LIVEROOM_GETPHONEVERIFYCODE                       "/man/v1/getPhoneVerifyCode"

/**
 *  请求
 */
#define LIVEROOM_GETPHONEVERIFYCODE_COUNTRY                      "country"
#define LIVEROOM_GETPHONEVERIFYCODE_AREACODE                     "area_code"
#define LIVEROOM_GETPHONEVERIFYCODE_PHONENO                      "phone_no"

/* 6.7.提交手机验证码 */
/* 接口路径 */
#define LIVEROOM_SUBMITPHONEVERIFYCODE                       "/man/v1/submitPhoneVerifyCode"

/**
 *  请求
 */
#define LIVEROOM_SUBMITPHONEVERIFYCODE_COUNTRY                      "country"
#define LIVEROOM_SUBMITPHONEVERIFYCODE_AREACODE                     "area_code"
#define LIVEROOM_SUBMITPHONEVERIFYCODE_PHONENO                      "phone_no"
#define LIVEROOM_SUBMITPHONEVERIFYCODE_VERIFYCODE                   "verify_code"

/* 6.8.提交流媒体服务器测速结果 */
/* 接口路径 */
#define LIVEROOM_SUBMITSERVERVELOMETER                              "/share/v1/t"

/**
 *  请求
 */
#define LIVEROOM_SUBMITSERVERVELOMETER_SID                          "sid"
#define LIVEROOM_SUBMITSERVERVELOMETER_RES                          "res"

/* 6.9.获取Hot/Following列表头部广告 */
/* 接口路径 */
#define LIVEROOM_BANNER                                 "/manList/v1/banner"

/**
 *  返回
 */
#define LIVEROOM_BANNER_BANNERIMG                               "banner_img"
#define LIVEROOM_BANNER_BANNERLINK                              "banner_link"

#endif /* REQUESTAUTHORIZATIONDEFINE_H_ */
