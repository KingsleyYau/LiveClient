/*
 * com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat.cpp
 *
 *  Created on: 2015-4-27
 *      Author: Samson
 */
#include "com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat.h"
#include "GlobalFunc.h"
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include "../livechat/DeviceJniIntToType.h"

class RequestLiveChatControllerCallback : public ILSLiveChatRequestLiveChatControllerCallback
{
public:
	RequestLiveChatControllerCallback() {};
	virtual ~RequestLiveChatControllerCallback() {};
public:
	virtual void OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) override;
	virtual void OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid) override;
	virtual void OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift>& giftList, int totalCount, const string& path, const string& version, const string& errnum, const string& errmsg) override;
	virtual void OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord>& recordList, const string& errnum, const string& errmsg, const string& inviteId) override;
	virtual void OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple>& recordMutiList, const string& errnum, const string& errmsg) override;
	virtual void OnSendPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCLCSendPhotoItem& item) override;
	virtual void OnPhotoFee(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId) override;
	virtual void OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId) override;
	virtual void OnPlayVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnSendGift(long requestId, bool success, const string& errnum, const string& errmsg) override;
	virtual void OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem>& itemList, const string& errnum, const string& errmsg) override;
	virtual void OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnGetVideo(long requestId, bool success, const string& errnum, const string& errmsg, const string& url) override;
	virtual void OnGetMagicIconConfig(long requestId, bool success, const string& errnum, const string& errmsg,const LSLCMagicIconConfig& config) override;
	virtual void OnChatRecharge(long requestId, bool success, const string& errnum, const string& errmsg, double credits) override;
	virtual void OnGetThemeConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCThemeConfig& config) override;
	virtual void OnGetThemeDetail(long requestId, bool success, const string& errnum, const string& errmsg, const ThemeItemList& themeList) override;
	virtual void OnCheckFunctions(long requestId, bool success, const string& errnum, const string& errmsg, const list<string>& flagList) override;
};
RequestLiveChatControllerCallback gRequestLiveChatControllerCallback;
LSLiveChatRequestLiveChatController gLSLiveChatRequestLiveChatController(&gLSLiveChatHttpRequestManager, &gRequestLiveChatControllerCallback);

/******************************************************************************/
void RequestLiveChatControllerCallback::OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) {
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onCheckCoupon( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* turn object to java object here */
	jobject jItem = NULL;
	JavaItemMap::const_iterator itr = gJavaItemMap.find(LIVECHAT_COUPON_ITEM_CLASS);
	if( itr != gJavaItemMap.end() ) {
		jclass cls = env->GetObjectClass(itr->second);
		if( cls != NULL) {
			jmethodID init = env->GetMethodID(cls, "<init>", "("
					"Ljava/lang/String;"
					"I"
					"I"
					"Z"
					"Ljava/lang/String;"
					"I"
					"Ljava/lang/String;"
					"Ljava/lang/String;"
					")V"
					);

			FileLog("httprequest", "LiveChat.Native::onCheckCoupon( GetMethodID <init> : %p )", init);

			jstring juserId = env->NewStringUTF(userId.c_str());
			jstring jfestivalid = env->NewStringUTF(item.festivalid.c_str());
			jstring jcouponid = env->NewStringUTF(item.couponid.c_str());
			jstring jenddate = env->NewStringUTF(item.enddate.c_str());
			jint status = item.status + 1;
			if( init != NULL ) {
				jItem = env->NewObject(cls, init,
						juserId,
						status,
						item.freetrial,
						item.refundflag,
						jfestivalid,
						item.time,
						jcouponid,
						jenddate
						);
				FileLog("httprequest", "LiveChat.Native::onCheckCoupon( NewObject: %p , item.status:%d )", jItem, status);
			}
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jfestivalid);
			env->DeleteLocalRef(jcouponid);
			env->DeleteLocalRef(jenddate);
		}
	}

	/* real callback java */
	//jobject callbackObj = gCallbackMap.Erase(requestId);

	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;";
	signure += "L";
	signure += LIVECHAT_COUPON_ITEM_CLASS;
	signure += ";";
	signure += ")V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnCheckCoupon", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onCheckCoupon( callback : %p, signure : %s )",
			callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jlong jrequestId = requestId;

		FileLog("httprequest", "LiveChat.Native::onCheckCoupon( CallObjectMethod "
				"jItem : %p )", jItem);

		env->CallVoidMethod(callbackObj, callback, jrequestId, success, jerrno, jerrmsg, jItem);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	if( jItem != NULL ) {
		env->DeleteLocalRef(jItem);
	}

	ReleaseEnv(isAttachThread);
}
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    CheckCoupon
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/request/OnCheckCouponCallCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_CheckCoupon
  (JNIEnv *env, jclass, jstring womanId, jint serviceType, jobject callback) {
	jlong requestId = -1;

	const char *cpWomanId = env->GetStringUTFChars(womanId, 0);

	requestId = gLSLiveChatRequestLiveChatController.CheckCoupon(cpWomanId, (LSLiveChatRequestLiveChatController::ServiceType)serviceType);
	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	env->ReleaseStringUTFChars(womanId, cpWomanId);

	return requestId;
}

/******************************************************************************/
void RequestLiveChatControllerCallback::OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid) {
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onUseCoupon( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject callbackObj = gCallbackMap.Erase(requestId);
	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();


	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnLCUseCoupon", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onUseCoupon( callbackCls : %p, callback : %p, signure : %s )",
			callbackCls, callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring juserId = env->NewStringUTF(userId.c_str());
		jstring jcouponid = env->NewStringUTF(couponid.c_str());
		jlong jrequestId = requestId;

		FileLog("httprequest", "LiveChat.Native::onUseCoupon( CallObjectMethod )");

		env->CallVoidMethod(callbackObj, callback, jrequestId, success, jerrno, jerrmsg, juserId, jcouponid);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(juserId);
		env->DeleteLocalRef(jcouponid);
	}

	ReleaseEnv(isAttachThread);
}
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    UseCoupon
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/request/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_UseCoupon
  (JNIEnv *env, jclass, jstring womanId, jint serviceType, jobject callback) {
	jlong requestId = -1;

	const char *cpWomanId = env->GetStringUTFChars(womanId, 0);

	requestId = gLSLiveChatRequestLiveChatController.UseCoupon(cpWomanId, (LSLiveChatRequestLiveChatController::ServiceType)serviceType);
	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	env->ReleaseStringUTFChars(womanId, cpWomanId);

	return requestId;
}

/******************************************************************************/
void RequestLiveChatControllerCallback::OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift>& giftList, int totalCount, const string& path, const string& version, const string& errnum, const string& errmsg)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onQueryChatVirtualGift( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* turn object to java object here */
	jobjectArray jItemArray = NULL;
	JavaItemMap::const_iterator itr = gJavaItemMap.find(LIVECHAT_GIFT_ITEM_CLASS);
	if( itr != gJavaItemMap.end() ) {
		jclass cls = env->GetObjectClass(itr->second);
		jmethodID init = env->GetMethodID(cls, "<init>", "("
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				")V");

		if( giftList.size() > 0 ) {
			jItemArray = env->NewObjectArray(giftList.size(), cls, NULL);
			int i = 0;
			for(list<LSLCGift>::const_iterator itr = giftList.begin(); itr != giftList.end(); itr++, i++) {
				jstring vgid = env->NewStringUTF(itr->vgid.c_str());
				jstring title = env->NewStringUTF(itr->title.c_str());
				jstring price = env->NewStringUTF(itr->price.c_str());

				jobject item = env->NewObject(cls, init,
						vgid,
						title,
						price
						);

				env->SetObjectArrayElement(jItemArray, i, item);

				env->DeleteLocalRef(vgid);
				env->DeleteLocalRef(title);
				env->DeleteLocalRef(price);

				env->DeleteLocalRef(item);
			}
		}
	}

	/* real callback java */
//	jobject callbackObj = gCallbackMap.Erase(requestId);

	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;";
	signure += "[L";
	signure += LIVECHAT_GIFT_ITEM_CLASS;
	signure += ";";
	signure += "I";
	signure += "Ljava/lang/String;";
	signure	+= "Ljava/lang/String;";
	signure += ")V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnQueryChatVirtualGift", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onQueryChatVirtualGift( callback : %p, signure : %s )",
			callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jpath = env->NewStringUTF(path.c_str());
		jstring jversion = env->NewStringUTF(version.c_str());


		FileLog("httprequest", "LiveChat.Native::onQueryChatVirtualGift( CallObjectMethod "
				"jItemArray : %p )", jItemArray);

		env->CallVoidMethod(callbackObj, callback, success, jerrno, jerrmsg,
				jItemArray, totalCount, jpath, jversion);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jpath);
		env->DeleteLocalRef(jversion);
	}

	if( jItemArray != NULL ) {
		env->DeleteLocalRef(jItemArray);
	}

	ReleaseEnv(isAttachThread);
}
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    QueryChatVirtualGift
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnQueryChatVirtualGiftCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_QueryChatVirtualGift
  (JNIEnv *env, jclass, jstring sessionId, jstring userId, jobject callback) {
	jlong requestId = -1;

	const char *cpSessionId = env->GetStringUTFChars(sessionId, 0);
	const char *cpUserId = env->GetStringUTFChars(userId, 0);

	requestId = gLSLiveChatRequestLiveChatController.QueryChatVirtualGift(cpSessionId, cpUserId);
	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	env->ReleaseStringUTFChars(sessionId, cpSessionId);
	env->ReleaseStringUTFChars(userId, cpUserId);

	return requestId;
}

/******************************************************************************/
jobjectArray GetArrayWithListRecord(JNIEnv* env, const list<LSLCRecord>& recordList)
{
	FileLog("httprequest", "LiveChat.Native::GetArrayWithListRecord() begin, recordList.size:%d", recordList.size());
	jobjectArray jItemArray = NULL;
	JavaItemMap::const_iterator itr = gJavaItemMap.find(LIVECHAT_RECORD_ITEM_CLASS);
	if( itr != gJavaItemMap.end() ) {
		jclass cls = env->GetObjectClass(itr->second);
		FileLog("httprequest", "LiveChat.Native::GetArrayWithListRecord() cls:%p", cls);
		if( NULL != cls && recordList.size() > 0 )
		{
			jItemArray = env->NewObjectArray(recordList.size(), cls, NULL);
			int i = 0;
			for(list<LSLCRecord>::const_iterator itr = recordList.begin(); itr != recordList.end(); itr++, i++) {
				jmethodID init = env->GetMethodID(cls, "<init>", "("
						"I"						// toflag
						"I"						// adddate
						"I"						// messageType
						"Ljava/lang/String;"	// textMsg
						"Ljava/lang/String;"	// inviteMsg
						"Ljava/lang/String;"	// warningMsg
						"Ljava/lang/String;"	// emotionId
						"Ljava/lang/String;"	// photoId
						"Ljava/lang/String;"	// photoSendId
						"Ljava/lang/String;"	// photoDesc
						"Z"						// photoCharge
						"Ljava/lang/String;"	// voiceId
						"Ljava/lang/String;"	// voiceType
						"I"						// voiceTime
						"Ljava/lang/String;"	// videoId
						"Ljava/lang/String;"	// videoSendId
						"Ljava/lang/String;"	// videoDesc
						"Z"						// videoCharge
						"Ljava/lang/String;"	// magicIconId
						")V");

				jstring textMsg = env->NewStringUTF(itr->textMsg.c_str());
				jstring inviteMsg = env->NewStringUTF(itr->inviteMsg.c_str());
				jstring warningMsg = env->NewStringUTF(itr->warningMsg.c_str());
				jstring emotionId = env->NewStringUTF(itr->emotionId.c_str());
				jstring photoId = env->NewStringUTF(itr->photoId.c_str());
				jstring photoSendId = env->NewStringUTF(itr->photoSendId.c_str());
				jstring photoDesc = env->NewStringUTF(itr->photoDesc.c_str());
				jstring voiceId = env->NewStringUTF(itr->voiceId.c_str());
				jstring voiceType = env->NewStringUTF(itr->voiceType.c_str());
				jstring videoId = env->NewStringUTF(itr->videoId.c_str());
				jstring videoSendId = env->NewStringUTF(itr->videoSendId.c_str());
				jstring videoDesc = env->NewStringUTF(itr->videoDesc.c_str());
				jstring magicIconId = env->NewStringUTF(itr->magicIconId.c_str());

				jobject item = env->NewObject(cls, init,
						itr->toflag,
						itr->adddate,
						itr->messageType,
						textMsg,
						inviteMsg,
						warningMsg,
						emotionId,
						photoId,
						photoSendId,
						photoDesc,
						itr->photoCharge,
						voiceId,
						voiceType,
						itr->voiceTime,
						videoId,
						videoSendId,
						videoDesc,
						itr->videoCharge,
						magicIconId);

				env->SetObjectArrayElement(jItemArray, i, item);

				env->DeleteLocalRef(textMsg);
				env->DeleteLocalRef(inviteMsg);
				env->DeleteLocalRef(warningMsg);
				env->DeleteLocalRef(emotionId);
				env->DeleteLocalRef(photoId);
				env->DeleteLocalRef(photoSendId);
				env->DeleteLocalRef(photoDesc);
				env->DeleteLocalRef(voiceId);
				env->DeleteLocalRef(voiceType);
				env->DeleteLocalRef(videoId);
				env->DeleteLocalRef(videoSendId);
				env->DeleteLocalRef(videoDesc);
				env->DeleteLocalRef(magicIconId);

				env->DeleteLocalRef(item);
			}
		}
	}

	FileLog("httprequest", "LiveChat.Native::GetArrayWithListRecord() end");
	return jItemArray;
}

void RequestLiveChatControllerCallback::OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord>& recordList, const string& errnum, const string& errmsg, const string& inviteId)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onQueryChatRecord( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);
	FileLog("httprequest", "LiveChat.Native::onQueryChatRecord() recordList.size:%d", recordList.size());

	/* turn object to java object here */
	jobjectArray jItemArray = GetArrayWithListRecord(env, recordList);

	/* real callback java */
	//jobject callbackObj = gCallbackMap.Erase(requestId);

	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;I";
	signure += "[L";
	signure += LIVECHAT_RECORD_ITEM_CLASS;
	signure += ";";
	signure += "Ljava/lang/String;";
	signure += ")V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnQueryChatRecord", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onQueryChatRecord( callback : %p, signure : %s )",
			callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jinviteId = env->NewStringUTF(inviteId.c_str());

		FileLog("httprequest", "LiveChat.Native::onQueryChatRecord( CallObjectMethod "
				"jItemArray : %p )", jItemArray);

		env->CallVoidMethod(callbackObj, callback, success, jerrno, jerrmsg, dbTime, jItemArray, jinviteId);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jinviteId);
	}

	if( jItemArray != NULL ) {
		env->DeleteLocalRef(jItemArray);
	}

	ReleaseEnv(isAttachThread);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    QueryChatRecord
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/request/OnQueryChatRecordCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_QueryChatRecord
  (JNIEnv *env, jclass cls, jstring inviteId, jobject callback)
{
	jlong requestId = -1;

	const char *cpInviteId = env->GetStringUTFChars(inviteId, 0);

	requestId = gLSLiveChatRequestLiveChatController.QueryChatRecord(cpInviteId);
	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	env->ReleaseStringUTFChars(inviteId, cpInviteId);

	return requestId;
}

/******************************************************************************/
void RequestLiveChatControllerCallback::OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple>& recordMutiList, const string& errnum, const string& errmsg)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onQueryChatRecordMutiple( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* turn object to java object here */
	jobjectArray jItemArray = NULL;
	JavaItemMap::const_iterator itr = gJavaItemMap.find(LIVECHAT_RECORD_MUTIPLE_ITEM_CLASS);
	if( itr != gJavaItemMap.end() ) {
		jclass cls = env->GetObjectClass(itr->second);

		if( recordMutiList.size() > 0 ) {
			FileLog("httprequest", "LiveChat.Native::onQueryChatRecordMutiple() recordMutiList.size():%d", recordMutiList.size());
			jItemArray = env->NewObjectArray(recordMutiList.size(), cls, NULL);
			int i = 0;
			for(list<LSLCRecordMutiple>::const_iterator itr = recordMutiList.begin(); itr != recordMutiList.end(); itr++, i++) {
				// recordList
				list<LSLCRecord> recordList = itr->recordList;
				jobjectArray jRecordList = GetArrayWithListRecord(env, recordList);
				// inviteId
				jstring inviteId = env->NewStringUTF(itr->inviteId.c_str());

				/* RecordMutiple item */
				string signure = "(L";
				signure += "java/lang/String;";
				signure += "[L";
				signure += LIVECHAT_RECORD_ITEM_CLASS;
				signure += ";)V";
				jmethodID init = env->GetMethodID(cls, "<init>", signure.c_str());
				// creaet item
				jobject item = env->NewObject(cls, init,
						inviteId,
						jRecordList
						);

				env->SetObjectArrayElement(jItemArray, i, item);

				// release item
				env->DeleteLocalRef(item);
				// release inviteId
				env->DeleteLocalRef(inviteId);
				// release recordList
				if( jRecordList != NULL ) {
					env->DeleteLocalRef(jRecordList);
				}
			}
		}
	}

		/* real callback java */
//	jobject callbackObj = gCallbackMap.Erase(requestId);
	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;I";
	signure += "[L";
	signure += LIVECHAT_RECORD_MUTIPLE_ITEM_CLASS;
	signure += ";";
	signure += ")V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnQueryChatRecordMutiple", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onQueryChatRecordMutiple() callback:%p, signure:%s, callbackObj:%p, callbackCls:%p",
			callback, signure.c_str(), callbackObj, callbackCls);

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());

		FileLog("httprequest", "LiveChat.Native::onQueryChatRecordMutiple( CallObjectMethod "
				"jItemArray : %p )", jItemArray);

		env->CallVoidMethod(callbackObj, callback, success, jerrno, jerrmsg, dbTime, jItemArray);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	if( jItemArray != NULL ) {
		env->DeleteLocalRef(jItemArray);
	}

	ReleaseEnv(isAttachThread);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    QueryChatRecordMutiple
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/request/OnQueryChatRecordMutipleCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_QueryChatRecordMutiple
  (JNIEnv *env, jclass cls, jobjectArray inviteIds, jobject callback)
{
	jlong requestId = -1;

	list<string> inviteIdList;
	if( inviteIds != NULL ) {
		jsize len = env->GetArrayLength(inviteIds);
		for(int i = 0; i < len; i++) {
			jstring inviteId = (jstring)env->GetObjectArrayElement(inviteIds, i);
			const char *cpInviteId = env->GetStringUTFChars(inviteId, 0);
			inviteIdList.push_back(cpInviteId);
			env->ReleaseStringUTFChars(inviteId, cpInviteId);
		}
	}

	requestId = gLSLiveChatRequestLiveChatController.QueryChatRecordMutiple(inviteIdList);
	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

// -------------------------- SendPhoto -------------------------
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    SendPhoto
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnLCSendPhotoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_SendPhoto
  (JNIEnv *env, jclass cls, jstring targetId, jstring inviteId, jstring userId, jstring sid, jstring filePath, jobject callback)
{
	jlong requestId = -1;
	const char *cpTemp = NULL;

	// targetId
	string strTargetId("");
	cpTemp = env->GetStringUTFChars(targetId, 0);
	strTargetId = cpTemp;
	env->ReleaseStringUTFChars(targetId, cpTemp);
	// inviteId
	string strInviteId("");
	cpTemp = env->GetStringUTFChars(inviteId, 0);
	strInviteId = cpTemp;
	env->ReleaseStringUTFChars(inviteId, cpTemp);
	// userId
	string strUserId("");
	cpTemp = env->GetStringUTFChars(userId, 0);
	strUserId = cpTemp;
	env->ReleaseStringUTFChars(userId, cpTemp);
	// sid
	string strSid("");
	cpTemp = env->GetStringUTFChars(sid, 0);
	strSid = cpTemp;
	env->ReleaseStringUTFChars(sid, cpTemp);
	// filePath
	string strFilePath("");
	cpTemp = env->GetStringUTFChars(filePath, 0);
	strFilePath = cpTemp;
	env->ReleaseStringUTFChars(filePath, cpTemp);

	requestId = gLSLiveChatRequestLiveChatController.SendPhoto(strTargetId, strInviteId, strUserId, strSid, strFilePath);
	if (requestId != -1) {
		jobject obj = env->NewGlobalRef(callback);
		gCallbackMap.Insert(requestId, obj);
	}
	else {
		FileLog("httprequest", "LiveChat.Native::SendPhoto() fails. "
			"requestId:%lld, targetId:%s, inviteId:%s, userId:%s, sid:%s, filePath:%s"
			, requestId, strTargetId.c_str(), strInviteId.c_str(), strUserId.c_str(), strSid.c_str(), strFilePath.c_str());
	}

	return requestId;
}

void RequestLiveChatControllerCallback::OnSendPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCLCSendPhotoItem& item)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onSendPhoto( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* create java item */
	jobject jItem = NULL;
	if (success) {
		jclass jItemCls = GetJClass(env, LIVECHAT_SENDPHOTO_TIME_CLASS);
		if(NULL != jItemCls) {
			jmethodID init = env->GetMethodID(jItemCls, "<init>", "("
						"Ljava/lang/String;"	// photoId
						"Ljava/lang/String;"	// sendId
						")V");

			jstring jphotoId = env->NewStringUTF(item.photoId.c_str());
			jstring jsendId = env->NewStringUTF(item.sendId.c_str());
			jItem = env->NewObject(jItemCls, init,
						jphotoId,
						jsendId
						);
			env->DeleteLocalRef(jphotoId);
			env->DeleteLocalRef(jsendId);
		}
	}

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;";
	signure += "L";
	signure += LIVECHAT_SENDPHOTO_TIME_CLASS;
	signure += ";";
	signure += ")V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCSendPhoto", signure.c_str());

	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jlong jlrequestId = requestId;

		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jItem);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	// delete jItem
	if (jItem != NULL) {
		env->DeleteLocalRef(jItem);
	}

	ReleaseEnv(isAttachThread);
}

// -------------------------- PhotoFee -------------------------
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    PhotoFee
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnLCPhotoFeeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_PhotoFee
  (JNIEnv *env, jclass cls, jstring targetId, jstring inviteId, jstring userId, jstring sid, jstring photoId, jobject callback)
{
	jlong requestId = -1;
	const char *cpTemp = NULL;

	// targetId
	string strTargetId("");
	cpTemp = env->GetStringUTFChars(targetId, 0);
	strTargetId = cpTemp;
	env->ReleaseStringUTFChars(targetId, cpTemp);
	// inviteId
	string strInviteId("");
	cpTemp = env->GetStringUTFChars(inviteId, 0);
	strInviteId = cpTemp;
	env->ReleaseStringUTFChars(inviteId, cpTemp);
	// userId
	string strUserId("");
	cpTemp = env->GetStringUTFChars(userId, 0);
	strUserId = cpTemp;
	env->ReleaseStringUTFChars(userId, cpTemp);
	// sid
	string strSid("");
	cpTemp = env->GetStringUTFChars(sid, 0);
	strSid = cpTemp;
	env->ReleaseStringUTFChars(sid, cpTemp);
	// photoId
	string strPhotoId("");
	cpTemp = env->GetStringUTFChars(photoId, 0);
	strPhotoId = cpTemp;
	env->ReleaseStringUTFChars(photoId, cpTemp);

	requestId = gLSLiveChatRequestLiveChatController.PhotoFee(strTargetId, strInviteId, strUserId, strSid, strPhotoId);
	if (requestId != -1) {
		jobject obj = env->NewGlobalRef(callback);
		gCallbackMap.Insert(requestId, obj);
	}
	else {
		FileLog("httprequest", "LiveChat.Native::PhotoFee() fails. "
			"requestId:%lld, targetId:%s, inviteId:%s, userId:%s, sid:%s, photoId:%s"
			, requestId, strTargetId.c_str(), strInviteId.c_str(), strUserId.c_str(), strSid.c_str(), strPhotoId.c_str());
	}

	return requestId;
}

void RequestLiveChatControllerCallback::OnPhotoFee(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onPhotoFee( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCPhotoFee", signure.c_str());

	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jlong jlrequestId = requestId;

		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}

// -------------------------- GetPhoto -------------------------
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetPhoto
 * Signature: (ILjava/lang/String;Ljava/lang/String;IILjava/lang/String;Lcom/qpidnetwork/request/OnLCGetPhotoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetPhoto
  (JNIEnv *env, jclass cls, int toFlag, jstring targetId, jstring userId, jstring sid, jstring photoId, int size, int mode, jstring filePath, jobject callback)
{
	jlong requestId = -1;
	const char *cpTemp = NULL;

	// targetId
	string strTargetId("");
	cpTemp = env->GetStringUTFChars(targetId, 0);
	strTargetId = cpTemp;
	env->ReleaseStringUTFChars(targetId, cpTemp);
	// userId
	string strUserId("");
	cpTemp = env->GetStringUTFChars(userId, 0);
	strUserId = cpTemp;
	env->ReleaseStringUTFChars(userId, cpTemp);
	// sid
	string strSid("");
	cpTemp = env->GetStringUTFChars(sid, 0);
	strSid = cpTemp;
	env->ReleaseStringUTFChars(sid, cpTemp);
	// photoId
	string strPhotoId("");
	cpTemp = env->GetStringUTFChars(photoId, 0);
	strPhotoId = cpTemp;
	env->ReleaseStringUTFChars(photoId, cpTemp);
	// filePath
	string strFilePath("");
	cpTemp = env->GetStringUTFChars(filePath, 0);
	strFilePath = cpTemp;
	env->ReleaseStringUTFChars(filePath, cpTemp);

	requestId = gLSLiveChatRequestLiveChatController.GetPhoto(
			(GETPHOTO_TOFLAG_TYPE)toFlag
			, strTargetId
			, strUserId
			, strSid
			, strPhotoId
			, (GETPHOTO_PHOTOSIZE_TYPE)size
			, (GETPHOTO_PHOTOMODE_TYPE)mode
			, strFilePath);
	if (requestId != -1) {
		jobject obj = env->NewGlobalRef(callback);
		gCallbackMap.Insert(requestId, obj);
	}
	else {
		FileLog("httprequest", "LiveChat.Native::GetPhoto() fails. "
			"requestId:%lld, toFlag:%d, targetId:%s, userId:%s, sid:%s, photoId:%s, size:%d, mode:%d, filePath:%s"
			, requestId, toFlag, strTargetId.c_str(), strUserId.c_str(), strSid.c_str(), strPhotoId.c_str(), size, mode, strFilePath.c_str());
	}
	return requestId;
}

void RequestLiveChatControllerCallback::OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onGetPhoto( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCGetPhoto", signure.c_str());

	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jfilePath = env->NewStringUTF(filePath.c_str());
		jlong jlrequestId = requestId;

		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jfilePath);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jfilePath);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}


// -------------------------- UploadVoice -------------------------
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    UploadVoice
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;ILjava/lang/String;ILjava/lang/String;Lcom/qpidnetwork/request/OnLCUploadVoiceCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_UploadVoice
  (JNIEnv *env, jclass cls, jstring voiceCode, jstring inviteId, jstring mineId, jboolean isMan, jstring userId, jint siteId, jstring fileType, jint voiceLength, jstring filePath, jobject callback)
{
	FileLog("httprequest", "LiveChat.Native::UploadVoice() begin");

	jlong requestId = -1;
	const char *cpTemp = NULL;

	// voiceCode
	string strVoiceCode("");
	cpTemp = env->GetStringUTFChars(voiceCode, 0);
	strVoiceCode = cpTemp;
	env->ReleaseStringUTFChars(voiceCode, cpTemp);
	// inviteId
	string strInviteId("");
	cpTemp = env->GetStringUTFChars(inviteId, 0);
	strInviteId = cpTemp;
	env->ReleaseStringUTFChars(inviteId, cpTemp);
	// mineId
	string strMineId("");
	cpTemp = env->GetStringUTFChars(mineId, 0);
	strMineId = cpTemp;
	env->ReleaseStringUTFChars(mineId, cpTemp);
	// userId
	string strUserId("");
	cpTemp = env->GetStringUTFChars(userId, 0);
	strUserId = cpTemp;
	env->ReleaseStringUTFChars(userId, cpTemp);
	// fileType
	string strFileType("");
	cpTemp = env->GetStringUTFChars(fileType, 0);
	strFileType = cpTemp;
	env->ReleaseStringUTFChars(fileType, cpTemp);
	// filePath
	string strFilePath("");
	cpTemp = env->GetStringUTFChars(filePath, 0);
	strFilePath = cpTemp;
	env->ReleaseStringUTFChars(filePath, cpTemp);

	requestId = gLSLiveChatRequestLiveChatController.UploadVoice(
					strVoiceCode
					, strInviteId
					, strMineId
					, isMan
					, strUserId
					, (OTHER_SITE_TYPE)siteId
					, strFileType
					, voiceLength
					, strFilePath);
	if (requestId != -1) {
		jobject obj = env->NewGlobalRef(callback);
		gCallbackMap.Insert(requestId, obj);
	}
	else {
		FileLog("httprequest", "LiveChat.Native::UploadVoice() fails. "
			"requestId:%lld"
			", voiceCode:%s"
			", inviteId:%s"
			", mineId:%s"
			", isMan:%d"
			", userId:%s"
			", siteId:%d"
			", fileType:%s"
			", voiceLength:%d"
			", filePath:%s"
			, requestId
			, strVoiceCode.c_str()
			, strInviteId.c_str()
			, strMineId.c_str()
			, isMan
			, strUserId.c_str()
			, siteId
			, strFileType.c_str()
			, voiceLength
			, strFilePath.c_str());
	}

	FileLog("httprequest", "LiveChat.Native::UploadVoice() requestId:%lld", requestId);

	return requestId;
}

void RequestLiveChatControllerCallback::OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onUploadVoice( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCUploadVoice", signure.c_str());

	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jvoiceId = env->NewStringUTF(voiceId.c_str());
		jlong jlrequestId = requestId;

		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jvoiceId);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jvoiceId);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}

// -------------------------- PlayVoice -------------------------
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    PlayVoice
 * Signature: (Ljava/lang/String;ILjava/lang/String;Lcom/qpidnetwork/request/OnLCPlayVoiceCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_PlayVoice
  (JNIEnv *env, jclass cls, jstring voiceId, jint siteType, jstring filePath, jobject callback)
{
	jlong requestId = -1;
	const char *cpTemp = NULL;

	// voiceId
	string strVoiceId("");
	cpTemp = env->GetStringUTFChars(voiceId, 0);
	strVoiceId = cpTemp;
	env->ReleaseStringUTFChars(voiceId, cpTemp);
	// filePath
	string strFilePath("");
	cpTemp = env->GetStringUTFChars(filePath, 0);
	strFilePath = cpTemp;
	env->ReleaseStringUTFChars(filePath, cpTemp);

	requestId = gLSLiveChatRequestLiveChatController.PlayVoice(strVoiceId, (OTHER_SITE_TYPE)siteType, strFilePath);
	if (requestId != -1) {
		jobject obj = env->NewGlobalRef(callback);
		gCallbackMap.Insert(requestId, obj);
	}
	else {
		FileLog("httprequest", "LiveChat.Native::PlayVoice() fails. "
			"requestId:%lld, voiceId:%s, siteType:%d, filePath:%s"
			, requestId, strVoiceId.c_str(), siteType, strFilePath.c_str());
	}
	return requestId;
}

void RequestLiveChatControllerCallback::OnPlayVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onPlayVoice( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCPlayVoice", signure.c_str());

	FileLog("httprequest", "LiveChat.Native::onPlayVoice(), errnum:%s, errmsg:%s, filePath:%s", errnum.c_str(), errmsg.c_str(), filePath.c_str());
	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jfilePath = env->NewStringUTF(filePath.c_str());
		jlong jlrequestId = requestId;

		FileLog("httprequest", "LiveChat.Native::onPlayVoice() jCallbackObj:%p, jCallback:%p, requestId:%ld, jerrno:%p, jerrmsg:%p, jfilePath:%p", jCallbackObj, jCallback, requestId, jerrno, jerrmsg, jfilePath);
		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jfilePath);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jfilePath);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}

/******************************************************************************/
void RequestLiveChatControllerCallback::OnSendGift(long requestId, bool success, const string& errnum, const string& errmsg)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onSendGift( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject callbackObj = gCallbackMap.Erase(requestId);
	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;)V";
	jmethodID callback = env->GetMethodID(callbackCls, "onLiveChatRequest", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onSendGift( callbackCls : %p, callback : %p, signure : %s )",
			callbackCls, callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());

		FileLog("httprequest", "LiveChat.Native::onSendGift( CallObjectMethod )");

		env->CallVoidMethod(callbackObj, callback, success, jerrno, jerrmsg);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	ReleaseEnv(isAttachThread);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    SendGift
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_SendGift
  (JNIEnv *env, jclass cls, jstring womanId, jstring vg_id, jstring device_id, jstring chat_id, jint use_type, jstring user_sid, jstring user_id, jobject callback) {
	jlong requestId = -1;

	const char *cpWomanId = env->GetStringUTFChars(womanId, 0);
	const char *cpVg_id = env->GetStringUTFChars(vg_id, 0);
	const char *cpDevice_id = env->GetStringUTFChars(device_id, 0);
	const char *cpChat_id = env->GetStringUTFChars(chat_id, 0);
	const char *cpUser_sid = env->GetStringUTFChars(user_sid, 0);
	const char *cpUser_id = env->GetStringUTFChars(user_id, 0);

	requestId = gLSLiveChatRequestLiveChatController.SendGift(
			cpWomanId,
			cpVg_id,
			cpDevice_id,
			cpChat_id,
			use_type,
			cpUser_sid,
			cpUser_id
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	env->ReleaseStringUTFChars(womanId, cpWomanId);
	env->ReleaseStringUTFChars(vg_id, cpVg_id);
	env->ReleaseStringUTFChars(device_id, cpDevice_id);
	env->ReleaseStringUTFChars(chat_id, cpChat_id);
	env->ReleaseStringUTFChars(user_sid, cpUser_sid);
	env->ReleaseStringUTFChars(user_id, cpUser_id);

	return requestId;
}

/**************************** QueryRecentVideo **************************/
void RequestLiveChatControllerCallback::OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem>& itemList, const string& errnum, const string& errmsg)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onQueryRecentVideoList( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* turn object to java object here */
	jobjectArray jItemArray = NULL;
	JavaItemMap::const_iterator itr = gJavaItemMap.find(LIVECHAT_LCVIDEO_TIME_CLASS);
	if( itr != gJavaItemMap.end() ) {
		jclass cls = env->GetObjectClass(itr->second);
		jmethodID init = env->GetMethodID(cls, "<init>", "("
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				")V");

		if( itemList.size() > 0 ) {
			int i = 0;
			jItemArray = env->NewObjectArray(itemList.size(), cls, NULL);
			for(list<LSLCVideoItem>::const_iterator itr = itemList.begin(); itr != itemList.end(); itr++, i++) {
				jstring videoid = env->NewStringUTF(itr->videoid.c_str());
				jstring title = env->NewStringUTF(itr->title.c_str());
				jstring inviteid = env->NewStringUTF(itr->inviteid.c_str());
				jstring video_url = env->NewStringUTF(itr->video_url.c_str());


				jobject item = env->NewObject(cls, init,
						videoid,
						title,
						inviteid,
						video_url
						);

				env->SetObjectArrayElement(jItemArray, i, item);

				env->DeleteLocalRef(videoid);
				env->DeleteLocalRef(title);
				env->DeleteLocalRef(inviteid);
				env->DeleteLocalRef(video_url);

				env->DeleteLocalRef(item);
			}
		}
	}

	/* real callback java */
	//jobject callbackObj = gCallbackMap.Erase(requestId);
	jobject callbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
		callbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();

	jclass callbackCls = env->GetObjectClass(callbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;";
	signure += "[L";
	signure += LIVECHAT_LCVIDEO_TIME_CLASS;
	signure += ";";
	signure += ")V";
	jmethodID callback = env->GetMethodID(callbackCls, "OnQueryRecentVideoList", signure.c_str());
	FileLog("httprequest", "LiveChat.Native::onQueryRecentVideoList( callback : %p, signure : %s )",
			callback, signure.c_str());

	if( callbackObj != NULL && callback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());

		FileLog("httprequest", "LiveChat.Native::onQueryRecentVideoList( CallObjectMethod "
				"jItemArray : %p )", jItemArray);

		env->CallVoidMethod(callbackObj, callback, success, jerrno, jerrmsg, jItemArray);

		env->DeleteGlobalRef(callbackObj);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	if( jItemArray != NULL ) {
		env->DeleteLocalRef(jItemArray);
	}

	ReleaseEnv(isAttachThread);
}
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    QueryRecentVideo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/request/OnQueryRecentVideoListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_QueryRecentVideo
  (JNIEnv *env, jclass, jstring user_sid, jstring user_id, jstring womanId, jobject callback) {
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.QueryRecentVideo(
			JString2String(env, user_sid),
			JString2String(env, user_id),
			JString2String(env, womanId)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

/**************************** GetVideoPhoto **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetVideoPhoto
 * Signature: (Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Lcom/qpidnetwork/request/OnRequestFileCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetVideoPhoto
  (JNIEnv *env, jclass, jstring user_sid, jstring user_id, jstring womanId, jstring videoid, jint size, jstring filePath, jobject callback) {
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.GetVideoPhoto(
			JString2String(env, user_sid),
			JString2String(env, user_id),
			JString2String(env, womanId),
			JString2String(env, videoid),
			(VIDEO_PHOTO_TYPE)size,
			JString2String(env, filePath)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onGetVideoPhoto( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCRequestFile", signure.c_str());

	FileLog("httprequest", "LiveChat.Native::onGetVideoPhoto(), errnum:%s, errmsg:%s, filePath:%s", errnum.c_str(), errmsg.c_str(), filePath.c_str());
	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jfilePath = env->NewStringUTF(filePath.c_str());
		jlong jlrequestId = requestId;

		FileLog("httprequest", "LiveChat.Native::onGetVideoPhoto() jCallbackObj:%p, jCallback:%p, requestId:%ld, jerrno:%p, jerrmsg:%p, jfilePath:%p", jCallbackObj, jCallback, requestId, jerrno, jerrmsg, jfilePath);
		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jfilePath);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jfilePath);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}
/**************************** GetVideo **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetVideo
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Lcom/qpidnetwork/request/OnGetVideoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetVideo
  (JNIEnv *env, jclass, jstring user_sid, jstring user_id, jstring womanId, jstring videoid, jstring inviteid, jint toflag, jstring sendid, jobject callback) {
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.GetVideo(
			JString2String(env, user_sid),
			JString2String(env, user_id),
			JString2String(env, womanId),
			JString2String(env, videoid),
			JString2String(env, inviteid),
			(GETVIDEO_CLIENT_TYPE)toflag,
			JString2String(env, sendid)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}
void RequestLiveChatControllerCallback::OnGetVideo(long requestId, bool success, const string& errnum, const string& errmsg, const string& url)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::onGetVideo( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCGetVideo", signure.c_str());

	FileLog("httprequest", "LiveChat.Native::onGetVideo(), errnum:%s, errmsg:%s, url:%s", errnum.c_str(), errmsg.c_str(), url.c_str());
	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jstring jUrl = env->NewStringUTF(url.c_str());
		jlong jlrequestId = requestId;

		FileLog("httprequest", "LiveChat.Native::onGetVideo() jCallbackObj:%p, jCallback:%p, requestId:%ld, jerrno:%p, jerrmsg:%p, jUrl:%p", jCallbackObj, jCallback, requestId, jerrno, jerrmsg, jUrl);
		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jUrl);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
		env->DeleteLocalRef(jUrl);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}

/**************************** GetMagicIconConfig **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetMagicIconConfig
 * Signature: (Lcom/qpidnetwork/request/OnGetMagicIconConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetMagicIconConfig
  (JNIEnv *env, jclass cls, jobject callback){

	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.GetMagicIconConfig();

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnGetMagicIconConfig(long requestId, bool success, const string& errnum, const string& errmsg,const LSLCMagicIconConfig& config){
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::OnGetMagicIconConfig( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);
	/* create java item */
	jobject jMagicConfigItem = NULL;
	if (success) {
		/*creat magic icon array */
		jclass jMagicIconItemCls = GetJClass(env, LIVECHAT_MAGIC_ICON_TIME_CLASS);
		jmethodID magicIconInit = env->GetMethodID(jMagicIconItemCls, "<init>", "("
							"Ljava/lang/String;"
							"Ljava/lang/String;"
							"DI"
							"Ljava/lang/String;"
							"I"
							")V");
		jobjectArray jMagicIconArray = env->NewObjectArray(config.magicIconList.size(),jMagicIconItemCls, NULL);
		int iMagicIconIndex;
		LSLCMagicIconConfig::MagicIconList::const_iterator magicIconIter;
		for(iMagicIconIndex = 0, magicIconIter = config.magicIconList.begin();
				magicIconIter != config.magicIconList.end();
				iMagicIconIndex++, magicIconIter++){
			jstring jIconId = env->NewStringUTF(magicIconIter->iconId.c_str());
			jstring jIconTitle = env->NewStringUTF(magicIconIter->iconTitle.c_str());
			jstring jTypeId = env->NewStringUTF(magicIconIter->typeId.c_str());

			jobject jMagicItem = env->NewObject(jMagicIconItemCls, magicIconInit,
							jIconId,
							jIconTitle,
							magicIconIter->price,
							magicIconIter->hotflag,
							jTypeId,
							magicIconIter->updatetime);
			env->SetObjectArrayElement(jMagicIconArray, iMagicIconIndex, jMagicItem);
			env->DeleteLocalRef(jMagicItem);

			env->DeleteLocalRef(jIconId);
			env->DeleteLocalRef(jIconTitle);
			env->DeleteLocalRef(jTypeId);
		}
		env->DeleteLocalRef(jMagicIconItemCls);
		FileLog("httprequest", "LiveChat.Native::OnGetMagicIconConfig(), jMagicIconArray:%p", jMagicIconArray);

		/*creat magic type array */
		jclass jMagicTypeItemCls = GetJClass(env, LIVECHAT_MAGIC_TYPE_TIME_CLASS);
		jmethodID magicTypeInit = env->GetMethodID(jMagicTypeItemCls,"<init>", "("
												"Ljava/lang/String;"
												"Ljava/lang/String;"
												")V");
		jobjectArray jMagicTypeArray = env->NewObjectArray(config.typeList.size(), jMagicTypeItemCls, NULL);
		int iMagicTypeIndex;
        LSLCMagicIconConfig::MagicTypeList::const_iterator jMagicTypeIter;
		for(iMagicTypeIndex = 0, jMagicTypeIter = config.typeList.begin();
				jMagicTypeIter != config.typeList.end();
				iMagicTypeIndex++, jMagicTypeIter++){
			jstring jMagicTypeId = env->NewStringUTF(jMagicTypeIter->typeId.c_str());
			jstring jMagicTypeTitle = env->NewStringUTF(jMagicTypeIter->typeTitle.c_str());
			jobject jMagicTypeItem = env->NewObject(jMagicTypeItemCls, magicTypeInit,
										jMagicTypeId,
										jMagicTypeTitle);
			env->SetObjectArrayElement(jMagicTypeArray, iMagicTypeIndex, jMagicTypeItem);
			env->DeleteLocalRef(jMagicTypeItem);
			env->DeleteLocalRef(jMagicTypeId);
			env->DeleteLocalRef(jMagicTypeTitle);
		}
		env->DeleteLocalRef(jMagicTypeItemCls);
		FileLog("httprequest", "LiveChat.Native::OnGetMagicIconConfig(), jMagicIconArray:%p, jMagicTypeArray: %p", jMagicIconArray, jMagicTypeArray);

		/*create magic config item*/
		jclass jMagicConfigItemCls = GetJClass(env, LIVECHAT_MAGIC_CONFIG_ITEM_CLASS);
		jmethodID magicConfigInit = env->GetMethodID(jMagicConfigItemCls, "<init>", "("
				"Ljava/lang/String;"
				"I"
				"[L"
				LIVECHAT_MAGIC_ICON_TIME_CLASS
				";"
				"[L"
				LIVECHAT_MAGIC_TYPE_TIME_CLASS
				";"
				")V");
		jstring jPath = env->NewStringUTF(config.path.c_str());
		jMagicConfigItem = env->NewObject(jMagicConfigItemCls, magicConfigInit,
				jPath,
				config.maxupdatetime,
				jMagicIconArray,
				jMagicTypeArray);
		env->DeleteLocalRef(jPath);
		env->DeleteLocalRef(jMagicConfigItemCls);
		env->DeleteLocalRef(jMagicIconArray);
		env->DeleteLocalRef(jMagicTypeArray);
	}

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCGetMagicIconConfig", "("
			"Z"
			"Ljava/lang/String;"
			"Ljava/lang/String;"
			"L"
			LIVECHAT_MAGIC_CONFIG_ITEM_CLASS
			";"
			")V");
	FileLog("httprequest", "LiveChat.Native::OnGetMagicIconConfig(), errnum:%s, errmsg:%s, jMagicConfigItem:%p"
				, errnum.c_str(), errmsg.c_str(), jMagicConfigItem);
	if(NULL != jCallbackObj && NULL != jCallback){
		jstring jerrNum = env->NewStringUTF(errnum.c_str());
		jstring jerrMessage = env->NewStringUTF(errmsg.c_str());
		env->CallVoidMethod(jCallbackObj, jCallback, success, jerrNum, jerrMessage, jMagicConfigItem);
		env->DeleteLocalRef(jerrNum);
		env->DeleteLocalRef(jerrMessage);
	}
	FileLog("httprequest", "LiveChat.Native::OnGetMagicIconConfig()finish");

	if(NULL != jCallbackObj){
		env->DeleteGlobalRef(jCallbackObj);
	}

	if(NULL != jCallbackCls){
		env->DeleteLocalRef(jCallbackCls);
	}

	if(NULL != jMagicConfigItem){
		env->DeleteLocalRef(jMagicConfigItem);
	}

	ReleaseEnv(isAttachThread);
}

/**************************** ChatRecharge **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    ChatRecharge
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/request/OnLCChatRechargeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_ChatRecharge
  (JNIEnv *env, jclass cls, jstring womanId, jstring user_sid, jstring user_id, jobject callback)
{
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.ChatRecharge(
			JString2String(env, womanId),
			JString2String(env, user_sid),
			JString2String(env, user_id)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnChatRecharge(long requestId, bool success, const string& errnum, const string& errmsg, double credits)
{
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::OnChatRecharge( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(JZLjava/lang/String;Ljava/lang/String;D)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCChatRecharge", signure.c_str());

	FileLog("httprequest", "LiveChat.Native::OnChatRecharge(), errnum:%s, errmsg:%s, credits:%d"
			, errnum.c_str(), errmsg.c_str(), credits);
	if( jCallbackObj != NULL && jCallback != NULL ) {
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		jlong jlrequestId = requestId;
		jdouble jcredits = credits;

		FileLog("httprequest", "LiveChat.Native::OnChatRecharge() jCallbackObj:%p, jCallback:%p, requestId:%ld, jerrno:%p, jerrmsg:%p, credits:%d"
				, jCallbackObj, jCallback, requestId, jerrno, jerrmsg, credits);
		env->CallVoidMethod(jCallbackObj, jCallback, jlrequestId, success, jerrno, jerrmsg, jcredits);

		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}

	// delete callback object & class
	if (jCallbackCls != NULL) {
		env->DeleteLocalRef(jCallbackCls);
	}
	if (jCallbackObj != NULL) {
		env->DeleteGlobalRef(jCallbackObj);
	}

	ReleaseEnv(isAttachThread);
}

/**************************** GetThemeConfig **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetThemeConfig
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnGetThemeConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetThemeConfig
  (JNIEnv *env, jclass cls, jstring user_sid, jstring user_id, jobject callback){
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.GetThemeConfig(
			JString2String(env, user_sid),
			JString2String(env, user_id)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnGetThemeConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCThemeConfig& config){
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::OnGetThemeConfig( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);
	/*create java item*/
	jobject jThemeConfig = NULL;
	if(success){
		/*create type list*/
		jclass jthemeTypeCls = GetJClass(env, LIVECHAT_THEME_TYPE_CLASS);
		jmethodID jthemeTypeInit = env->GetMethodID(jthemeTypeCls, "<init>", "("
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				")V");
		jobjectArray jThemeTypeArray = env->NewObjectArray(config.themeTypeList.size(), jthemeTypeCls, NULL);
        LSLCThemeConfig::ThemeTypeList::const_iterator themeTypeIter;
		int iTypeIndex;
		for(iTypeIndex = 0, themeTypeIter = config.themeTypeList.begin();
				themeTypeIter != config.themeTypeList.end();
				iTypeIndex++,themeTypeIter++){
			jstring jtypeId = env->NewStringUTF(themeTypeIter->typeId.c_str());
			jstring jtypeName = env->NewStringUTF(themeTypeIter->typeName.c_str());

			jobject jthemeTypeItem = env->NewObject(jthemeTypeCls, jthemeTypeInit, jtypeId, jtypeName);
			env->SetObjectArrayElement(jThemeTypeArray, iTypeIndex , jthemeTypeItem);
			env->DeleteLocalRef(jthemeTypeItem);

			env->DeleteLocalRef(jtypeId);
			env->DeleteLocalRef(jtypeName);
		}
		env->DeleteLocalRef(jthemeTypeCls);
		FileLog("httprequest", "LiveChat.Native::OnGetThemeConfig(), jThemeTypeArray:%p", jThemeTypeArray);

		/*create tag list*/
		jclass jthemeTagCls = GetJClass(env, LIVECHAT_THEME_TAG_CLASS);
		jmethodID jthemeTagInit = env->GetMethodID(jthemeTagCls, "<init>", "("
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				")V");
		jobjectArray jthemeTagArray = env->NewObjectArray(config.themeTagList.size(), jthemeTagCls, NULL);
        LSLCThemeConfig::ThemeTagList::const_iterator themeTagIter;
		int iTagIndex;
		for(iTagIndex = 0, themeTagIter = config.themeTagList.begin();
				themeTagIter != config.themeTagList.end();
				iTagIndex++, themeTagIter++){
			jstring jtagId = env->NewStringUTF(themeTagIter->tagId.c_str());
			jstring jtypeId = env->NewStringUTF(themeTagIter->typeId.c_str());
			jstring jtagName = env->NewStringUTF(themeTagIter->tagName.c_str());

			jobject jtagItem = env->NewObject(jthemeTagCls, jthemeTagInit, jtagId, jtypeId, jtagName);
			env->SetObjectArrayElement(jthemeTagArray, iTagIndex, jtagItem);
			env->DeleteLocalRef(jtagItem);

			env->DeleteLocalRef(jtagId);
			env->DeleteLocalRef(jtypeId);
			env->DeleteLocalRef(jtagName);
		}
		env->DeleteLocalRef(jthemeTagCls);
		FileLog("httprequest", "LiveChat.Native::OnGetThemeConfig(), jthemeTagArray:%p", jthemeTagArray);

		/*create theme item list*/
		jclass jthemeItemCls = GetJClass(env, LIVECHAT_THEME_ITEM_CLASS);
		jmethodID jthemeItemInit = env->GetMethodID(jthemeItemCls, "<init>", "("
				"Ljava/lang/String;"
				"DZZ"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"II"
				"Ljava/lang/String;"
				")V");
		jobjectArray jthemeItemArray = env->NewObjectArray(config.themeItemList.size(), jthemeItemCls, NULL);
		ThemeItemList::const_iterator themeItemIter;
		int iItemIndex;
		for(iItemIndex = 0, themeItemIter=config.themeItemList.begin();
				themeItemIter != config.themeItemList.end();
				iItemIndex++, themeItemIter++){
			jstring jthemeId = env->NewStringUTF(themeItemIter->themeId.c_str());
			jstring jtypeId = env->NewStringUTF(themeItemIter->typeId.c_str());
			jstring jTagId = env->NewStringUTF(themeItemIter->tagId.c_str());
			jstring jTitle = env->NewStringUTF(themeItemIter->title.c_str());
			jstring jDescript = env->NewStringUTF(themeItemIter->descript.c_str());

			jobject jthemeItem = env->NewObject(jthemeItemCls, jthemeItemInit, jthemeId, themeItemIter->price, themeItemIter->isNew, themeItemIter->isSale,
					jtypeId, jTagId, jTitle, themeItemIter->validsecond, themeItemIter->isBase, jDescript);
			env->SetObjectArrayElement(jthemeItemArray, iItemIndex, jthemeItem);
			env->DeleteLocalRef(jthemeItem);

			env->DeleteLocalRef(jthemeId);
			env->DeleteLocalRef(jtypeId);
			env->DeleteLocalRef(jTagId);
			env->DeleteLocalRef(jTitle);
			env->DeleteLocalRef(jDescript);
		}
		env->DeleteLocalRef(jthemeItemCls);
		FileLog("httprequest", "LiveChat.Native::OnGetThemeConfig(), jthemeItemArray:%p", jthemeItemArray);

		/*create theme config item*/
		jclass jthemeConfig = GetJClass(env, LIVECHAT_THEME_CONFIG_CLASS);
		jmethodID jthemeConfigInit = env->GetMethodID(jthemeConfig, "<init>", "("
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"[L"
				LIVECHAT_THEME_TYPE_CLASS
				";"
				"[L"
				LIVECHAT_THEME_TAG_CLASS
				";"
				"[L"
				LIVECHAT_THEME_ITEM_CLASS
				";"
				")V");

		jstring jthemeVersion = env->NewStringUTF(config.themeVersion.c_str());
		jstring jthemePath = env->NewStringUTF(config.themePath.c_str());
		jThemeConfig = env->NewObject(jthemeConfig, jthemeConfigInit, jthemeVersion, jthemePath, jThemeTypeArray,
				jthemeTagArray, jthemeItemArray);
		env->DeleteLocalRef(jthemeVersion);
		env->DeleteLocalRef(jthemePath);
		env->DeleteLocalRef(jThemeTypeArray);
		env->DeleteLocalRef(jthemeTagArray);
		env->DeleteLocalRef(jthemeItemArray);
	}

	/*call back java*/
	//jobject jcallbackObj = gCallbackMap.Erase(requestId);
	jobject jcallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jcallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jcallbackCls = env->GetObjectClass(jcallbackObj);

	jmethodID jcallback = env->GetMethodID(jcallbackCls, "OnLCGetThemeConfig", "(Z"
			"Ljava/lang/String;"
			"Ljava/lang/String;"
			"L"
			LIVECHAT_THEME_CONFIG_CLASS
			";"
			")V");
	if(NULL != jcallback && NULL != jcallbackObj){
		jstring jerrNum = env->NewStringUTF(errnum.c_str());
		jstring jerrMessage = env->NewStringUTF(errmsg.c_str());
		env->CallVoidMethod(jcallbackObj, jcallback, success, jerrNum, jerrMessage, jThemeConfig);
		env->DeleteLocalRef(jerrNum);
		env->DeleteLocalRef(jerrMessage);
	}

	FileLog("httprequest", "LiveChat.Native::OnGetThemeConfig()finish");

	if(NULL != jcallbackObj){
		env->DeleteGlobalRef(jcallbackObj);
	}

	if(NULL != jcallbackCls){
		env->DeleteLocalRef(jcallbackCls);
	}

	if(NULL != jThemeConfig){
		env->DeleteLocalRef(jThemeConfig);
	}

	ReleaseEnv(isAttachThread);
}

/**************************** GetThemeDetail **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    GetThemeDetail
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnGetThemeDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_GetThemeDetail
  (JNIEnv *env, jclass cls, jstring themeIds, jstring user_sid, jstring user_id, jobject callback){
	jlong requestId = -1;

	requestId = gLSLiveChatRequestLiveChatController.GetThemeDetail(
			JString2String(env, themeIds),
			JString2String(env, user_sid),
			JString2String(env, user_id)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnGetThemeDetail(long requestId, bool success, const string& errnum, const string& errmsg, const ThemeItemList& themeList){
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	FileLog("httprequest", "LiveChat.Native::OnGetThemeDetail( success : %s, env:%p, isAttachThread:%d )", success?"true":"false", env, isAttachThread);

	/*create theme list*/
	jclass jthemeItemCls = GetJClass(env, LIVECHAT_THEME_ITEM_CLASS);
	jmethodID jthemeItemInit = env->GetMethodID(jthemeItemCls, "<init>", "("
					"Ljava/lang/String;"
					"DZZ"
					"Ljava/lang/String;"
					"Ljava/lang/String;"
					"Ljava/lang/String;"
					"II"
					"Ljava/lang/String;"
					")V");
	jobjectArray jthemeItemArray = env->NewObjectArray(themeList.size(), jthemeItemCls, NULL);
	ThemeItemList::const_iterator themeItemIter;
	int iItemIndex;
	for(iItemIndex = 0, themeItemIter = themeList.begin();
			themeItemIter != themeList.end();
			iItemIndex++, themeItemIter++){
		jstring jthemeId = env->NewStringUTF(themeItemIter->themeId.c_str());
		jstring jtypeId = env->NewStringUTF(themeItemIter->typeId.c_str());
		jstring jTagId = env->NewStringUTF(themeItemIter->tagId.c_str());
		jstring jTitle = env->NewStringUTF(themeItemIter->title.c_str());
		jstring jDescript = env->NewStringUTF(themeItemIter->descript.c_str());

		jobject jthemeItem = env->NewObject(jthemeItemCls, jthemeItemInit, jthemeId, themeItemIter->price, themeItemIter->isNew, themeItemIter->isSale,
				jtypeId, jTagId, jTitle, themeItemIter->validsecond, themeItemIter->isBase, jDescript);
		env->SetObjectArrayElement(jthemeItemArray, iItemIndex, jthemeItem);
		env->DeleteLocalRef(jthemeItem);

		env->DeleteLocalRef(jthemeId);
		env->DeleteLocalRef(jtypeId);
		env->DeleteLocalRef(jTagId);
		env->DeleteLocalRef(jTitle);
		env->DeleteLocalRef(jDescript);
	}
	env->DeleteLocalRef(jthemeItemCls);
	FileLog("httprequest", "LiveChat.Native::OnGetThemeDetail(), jthemeItemArray:%p", jthemeItemArray);

	/*call back java*/
	//jobject jcallbackObj = gCallbackMap.Erase(requestId);
	jobject jcallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jcallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jcallbackCls = env->GetObjectClass(jcallbackObj);

	jmethodID jcallback = env->GetMethodID(jcallbackCls, "OnLCGetThemeDetail", "(Z"
			"Ljava/lang/String;"
			"Ljava/lang/String;"
			"[L"
			LIVECHAT_THEME_ITEM_CLASS
			";"
			")V");
	if(NULL != jcallback && NULL != jcallbackObj){
		jstring jerrNum = env->NewStringUTF(errnum.c_str());
		jstring jerrMessage = env->NewStringUTF(errmsg.c_str());
		env->CallVoidMethod(jcallbackObj, jcallback, success, jerrNum, jerrMessage, jthemeItemArray);
		env->DeleteLocalRef(jerrNum);
		env->DeleteLocalRef(jerrMessage);
	}

	FileLog("httprequest", "LiveChat.Native::OnGetThemeDetail()finish");

	if(NULL != jcallbackObj){
		env->DeleteGlobalRef(jcallbackObj);
	}

	if(NULL != jcallbackCls){
		env->DeleteLocalRef(jcallbackCls);
	}

	if(NULL != jthemeItemArray){
		env->DeleteLocalRef(jthemeItemArray);
	}

	ReleaseEnv(isAttachThread);
}

/**************************** CheckFunctions **************************/
/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat
 * Method:    CheckFunctions
 * Signature: ([IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/request/OnCheckFunctionsCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJniLiveChat_CheckFunctions
  (JNIEnv *env, jclass cls, jintArray functionArray, jint deviceType, jstring versionCode, jstring user_sid, jstring user_id, jobject callback){
	jlong requestId = -1;

	string functionIds = "";
	jsize len = env->GetArrayLength(functionArray);
	jint *functions = env->GetIntArrayElements(functionArray, JNI_FALSE);
	for(int i = 0; i < len; i++) {
		char buffer[32] = {0};
		if(i < len-1){
			if(functions[i]>=0 && functions[i]<_countof(FunctionsArray)){
				snprintf(buffer, sizeof(buffer), "%d", FunctionsArray[functions[i]]);
				functionIds += buffer;
				functionIds += ",";
			}
		}else if(i == len-1){
			if(functions[i]>=0 && functions[i]<_countof(FunctionsArray)){
				snprintf(buffer, sizeof(buffer), "%d", FunctionsArray[functions[i]]);
				functionIds += buffer;
			}
		}
	}
	TDEVICE_TYPE type = IntToDeviceType(deviceType);

	requestId = gLSLiveChatRequestLiveChatController.CheckFunctions(
			functionIds,
			type,
			JString2String(env, versionCode),
			JString2String(env, user_sid),
			JString2String(env, user_id)
			);

	jobject obj = env->NewGlobalRef(callback);
	gCallbackMap.Insert(requestId, obj);

	return requestId;
}

void RequestLiveChatControllerCallback::OnCheckFunctions(long requestId, bool success, const string& errnum, const string& errmsg, const list<string>& flagList){
	JNIEnv* env = NULL;
	bool isAttachThread = false;
	GetEnv(&env, &isAttachThread);

	jintArray flagsArray = env->NewIntArray(flagList.size());
	list<string>::const_iterator flagIter;
	int iFlagIndex;
	jint tmp[flagList.size()];
	for(iFlagIndex = 0, flagIter = flagList.begin();
			flagIter != flagList.end();
			iFlagIndex++, flagIter++){
		tmp[iFlagIndex] = atoi((*flagIter).c_str());
	}
	env->SetIntArrayRegion(flagsArray, 0, flagList.size(), tmp);

	/* real callback java */
	//jobject jCallbackObj = gCallbackMap.Erase(requestId);
	jobject jCallbackObj = NULL;
	CallbackMap::iterator callbackItr = gCallbackMap.Find(requestId);
	if (callbackItr != gCallbackMap.End()) {
        jCallbackObj = callbackItr->second;
	}
	gCallbackMap.Erase(requestId);
	gCallbackMap.Unlock();
	jclass jCallbackCls = env->GetObjectClass(jCallbackObj);

	string signure = "(ZLjava/lang/String;Ljava/lang/String;[I)V";
	jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLCCheckFunctions", signure.c_str());

	FileLog("httprequest", "LiveChat.Native::OnCheckFunctions(), errnum:%s, errmsg:%s, flagList size:%d"
				, errnum.c_str(), errmsg.c_str(), flagList.size());

	if(NULL != jCallbackObj && NULL != jCallback){
		jstring jerrno = env->NewStringUTF(errnum.c_str());
		jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
		FileLog("httprequest", "LiveChat.Native::OnCheckFunctions() jCallbackObj:%p, jCallback:%p, requestId:%ld, jerrno:%p, jerrmsg:%p, flagList size:%d"
						, jCallbackObj, jCallback, requestId, jerrno, jerrmsg, flagList.size());
		env->CallVoidMethod(jCallbackObj, jCallback, success, jerrno, jerrmsg, flagsArray);
		env->DeleteLocalRef(jerrno);
		env->DeleteLocalRef(jerrmsg);
	}
	env->DeleteLocalRef(flagsArray);
	if(NULL != jCallbackObj){
		env->DeleteGlobalRef(jCallbackObj);
	}
	if(NULL != jCallbackCls){
		env->DeleteLocalRef(jCallbackCls);
	}
	ReleaseEnv(isAttachThread);
}
