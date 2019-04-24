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
#define LOGIN_REGIONID          "region_id"
#define LOGIN_USERSIDTYPE       "user_sid_type"

/**
 * 返回
 */
#define LOGIN_USERID		    "userid"
#define LOGIN_TOKEN             "token"
#define LOGIN_SESSIONID         "sessionid"
#define LOGIN_NICKNAME          "nickname"
#define LOGIN_LEVEL 			"level"
#define LOGIN_EXPERIENCE        "experience"
#define LOGIN_PHOTOURL			"photourl"
#define LOGIN_ISPUSHAD          "is_push_ad"
#define LOGIN_SVRLIST           "svr_list"
#define LOGIN_SVRLIST_SVRID                 "svrid"
#define LOGIN_SVRLIST_TURL                  "turl"
#define LOGIN_USERTYPE          "user_type"
#define LOGIN_QNMAINADURL       "qn_main_ad_url"
#define LOGIN_QNMAINADTITLE     "qn_main_ad_title"
#define LOGIN_QNMAINADID        "qn_main_ad_id"
#define LOGIN_GAUID             "ga_uid"
#define LOGIN_LIVECHAT          "livechat"
#define LOGIN_HANGOUTPRIV           "hangoutPriv"
#define LOGIN_LIVECHAT_INVITE   "livechat_invite"
#define LOGIN_MAILPRIV          "mailPriv"
#define LOGIN_MAILPRIV_USERSENDMAILPRIV  "userSendMailPriv"
#define LOGIN_MAILPRIV_USERSENDMAILIMGPRIV  "userSendMailImgPriv"
#define LOGIN_MAILPRIV_USERSENDMAILIMGPRIV_ISPRIV           "isPriv"
#define LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_MAX_IMG          "max_img"
#define LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG     "reply_postStampMsg"
#define LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_COINMSG          "reply_coinMsg"
#define LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG     "quickreply_postStampMsg"
#define LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_COINMSG          "quickreply_coinMsg"
#define LOGIN_USER_PRIV         "user_priv"
#define LOGIN_USER_PRIV_LIVECHAT        "livechat"
#define LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_PRIV              "livechat_priv"
#define LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_INVITE            "livechat_invite"
#define LOGIN_USER_PRIV_LIVECHAT_PRIVMBPPSENDVIALIVECHAT    "priv_mb_pp_send_via_livechat"
#define LOGIN_USER_PRIV_LIVECHAT_PRIVMBLIVECHATINVITATIONVOICE    "priv_mb_livechat_invitation_voice"
#define LOGIN_USER_PRIV_MAILPRIV        "mailPriv"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILPRIV           "userSendMailPriv"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV        "userSendMailImgPriv"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_ISPRIV                 "isPriv"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_MAXIMG                 "max_img"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_REPLYPOSTSTAMPMSG      "reply_postStampMsg"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_REPLYCOINMSG           "reply_coinMsg"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_QUICKREPLYPOSTSTAMPMSG "quickreply_postStampMsg"
#define LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV_QUICKREPLYCOINMSG      "quickreply_coinMsg"
#define LOGIN_USER_PRIV_HANGOUT         "hangout"
#define LOGIN_USER_PRIV_HANGOUT_HANGOUTPRIV         "hangoutPriv"
#define LOGIN_USER_PRIV_SAYHI           "say_hi"


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

/* 2.4.Facebook注册及登录接口（仅独立） */
/* 接口路径 */
#define OWN_FACKBOOK_LOGIN_PATH                   "/App/member/facebooklogin"

/**
 * 请求
 */
#define OWN_FACKBOOK_LOGIN_FTOKEN                   "ftoken"
#define OWN_FACKBOOK_LOGIN_EMAIL                    "email"
#define OWN_FACKBOOK_LOGIN_PASSWORD                 "password"
#define OWN_FACKBOOK_LOGIN_GENDER                   "gender"
#define OWN_FACKBOOK_LOGIN_NICKNAME                 "nick_name"
#define OWN_FACKBOOK_LOGIN_BIRTHDAY                 "birthday"
#define OWN_FACKBOOK_LOGIN_INVITECODE               "invite_code"
#define OWN_FACKBOOK_LOGIN_DEVICEID                 "deviceId"
#define OWN_FACKBOOK_LOGIN_MODEL                    "model"
#define OWN_FACKBOOK_LOGIN_MANUFACTURER             "manufacturer"
#define OWN_FACKBOOK_LOGIN_UTMREFERRER              "utm_referrer"

/* 返回 */
#define OWN_FACKBOOK_LOGIN_SESSIONID                "sessionid"

/* 2.5.邮箱注册（仅独立） */
/* 接口路径 */
#define OWN_REGISTER_PATH                   "/App/member/joincheck"

/**
 * 请求
 */
#define OWN_REGISTER_EMAIL                      "email"
#define OWN_REGISTER_PASSWORD                   "passwd1"
#define OWN_REGISTER_GENDER                     "gender"
#define OWN_REGISTER_NICKNAME                   "nick_name"
#define OWN_REGISTER_BIRTHDAY                   "birthday"
#define OWN_REGISTER_INVITECODE                 "invite_code"
#define OWN_REGISTER_DEVICEID                   "deviceId"
#define OWN_REGISTER_MODEL                      "model"
#define OWN_REGISTER_MANUFACTURER               "manufacturer"
#define OWN_REGISTER_UTMREFERRER                "utm_referrer"

/* 返回 */
#define OWN_REGISTER_SESSIONID                "sessionid"

/* 2.6.邮箱登录（仅独立） */
/* 接口路径 */
#define OWN_EMAIL_LOGIN_PATH                   "/App/member/logincheck"

/**
 * 请求
 */
#define OWN_EMAIL_LOGIN_EMAIL                      "email"
#define OWN_EMAIL_LOGIN_PASSWORD                   "password"
#define OWN_EMAIL_LOGIN_VERSIONCODE                "versioncode"
#define OWN_EMAIL_LOGIN_DEVICEID                   "deviceId"
#define OWN_EMAIL_LOGIN_MODEL                      "model"
#define OWN_EMAIL_LOGIN_MANUFACTURER               "manufacturer"
#define OWN_EMAIL_LOGIN_CHECKCODE                  "checkcode"

/* 返回 */
#define OWN_EMAIL_LOGIN_SESSIONID                "sessionid"

/* 2.7.找回密码（仅独立） */
/* 接口路径 */
#define OWN_FIND_PASSWORD_PATH                   "/App/member/find_pw"

/**
 * 请求
 */
#define OWN_FIND_PASSWORD_SENDMAIL                      "sendmail"
#define OWN_FIND_PASSWORD_CHECKCODE                      "checkcode"

/* 2.8.检测邮箱注册状态（仅独立）） */
/* 接口路径 */
#define OWN_CHECK_MAIL_PATH                   "/App/member/checkmail"

/**
 * 请求
 */
#define OWN_CHECK_MAIL_EMAIL                      "email"

/* 2.9.提交用户头像接口（仅独立）） */
/* 接口路径 */
#define OWN_UPLOAD_PHOTO_PATH                   "/App/member/uploadphoto"

/**
 * 请求
 */
#define OWN_UPLOAD_PHOTO_PHOTONAME               "photoname"

/* 返回 */
#define OWN_UPLOAD_PHOTO_PHOTOURL                "photourl"


/* 2.10.获取验证码（仅独立）） */
/* 接口路径 */
#define OWN_GIFAUTH_PATH                   "/App/member/gifAuth"

/**
 * 请求
 */
#define OWN_GIFAUTH_ID                      "id"
#define OWN_GIFAUTH_USECODE                 "usecode"

/* 2.11.显示用户头像（仅独立）） */
/* 接口路径 */
#define OWN_SHOWPHOTO_PATH                   "/App/member/showphoto"

/* 2.13.可登录的站点列表 */
#define VALIDSITEID_PATH                    "/member/validsiteid"

/**
 * 请求
 */
#define VALIDSITEID_EMAIL                       "email"
#define VALIDSITEID_PASSWORD                    "password"

/**
 * 返回
 */
#define VALIDSITEID_DATALIST                       "datalist"
#define VALIDSITEID_DATALIST_SITEID                                 "siteid"
#define VALIDSITEID_DATALIST_ISLIVE                                 "islive"

/* 2.14.添加App token */
#define LIVEROOM_ADDTOKEN_PATH                    "/member/add_token"

/**
 * 请求
 */
#define LIVEROOM_ADDTOKEN_TOKEN                      "token"
#define LIVEROOM_ADDTOKEN_APPID                      "app_id"
#define LIVEROOM_ADDTOKEN_DEVICEID                   "device_id"

/* 2.15.销毁App token */
#define LIVEROOM_DESTROYTOKEN_PATH                    "/member/destroy_token"

/* 2.16.找回密码 */
#define LIVEROOM_FINDPW_PATH                    "/user/dofindPwd"

/**
 * 请求
 */
#define LIVEROOM_FINDPW_SENDMAIL                      "sendmail"
#define LIVEROOM_FINDPW_VERIFYCODE                    "verify_code"

/**
 * 返回
 */
#define LIVEROOM_FINDPW_ERRORMSG                   "errorMsg"

/* 2.17.修改密码 */
#define LIVEROOM_CHANGEPWD_PATH                    "/member/changepwd"

/**
 * 请求
 */
#define LIVEROOM_FINDPW_PASSWORDNEW                      "passwordNew"
#define LIVEROOM_FINDPW_PASSWORDOLD                      "passwordOld"

/* 2.18.token登录认证 */
#define LIVEROOM_DOLOGIN_PATH                           "/member/dologin"

/**
 * 请求
 */
#define LIVEROOM_DOLOGIN_TOKEN                          "token"
#define LIVEROOM_DOLOGIN_MEMBERID                       "memberid"
#define LIVEROOM_DOLOGIN_DEVICEID                       "deviceId"
#define LIVEROOM_DOLOGIN_VERSIONCODE                    "versioncode"
#define LIVEROOM_DOLOGIN_MODEL                          "model"
#define LIVEROOM_DOLOGIN_MANUFACTURER                   "manufacturer"

/* 2.19.获取认证token证 */
#define LIVEROOM_GETTOKEN_PATH                           "/user/goto"


/**
 * 请求
 */
#define LIVEROOM_DOLOGIN_URL                            "url"
#define LIVEROOM_DOLOGIN_SITEID                         "siteid"

/**
 * 返回
 */
#define LIVEROOM_DOLOGIN_MEMBERID                        "memberid"
#define LIVEROOM_DOLOGIN_SID                             "sid"

/* 2.20.帐号密码登录 */
#define LIVEROOM_PASSWORDLOGIN_PATH                      "/user/dologin"


/**
 * 请求
 */
#define LIVEROOM_PASSWORDLOGIN_EMAIL                            "email"
#define LIVEROOM_PASSWORDLOGIN_PASSWORD                        "password"
#define LIVEROOM_PASSWORDLOGIN_AUTHCODE                        "auth_code"
#define LIVEROOM_PASSWORDLOGIN_SOURCE                          "source"
#define LIVEROOM_PASSWORDLOGIN_AF_DEVICEID                     "af_deviceid"
#define LIVEROOM_PASSWORDLOGIN_GAID                            "gaid"
#define LIVEROOM_PASSWORDLOGIN_DEVICEID                        "deviceId"

/**
 * 返回
 */
#define LIVEROOM_PASSWORDLOGIN_USERSID                        "user_sid"
#define LIVEROOM_PASSWORDLOGIN_MANID                          "manid"

/* 2.21.token登录 */
#define LIVEROOM_AUTH_PATH                                    "/user/auth"

/**
 * 请求
 */
#define LIVEROOM_AUTH_MEMBERID                            "memberid"
#define LIVEROOM_AUTH_SID                                 "sid"

/**
 * 返回
 */
#define LIVEROOM_AUTH_USERSID                        "user_sid"
#define LIVEROOM_AUTH_MANID                          "manid"

/* 2.22.获取验证码 */
#define LIVEROOM_VALIDATECODE_PATH                   "/index/validateCode"

/**
 * 请求
 */
#define LIVEROOM_VALIDATECODE_ID                     "id"

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
#define LIVEROOM_HOT_ISFORTEST              "is_for_test"

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
#define LIVEROOM_HOT_SHOWINFO             "show_info"
#define LIVEROOM_HOT_PROGRAMLIST_SHOWLIVEID                 "live_show_id"
#define LIVEROOM_HOT_PROGRAMLIST_ANCHORID                   "anchor_id"
#define LIVEROOM_HOT_PROGRAMLIST_ANCHORNICKNAME             "anchor_nickname"
#define LIVEROOM_HOT_PROGRAMLIST_ANCHORAVATAR               "anchor_avatar"
#define LIVEROOM_HOT_PROGRAMLIST_SHOWTITLE                  "show_title"
#define LIVEROOM_HOT_PROGRAMLIST_SHOWINTRODUCE              "show_introduce"
#define LIVEROOM_HOT_PROGRAMLIST_COVER                      "cover"
#define LIVEROOM_HOT_PROGRAMLIST_APPROVETIME                "approve_time"
#define LIVEROOM_HOT_PROGRAMLIST_STARTTIME                  "start_time"
#define LIVEROOM_HOT_PROGRAMLIST_DURATION                   "duration"
#define LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOSTART             "left_sec_to_start"
#define LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOENTER             "left_sec_to_enter"
#define LIVEROOM_HOT_PROGRAMLIST_PRICE                      "price"
#define LIVEROOM_HOT_PROGRAMLIST_STATUS                     "status"
#define LIVEROOM_HOT_PROGRAMLIST_TICKETSTATUS               "ticket_status"
#define LIVEROOM_HOT_PROGRAMLIST_HASFOLLOW                  "has_follow"
#define LIVEROOM_HOT_PROGRAMLIST_TICKETISFULL               "ticket_is_full"
#define LIVEROOM_HOT_PROGRAMLIST_PRIV                       "priv"
#define LIVEROOM_HOT_PROGRAMLIST_PRIV_ONEONONE                      "oneonone"
#define LIVEROOM_HOT_PROGRAMLIST_PRIV_BOOKING                       "booking"
#define LIVEROOM_HOT_PROGRAMLIST_CHAT_ONLINE_STATUS         "chat_online_status"

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
#define LIVEROOM_FANS_HASTICKET          "has_ticket"


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
#define LIVEROOM_GETTALENTLIST_LIST_DESCRIPTION      "description"
#define LIVEROOM_GETTALENTLIST_LIST_GIFTID           "gift_id"
#define LIVEROOM_GETTALENTLIST_LIST_GIFTNAME         "gift_name"
#define LIVEROOM_GETTALENTLIST_LIST_GIFTNUM          "gift_num"

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
#define LIVEROOM_GETTALENTSTATUS_STATUS                     "status"
#define LIVEROOM_GETTALENTSTATUS_GIFTID                     "gift_id"
#define LIVEROOM_GETTALENTSTATUS_GIFTNAME                   "gift_name"
#define LIVEROOM_GETTALENTSTATUS_GIFTNUM                    "gift_num"

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
#define LIVEROOM_BACKPACK_GIFT_LIST_STARTVALIDDATE          "start_valid_date"
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
#define LIVEROOM_VOUCHERLIST_LIST_PHOTOURLMOBILE            "photourl_mobile"
#define LIVEROOM_VOUCHERLIST_LIST_DESC                      "desc"
#define LIVEROOM_VOUCHERLIST_LIST_USEROOMTYPE               "use_room_type"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORTYPE                "anchor_type"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORID                  "anchor_id"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORNICKNAME            "anchor_nickname"
#define LIVEROOM_VOUCHERLIST_LIST_ANCHORPHOTORUL            "anchor_photourl"
#define LIVEROOM_VOUCHERLIST_LIST_GRANTEDDATE               "granted_date"
#define LIVEROOM_VOUCHERLIST_LIST_STARTVALIDDATE            "start_valid_date"
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
#define LIVEROOM_RIDELIST_LIST_STARTVALIDDATE           "start_valid_date"
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

/* 5.6.获取试用券可用信息 */
/* 接口路径 */
#define LIVEROOM_GETVOUCHERAVAILABLEINFO                  "/share/v1/getVoucherAvailableInfo"

/**
 *  返回
 */
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICEXPTIME                          "onlypublic_exp_time"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATEEXPTIME                         "onlyprivate_exp_time"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR                                 "bind_anchor"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_ANCHORID                                    "anchor_id"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_USEROOMTYPE                                 "use_room_type"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_EXPTIME                                     "exp_time"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICNEWANCHOREXPTIME                  "onlypublic_new_anchor_exp_time"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATENEWANCHOREXPTIME                 "onlyprivate_new_anchor_exp_time"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR                               "watched_anchor"
#define LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR_ANCHORID                                 "anchor_id"


/* ########################	其它 模块  ######################## */

/* 6.1.同步配置 */
/* 接口路径 */
#define LIVEROOM_GET_CONFIG                       "/share/v1/getconfig"

/**
 * 返回
 */
#define LIVEROOM_IMSVR_URL                      "imsvr_url"
#define LIVEROOM_HTTPSVR_URL                    "httpsvr_url"
#define LIVEROOM_HTTPSVR_MOBILE_URL             "httpsvr_mobile_url"
#define LIVEROOM_ADDCREDITS_URL                 "addcredits_url"
#define LIVEROOM_ANCHOR_PAGE                    "anchor_page"
#define LIVEROOM_USER_LEVEL                     "user_level"
#define LIVEROOM_INTIMACY                       "intimacy"
#define LIVEROOM_USERPROTOCOL                   "user_protocol"
#define LIVEROOM_TERMSOFUSE                     "terms_of_use"
#define LIVEROOM_PRIVACYPOLICY                  "privacy_policy"
#define LIVEROOM_SHOWDETAILPAGE                 "show_detail_page"
#define LIVEROOM_SHOWDESCRIPTION                "show_description"
#define LIVEROOM_MINAVAILABLEVER                "min_available_ver"
#define LIVEROOM_MINAVAILABLEMSG                "min_available_msg"
#define LIVEROOM_NEWEST_VER                     "newest_ver"
#define LIVEROOM_NEWEST_MSG                     "newest_msg"
#define LIVEROOM_DOWNLOADAPPURL_MSG             "download_app_url"
#define LIVEROOM_SVRLIST                        "svr_list"
#define LIVEROOM_SVRLIST_SVRID                                  "svrid"
#define LIVEROOM_SVRLIST_TURL                                   "turl"
#define LIVEROOM_HANGOUT                        "hangout"
#define LIVEROOM_HANGOUT_CREDITPERMINUTE                        "credit_per_minute"
#define LIVEROOM_HANGOUT_CREDITPRICE                            "credit_price"
#define LIVEROOM_LOIHURL                        "loi_h5_url"
#define LIVEROOM_EMFHURL                        "emf_h5_url"
#define LIVEROOM_PMSTARTNOTICE                  "pm_start_notice"
#define LIVEROOM_POSTSTAMPURL                   "post_stamp_url"
#define LIVEROOM_SOCKET_HOST                    "socket_host"
#define LIVEROOM_SOCKET_HOST_DOMAIN             "socket_host_domain"
#define LIVEROOM_SOCKET_PORT                    "socket_port"
#define LIVEROOM_MIN_BALANCE_FOR_CHAT           "min_balance_for_chat"
#define LIVEROOM_CHAT_VOICE_HOSTURL             "chat_voice_hosturl"
#define LIVEROOM_SEND_LETTER                    "send_letter"

/* 6.2.获取账号余额 */
/* 接口路径 */
#define LIVEROOM_GET_LEFTCREDIT                       "/share/v1/getLeftCredit"

/**
 * 返回
 */
#define LIVEROOM_GETCREDIT_CREDIT                 "credit"
#define LIVEROOM_GETCREDIT_COUPON                 "coupon"
#define LIVEROOM_GETCREDIT_POSTSTAMP              "poststamp"

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
#define LIVEROOM_BANNER_BANNERNAME                              "banner_name"
#define LIVEROOM_BANNER_BANNERIMG                               "banner_img"
#define LIVEROOM_BANNER_BANNERLINK                              "banner_link"

/* 6.10.获取主播/观众信息 */
/* 接口路径 */
#define LIVEROOM_GETUSERINFO                                 "/share/v1/getUserInfo"

/**
 *  请求
 */
#define LIVEROOM_GETUSERINFO_USERID                      "userid"

/**
 *  返回
 */
#define LIVEROOM_GETUSERINFO_LSUSERID                   "userid"
#define LIVEROOM_GETUSERINFO_NICKNAME                   "nickname"
#define LIVEROOM_GETUSERINFO_PHOTOURL                   "photourl"
#define LIVEROOM_GETUSERINFO_AGE                        "age"
#define LIVEROOM_GETUSERINFO_COUNTRY                    "country"
#define LIVEROOM_GETUSERINFO_USERLEVEL                  "user_level"
#define LIVEROOM_GETUSERINFO_ISONLINE                   "is_online"
#define LIVEROOM_GETUSERINFO_ISANCHOR                   "is_anchor"
#define LIVEROOM_GETUSERINFO_LEFTCREDIT                 "left_credit"
#define LIVEROOM_GETUSERINFO_ANCHORINFO                 "anchor_info"
#define LIVEROOM_GETUSERINFO_ANCHORINFO_ADDRESS                 "address"
#define LIVEROOM_GETUSERINFO_ANCHORINFO_ANCHORTYPE              "anchor_type"
#define LIVEROOM_GETUSERINFO_ANCHORINFO_ISLIVE                  "is_live"
#define LIVEROOM_GETUSRRINFO_ANCHORINFO_INTRODUCTION            "introduction"
#define LIVEROOM_GETUSRRINFO_ANCHORINFO_ROOM_PHOTOURL           "room_photourl"

/* 6.11.获取分享链接 */
/* 接口路径 */
#define LIVEROOM_GETSHARELINK                                 "/nodeApi/getShareLink"

/**
 *  请求
 */
#define LIVEROOM_GETSHARELINK_SHAREUSERID                       "shareuserid"
#define LIVEROOM_GETSHARELINK_ANCHORID                          "anchorid"
#define LIVEROOM_GETSHARELINK_SHARETYPE                         "sharetype"
#define LIVEROOM_GETSHARELINK_SHAREPAGETYPE                     "sharepagetype"

/**
 *  返回
 */
#define LIVEROOM_GETSHARELINK_SHAREID                           "shareid"
#define LIVEROOM_GETSHARELINK_SHARELINK                         "sharelink"

/* 6.12.分享链接成功 */
/* 接口路径 */
#define LIVEROOM_SETSHARESUC                                 "/nodeApi/setShareSuc"

/**
 *  请求
 */
#define LIVEROOM_SETSHARESUC_SHAREID                        "shareid"

/* 6.13.提交Feedback（仅独立） */
/* 接口路径 */
#define LIVEROOM_SUBMITFEEDBACK                                 "/man/v1/submitFeedback"

/**
 *  请求
 */
#define LIVEROOM_SUBMITFEEDBACK_MAIL                        "mail"
#define LIVEROOM_SUBMITFEEDBACK_MSG                         "msg"

/* 6.14.获取个人信息（仅独立） */
/* 接口路径 */
#define LIVEROOM_GETMANBASEINFO                                 "/man/v1/getManBaseInfo"

/**
 *  返回
 */
#define LIVEROOM_GETMANBASEINFO_USERID                          "userid"
#define LIVEROOM_GETMANBASEINFO_NICKNAME                        "nickname"
#define LIVEROOM_GETMANBASEINFO_NICKNAMESTATUS                  "nickname_status"
#define LIVEROOM_GETMANBASEINFO_PHOTOURL                        "photourl"
#define LIVEROOM_GETMANBASEINFO_PHOTOSTATUS                     "photo_status"
#define LIVEROOM_GETMANBASEINFO_BIRTHDAY                        "birthday"
#define LIVEROOM_GETMANBASEINFO_USERLEVEL                       "user_level"
#define LIVEROOM_GETMANBASEINFO_GENDER                          "gender"
#define LIVEROOM_GETMANBASEINFO_USERTYPE                        "user_type"
#define LIVEROOM_GETMANBASEINFO_GAUID                           "ga_uid"

/* 6.15.设置个人信息（仅独立） */
/* 接口路径 */
#define LIVEROOM_SETMANBASEINFO                                 "/man/v1/setManBaseInfo"

/**
 *  请求
 */
#define LIVEROOM_SETMANBASEINFO_NICKNAME                          "nickname"


/* 6.16.提交crash dump文件（仅独立提交） */
/* 接口路径 */
#define LIVEROOM_CRASHFILE                                 "/App/other/crash_file"

/**
 *  请求
 */
#define LIVEROOM_CRASHFILE_DEVICEID                          "deviceId"
#define LIVEROOM_CRASHFILE_CRASHFILE                         "crashfile"

/* 6.17.获取主界面未读数量 */
/* 接口路径 */
#define LIVEROOM_GETTOTALNOREADNUM                                "/pman/common/api/getTotalUnreadNum"

/**
 *  返回
 */
#define LIVEROOM_GETTOTALNOREADNUM_SHOWTICKETUNREADNUM           "show_ticket_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_LOIUNREADNUM                   "loi_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_EMFUNREADNUM                   "emf_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_PRIVATEMESSAGEUNREADNUM        "private_message_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_BOOKINGUNREADNUM               "booking_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_BACKPACKUNREADNUM              "backpack_unread_num"
#define LIVEROOM_GETTOTALNOREADNUM_SAYHIRESPONSEUNREADNUM         "say_hi_response_unread_num"

/* 6.18.查询个人信息 */
/* 接口路径 */
#define LIVEROOM_MYPROFILE                              "/member/myprofile"

/**
 *  返回
 */
/* 个人信息 */
#define LIVEROOM_MYPROFILE_MANID            "manid"
#define LIVEROOM_MYPROFILE_FIRSTNAME        "firstname"
#define LIVEROOM_MYPROFILE_LASTNAME         "lastname"
#define LIVEROOM_MYPROFILE_BIRTHDAY         "birthday"
#define LIVEROOM_MYPROFILE_AGE               "age"
#define LIVEROOM_MYPROFILE_GENDER            "gender"
#define LIVEROOM_MYPROFILE_EMAIL            "email"
#define LIVEROOM_MYPROFILE_COUNTRY            "country"
#define LIVEROOM_MYPROFILE_MARRY            "marry"
#define LIVEROOM_MYPROFILE_WEIGHT             "weight"
#define LIVEROOM_MYPROFILE_HEIGHT            "height"
#define LIVEROOM_MYPROFILE_SMOKE            "smoke"
#define LIVEROOM_MYPROFILE_DRINK            "drink"
#define LIVEROOM_MYPROFILE_LANGUAGE        "language"
#define LIVEROOM_MYPROFILE_RELIGION        "religion"
#define LIVEROOM_MYPROFILE_EDUCATION        "education"
#define LIVEROOM_MYPROFILE_PROFESSION        "profession"
#define LIVEROOM_MYPROFILE_ETHNICITY        "ethnicity"
#define LIVEROOM_MYPROFILE_INCOME            "income"
#define LIVEROOM_MYPROFILE_CHILDREN        "children"
#define LIVEROOM_MYPROFILE_JJ                "jj"
#define LIVEROOM_MYPROFILE_RS_STATUS        "rs_status"
#define LIVEROOM_MYPROFILE_RS_CONTENT        "rs_content"
#define LIVEROOM_MYPROFILE_ADDRESS1        "address1"
#define LIVEROOM_MYPROFILE_ADDRESS2        "address2"
#define LIVEROOM_MYPROFILE_CITY            "city"
#define LIVEROOM_MYPROFILE_PROVINCE        "province"
#define LIVEROOM_MYPROFILE_ZIPCODE            "zipcode"
#define LIVEROOM_MYPROFILE_TELEPHONE        "telephone"
#define LIVEROOM_MYPROFILE_TELEPHONE_CC    "telephone_cc"
#define LIVEROOM_MYPROFILE_FAX                "fax"
#define LIVEROOM_MYPROFILE_ALTERNATE_EMAIL    "alternate_email"
#define LIVEROOM_MYPROFILE_MONEY            "money"
#define LIVEROOM_MYPROFILE_V_ID            "v_id"
#define LIVEROOM_MYPROFILE_PHOTO            "photo"
#define LIVEROOM_MYPROFILE_PHOTOURL        "photoURL"
#define LIVEROOM_MYPROFILE_INTEGRAL        "integral"
#define LIVEROOM_MYPROFILE_MOBILE            "mobile"
#define LIVEROOM_MYPROFILE_MOBILE_CC        "mobile_cc"
#define LIVEROOM_MYPROFILE_MOBILE_STATUS    "mobile_status"
#define LIVEROOM_MYPROFILE_LANDLINE        "landline"
#define LIVEROOM_MYPROFILE_LANDLINE_CC        "landline_cc"
#define LIVEROOM_MYPROFILE_LANDLINE_AC        "landline_ac"
#define LIVEROOM_MYPROFILE_LANDLINE_STATUS    "landline_status"
#define LIVEROOM_MYPROFILE_INTERESTS        "interests"
#define LIVEROOM_MYPROFILE_ZODIAC          "zodiac"


/* 6.19.修改个人信息 */
/* 接口路径 */
#define LIVEROOM_UPDATEPRO                              "/member/updatepro"

#define LIVEROOM_UPDATEPRO_JJRESULT                     "jj_result"

/* 6.20.检查客户端更新 */
/* 接口路径 */
#define LIVEROOM_VERSIONCHECK                              "/other/versioncheck"

/*
 请求
 */
#define LIVEROOM_VERSIONCHECK_CURRVERSION                   "currVersion"

/*
 返回
 */
#define LIVEROOM_VERSIONCHECK_VERCODE        "versionCode"
#define LIVEROOM_VERSIONCHECK_VERNAME        "versionName"
#define LIVEROOM_VERSIONCHECK_VERDESC        "versionDesc"
#define LIVEROOM_VERSIONCHECK_FORCEUPDATE    "forceUpdate"
#define LIVEROOM_VERSIONCHECK_URL            "url"
#define LIVEROOM_VERSIONCHECK_STOREURL       "store_url"
#define LIVEROOM_VERSIONCHECK_PUBTIME        "pubtime"
#define LIVEROOM_VERSIONCHECK_CHECKTIME      "checktime"

/* 6.21.开始编辑简介触发计时 */
/* 接口路径 */
#define LIVEROOM_INTROEDIT                              "/member/intro_edit"

/* 6.22.收集手机硬件信息 */
/* 接口路径 */
#define LIVEROOM_PHONEINFO                              "/other/phoneinfo"

/**
 *  请求
 */
#define LIVEROOM_PHONEINFO_MODEL                        "model"
#define LIVEROOM_PHONEINFO_MANUFACTURER                 "manufacturer"
#define LIVEROOM_PHONEINFO_OS                           "os"
#define LIVEROOM_PHONEINFO_RELEASE                      "release"
#define LIVEROOM_PHONEINFO_SDK                          "sdk"
#define LIVEROOM_PHONEINFO_DENSITY                      "density"
#define LIVEROOM_PHONEINFO_DENSITYDPI                   "densityDpi"
#define LIVEROOM_PHONEINFO_WIDTH                        "width"
#define LIVEROOM_PHONEINFO_HEIGHT                       "height"
#define LIVEROOM_PHONEINFO_DATA                         "data"
#define LIVEROOM_PHONEINFO_VERSIONCODE                  "versionCode"
#define LIVEROOM_PHONEINFO_VERSIONNAME                  "versionName"
#define LIVEROOM_PHONEINFO_PHONETYPE                    "PhoneType"
#define LIVEROOM_PHONEINFO_NETWORKTYPE                  "NetworkType"
#define LIVEROOM_PHONEINFO_LANGUAGE                     "language"
#define LIVEROOM_PHONEINFO_COUNTRY                      "country"
#define LIVEROOM_PHONEINFO_SITEID                       "siteid"
#define LIVEROOM_PHONEINFO_ACTION                       "action"
#define LIVEROOM_PHONEINFO_LINENUMBER                   "line1Number"
#define LIVEROOM_PHONEINFO_DEVICEID                     "deviceId"
#define LIVEROOM_PHONEINFO_SIMOPERATORNAME              "SimOperatorName"
#define LIVEROOM_PHONEINFO_SIMOPERATOR                  "SimOperator"
#define LIVEROOM_PHONEINFO_SIMCOUNTRYISO                "simCountryIso"
#define LIVEROOM_PHONEINFO_SIMSTATE                     "SimState"


/* ########################   支付 模块  ######################## */

/* 7.1.获取买点信息（仅独立）（仅iOS） */
/* 接口路径 */
#define LIVEROOM_PREMIUM_MEMBERSHIP                                 "/App/member/premium_membership"

/**
 *  请求
 */
#define LIVEROOM_PREMIUM_MEMBERSHIP_SITEID                       "siteid"


/**
 *  返回
 */
#define LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS                        "products"
#define LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_ID                             "id"
#define LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_NAME                           "name"
#define LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_PRICE                          "price"
#define LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_ICON                           "icon"
#define LIVEROOM_PREMIUM_MEMBERSHIP_DESC                            "desc"
#define LIVEROOM_PREMIUM_MEMBERSHIP_MORE                            "more"

/* 7.2.获取订单信息（仅独立）（仅iOS） */
/* 接口路径 */
#define LIVEROOM_ORDER_IOSPAY                                 "/App/member/ios_pay"

/**
 *  请求
 */
#define LIVEROOM_ORDER_IOSPAY_MANID                         "manid"
#define LIVEROOM_ORDER_IOSPAY_SID                           "sid"
#define LIVEROOM_ORDER_IOSPAY_NUMBER                        "number"
#define LIVEROOM_ORDER_IOSPAY_SITED                         "siteid"

/**
 *  返回
 */
#define LIVEROOM_ORDER_IOSPAY_ORDERNO                           "orderno"
#define LIVEROOM_ORDER_IOSPAY_PRODUCTID                         "product_id"

/* 7.3.验证订单信息（仅独立）（仅iOS） */
/* 接口路径 */
#define LIVEROOM_ORDER_IOSCALLBACK                                 "/App/member/ios_callback"

/**
 *  请求
 */
#define LIVEROOM_ORDER_IOSCALLBACK_MANID                            "manid"
#define LIVEROOM_ORDER_IOSCALLBACK_SID                              "sid"
#define LIVEROOM_ORDER_IOSCALLBACK_RECEIPT                          "receipt"
#define LIVEROOM_ORDER_IOSCALLBACK_ORDERNO                          "orderno"
#define LIVEROOM_ORDER_IOSCALLBACK_CODE                             "code"


/* 7.4.获取订单信息 (仅iOS） */
/* 接口路径 */
#define LIVEROOM_IOSPAY                                 "/member/ios_pay"

/**
 *  请求
 */
#define LIVEROOM_IOSPAY_MANID                         "manid"
#define LIVEROOM_IOSPAY_SID                           "sid"
#define LIVEROOM_IOSPAY_NUMBER                        "number"

/**
 *  返回
 */
#define LIVEROOM_IOSPAY_ORDERNO                           "orderno"
#define LIVEROOM_IOSPAY_PRODUCTID                         "product_id"

/* 7.5.验证订单信息（仅iOS） */
/* 接口路径 */
#define LIVEROOM_IOSCALLBACK                                 "/member/ios_callback"

/**
 *  请求
 */
#define LIVEROOM_IOSCALLBACK_MANID                            "manid"
#define LIVEROOM_IOSCALLBACK_SID                              "sid"
#define LIVEROOM_IOSCALLBACK_RECEIPT                          "receipt"
#define LIVEROOM_IOSCALLBACK_ORDERNO                          "orderno"
#define LIVEROOM_IOSCALLBACK_CODE                             "code"

/* 7.6.获取产品列表（仅iOS） */
/* 接口路径 */
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP                                 "/member/premium_membership"

/**
 *  请求
 */
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_SITEID                       "siteid"


/**
 *  返回
 */
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_TITLE                           "title"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_SUBTITLE                        "subtitle"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_PRODUCTS                        "products"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_PRODUCTS_ID                          "id"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_PRODUCTS_NAME                        "name"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_PRODUCTS_PRICE                       "price"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_DESC                            "desc"
#define LIVEROOM_IOSPREMIUM_MEMBERSHIP_MORE                            "more"

/* 7.7.获取h5买点页面URL（仅Android */
/* 接口路径 */
#define LIVEROOM_MOBILEPAYGOTO_PATH                            "/user/mobilePayGoto"

/**
 *  请求
 */
#define LIVEROOM_MOBILEPAYGOTO_url                              "url"
#define LIVEROOM_MOBILEPAYGOTO_SITEID                           "siteid"
#define LIVEROOM_MOBILEPAYGOTO_ORDERTYPE                        "orderType"
#define LIVEROOM_MOBILEPAYGOTO_CLICKFROM                        "clickFrom"
#define LIVEROOM_MOBILEPAYGOTO_NUMBER                           "number"

/**
 *  返回
 */
#define LIVEROOM_MOBILEPAYGOTO_REDIRECT                         "redirect"

/* ########################   多人互动模块  ######################## */
/* 8.1.获取可邀请多人互动的主播列表 */
/* 接口路径 */
#define LIVEROOM_GETCANHANGOUTANCHORLIST                                "/man/v1/getCanHangoutAnchorList"

/**
 *  请求
 */
#define LIVEROOM_GETCANHANGOUTANCHORLIST_TYPE                           "type"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_ANCHORID                       "anchor_id"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_START                          "start"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_STEP                           "step"

/**
 *  返回
 */
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST                           "list"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ANCHORID                              "anchor_id"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_NICKNAME                              "nickname"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_PHOTOURL                              "photourl"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AVATAR_IMG                            "avatar_img"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AGE                                   "age"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_COUNTRY                               "country"
#define LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ONLINESTATUS                          "online_status"

/* 8.2.发起多人互动邀请*/
/* 接口路径 */
#define LIVEROOM_SENDINVITATIONHANGOUT                                "/man/v1/sendInvitationHangout"

/**
 *  请求
 */
#define LIVEROOM_SENDINVITATIONHANGOUT_ROOMID                         "room_id"
#define LIVEROOM_SENDINVITATIONHANGOUT_ANCHORID                       "anchor_id"
#define LIVEROOM_SENDINVITATIONHANGOUT_RECOMMENDID                    "recommend_id"
#define LIVEROOM_SENDINVITATIONHANGOUT_CREATEONLY                     "create_only"

/**
 *  返回
 */
#define LIVEROOM_SENDINVITATIONHANGOUT_INVITEID                        "invite_id"
#define LIVEROOM_SENDINVITATIONHANGOUT_EXPIRE                          "expire"

/* 8.3.取消多人互动邀请*/
/* 接口路径 */
#define LIVEROOM_CANCELHANGOUTINVIT                                     "/man/v1/cancelHangoutInvit"

/**
 *  请求
 */
#define LIVEROOM_CANCELHANGOUTINVIT_INVITEID                            "invite_id"

/* 8.4.获取多人互动邀请状态*/
/* 接口路径 */
#define LIVEROOM_GETHANGOUTINVITSTATUS                                   "/share/v1/getHangoutInvitStatus"

/**
 *  请求
 */
#define LIVEROOM_GETHANGOUTINVITSTATUS_INVITEID                          "invite_id"

/**
 *  返回
 */
#define LIVEROOM_GETHANGOUTINVITSTATUS_STATUS                            "status"
#define LIVEROOM_GETHANGOUTINVITSTATUS_ROOMID                            "roomid"
#define LIVEROOM_GETHANGOUTINVITSTATUS_EXPIRE                            "expire"

/* 8.5.同意主播敲门请求*/
/* 接口路径 */
#define LIVEROOM_DEALKNOCKREQUEST                                       "/man/v1/dealKnockRequest"

/**
 *  请求
 */
#define LIVEROOM_DEALKNOCKREQUEST_KNOCKID                               "knock_id"

/* 8.6.获取多人互动直播间可发送的礼物列表*/
/* 接口路径 */
#define LIVEROOM_HANGOUTGIFTLIST                                       "/man/v1/hangoutGiftList"

/**
 *  请求
 */
#define LIVEROOM_HANGOUTGIFTLIST_ROOMID                                "roomid"

/**
 *  返回
 */
#define LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST                            "buyfor_list"
#define LIVEROOM_HANGOUTGIFTLIST_NORMALLIST                            "normal_list"
#define LIVEROOM_HANGOUTGIFTLIST_CELEBRATIONLIST                       "celebration_list"
#define LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID                                              "id"

/* 8.7.获取Hang-out列表*/
/* 接口路径 */
#define LIVEROOM_GETRECENTCONTACEANCHOR                                 "/pman/hangout/api/getHtOnlineAnchor"


/**
 *  返回
 */
//#define LIVEROOM_GETRECENTCONTACEANCHOR_LIST                             "list"
#define LIVEROOM_GETRECENTCONTACEANCHOR_ANCHORID                         "anchor_id"
#define LIVEROOM_GETRECENTCONTACEANCHOR_NICKNAME                         "nickname"
#define LIVEROOM_GETRECENTCONTACEANCHOR_AVATARIMG                        "avatar_img"
#define LIVEROOM_GETRECENTCONTACEANCHOR_COVERIMG                         "cover_img"
#define LIVEROOM_GETRECENTCONTACEANCHOR_ONLINESTATUS                     "online_status"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSNUM                       "friends_num"
#define LIVEROOM_GETRECENTCONTACEANCHOR_INVITATION_MSG                   "invitation_msg"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO                      "friends_info"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_ANCHORID             "anchor_id"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_AVATARIMG            "avatar_img"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_COVERIMG             "cover_img"
#define LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_NICKNAME             "nickname"

/* 8.8.获取指定主播的Hang-out好友列表*/
/* 接口路径 */
#define LIVEROOM_GETHANGOUTFRIENDS                                      "/pman/hangout/api/getHangoutFriends"

/**
 *  请求
 */
#define LIVEROOM_GETHANGOUTFRIENDS_ANCHORID                              "anchorid"

/* 8.9.自动邀请Hangout直播邀請展示條件*/
/* 接口路径 */
#define LIVEROOM_AUTOINVITATIONHANGOUTLIVEDISPLAY                        "/man/v1/autoInvitationHangoutLiveDisplay"

/**
 *  请求
 */
#define LIVEROOM_AUTOINVITATIONHANGOUTLIVEDISPLAY_ANCHORID               "anchorid"
#define LIVEROOM_AUTOINVITATIONHANGOUTLIVEDISPLAY_IS_AUTO                "is_auto"

/* 8.10.自动邀请hangout点击记录*/
/* 接口路径 */
#define LIVEROOM_AUTOINVITATIONCLICKLOG                                  "/man/v1/autoInvitationHangoutClickLog"

/**
 *  请求
 */
#define LIVEROOM_AUTOINVITATIONCLICKLOG_ANCHORID                          "anchorid"
#define LIVEROOM_AUTOINVITATIONCLICKLOG_IS_AUTO                            "is_auto"

/* 8.11.获取当前会员Hangout直播状态*/
/* 接口路径 */
#define LIVEROOM_GETHANGOUTATUS                                         "/pman/hangout/api/getHangoutStatus"

/**
 *  返回
 */
#define LIVEROOM_GETHANGOUTATUS_LIVE_ROOM_ID                           "live_room_id"
#define LIVEROOM_GETHANGOUTATUS_LIVEROOMANCHOR                         "liveroomanchor"

/* 9.1.获取节目列表未读 */
/* 接口路径 */
#define GETNOREADNUMPROGRAM_PATH                                        "/man/v1/noreadShowNum"

/**
 *  返回
 */
#define GETNOREADNUMPROGRAM_NUM                                          "num"

/* 9.2.获取节目列表 */
/* 接口路径 */
#define GETPROGRAMLIST_PATH                                                "/man/v1/showList"

/**
 *  请求
 */
#define GETPROGRAMLIST_SORTTYPE                                             "sort_type"
#define GETPROGRAMLIST_START                                                "start"
#define GETPROGRAMLIST_STEP                                                 "step"

/**
 *  返回
 */
#define  GETPROGRAMLIST_LIST                                                "list"

/* 9.3.购买*/
/* 接口路径 */
#define BUYPROGRAM_PATH                                                     "/man/v1/buyTicket"



/**
 *  请求
 */
#define BUYPROGRAM_LIVESHOWID                                               "live_show_id"

/**
 *  返回
 */
#define BUYPROGRAM_LEFTCREDIT                                               "left_credit"

/* 9.4.关注/取消关注关注节目*/
/* 接口路径 */
#define CHANGEFAVOURITE_PATH                                                "/man/v1/followShow"

/**
 *  请求
 */
#define CHANGEFAVOURITE_LIVESHOWID                                           "live_show_id"
#define CHANGEFAVOURITE_CANCEL                                               "cancel"

/* 9.5.获取可进入的节目信息*/
/* 接口路径 */
#define GETSHOWROOMINFO_PATH                                                "/man/v1/getShowRoomInfo"

/**
 *  请求
 */
#define GETSHOWROOMINFO_LIVESHOWID                                           "live_show_id"

/**
 *  返回
 */
#define GETSHOWROOMINFO_SHOWINFO                                            "show_info"
#define GETSHOWROOMINFO_ROOMID                                              "room_id"


/* 9.6.获取节目推荐列表 */
/* 接口路径 */
#define SHOWLISTWITHANCHORID_PATH                                                "/man/v1/showListWithAnchorId"

/**
 *  请求
 */
#define SHOWLISTWITHANCHORID_ANCHORID                                             "anchor_id"
#define SHOWLISTWITHANCHORID_START                                                "start"
#define SHOWLISTWITHANCHORID_STEP                                                 "step"
#define SHOWLISTWITHANCHORID_SORTTYPE                                             "sort_type"

/**
 *  返回
 */
#define  SHOWLISTWITHANCHORI_LIST                                                "list"

/* 10.1.获取私信联系人列表 */
/* 接口路径 */
#define GETPRIVATEMSGFRIENDLIST_PATH                                              "/share/v1/getPrivateMsgFriendList"

/**
 *  返回
 */
#define GETPRIVATEMSGFRIENDLIST_DBTIME                                              "dbtime"
#define GETPRIVATEMSGFRIENDLIST_LIST                                                "list"
#define GETPRIVATEMSGFRIENDLIST_LIST_USERID                                                     "user_id"
#define GETPRIVATEMSGFRIENDLIST_LIST_NICKNAME                                                   "nick_name"
#define GETPRIVATEMSGFRIENDLIST_LIST_AVATARIMG                                                  "avatar_img"
#define GETPRIVATEMSGFRIENDLIST_LIST_ONLINESTATUS                                               "online_status"
#define GETPRIVATEMSGFRIENDLIST_LIST_LASTMSG                                                    "last_msg"
#define GETPRIVATEMSGFRIENDLIST_LIST_UPDATETIME                                                 "update_time"
#define GETPRIVATEMSGFRIENDLIST_LIST_UNREADNUM                                                  "unread_num"
#define GETPRIVATEMSGFRIENDLIST_LIST_ANCHORTYPE                                                 "anchor_type"

/* 10.2.获取私信Follow联系人列表 */
/* 接口路径 */
#define GETFOLLOWPRIVATEMSGFRIENDLIST_PATH                                              "/share/v1/getFollowPrivateMsgFriendList"

/**
 *  返回
 */
#define GETFOLLOWPRIVATEMSGFRIENDLIST_LIST                                                "list"


/* 10.3.获取私信消息列表 */
/* 接口路径 */
#define GETPRIVATEMESSAGEHISTORYBYID_PATH                                              "/share/v1/getPrivateMessageHistoryByid"

/**
 *  请求
 */
#define GETPRIVATEMESSAGEHISTORYBYID_TOID                                               "to_id"
#define GETPRIVATEMESSAGEHISTORYBYID_STARTMSGID                                         "start_msgid"
#define GETPRIVATEMESSAGEHISTORYBYID_ORDER                                              "order"
#define GETPRIVATEMESSAGEHISTORYBYID_LIMIT                                              "limit"

/**
 *  返回
 */
#define GETPRIVATEMESSAGEHISTORYBYID_DBTIME                                              "dbtime"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST                                                "list"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_ID                                             "id"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_FROMID                                         "from_id"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_TOID                                           "to_id"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_NICKNAME                                       "nick_name"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_AVATARIMG                                      "avatar_img"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_CONTENT                                        "content"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_ISREAD                                         "is_read"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_ADDTIME                                        "add_time"
#define GETPRIVATEMESSAGEHISTORYBYID_LIST_MSGTYPE                                        "msg_type"

/* 10.4.标记私信已读 */
/* 接口路径 */
#define SETPRIVATEMESSAGEREADED_PATH                                              "/share/v1/setPrivateMessageReaded"

/**
 *  请求
 */
#define SETPRIVATEMESSAGEREADED_TOID                                               "to_id"
#define SETPRIVATEMESSAGEREADED_MSGID                                         "msg_id"

/**
 *  返回
 */
#define SETPRIVATEMESSAGEREADED_RESULT                                             "result"


/* 11.1.获取推送设置 */
/* 接口路径 */
#define GETPUSHCONFIG_PATH                                              "/member/priv/api/getPushConfig"

/**
 *  返回
 */
#define GETPUSHCONFIG_PRIVMSG_PUSH                                            "priv_mb_privmsg_app_push"
#define GETPUSHCONFIG_MAIL_PUSH                                               "priv_mb_mail_app_push"
#define GETPUSHCONFIG_SAYHI_PUSH                                              "priv_mb_say_hi_app_push"


/* 11.2.修改推送设置 */
/* 接口路径 */
#define SETPUSHCONFIG_PATH                                                  "/member/priv/api/setPushConfig"

/**
 *  请求
 */
#define SETPUSHCONFIG_PRIVMSG_PUSH                                                "priv_mb_privmsg_app_push"
#define SETPUSHCONFIG_MAIL_PUSH                                                   "priv_mb_mail_app_push"
#define SETPUSHCONFIG_SAYHI_PUSH                                                  "priv_mb_say_hi_app_push"


/**************************** 意向信及信件 *****************************/
/* 信件公共部分 */
#define LETTER_TAG                              "tag"
#define LETTER_START                            "start"
#define LETTER_STEP                             "step"
#define LETTER_TYPE                             "type"
#define LETTER_LIST                             "list"
#define LETTER_OPP_ANCHOR                       "opp_anchor"
#define LETTER_OPP_USER                         "opp_user"
#define LETTER_ANCHOR_ID                        "anchor_id"
#define LETTER_ANCHOR_AVATAR                    "anchor_avatar"
#define LETTER_ANCHOR_NICKNAME                  "anchor_nickname"
#define LETTER_ANCHOR_COVER                     "anchor_cover"
#define LETTER_AGE                              "age"
#define LETTER_COUNTRY                          "country"
#define LETTER_ONLINE_STATUS                    "online_status"
#define LETTER_IS_IN_PUBLIC                     "is_in_public"
#define LETTER_IS_FOLLOW                        "is_follow"
#define LETTER_LOI_ID                           "loi_id"
#define LETTER_LOI_SEND_TIME                    "loi_send_time"
#define LETTER_LOI_BRIEF                        "loi_brief"
#define LETTER_HAS_IMG                          "has_img"
#define LETTER_HAS_VIDEO                        "has_video"
#define LETTER_HAS_READ                         "has_read"
#define LETTER_HAS_REPLIED                      "has_replied"
#define LETTER_LOI_CONTENT                      "loi_content"
#define LETTER_LOI_IMG_LIST                     "loi_img_list"
#define LETTER_ORIGIN_IMG                       "origin_img"
#define LETTER_SMALL_IMG                        "small_img"
#define LETTER_BLUR_IMG                         "blur_img"
#define LETTER_LOI_VIDEO_LIST                   "loi_video_list"
#define LETTER_COVER                            "cover"
#define LETTER_VIDEO                            "video"
#define LETTER_VIDEO_TOTAL_TIME                 "video_total_time"
#define LETTER_EMF_ID                           "emf_id"
#define LETTER_EMF_SEND_TIME                    "emf_send_time"
#define LETTER_EMF_BRIEF                        "emf_brief"
#define LETTER_EMF_CONTENT                      "emf_content"
#define LETTER_EMF_IMG_LIST                     "emf_img_list"
#define LETTER_RESOURCE_ID                      "resource_id"
#define LETTER_IS_FREE                           "is_free"
#define LETTER_STATUS                           "status"
#define LETTER_DESCRIBE                         "describe"
#define LETTER_EMF_VIDEO_LIST                   "emf_video_list"
#define LETTER_COVER_SMALL_IMG                  "cover_small_img"
#define LETTER_COVER_ORIGIN_IMG                 "cover_origin_img"
#define LETTER_CONTENT                          "content"
#define LETTER_IMG_LIST                         "img_list"
#define LETTER_IMGURL                           "imgUrl"
#define LETTER_COMSUME_TYPE                     "comsume_type"
#define LETTER_FILE                             "file"
#define LETTER_URL                              "url"
#define LETTER_MD5                              "md5"
#define LETTER_CLICK_TYPE                       "click_type"
#define LETTER_VIDEO_URL                        "video_url"

/* 13.1.获取意向信列表 */
/* 接口路径 */
#define LETTER_GETLOILIST                       "/pman/loi/api/getLoiList"

/* 13.2.获取意向信详情 */
/* 接口路径 */
#define LETTER_GETLOIDETAIL                     "/pman/loi/api/getLoiDetail"

/* 13.3.获取信件列表 */
/* 接口路径 */
#define LETTER_GETEMFLIST                        "/pman/emf/api/getEmfList"

/* 13.4.获取信件详情 */
/* 接口路径 */
#define LETTER_GETEMFDETAIL                     "/pman/emf/api/getEmfDetail"

/* 13.5.发送信件 */
/* 接口路径 */
#define LETTER_SENDEMF                           "/pman/emf/api/sendEmf"

/* 13.6.上传附件 */
/* 接口路径 */
#define LETTER_UPLOADLETTERPHOTO                 "/api/?act=uploadManPhoto"

/* 13.7.购买信件附件 */
/* 接口路径 */
#define LETTER_BUYPRIVATEPHOTOVIDEO              "/pman/member/emf/api/buyPrivatePhotoVideo"

/* 13.8.获取发送信件所需的余额 */
/* 接口路径 */
#define LIVEROOM_GETSENDMAILPRICE                       "/member/emf/api/getSendMailPrice"

/**
 *  请求
 */
#define LIVEROOM_GETSENDMAILPRICE_IMGNUMBER            "imgNumber"

/**
 *  返回
 */
#define LIVEROOM_GETSENDMAILPRICE_CREDIT_PRICE                 "credit_price"
#define LIVEROOM_GETSENDMAILPRICE_STAMP_PRICE                  "stamp_price"

/* 13.9.获取主播信件权限 */
/* 接口路径 */
#define LIVEROOM_CANSENDEMF                       "/member/emf/api/canSendEmf"

/**
 *  请求
 */
#define LIVEROOM_CANSENDEMF_ANCHOR_ID                       "anchor_id"

/**
 *  返回
 */
#define LIVEROOM_CANSENDEMF_USER_CAN_SEND                 "user_can_send"
#define LIVEROOM_CANSENDEMF_ANCHOR_CAN_SEND               "anchor_can_send"

/**************************** SayHi *****************************/
/* 14.1.获取主题、文本配置信息 */
/* 接口路径 */
#define LIVEROOM_RESOURCECONFIG                       "/pman/sayHi/api/resourceConfig"

/**
 *  返回
 */
#define LIVEROOM_RESOURCECONFIG_THEMELIST             "theme_list"
#define LIVEROOM_RESOURCECONFIG_THEMELIST_ID                    "id"
#define LIVEROOM_RESOURCECONFIG_THEMELIST_NAME                  "name"
#define LIVEROOM_RESOURCECONFIG_THEMELIST_SMALLIMG              "small_img"
#define LIVEROOM_RESOURCECONFIG_THEMELIST_BIGIMG                "big_img"
#define LIVEROOM_RESOURCECONFIG_TESTLIST              "text_list"
#define LIVEROOM_RESOURCECONFIG_TESTLIST_ID                    "id"
#define LIVEROOM_RESOURCECONFIG_TESTLIST_TEXT                  "text"

/* 14.2.符合发送Say Hi的主播列表 */
/* 接口路径 */
#define LIVEROOM_GETSAYHIANCHORLIST                    "/pman/sayHi/api/getSayHiAnchorList"

/**
 *  返回
 */
#define LIVEROOM_GETSAYHIANCHORLIST_LIST                "list"
#define LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORID           "anchor_id"
#define LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORNICKNAME     "anchor_nickname"
#define LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORCOVER        "anchor_cover"
#define LIVEROOM_GETSAYHIANCHORLIST_LIST_ONLINESTATUS       "online_status"

/* 14.3.检测对某主播是否能发送sayHi */
/* 接口路径 */
#define LIVEROOM_ISCANSENDSAYHI                    "/pman/sayHi/api/isCanSendSayHi"

/**
 *  请求
 */
#define LIVEROOM_ISCANSENDSAYHI_ANCHORID            "anchor_id"

/**
 *  返回
 */
#define LIVEROOM_ISCANSENDSAYHI_RESULT              "result"

/* 14.4.发送sayHi */
/* 接口路径 */
#define LIVEROOM_SENDSAYHI                    "/pman/sayHi/api/sendSayHi"

/**
 *  请求
 */
#define LIVEROOM_SENDSAYHI_ANCHORID             "anchor_id"
#define LIVEROOM_SENDSAYHI_THEMEID              "theme_id"
#define LIVEROOM_SENDSAYHI_TEXTID               "text_id"

/**
 *  返回
 */
#define LIVEROOM_SENDSAYHI_SAYHIID              "say_hi_id"
#define LIVEROOM_SENDSAYHI_ID                   "id"

/* 14.5.All ‘Say Hi’列表 */
/* 接口路径 */
#define LIVEROOM_ALLSAYHILIST                    "/pman/sayHi/api/allSayHiList"

/**
 *  请求
 */
#define LIVEROOM_ALLSAYHILIST_START             "start"
#define LIVEROOM_ALLSAYHILIST_STEP              "step"

/**
 *  返回
 */
#define LIVEROOM_ALLSAYHILIST_TOTALCOUNT        "total_count"
#define LIVEROOM_ALLSAYHILIST_LIST              "list"
#define LIVEROOM_ALLSAYHILIST_LIST_SAYHIID              "say_hi_id"
#define LIVEROOM_ALLSAYHILIST_LIST_ANCHORID             "anchor_id"
#define LIVEROOM_ALLSAYHILIST_LIST_ANCHORNICKNAME       "anchor_nickname"
#define LIVEROOM_ALLSAYHILIST_LIST_ANCHORCOVER          "anchor_cover"
#define LIVEROOM_ALLSAYHILIST_LIST_ANCHORAVATAR         "anchor_avatar"
#define LIVEROOM_ALLSAYHILIST_LIST_ANCHORAGE            "anchor_age"
#define LIVEROOM_ALLSAYHILIST_LIST_RESPONSENUM          "response_num"
#define LIVEROOM_ALLSAYHILIST_LIST_UNREADNUM            "unread_num"

/* 14.6.Waiting for your reply列表 */
/* 接口路径 */
#define LIVEROOM_WAITINGREPLYSAYHILIST              "/sayHi/api/waitingReplySayHiList"

/**
 *  请求
 */
#define LIVEROOM_WAITINGREPLYSAYHILIST_START            "start"
#define LIVEROOM_WAITINGREPLYSAYHILIST_STEP             "step"
#define LIVEROOM_WAITINGREPLYSAYHILIST_SORT             "sort"

/**
 *  返回
 */
#define LIVEROOM_WAITINGREPLYSAYHILIST_TOTALCOUNT        "total_count"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST              "list"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_SAYHIID             "say_hi_id"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSEID          "response_id"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORID            "anchor_id"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORNICKNAME      "anchor_nickname"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORCOVER         "anchor_cover"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAVATAR        "anchor_avatar"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAGE           "anchor_age"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSETIME        "response_time"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_CONTENT             "content"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASIMG              "has_img"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASREAD             "has_read"
#define LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ISFREE              "is_free"

/* 14.7.SayHi详情 */
/* 接口路径 */
#define LIVEROOM_SAYHIDETAIL                "/pman/sayHi/api/sayHiDetail"

/**
 *  请求
 */
#define LIVEROOM_SAYHIDETAIL_SAYHIID            "say_hi_id"
#define LIVEROOM_SAYHIDETAIL_SORT               "sort"

/**
 *  返回
 */
#define LIVEROOM_SAYHIDETAIL_DETAIL             "detail"
#define LIVEROOM_SAYHIDETAIL_DETAIL_SAYHIID             "say_hi_id"
#define LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORID            "anchor_id"
#define LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORNICKNAME      "anchor_nickname"
#define LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORCOVER         "anchor_cover"
#define LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAVATAR        "anchor_avatar"
#define LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAGE           "anchor_age"
#define LIVEROOM_SAYHIDETAIL_DETAIL_SENDTIME            "send_time"
#define LIVEROOM_SAYHIDETAIL_DETAIL_TEXT                "text"
#define LIVEROOM_SAYHIDETAIL_DETAIL_IMG                 "img"
#define LIVEROOM_SAYHIDETAIL_DETAIL_RESPONSENUM         "response_num"
#define LIVEROOM_SAYHIDETAIL_DETAIL_UNREADNUM           "unread_num"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST       "response_list"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSEID    "response_id"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSETIME  "response_time"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_CONTENT       "content"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_ISFREE        "is_free"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASREAD       "has_read"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASIMG        "has_img"
#define LIVEROOM_SAYHIDETAIL_RESPONSELIST_IMG           "img"

/* 14.8.查看主播回复(扣费) */
/* 接口路径 */
#define LIVEROOM_READRESPONSE                "/pman/sayHi/api/readResponse"

/**
 *  请求
 */
#define LIVEROOM_READRESPONSE_SAYHIID        "say_hi_id"
#define LIVEROOM_READRESPONSE_RESPONSEID     "response_id"

/**
 *  返回
 */
#define LIVEROOM_READRESPONSE_RESULT        "result"

#endif /* REQUESTAUTHORIZATIONDEFINE_H_ */
