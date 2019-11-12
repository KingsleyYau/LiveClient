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
#define LSCONTACT_ITEM_CLASS 	        "com/qpidnetwork/livemodule/httprequest/item/ContactItem"
#define PAGERECOMMEND_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/PageRecommendItem"
#define GIFTTYPE_ITEM_CLASS 	        "com/qpidnetwork/livemodule/httprequest/item/GiftTypeItem"

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
#define PACKAGE_VOUCHOR_BACKPACKUNREAD_ITEM_CLASS 	"com/qpidnetwork/livemodule/httprequest/item/PackageUnreadCountItem"

/* 6.其他    */
#define OTHER_CONFIG_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/ConfigItem"
#define OTHER_ANCHORINFO_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/AnchorInfoItem"
#define OTHER_USERINFO_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/UserInfoItem"
#define OTHER_MAINUNREADNUM_ITEM_CLASS		"com/qpidnetwork/livemodule/httprequest/item/MainUnreadNumItem"
#define OTHER_LSPROFILE_ITEM_CLASS		    "com/qpidnetwork/livemodule/httprequest/item/LSProfileItem"
#define OTHER_LSVERSIONCHECK_ITEM_CLASS		"com/qpidnetwork/livemodule/httprequest/item/LSOtherVersionCheckItem"
#define OTHER_LSLEFTCREDIT_ITEM_CLASS		"com/qpidnetwork/livemodule/httprequest/item/LSLeftCreditItem"


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


/* 8.Other模块*/
#define OTHER_EMOTIONCONFIG_ITEM_CLASS    "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigItem"
#define OTHER_EMOTIONCONFIG_TYPE_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigTypeItem"
#define OTHER_EMOTIONCONFIG_TAG_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigTagItem"
#define OTHER_EMOTIONCONFIG_EMOTION_ITEM_CLASS    "com/qpidnetwork/livemodule/livechathttprequest/item/OtherEmotionConfigEmotionItem"
#define OTHER_GETCOUNT_ITEM_CLASS        "com/qpidnetwork/livemodule/livechathttprequest/item/LCOtherGetCountItem"

/* 14.SayHi模块*/
#define SAYHI_SAYHIALLLISTINFO_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/SayHiAllListInfoItem"
#define SAYHI_SAYHIALLLLIST_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/SayHiAllListItem"
#define SAYHI_SAYHIDETAILANCHOR_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/SayHiDetailAnchorItem"
#define SAYHI_SAYHIDETAIL_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/SayHiDetailItem"
#define SAYHI_SAYHIDETAILRESPONSELIST_ITEM_CLASS 	"com/qpidnetwork/livemodule/httprequest/item/SayHiDetailResponseListItem"
#define SAYHI_SAYHIRECOMMENDANCHOR_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/SayHiRecommendAnchorItem"
#define SAYHI_SAYHIRESOURCECONFIG_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/SayHiResourceConfigItem"
#define SAYHI_SAYHIRESPONSELISTINFO_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/SayHiResponseListInfoItem"
#define SAYHI_SAYHIRESPONSELIST_ITEM_CLASS 	        "com/qpidnetwork/livemodule/httprequest/item/SayHiResponseListItem"
#define SAYHI_SAYHISENDINFO_ITEM_CLASS 	            "com/qpidnetwork/livemodule/httprequest/item/SayHiSendInfoItem"
#define SAYHI_SAYHITEXT_ITEM_CLASS 	                "com/qpidnetwork/livemodule/httprequest/item/SayHiTextItem"
#define SAYHI_SAYHITHEME_ITEM_CLASS 	            "com/qpidnetwork/livemodule/httprequest/item/SayHiThemeItem"

/* 15.鲜花礼品模块*/
#define FLOWERGIFT_FLOWERGIFT_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/LSFlowerGiftItem"
#define FLOWERGIFT_STROREFLOWERGIFT_ITEM_CLASS 		    "com/qpidnetwork/livemodule/httprequest/item/LSStoreFlowerGiftItem"
#define FLOWERGIFT_FLOWERGIFTBASEINFO_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/LSFlowerGiftBaseInfoItem"
#define FLOWERGIFT_DELIVERY_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/LSDeliveryItem"
#define FLOWERGIFT_RECIPIENTANCHORGIFT_ITEM_CLASS 	    "com/qpidnetwork/livemodule/httprequest/item/LSRecipientAnchorGiftItem"
#define FLOWERGIFT_MYCART_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/LSMyCartItem"
#define FLOWERGIFT_CHECKOUTGIFT_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/LSCheckoutGiftItem"
#define FLOWERGIFT_GREETINGCARD_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/LSGreetingCardItem"
#define FLOWERGIFT_CHECKOUT_ITEM_CLASS 		            "com/qpidnetwork/livemodule/httprequest/item/LSCheckoutItem"

/* 广告 */
#define OTHER_ADWOMANLISTADVERT_ITEM_CLASS 		        "com/qpidnetwork/livemodule/httprequest/item/LSAdWomanListAdvertItem"

#endif /* CALLBACKITEMANDROIDDEF_H_ */
