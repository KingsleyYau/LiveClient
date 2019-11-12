/*
 * com_qpidnetwork_anchor_httprequest_RequestJniLiveShow.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_anchor_httprequest_RequestJniLiveShow.h"

/*********************************** 3.1.获取直播间观众头像列表  ****************************************/

class RequestZBLiveFansListCallback : public IRequestZBLiveFansListCallback {
	void OnZBLiveFansList(ZBHttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansList& listItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAudienceList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getAudienceArray(env, listItem);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += AUDIENCE_INFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAudienceList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAudienceList( callback : %p, signature : %s )",
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

RequestZBLiveFansListCallback gRequestZBLiveFansListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GetAudienceListInRoom
 * Signature: (Ljava/lang/String;IILcom/qpidnetwork/livemodule/httprequest/OnGetAudienceListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetAudienceListInRoom
  (JNIEnv *env, jclass cls, jstring roomId, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAudienceListInRoom( roomId : %s, start : %d, step: %d )",
            JString2String(env, roomId).c_str(), start, step);
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBLiveFansList(&gHttpRequestManager,
    									JString2String(env, roomId),
    									start,
    									step,
                                        &gRequestZBLiveFansListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.2.获取指定观众信息  ****************************************/

class RequestZBGetNewFansBaseInfoCallback : public IRequestZBGetNewFansBaseInfoCallback {
	void OnZBGetNewFansBaseInfo(ZBHttpGetNewFansBaseInfoTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansInfoItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAudienceDetailInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = getAudienceBaseInfoItem(env, item);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += AUDIENCE_BASE_INFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAudienceDetailInfo", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetAudienceDetailInfo( callback : %p, signature : %s )",
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

RequestZBGetNewFansBaseInfoCallback gRequestZBGetNewFansBaseInfoCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GetAudienceDetailInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetAudienceDetailInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetAudienceDetailInfo
  (JNIEnv *env, jclass cls, jstring userId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAudienceDetailInfo( userId : %s )",
            JString2String(env, userId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetNewFansBaseInfo(&gHttpRequestManager,
    									JString2String(env, userId),
                                        &gRequestZBGetNewFansBaseInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.3.获取礼物列表  ****************************************/

class RequestZBGetAllGiftListCallback : public IRequestZBGetAllGiftListCallback {
    void OnZBGetAllGiftList(ZBHttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBGiftItemList& itemList) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobjectArray jItemArray = getGiftArray(env, itemList);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "[L";
            signature += GIFT_DETAIL_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetGiftList", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetGiftList( callback : %p, signature : %s )",
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

RequestZBGetAllGiftListCallback gRequestZBGetAllGiftListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GetAllGiftList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetAllGiftList
        (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAllGiftList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetAllGiftList(&gHttpRequestManager,
                                                   &gRequestZBGetAllGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.4.获取主播直播间礼物列表  ****************************************/

class RequestZBGiftListCallback : public IRequestZBGiftListCallback {
    void OnZBGiftList(ZBHttpGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftLimitNumItemList& itemList) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGiftLimitNumList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobjectArray jItemArray = getGiftLimitNumArray(env, itemList);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "[L";
            signature += GIFT_LIMIT_NUM_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGiftLimitNumList", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGiftLimitNumList( callback : %p, signature : %s )",
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

RequestZBGiftListCallback gRequestZBGiftListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GiftLimitNumList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGiftLimitNumListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GiftLimitNumList
        (JNIEnv *env, jclass cls, jstring roomId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GiftLimitNumList( roomId : %s )",
            JString2String(env, roomId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGiftList(&gHttpRequestManager,
                                               JString2String(env, roomId),
                                               &gRequestZBGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.5.获取指定礼物详情  ****************************************/

class RequestZBGetGiftDetailCallback : public IRequestZBGetGiftDetailCallback {
	void OnZBGetGiftDetail(ZBHttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftInfoItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI:::onGetGiftDetail( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getGiftDetailItem(env, item);
		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += GIFT_DETAIL_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetGiftDetail", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetGiftDetail( callback : %p, signature : %s )",
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

RequestZBGetGiftDetailCallback gRequestZBGetGiftDetailCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GetGiftDetail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetGiftDetail
  (JNIEnv *env, jclass cls, jstring giftId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetGiftDetail( giftId : %s )",
            JString2String(env, giftId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetGiftDetail(&gHttpRequestManager,
    									JString2String(env, giftId),
                                        &gRequestZBGetGiftDetailCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.6.获取文本表情列表  ****************************************/

class RequestZBGetEmoticonListCallback : public IRequestZBGetEmoticonListCallback {
	void OnZBGetEmoticonList(ZBHttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const ZBEmoticonItemList& listItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetEmotionList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getEmotionCategoryArray(env, listItem);
		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += EMOTION_CATEGORY_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetEmotionList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetEmotionList( callback : %p, signature : %s )",
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

RequestZBGetEmoticonListCallback gRequestZBGetEmoticonListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    GetEmotionList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetEmotionListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetEmotionList
  (JNIEnv *env, jclass cls, jobject callback){

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetEmotionList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetEmoticonList(&gHttpRequestManager,
                                        &gRequestZBGetEmoticonListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.7.主播回复才艺点播邀请  ****************************************/

class RequestZBDealTalentRequestCallback : public IRequestZBDealTalentRequestCallback {
    void OnZBDealTalentRequest(ZBHttpDealTalentRequestTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBDealTalentRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBDealTalentRequest( callback : %p, signature : %s )",
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

RequestZBDealTalentRequestCallback gRequestZBDealTalentRequestCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    DealTalentRequest
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_DealTalentRequest
        (JNIEnv * env, jclass cls, jstring talentInviteId, jint status, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::DealTalentRequest( talentInviteId : %s, status : %d )",
            JString2String(env, talentInviteId).c_str(), status);
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBDealTalentRequest(&gHttpRequestManager,
                                                        JString2String(env, talentInviteId),
                                                        IntToTalentReplyTypeOperateType(status),
                                                      &gRequestZBDealTalentRequestCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.8.设置主播公开直播间自动邀请状态 ****************************************/
class RequestZBSetAutoPushCallback : public IRequestZBSetAutoPushCallback {
    void OnZBSetAutoPush(ZBHttpSetAutoPushTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBSetAutoPush( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBSetAutoPush( callback : %p, signature : %s )",
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

RequestZBSetAutoPushCallback gRequestZBSetAutoPushCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniLiveShow
 * Method:    SetAutoPush
 * Signature: (ILcom/qpidnetwork/anchor/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_SetAutoPush
        (JNIEnv * env, jclass cls, jint status, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetAutoPush( status : %d )", status);
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBSetAutoPush(&gHttpRequestManager,
                                                  IntToSetPushTypeOperateType(status),
                                                  &gRequestZBSetAutoPushCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.9.获取主播当前直播间信息 ****************************************/
class RequestGetCurrentRoomInfoCallback : public IRequestGetCurrentRoomInfoCallback {
    void OnGetCurrentRoomInfo(HttpGetCurrentRoomInfoTask* task, bool success, int errnum, const string& errmsg, ZBHttpCurrentRoomItem roomItem) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCurrentRoomInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        jobject jItem = getCurrentRoomItem(env, roomItem);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
                    signature += "L";
                    signature += PUSH_ROOM_INFO_ITEM_CLASS;
                    signature += ";";
                   signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCurrentRoomInfo", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCurrentRoomInfo( callback : %p, signature : %s )",
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

RequestGetCurrentRoomInfoCallback gRequestGetCurrentRoomInfoCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniLiveShow_GetCurrentRoomInfo
        (JNIEnv * env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCurrentRoomInfo()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetCurrentRoomInfo(&gHttpRequestManager,
                                                  &gRequestGetCurrentRoomInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
