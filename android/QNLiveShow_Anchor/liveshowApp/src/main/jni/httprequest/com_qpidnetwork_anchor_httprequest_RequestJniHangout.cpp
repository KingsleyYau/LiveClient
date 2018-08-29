/*
 * com_qpidnetwork_anchor_httprequest_RequestJniHangout.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_anchor_httprequest_RequestJniHangout.h"

/*********************************** 6.1.获取可推荐的好友列表  ****************************************/

class RequestAnchorGetCanRecommendFriendListCallback : public IRequestAnchorGetCanRecommendFriendListCallback {
	void OnAnchorGetCanRecommendFriendList(HttpAnchorGetCanRecommendFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorItemList& anchorList) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getAnchorArray(env, anchorList);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += ANCHOR_INFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAnchorList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAnchorList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItemArray != NULL){
			env->DeleteLocalRef(jItemArray);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestAnchorGetCanRecommendFriendListCallback gRequestAnchorGetCanRecommendFriendListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    GetCanRecommendFriendList
 * Signature: (IILcom/qpidnetwork/anchor/httprequest/OnGetAnchorListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_GetCanRecommendFriendList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAudienceListInRoom( start : %d, step: %d )",
            start, step);
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorGetCanRecommendFriendList(&gHttpRequestManager,
    									start,
    									step,
                                        &gRequestAnchorGetCanRecommendFriendListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.2.主播推荐好友给观众  ****************************************/

class RequestAnchorRecommendFriendJoinHangoutCallback : public IRequestAnchorRecommendFriendJoinHangoutCallback {
	void OnAnchorRecommendFriend(HttpAnchorRecommendFriendJoinHangoutTask* task, bool success, int errnum, const string& errmsg, const string& anchorId) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRecommendFriend( success : %s, task : %p, isAttachThread:%d, anchorId: %s)", success?"true":"false", task, isAttachThread, anchorId.c_str());

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRecommendFriend", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRecommendFriend( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring janchorId = env->NewStringUTF(anchorId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, janchorId);
				env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(janchorId);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestAnchorRecommendFriendJoinHangoutCallback gRequestAnchorRecommendFriendJoinHangoutCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    RecommendFriendJoinHangout
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnRecommendFriendCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_RecommendFriendJoinHangout
  (JNIEnv *env, jclass cls, jstring friendId, jstring roomId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::RecommendFriendJoinHangout( friendId : %s, roomId : %s )",
            JString2String(env, friendId).c_str(), JString2String(env, roomId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorRecommendFriend(&gHttpRequestManager,
    									JString2String(env, friendId),
                                        JString2String(env, roomId),
                                        &gRequestAnchorRecommendFriendJoinHangoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.3.主播回复多人互动邀请  ****************************************/

class RequestAnchorDealInvitationHangoutCallback : public IRequestAnchorDealInvitationHangoutCallback {
    void OnAnchorDealInvitationHangout(HttpAnchorDealInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onDealInvitationHangout( success : %s, task : %p, isAttachThread:%d, rooomId : %s )", success?"true":"false", task, isAttachThread, roomId.c_str());

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onDealInvitationHangout", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onDealInvitationHangout( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jroomId);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
            }
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorDealInvitationHangoutCallback gRequestAnchorDealInvitationHangoutCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    DealInvitationHangout
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/anchor/httprequest/OnDealInvitationHangoutCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_DealInvitationHangout
        (JNIEnv *env, jclass cls, jstring inviteId, jint type, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::DealInvitationHangout() inviteId: %s, type: %d", JString2String(env, inviteId).c_str(), type);
    jlong taskId = -1;
    AnchorMultiplayerReplyType jtype = IntToAnchorMultiplayerReplyTypeOperateType(type);
    taskId = gHttpRequestController.AnchorDealInvitationHangout(&gHttpRequestManager,
                                                                JString2String(env, inviteId).c_str(),
                                                                jtype,
                                                                &gRequestAnchorDealInvitationHangoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.4.获取未结束的多人互动直播间列表  ****************************************/

class RequestAnchorGetOngoingHangoutListCallback : public IRequestAnchorGetOngoingHangoutListCallback {
    void OnAnchorGetOngoingHangoutList(HttpAnchorGetOngoingHangoutListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutItemList& hangoutList) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetOngoingHangout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobjectArray jItemArray = getAnchorHangoutArray(env, hangoutList);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "[L";
            signature += ANCHOR_HANGOUT_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetOngoingHangout", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetOngoingHangout( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray);
                env->DeleteLocalRef(jerrmsg);
            }
        }

        if(jItemArray != NULL){
            env->DeleteLocalRef(jItemArray);
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorGetOngoingHangoutListCallback gRequestAnchorGetOngoingHangoutListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    GetOngoingHangoutList
 * Signature: (IILcom/qpidnetwork/anchor/httprequest/OnGetOngoingHangoutListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_GetOngoingHangoutList
        (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetOngoingHangoutList( start : %d, step : %d )",
            start, step);
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorGetOngoingHangoutList(&gHttpRequestManager,
                                                                start,
                                                                step,
                                               &gRequestAnchorGetOngoingHangoutListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.5.发起敲门请求  ****************************************/

class RequestAnchorSendKnockRequestCallback : public IRequestAnchorSendKnockRequestCallback {
	void OnAnchorSendKnockRequest(HttpAnchorSendKnockRequestTask* task, bool success, int errnum, const string& errmsg, const string& knockId, int expire) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI:::onSendKnockRequest( success : %s, task : %p, isAttachThread:%d knockId : %s expire : %d)", success?"true":"false", task, isAttachThread, knockId.c_str(), expire);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;I)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSendKnockRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSendKnockRequest( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jknockId = env->NewStringUTF(knockId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jknockId, expire);
				env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jknockId);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestAnchorSendKnockRequestCallback gRequestAnchorSendKnockRequestCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    SendKnockRequest
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnGetSendKnockRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_SendKnockRequest
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SendKnockRequest( roomId : %s )",
            JString2String(env, roomId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorSendKnockRequest(&gHttpRequestManager,
    									JString2String(env, roomId),
                                        &gRequestAnchorSendKnockRequestCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.6.获取敲门状态 ****************************************/

class RequestAnchorGetHangoutKnockStatusCallback : public IRequestAnchorGetHangoutKnockStatusCallback {
	void OnAnchorGetHangoutKnockStatus(HttpAnchorGetHangoutKnockStatusTask* task, bool success, int errnum, const string& errmsg, const string& roomId, AnchorMultiKnockType status, int expire) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetHangoutKnockStatus( success : %s, task : %p, isAttachThread:%d, roomId:%s, status : %d expire : %d)", success?"true":"false", task, isAttachThread, roomId.c_str(), status, expire);
		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;II)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutKnockStatus", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetHangoutKnockStatus( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                jint jstatus = AnchorMultiKnockTypeToInt(status);
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jroomId, jstatus, expire);
				env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestAnchorGetHangoutKnockStatusCallback gRequestAnchorGetHangoutKnockStatusCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    GetHangoutKnockStatus
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnGetHangoutKnockStatusCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_GetHangoutKnockStatus
  (JNIEnv *env, jclass cls, jstring knockId, jobject callback){

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutKnockStatus() knockId : %s", JString2String(env, knockId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorGetHangoutKnockStatus(&gHttpRequestManager,
                                                                JString2String(env, knockId).c_str(),
                                                                &gRequestAnchorGetHangoutKnockStatusCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.7.取消敲门请求  ****************************************/

class RequestAnchorCancelHangoutKnockCallback : public IRequestAnchorCancelHangoutKnockCallback {
    void OnAnchorCancelHangoutKnock(HttpAnchorCancelHangoutKnockTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelHangoutKnock( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelHangoutKnock( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorCancelHangoutKnockCallback gRequestAnchorCancelHangoutKnockCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    CancelHangoutKnock
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_CancelHangoutKnock
        (JNIEnv * env, jclass cls, jstring knockId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CancelHangoutKnock( knockId : %s)",
            JString2String(env, knockId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorCancelHangoutKnock(&gHttpRequestManager,
                                                             JString2String(env, knockId),
                                                             &gRequestAnchorCancelHangoutKnockCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.8.获取多人互动直播间礼物列表 ****************************************/
class RequestAnchorHangoutGiftListCallback : public IRequestAnchorHangoutGiftListCallback {
    void OnAnchorHangoutGiftList(HttpAnchorHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutGiftListItem& hangoutGiftItem) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onHangoutGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        jobject jItem = getAnchorHangoutGiftListItem(env, hangoutGiftItem);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "L";
            signature += ANCHOR_HANGOUT_GIFTLIST_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onHangoutGiftList", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onHangoutGiftList( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
                env->DeleteLocalRef(jerrmsg);
            }
        }

        if(jItem != NULL){
            env->DeleteLocalRef(jItem);
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorHangoutGiftListCallback gRequestAnchorHangoutGiftListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    HangoutGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnHangoutGiftListCallback;)J
 */

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_HangoutGiftList
        (JNIEnv * env, jclass cls, jstring roomId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::HangoutGiftList( roomId : %s )", JString2String(env, roomId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorHangoutGiftList(&gHttpRequestManager,
                                                          JString2String(env, roomId),
                                                          &gRequestAnchorHangoutGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/***********************************  6.9.请求添加好友 ****************************************/
class RequestAddAnchorFriendCallback : public IRequestAddAnchorFriendCallback {
    void OnAddAnchorFriend(HttpAddAnchorFriendTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddAnchorFriend( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddAnchorFriend( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
            }
        }


        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAddAnchorFriendCallback gRequestAddAnchorFriendCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    AddAnchorFriend
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_AddAnchorFriend
        (JNIEnv * env, jclass cls, jstring userId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AddAnchorFriend( userId : %s )", JString2String(env, userId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AddAnchorFriend(&gHttpRequestManager,
                                                          JString2String(env, userId),
                                                          &gRequestAddAnchorFriendCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.10.获取好友关系信息 ****************************************/
class RequestGetFriendRelationCallback : public IRequestGetFriendRelationCallback {
    void OnGetFriendRelation(HttpGetFriendRelationTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorFriendItem& item) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetFriendRelation( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        jobject jItem = getAnchorFriendItem(env, item);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "L";
            signature += ANCHOR_INFO_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutFriendRelation", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetFriendRelation( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
                env->DeleteLocalRef(jerrmsg);
            }
        }

        if(jItem != NULL){
            env->DeleteLocalRef(jItem);
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestGetFriendRelationCallback gRequestGetFriendRelationCallbackk;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniHangout
 * Method:    GetHangoutFriendRelation
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnGetHangoutFriendRelationCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniHangout_GetHangoutFriendRelation
        (JNIEnv * env, jclass cls, jstring anchorId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutFriendRelation( anchorId : %s )", JString2String(env, anchorId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetFriendRelation(&gHttpRequestManager,
                                                          JString2String(env, anchorId),
                                                          &gRequestGetFriendRelationCallbackk);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
