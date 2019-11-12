/*
 * GobalFunc.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"


JavaVM* gJavaVM;

CallbackMap gCallbackMap;

JavaItemMap gJavaItemMap;

HttpRequestManager gHttpRequestManager;

HttpRequestManager gDomainRequestManager;

HttpRequestManager gPhotoUploadRequestManager;

HttpRequestManager gConfigRequestManager;

HttpRequestController gHttpRequestController;

LSLiveChatHttpRequestManager gLSLiveChatHttpRequestManager;

LSLiveChatHttpRequestHostManager gLSLiveChatHttpRequestHostManager;

KMutex mTokenMutex;
string gToken;

 string JString2String(JNIEnv* env, jstring str) {
 	string result("");
 	if (NULL != str) {
 		const char* cpTemp = env->GetStringUTFChars(str, 0);
 		result = cpTemp;
 		env->ReleaseStringUTFChars(str, cpTemp);
 	}
 	return result;
 }

void InitEnumHelper(JNIEnv *env, const char *path, jobject *objptr) {
	FileLog("httprequest", "InitEnumHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("httprequest", "InitEnumHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
    if( !constr ) {
    	FileLog("httprequest", "InitEnumHelper( !constr )");
        return;
    }

    jobject obj = env->NewObject(cls, constr, NULL, 0);
    if( !obj ) {
    	FileLog("httprequest", "InitEnumHelper( !obj )");
        return;
    }

    (*objptr) = env->NewGlobalRef(obj);
}

 void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr) {
 	FileLog("httprequest", "InitClassHelper( path : %s )", path);
     jclass cls = env->FindClass(path);
     if( !cls ) {
     	FileLog("httprequest", "InitClassHelper( !cls )");
         return;
     }

     jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
     if( !constr ) {
     	FileLog("httprequest", "InitClassHelper( !constr )");
         constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
         if( !constr ) {
         	FileLog("httprequest", "InitClassHelper( !constr )");
             return;
         }
         return;
     }

     jobject obj = env->NewObject(cls, constr);
     if( !obj ) {
     	FileLog("httprequest", "InitClassHelper( !obj )");
         return;
     }

     (*objptr) = env->NewGlobalRef(obj);
 }


 jclass GetJClass(JNIEnv* env, const char* classPath)
 {
 	jclass jCls = NULL;
 	JavaItemMap::iterator itr = gJavaItemMap.find(classPath);
 	if( itr != gJavaItemMap.end() ) {
 		jobject jItemObj = itr->second;
 		jCls = env->GetObjectClass(jItemObj);
 	}
 	return jCls;
 }

 /* JNI_OnLoad */
 jint JNI_OnLoad(JavaVM* vm, void* reserved) {
 	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::JNI_OnLoad( httprequest.so JNI_OnLoad )");
 	gJavaVM = vm;

 	// Get JNI
 	JNIEnv* env;
 	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                            JNI_VERSION_1_4)) {
 		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::JNI_OnLoad ( could not get JNI env )");
 		return -1;
 	}

 	HttpClient::Init();

 	gLSLiveChatHttpRequestManager.SetHostManager(&gLSLiveChatHttpRequestHostManager);

 	//gHttpRequestManager.SetHostManager(&gHttpRequestHostManager);

 	//	InitEnumHelper(env, COUNTRY_ITEM_CLASS, &gCountryItem);

 	/* 2.认证模块 */
 	jobject jLoginItem;
 	InitClassHelper(env, LOGIN_ITEM_CLASS, &jLoginItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(LOGIN_ITEM_CLASS, jLoginItem));

 	jobject jServerItem;
 	InitClassHelper(env, SERVER_ITEM_CLASS, &jServerItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(SERVER_ITEM_CLASS, jServerItem));

	jobject jLSValidSiteIdItem;
	InitClassHelper(env, LSVALIDSITEID_ITEM_CLASS, &jLSValidSiteIdItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LSVALIDSITEID_ITEM_CLASS, jLSValidSiteIdItem));

	jobject jUserSendMailPrivItem;
	InitClassHelper(env, USERSENDMAILPRIV_ITEM_CLASS, &jUserSendMailPrivItem);
	gJavaItemMap.insert(JavaItemMap::value_type(USERSENDMAILPRIV_ITEM_CLASS, jUserSendMailPrivItem));

	jobject jMailPrivItem;
	InitClassHelper(env, MAILPRIV_ITEM_CLASS, &jMailPrivItem);
	gJavaItemMap.insert(JavaItemMap::value_type(MAILPRIV_ITEM_CLASS, jMailPrivItem));

	jobject jLiveChatPrivItem;
	InitClassHelper(env, LIVECHATPRIV_ITEM_CLASS, &jLiveChatPrivItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHATPRIV_ITEM_CLASS, jLiveChatPrivItem));

	jobject jHangoutPrivItem;
	InitClassHelper(env, HANGOUTPRIV_ITEM_CLASS, &jHangoutPrivItem);
	gJavaItemMap.insert(JavaItemMap::value_type(HANGOUTPRIV_ITEM_CLASS, jHangoutPrivItem));

	jobject jUserPrivItem;
	InitClassHelper(env, USERPRIV_ITEM_CLASS, &jUserPrivItem);
	gJavaItemMap.insert(JavaItemMap::value_type(USERPRIV_ITEM_CLASS, jUserPrivItem));

 	/* 3.直播间模块  */
 	jobject jHotListItem;
 	InitClassHelper(env, HOTLIST_ITEM_CLASS, &jHotListItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(HOTLIST_ITEM_CLASS, jHotListItem));

 	jobject jFollowingListItem;
 	InitClassHelper(env, FOLLOWINGLIST_ITEM_CLASS, &jFollowingListItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(FOLLOWINGLIST_ITEM_CLASS, jFollowingListItem));

 	jobject jValidRoomItem;
 	InitClassHelper(env, VALID_LIVEROOM_ITEM_CLASS, &jValidRoomItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(VALID_LIVEROOM_ITEM_CLASS, jValidRoomItem));

 	jobject jImmediateInviteItem;
 	InitClassHelper(env, IMMEDIATE_INVITE_ITEM_CLASS, &jImmediateInviteItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(IMMEDIATE_INVITE_ITEM_CLASS, jImmediateInviteItem));

 	jobject jAudienceInfoItem;
 	InitClassHelper(env, AUDIENCE_INFO_ITEM_CLASS, &jAudienceInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(AUDIENCE_INFO_ITEM_CLASS, jAudienceInfoItem));

 	jobject jAudienceBaseInfoItem;
 	InitClassHelper(env, AUDIENCE_BASE_INFO_ITEM_CLASS, &jAudienceBaseInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(AUDIENCE_BASE_INFO_ITEM_CLASS, jAudienceBaseInfoItem));

 	jobject jSendableGiftItem;
 	InitClassHelper(env, SENDABLE_GIFT_ITEM_CLASS, &jSendableGiftItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(SENDABLE_GIFT_ITEM_CLASS, jSendableGiftItem));

 	jobject jGiftDetailItem;
 	InitClassHelper(env, GIFT_DETAIL_ITEM_CLASS, &jGiftDetailItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(GIFT_DETAIL_ITEM_CLASS, jGiftDetailItem));

 	jobject jEmotionCategoryItem;
 	InitClassHelper(env, EMOTION_CATEGORY_ITEM_CLASS, &jEmotionCategoryItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(EMOTION_CATEGORY_ITEM_CLASS, jEmotionCategoryItem));

 	jobject jEmotionItem;
 	InitClassHelper(env, EMOTION_ITEM_CLASS, &jEmotionItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(EMOTION_ITEM_CLASS, jEmotionItem));

 	jobject jTalentItem;
 	InitClassHelper(env, TALENT_ITEM_CLASS, &jTalentItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(TALENT_ITEM_CLASS, jTalentItem));

 	jobject jTalentInviteItem;
 	InitClassHelper(env, TALENT_INVITE_ITEM_CLASS, &jTalentInviteItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(TALENT_INVITE_ITEM_CLASS, jTalentInviteItem));


 	jobject jContactItem;
 	InitClassHelper(env, LSCONTACT_ITEM_CLASS, &jContactItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(LSCONTACT_ITEM_CLASS, jContactItem));

 	jobject jPageRecommendItem;
 	InitClassHelper(env, PAGERECOMMEND_ITEM_CLASS, &jPageRecommendItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(PAGERECOMMEND_ITEM_CLASS, jPageRecommendItem));

 	jobject jGiftTypeItem;
 	InitClassHelper(env, GIFTTYPE_ITEM_CLASS, &jGiftTypeItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(GIFTTYPE_ITEM_CLASS, jGiftTypeItem));

 	/* 4.个人信息模块    */
 	jobject jBookInviteItem;
 	InitClassHelper(env, BOOK_INVITE_ITEM_CLASS, &jBookInviteItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_INVITE_ITEM_CLASS, jBookInviteItem));

 	jobject jBookInviteConfigItem;
 	InitClassHelper(env, BOOK_INVITE_CONFIG_ITEM_CLASS, &jBookInviteConfigItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_INVITE_CONFIG_ITEM_CLASS, jBookInviteConfigItem));

 	jobject jBookTimeItem;
 	InitClassHelper(env, BOOK_TIME_ITEM_CLASS, &jBookTimeItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_TIME_ITEM_CLASS, jBookTimeItem));

 	jobject jBookGiftItem;
 	InitClassHelper(env, BOOK_GIFT_ITEM_CLASS, &jBookGiftItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_GIFT_ITEM_CLASS, jBookGiftItem));

 	jobject jBookPhoneItem;
 	InitClassHelper(env, BOOK_PHONE_ITEM_CLASS, &jBookPhoneItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_PHONE_ITEM_CLASS, jBookPhoneItem));

 	jobject jauthorityItem;
    InitClassHelper(env, HTTP_AUTHORITY_ITEM_CLASS, &jauthorityItem);
    gJavaItemMap.insert(JavaItemMap::value_type(HTTP_AUTHORITY_ITEM_CLASS, jauthorityItem));

 	/* 5.背包    */
 	jobject jPackageGiftItem;
 	InitClassHelper(env, PACKAGE_GIFT_ITEM_CLASS, &jPackageGiftItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_GIFT_ITEM_CLASS, jPackageGiftItem));

 	jobject jPackageVoucherItem;
 	InitClassHelper(env, PACKAGE_VOUCHER_ITEM_CLASS, &jPackageVoucherItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_VOUCHER_ITEM_CLASS, jPackageVoucherItem));

 	jobject jPackageRideItem;
 	InitClassHelper(env, PACKAGE_RIDE_ITEM_CLASS, &jPackageRideItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_RIDE_ITEM_CLASS, jPackageRideItem));

	jobject jPackageBindAnchorItem;
	InitClassHelper(env, PACKAGE_BIND_ANCHOR_ITEM_CLASS, &jPackageBindAnchorItem);
	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_BIND_ANCHOR_ITEM_CLASS, jPackageBindAnchorItem));

	jobject jPackageVouchorAvailableItem;
	InitClassHelper(env, PACKAGE_VOUCHOR_AVAILABLE_ITEM_CLASS, &jPackageVouchorAvailableItem);
	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_VOUCHOR_AVAILABLE_ITEM_CLASS, jPackageVouchorAvailableItem));


	jobject jPackageUnreadItem;
	InitClassHelper(env, PACKAGE_VOUCHOR_BACKPACKUNREAD_ITEM_CLASS, &jPackageUnreadItem);
	gJavaItemMap.insert(JavaItemMap::value_type(PACKAGE_VOUCHOR_BACKPACKUNREAD_ITEM_CLASS, jPackageUnreadItem));


 	/* 6.其他    */
 	jobject jConfigItem;
 	InitClassHelper(env, OTHER_CONFIG_ITEM_CLASS, &jConfigItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_CONFIG_ITEM_CLASS, jConfigItem));

 	jobject jAnchorInfoItem;
 	InitClassHelper(env, OTHER_ANCHORINFO_ITEM_CLASS, &jAnchorInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_ANCHORINFO_ITEM_CLASS, jAnchorInfoItem));

 	jobject jUserInfoItem;
 	InitClassHelper(env, OTHER_USERINFO_ITEM_CLASS, &jUserInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_USERINFO_ITEM_CLASS, jUserInfoItem));

	 jobject jMainUnReadNumItem;
	 InitClassHelper(env, OTHER_MAINUNREADNUM_ITEM_CLASS, &jMainUnReadNumItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(OTHER_MAINUNREADNUM_ITEM_CLASS, jMainUnReadNumItem));

	 jobject jLSProfileItem;
	 InitClassHelper(env, OTHER_LSPROFILE_ITEM_CLASS, &jLSProfileItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(OTHER_LSPROFILE_ITEM_CLASS, jLSProfileItem));

	 jobject jLSVersionCheckItem;
	 InitClassHelper(env, OTHER_LSVERSIONCHECK_ITEM_CLASS, &jLSVersionCheckItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(OTHER_LSVERSIONCHECK_ITEM_CLASS, jLSVersionCheckItem));

	 jobject jLSLeftCreditItem;
	 InitClassHelper(env, OTHER_LSLEFTCREDIT_ITEM_CLASS, &jLSLeftCreditItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(OTHER_LSLEFTCREDIT_ITEM_CLASS, jLSLeftCreditItem));


	 /* 8.多人互动 */
	 jobject jHangoutAnchorInfoItem;
	 InitClassHelper(env, HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS, &jHangoutAnchorInfoItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS, jHangoutAnchorInfoItem));

	 jobject jHangoutGiftListItem;
	 InitClassHelper(env, HANGOUT_HANGOUGIFTLIST_ITEM_CLASS, &jHangoutGiftListItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(HANGOUT_HANGOUGIFTLIST_ITEM_CLASS, jHangoutGiftListItem));

	 jobject jHangoutOnlineAnchorItem;
	 InitClassHelper(env, HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS, &jHangoutOnlineAnchorItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS, jHangoutOnlineAnchorItem));

	 jobject jHangoutRoomStatusItem;
	 InitClassHelper(env, HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS, &jHangoutRoomStatusItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS, jHangoutRoomStatusItem));


	 /* 9.节目 */
	 jobject jProgramInfoItem;
	 InitClassHelper(env, PROGRAM_PROGRAMINFO_ITEM_CLASS, &jProgramInfoItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(PROGRAM_PROGRAMINFO_ITEM_CLASS, jProgramInfoItem));


jobject jCoupon;
	InitClassHelper(env, LIVECHAT_COUPON_ITEM_CLASS, &jCoupon);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_COUPON_ITEM_CLASS, jCoupon));

	jobject jGift;
	InitClassHelper(env, LIVECHAT_GIFT_ITEM_CLASS, &jGift);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_GIFT_ITEM_CLASS, jGift));

	jobject jRecord;
	InitClassHelper(env, LIVECHAT_RECORD_ITEM_CLASS, &jRecord);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_RECORD_ITEM_CLASS, jRecord));

	jobject jRecordMutiple;
	InitClassHelper(env, LIVECHAT_RECORD_MUTIPLE_ITEM_CLASS, &jRecordMutiple);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_RECORD_MUTIPLE_ITEM_CLASS, jRecordMutiple));

	jobject jSendPhoto;
	InitClassHelper(env, LIVECHAT_SENDPHOTO_TIME_CLASS, &jSendPhoto);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_SENDPHOTO_TIME_CLASS, jSendPhoto));

	jobject jLCVideoItem;
	InitClassHelper(env, LIVECHAT_LCVIDEO_TIME_CLASS, &jLCVideoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_LCVIDEO_TIME_CLASS, jLCVideoItem));

	jobject jLCMagicConfigItem;
	InitClassHelper(env, LIVECHAT_MAGIC_CONFIG_ITEM_CLASS, &jLCMagicConfigItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_MAGIC_CONFIG_ITEM_CLASS, jLCMagicConfigItem));

	jobject jLCMagicIconItem;
	InitClassHelper(env, LIVECHAT_MAGIC_ICON_TIME_CLASS, &jLCMagicIconItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_MAGIC_ICON_TIME_CLASS, jLCMagicIconItem));

	jobject jLCMagicTypeItem;
	InitClassHelper(env, LIVECHAT_MAGIC_TYPE_TIME_CLASS, &jLCMagicTypeItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_MAGIC_TYPE_TIME_CLASS, jLCMagicTypeItem));

	jobject jLCThemeConfigItem;
	InitClassHelper(env, LIVECHAT_THEME_CONFIG_CLASS, &jLCThemeConfigItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_THEME_CONFIG_CLASS, jLCThemeConfigItem));

	jobject jLCThemeTypeItem;
	InitClassHelper(env, LIVECHAT_THEME_TYPE_CLASS, &jLCThemeTypeItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_THEME_TYPE_CLASS, jLCThemeTypeItem));

	jobject jLCThemeTagItem;
	InitClassHelper(env, LIVECHAT_THEME_TAG_CLASS, &jLCThemeTagItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_THEME_TAG_CLASS, jLCThemeTagItem));

	jobject jLCThemeItem;
	InitClassHelper(env, LIVECHAT_THEME_ITEM_CLASS, &jLCThemeItem);
	gJavaItemMap.insert(JavaItemMap::value_type(LIVECHAT_THEME_ITEM_CLASS, jLCThemeItem));

	jobject jOtherEmotionConfigItem;
	InitClassHelper(env, OTHER_EMOTIONCONFIG_ITEM_CLASS, &jOtherEmotionConfigItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_EMOTIONCONFIG_ITEM_CLASS, jOtherEmotionConfigItem));
	jobject jOtherEmotionConfigTypeItem;
	InitClassHelper(env, OTHER_EMOTIONCONFIG_TYPE_ITEM_CLASS, &jOtherEmotionConfigTypeItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_EMOTIONCONFIG_TYPE_ITEM_CLASS, jOtherEmotionConfigTypeItem));
	jobject jOtherEmotionConfigTagItem;
	InitClassHelper(env, OTHER_EMOTIONCONFIG_TAG_ITEM_CLASS, &jOtherEmotionConfigTagItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_EMOTIONCONFIG_TAG_ITEM_CLASS, jOtherEmotionConfigTagItem));
	jobject jOtherEmotionConfigEmotionItem;
	InitClassHelper(env, OTHER_EMOTIONCONFIG_EMOTION_ITEM_CLASS, &jOtherEmotionConfigEmotionItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_EMOTIONCONFIG_EMOTION_ITEM_CLASS, jOtherEmotionConfigEmotionItem));

	jobject jOtherGetCountItem;
	InitClassHelper(env, OTHER_GETCOUNT_ITEM_CLASS, &jOtherGetCountItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_GETCOUNT_ITEM_CLASS, jOtherGetCountItem));

	/* SayHi */
	jobject jSayHiAllListInfoItem;
	InitClassHelper(env, SAYHI_SAYHIALLLISTINFO_ITEM_CLASS, &jSayHiAllListInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIALLLISTINFO_ITEM_CLASS, jSayHiAllListInfoItem));
	jobject jSayHiAllListItem;
	InitClassHelper(env, SAYHI_SAYHIALLLLIST_ITEM_CLASS, &jSayHiAllListItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIALLLLIST_ITEM_CLASS, jSayHiAllListItem));
	jobject jSayHiDetailAnchorItem;
	InitClassHelper(env, SAYHI_SAYHIDETAILANCHOR_ITEM_CLASS, &jSayHiDetailAnchorItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIDETAILANCHOR_ITEM_CLASS, jSayHiDetailAnchorItem));
	jobject jSayHiDetailItem;
	InitClassHelper(env, SAYHI_SAYHIDETAIL_ITEM_CLASS, &jSayHiDetailItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIDETAIL_ITEM_CLASS, jSayHiDetailItem));
	jobject jSayHiDetailResponseListItem;
	InitClassHelper(env, SAYHI_SAYHIDETAILRESPONSELIST_ITEM_CLASS, &jSayHiDetailResponseListItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIDETAILRESPONSELIST_ITEM_CLASS, jSayHiDetailResponseListItem));
	jobject jSayHiRecommendAnchorItem;
	InitClassHelper(env, SAYHI_SAYHIRECOMMENDANCHOR_ITEM_CLASS, &jSayHiRecommendAnchorItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIRECOMMENDANCHOR_ITEM_CLASS, jSayHiRecommendAnchorItem));
	jobject jSayHiResourceConfigItemm;
	InitClassHelper(env, SAYHI_SAYHIRESOURCECONFIG_ITEM_CLASS, &jSayHiResourceConfigItemm);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIRESOURCECONFIG_ITEM_CLASS, jSayHiResourceConfigItemm));
	jobject jSayHiResponseListInfoItem;
	InitClassHelper(env, SAYHI_SAYHIRESPONSELISTINFO_ITEM_CLASS, &jSayHiResponseListInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIRESPONSELISTINFO_ITEM_CLASS, jSayHiResponseListInfoItem));
	jobject jSayHiResponseListItem;
	InitClassHelper(env, SAYHI_SAYHIRESPONSELIST_ITEM_CLASS, &jSayHiResponseListItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHIRESPONSELIST_ITEM_CLASS, jSayHiResponseListItem));
	jobject jSayHiSendInfoItem;
	InitClassHelper(env, SAYHI_SAYHISENDINFO_ITEM_CLASS, &jSayHiSendInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHISENDINFO_ITEM_CLASS, jSayHiSendInfoItem));
	jobject jSayHiTextItem;
	InitClassHelper(env, SAYHI_SAYHITEXT_ITEM_CLASS, &jSayHiTextItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHITEXT_ITEM_CLASS, jSayHiTextItem));
	jobject jSayHiThemeItem;
	InitClassHelper(env, SAYHI_SAYHITHEME_ITEM_CLASS, &jSayHiThemeItem);
	gJavaItemMap.insert(JavaItemMap::value_type(SAYHI_SAYHITHEME_ITEM_CLASS, jSayHiThemeItem));

	/* 鲜花礼品 */
	jobject jFlowerGiftItem;
	InitClassHelper(env, FLOWERGIFT_FLOWERGIFT_ITEM_CLASS, &jFlowerGiftItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_FLOWERGIFT_ITEM_CLASS, jFlowerGiftItem));

	jobject jStoreFlowerGiftItem;
	InitClassHelper(env, FLOWERGIFT_STROREFLOWERGIFT_ITEM_CLASS, &jStoreFlowerGiftItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_STROREFLOWERGIFT_ITEM_CLASS, jStoreFlowerGiftItem));

	jobject jFlowerGiftBaseInfoItem;
	InitClassHelper(env, FLOWERGIFT_FLOWERGIFTBASEINFO_ITEM_CLASS, &jFlowerGiftBaseInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_FLOWERGIFTBASEINFO_ITEM_CLASS, jFlowerGiftBaseInfoItem));

	jobject jDeliveryItem;
	InitClassHelper(env, FLOWERGIFT_DELIVERY_ITEM_CLASS, &jDeliveryItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_DELIVERY_ITEM_CLASS, jDeliveryItem));

	jobject jRecipientAnchorGiftItem;
	InitClassHelper(env, FLOWERGIFT_RECIPIENTANCHORGIFT_ITEM_CLASS, &jRecipientAnchorGiftItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_RECIPIENTANCHORGIFT_ITEM_CLASS, jRecipientAnchorGiftItem));

	jobject jMyCartItem;
	InitClassHelper(env, FLOWERGIFT_MYCART_ITEM_CLASS, &jMyCartItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_MYCART_ITEM_CLASS, jMyCartItem));

	jobject jCheckoutGiftItem;
	InitClassHelper(env, FLOWERGIFT_CHECKOUTGIFT_ITEM_CLASS, &jCheckoutGiftItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_CHECKOUTGIFT_ITEM_CLASS, jCheckoutGiftItem));

	jobject jGreetingCardItem;
	InitClassHelper(env, FLOWERGIFT_GREETINGCARD_ITEM_CLASS, &jGreetingCardItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_GREETINGCARD_ITEM_CLASS, jGreetingCardItem));

	jobject jCheckoutItem;
	InitClassHelper(env, FLOWERGIFT_CHECKOUT_ITEM_CLASS, &jCheckoutItem);
	gJavaItemMap.insert(JavaItemMap::value_type(FLOWERGIFT_CHECKOUT_ITEM_CLASS, jCheckoutItem));

	/* 广告 */
	jobject jadwomanListAdvertItem;
	InitClassHelper(env, OTHER_ADWOMANLISTADVERT_ITEM_CLASS, &jadwomanListAdvertItem);
	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_ADWOMANLISTADVERT_ITEM_CLASS, jadwomanListAdvertItem));

 	return JNI_VERSION_1_4;
 }

 bool GetEnv(JNIEnv** env, bool* isAttachThread)
 {
 	*isAttachThread = false;
 	jint iRet = JNI_ERR;
 	FileLog(LIVESHOW_HTTP_LOG, "GetEnv() begin, env:%p", env);
 	iRet = gJavaVM->GetEnv((void**) env, JNI_VERSION_1_4);
 	FileLog(LIVESHOW_HTTP_LOG, "GetEnv() gJavaVM->GetEnv(&gEnv, JNI_VERSION_1_4), iRet:%d", iRet);
 	if( iRet == JNI_EDETACHED ) {
 		iRet = gJavaVM->AttachCurrentThread(env, NULL);
 		*isAttachThread = (iRet == JNI_OK);
 	}

	FileLog(LIVESHOW_HTTP_LOG, "GetEnv() end, env:%p, gIsAttachThread:%d, iRet:%d", *env, *isAttachThread, iRet);
 	return (iRet == JNI_OK);
 }

 bool ReleaseEnv(bool isAttachThread)
 {
 	FileLog(LIVESHOW_HTTP_LOG, "ReleaseEnv(bool) begin, isAttachThread:%d", isAttachThread);
 	if (isAttachThread) {
 		gJavaVM->DetachCurrentThread();
 	}
 	FileLog(LIVESHOW_HTTP_LOG, "ReleaseEnv(bool) end");
 	return true;
 }

 /**
  * 根据Task Id 取回Callback object
  * @param Task Id
  */
 jobject getCallbackObjectByTask(long task){
     jobject callBackObject = NULL;
 	gCallbackMap.Lock();
 	CallbackMap::iterator callbackItr = gCallbackMap.Find(task);
 	if(callbackItr != gCallbackMap.End()){
 		callBackObject = callbackItr->second;
 	}
 	gCallbackMap.Erase((long)task);
 	gCallbackMap.Unlock();
 	return callBackObject;
 }

 /**
  * 存储callback object 到全局Map中，用于回调时取回使用
  * @param task  task id
  * @param callBackObject callback对象
  */
 void putCallbackIntoMap(long task, jobject callBackObject){
     gCallbackMap.Lock();
     gCallbackMap.Insert(task, callBackObject);
     gCallbackMap.Unlock();
 }

 /**
  * 存储Http认证Token
  */
 void saveHttpToken(string token){
	 mTokenMutex.lock();
	 gToken = token;
	 mTokenMutex.unlock();
 }

 /**
  * 去除httpToken
  */
 string getHttpToken(){
	 return gToken;
 }
