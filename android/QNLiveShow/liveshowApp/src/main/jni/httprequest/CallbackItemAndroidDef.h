/*
 * CallbackItemAndroidDef.h
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */

#ifndef CALLBACKITEMANDROIDDEF_H_
#define CALLBACKITEMANDROIDDEF_H_

/* 2.认证模块 */
#define LOGIN_ITEM_CLASS 				"com/qpidnetwork/livemodule/httprequest/item/LoginItem"
#define SERVER_ITEM_CLASS               "com/qpidnetwork/livemodule/httprequest/item/ServerItem"
#define LSVALIDSITEID_ITEM_CLASS        "com/qpidnetwork/livemodule/httprequest/item/LSValidSiteIdItem"
#define USERSENDMAILPRIV_ITEM_CLASS     "com/qpidnetwork/livemodule/httprequest/item/UserSendMailPrivItem"
#define MAILPRIV_ITEM_CLASS             "com/qpidnetwork/livemodule/httprequest/item/MailPrivItem"
#define LIVECHATPRIV_ITEM_CLASS         "com/qpidnetwork/livemodule/httprequest/item/LiveChatPrivItem"
#define HANGOUTPRIV_ITEM_CLASS          "com/qpidnetwork/livemodule/httprequest/item/HangoutPrivItem"
#define USERPRIV_ITEM_CLASS             "com/qpidnetwork/livemodule/httprequest/item/UserPrivItem"

/* 3.直播间模块   */
#define HOTLIST_ITEM_CLASS 				"com/qpidnetwork/livemodule/httprequest/item/HotListItem"
#define FOLLOWINGLIST_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/FollowingListItem"
#define VALID_LIVEROOM_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/ValidLiveRoomItem"
#define IMMEDIATE_INVITE_ITEM_CLASS 	"com/qpidnetwork/livemodule/httprequest/item/ImmediateInviteItem"
#define AUDIENCE_INFO_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/AudienceInfoItem"
#define SENDABLE_GIFT_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/SendableGiftItem"
#define GIFT_DETAIL_ITEM_CLASS 			"com/qpidnetwork/livemodule/httprequest/item/GiftItem"
#define EMOTION_CATEGORY_ITEM_CLASS 	"com/qpidnetwork/livemodule/httprequest/item/EmotionCategory"
#define EMOTION_ITEM_CLASS 				"com/qpidnetwork/livemodule/httprequest/item/EmotionItem"
#define TALENT_ITEM_CLASS 				"com/qpidnetwork/livemodule/httprequest/item/TalentInfoItem"
#define TALENT_INVITE_ITEM_CLASS        "com/qpidnetwork/livemodule/httprequest/item/TalentInviteItem"
#define AUDIENCE_BASE_INFO_ITEM_CLASS 	"com/qpidnetwork/livemodule/httprequest/item/AudienceBaseInfoItem"

/* 4.预约私密     */
#define BOOK_INVITE_ITEM_CLASS 			"com/qpidnetwork/livemodule/httprequest/item/BookInviteItem"
#define BOOK_INVITE_CONFIG_ITEM_CLASS   "com/qpidnetwork/livemodule/httprequest/item/ScheduleInviteConfig"
#define BOOK_TIME_ITEM_CLASS   			"com/qpidnetwork/livemodule/httprequest/item/ScheduleInviteBookTimeItem"
#define BOOK_GIFT_ITEM_CLASS   			"com/qpidnetwork/livemodule/httprequest/item/ScheduleInviteGiftItem"
#define BOOK_PHONE_ITEM_CLASS   		"com/qpidnetwork/livemodule/httprequest/item/ScheduleInviteBookPhoneItem"
#define HTTP_AUTHORITY_ITEM_CLASS   	"com/qpidnetwork/livemodule/httprequest/item/HttpAuthorityItem"


/* 5.背包    */
#define PACKAGE_GIFT_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/PackageGiftItem"
#define PACKAGE_VOUCHER_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/VoucherItem"
#define PACKAGE_RIDE_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/RideItem"
#define PACKAGE_BIND_ANCHOR_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/BindAnchorItem"
#define PACKAGE_VOUCHOR_AVAILABLE_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/VouchorAvailableInfoItem"

/* 6.其他    */
#define OTHER_CONFIG_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/ConfigItem"
#define OTHER_ANCHORINFO_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/AnchorInfoItem"
#define OTHER_USERINFO_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/UserInfoItem"
#define OTHER_MAINUNREADNUM_ITEM_CLASS		"com/qpidnetwork/livemodule/httprequest/item/MainUnreadNumItem"
#define OTHER_LSPROFILE_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/LSProfileItem"
#define OTHER_LSVERSIONCHECK_ITEM_CLASS		"com/qpidnetwork/livemodule/httprequest/item/LSOtherVersionCheckItem"


/* 8.多人互动 */
#define HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/HangoutAnchorInfoItem"
#define HANGOUT_HANGOUGIFTLIST_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/HangoutGiftListItem"
#define HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/HangoutOnlineAnchorItem"
#define HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS 		"com/qpidnetwork/livemodule/httprequest/item/HangoutRoomStatusItem"

/* 9.节目 */
#define PROGRAM_PROGRAMINFO_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/ProgramInfoItem"

/* 5.live chat 模块 */
#define LIVECHAT_COUPON_ITEM_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/Coupon"
#define LIVECHAT_GIFT_ITEM_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/Gift"
#define LIVECHAT_RECORD_ITEM_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/Record"
#define LIVECHAT_RECORD_MUTIPLE_ITEM_CLASS		"com/qpidnetwork/livemodule/livechathttprequest/item/RecordMutiple"
#define LIVECHAT_SENDPHOTO_TIME_CLASS			"com/qpidnetwork/livemodule/livechathttprequest/item/LCSendPhotoItem"
#define LIVECHAT_LCVIDEO_TIME_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/LCVideoItem"
#define LIVECHAT_MAGIC_CONFIG_ITEM_CLASS		"com/qpidnetwork/livemodule/livechathttprequest/item/MagicIconConfig"
#define LIVECHAT_MAGIC_ICON_TIME_CLASS			"com/qpidnetwork/livemodule/livechathttprequest/item/MagicIconItem"
#define LIVECHAT_MAGIC_TYPE_TIME_CLASS			"com/qpidnetwork/livemodule/livechathttprequest/item/MagicIconType"
#define LIVECHAT_THEME_CONFIG_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/ThemeConfig"
#define LIVECHAT_THEME_TYPE_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/ThemeTypeItem"
#define LIVECHAT_THEME_TAG_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/ThemeTagItem"
#define LIVECHAT_THEME_ITEM_CLASS				"com/qpidnetwork/livemodule/livechathttprequest/item/ThemeItem"


///* 8.Other模块*/
#define OTHER_EMOTIONCONFIG_ITEM_CLASS    "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigItem"
#define OTHER_EMOTIONCONFIG_TYPE_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigTypeItem"
#define OTHER_EMOTIONCONFIG_TAG_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigTagItem"
#define OTHER_EMOTIONCONFIG_EMOTION_ITEM_CLASS    "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigEmotionItem"
#define OTHER_GETCOUNT_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/LCOtherGetCountItem"

#endif /* CALLBACKITEMANDROIDDEF_H_ */
