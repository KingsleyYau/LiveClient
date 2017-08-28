/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow.h"

/*********************************** 3.1.分页获取热播列表  ****************************************/

class RequestGetAnchorListCallback : public IRequestGetAnchorListCallback{
	void OnGetAnchorList(HttpGetAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getHotListArray(env, listItem);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HOTLIST_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHotList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetAnchorList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestGetAnchorListCallback gRequestGetAnchorListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetHotLiveList
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetLiveRoomListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetHotLiveList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetAnchorList(&gHttpRequestManager,
                                        start,
                                        step,
                                        &gRequestGetAnchorListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.2.获取Following列表  ****************************************/

class RequestGetFollowListCallback : public IRequestGetFollowListCallback{
	void OnGetFollowList(HttpGetFollowListTask* task, bool success, int errnum, const string& errmsg, const FollowItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetFollowList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getFollowingListArray(env, listItem);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += FOLLOWINGLIST_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetFollowingList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetFollowList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestGetFollowListCallback gRequestGetFollowListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetFollowingLiveList
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetFollowingListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetFollowingLiveList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetFollowList(&gHttpRequestManager,
                                        start,
                                        step,
                                        &gRequestGetFollowListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.3.获取本人有效直播间及邀请信息  ****************************************/

class RequestGetRoomInfoCallback : public IRequestGetRoomInfoCallback{
	void OnGetRoomInfo(HttpGetRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpGetRoomInfoItem& Item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetLivingRoomAndInvites( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        //直播中列表
		jobjectArray jvalidItemArray = getValidRoomArray(env, Item.roomList);
		//立即邀请中
		jobjectArray jimmediateInviteArray = getImmediateInviteArray(env, Item.inviteList);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += VALID_LIVEROOM_ITEM_CLASS;
			signature += ";";
			signature += "[L";
			signature += IMMEDIATE_INVITE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetLivingRoomAndInvites", signature.c_str());
			FileLog("httprequest", "JNI::onGetLivingRoomAndInvites( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jvalidItemArray, jimmediateInviteArray);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jvalidItemArray != NULL){
			env->DeleteLocalRef(jvalidItemArray);
		}

		if(jimmediateInviteArray != NULL){
			env->DeleteLocalRef(jimmediateInviteArray);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetRoomInfoCallback gRequestGetRoomInfoCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetLivingRoomAndInvites
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetLivingRoomAndInvitesCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetLivingRoomAndInvites
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetRoomInfo(&gHttpRequestManager,
                                        &gRequestGetRoomInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.4.获取直播间观众头像列表  ****************************************/

class RequestLiveFansListCallback : public IRequestLiveFansListCallback{
	void OnLiveFansList(HttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const HttpLiveFansList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetAudienceList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getAudienceArray(env, listItem);

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
			FileLog("httprequest", "JNI::onGetAudienceList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestLiveFansListCallback gRequestLiveFansListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetAudienceListInRoom
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetAudienceListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetAudienceListInRoom
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.LiveFansList(&gHttpRequestManager,
    									JString2String(env, roomId),
                                        &gRequestLiveFansListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.5.获取礼物列表  ****************************************/

class RequestGetAllGiftListCallback : public IRequestGetAllGiftListCallback{
	void OnGetAllGiftList(HttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getNormalGiftArray(env, itemList);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += NORMAL_GIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetGiftList", signature.c_str());
			FileLog("httprequest", "JNI::onGetGiftList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestGetAllGiftListCallback gRequestGetAllGiftListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetAllGiftList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetAllGiftList
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetAllGiftList(&gHttpRequestManager,
                                        &gRequestGetAllGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.6.获取直播间可发送的礼物列表  ****************************************/

class RequestGetGiftListByUserIdCallback : public IRequestGetGiftListByUserIdCallback{
	void OnGetGiftListByUserId(HttpGetGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetSendableGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getJavaStringArray(env, itemList);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;[Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetSendableGiftList", signature.c_str());
			FileLog("httprequest", "JNI::onGetSendableGiftList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestGetGiftListByUserIdCallback gRequestGetGiftListByUserIdCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetSendableGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetSendableGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetSendableGiftList
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetGiftListByUserId(&gHttpRequestManager,
    									JString2String(env, roomId),
                                        &gRequestGetGiftListByUserIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.7.获取指定礼物详情  ****************************************/

class RequestGetGiftDetailCallback : public IRequestGetGiftDetailCallback{
	void OnGetGiftDetail(HttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpGiftInfoItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetGiftDetail( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getGiftDetailItem(env, item);

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
			FileLog("httprequest", "JNI::onGetGiftDetail( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItem);
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

RequestGetGiftDetailCallback gRequestGetGiftDetailCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetGiftDetail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetGiftDetail
  (JNIEnv *env, jclass cls, jstring giftId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetGiftDetail(&gHttpRequestManager,
    									JString2String(env, giftId),
                                        &gRequestGetGiftDetailCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.8.获取文本表情列表  ****************************************/

class RequestGetEmoticonListCallback : public IRequestGetEmoticonListCallback{
	void OnGetEmoticonList(HttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const EmoticonItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetEmotionList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getEmotionCategoryArray(env, listItem);

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
			FileLog("httprequest", "JNI::onGetEmotionList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

RequestGetEmoticonListCallback gRequestGetEmoticonListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetEmotionList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetEmotionListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetEmotionList
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetEmoticonList(&gHttpRequestManager,
                                        &gRequestGetEmoticonListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.9.获取指定立即私密邀请信息  ****************************************/

class RequestGetInviteInfoCallback : public IRequestGetInviteInfoCallback{
	void OnGetInviteInfo(HttpGetInviteInfoTask* task, bool success, int errnum, const string& errmsg, const HttpInviteInfoItem& inviteItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetImediateInviteInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getImmediateInviteItem(env, inviteItem);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += IMMEDIATE_INVITE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetImediateInviteInfo", signature.c_str());
			FileLog("httprequest", "JNI::onGetImediateInviteInfo( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItem);
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

RequestGetInviteInfoCallback gRequestGetInviteInfoCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetImediateInviteInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetImediateInviteInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetImediateInviteInfo
  (JNIEnv *env, jclass cls, jstring inviteId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetInviteInfo(&gHttpRequestManager,
    									JString2String(env, inviteId),
                                        &gRequestGetInviteInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
