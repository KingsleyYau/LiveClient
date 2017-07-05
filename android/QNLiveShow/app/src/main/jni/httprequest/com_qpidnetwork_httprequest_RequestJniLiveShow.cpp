/*
 * com_qpidnetwork_httprequest_RequestJniLiveShow.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_httprequest_RequestJniLiveShow.h"
#include "RequestJniConvert.h"

/*********************************** 主播创建直播室 ****************************************/

class RequestLiveRoomCreateCallback : public IRequestLiveRoomCreateCallback{
	void OnCreateLiveRoom(HttpLiveRoomCreateTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onCreateLiveRoom( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onCreateLiveRoom", signature.c_str());
			FileLog("httprequest", "JNI::onCreateLiveRoom( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jroomUrl = env->NewStringUTF(roomUrl.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jroomId, jroomUrl);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jroomUrl);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestLiveRoomCreateCallback gRequestLiveRoomCreateCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    CreateLiveRoom
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnCreateLiveRoomCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_CreateLiveRoom
  (JNIEnv *env, jclass cls, jstring roomName, jstring roomPhotoId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.CreateLiveRoom(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, roomName),
                                        JString2String(env, roomPhotoId),
                                        &gRequestLiveRoomCreateCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 用于主播Crash或异常时，重新启动恢复状态使用  ****************************************/

class RequestCheckLiveRoomCallback : public IRequestCheckLiveRoomCallback{
	void OnCheckLiveRoom(HttpCheckLiveRoomTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnCheckLiveRoom( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onCreateLiveRoom", signature.c_str());
			FileLog("httprequest", "JNI::OnCheckLiveRoom( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jroomUrl = env->NewStringUTF(roomUrl.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jroomId, jroomUrl);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jroomUrl);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestCheckLiveRoomCallback gRequestCheckLiveRoomCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetCreatedLiveRoom
 * Signature: (Lcom/qpidnetwork/httprequest/OnCreateLiveRoomCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetCreatedLiveRoom
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.CheckLiveRoom(&gHttpRequestManager,
                                        gToken,
                                        &gRequestCheckLiveRoomCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 主播结束直播，退出房间  ****************************************/

class RequestCloseLiveRoomCallback : public IRequestCloseLiveRoomCallback{
	void OnCloseLiveRoom(HttpCloseLiveRoomTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnCloseLiveRoom( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnCloseLiveRoom( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestCloseLiveRoomCallback gRequestCloseLiveRoomCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    CloseLiveRoom
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_CloseLiveRoom
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.CloseLiveRoom(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, roomId),
                                        &gRequestCloseLiveRoomCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 用于获取固定前（20 暂定）观众列表  ****************************************/

class RequestGetLiveRoomFansListCallback : public IRequestGetLiveRoomFansListCallback{
	void OnGetLiveRoomFansList(HttpGetLiveRoomFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomFansList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(AUDIENCE_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomFansList( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");

			if( listItem.size() > 0 ) {
				jItemArray = env->NewObjectArray(listItem.size(), cls, NULL);
				int i = 0;
				for(ViewerItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
					jstring juserId = env->NewStringUTF(itr->userId.c_str());
					jstring jnickName = env->NewStringUTF(itr->nickName.c_str());
					jstring jphotoUrl = env->NewStringUTF(itr->photoUrl.c_str());

					jobject item = env->NewObject(cls, init,
							juserId,
							jnickName,
							jphotoUrl
							);

					env->SetObjectArrayElement(jItemArray, i, item);

					env->DeleteLocalRef(juserId);
					env->DeleteLocalRef(jnickName);
					env->DeleteLocalRef(jphotoUrl);

					env->DeleteLocalRef(item);
				}
			}
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += AUDIENCE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAudienceList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomFansList( callback : %p, signature : %s )",
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

RequestGetLiveRoomFansListCallback gRequestGetLiveRoomFansListCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetLimitAudienceListInRoom
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnGetAudienceListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetLimitAudienceListInRoom
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomFansList(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, roomId),
                                        &gRequestGetLiveRoomFansListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 根据分页Id及步长获取指定观众列表  ****************************************/

class RequestGetLiveRoomAllFansListCallback : public IRequestGetLiveRoomAllFansListCallback{
	void OnGetLiveRoomAllFansList(HttpGetLiveRoomAllFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(AUDIENCE_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");

			if( listItem.size() > 0 ) {
				jItemArray = env->NewObjectArray(listItem.size(), cls, NULL);
				int i = 0;
				for(ViewerItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
					jstring juserId = env->NewStringUTF(itr->userId.c_str());
					jstring jnickName = env->NewStringUTF(itr->nickName.c_str());
					jstring jphotoUrl = env->NewStringUTF(itr->photoUrl.c_str());

					jobject item = env->NewObject(cls, init,
							juserId,
							jnickName,
							jphotoUrl
							);

					env->SetObjectArrayElement(jItemArray, i, item);

					env->DeleteLocalRef(juserId);
					env->DeleteLocalRef(jnickName);
					env->DeleteLocalRef(jphotoUrl);

					env->DeleteLocalRef(item);
				}
			}
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += AUDIENCE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAudienceList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( callback : %p, signature : %s )",
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

RequestGetLiveRoomAllFansListCallback gRequestGetLiveRoomAllFansListCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetPagingAudienceListInRoom
 * Signature: (Ljava/lang/String;IILcom/qpidnetwork/httprequest/OnGetAudienceListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetPagingAudienceListInRoom
  (JNIEnv *env, jclass cls, jstring roomId, jint start, jint step, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomAllFansList(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, roomId),
                                        start,
                                        step,
                                        &gRequestGetLiveRoomAllFansListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 分页获取热播列表  ****************************************/

class RequestGetLiveRoomHotCallback : public IRequestGetLiveRoomHotCallback{
	void OnGetLiveRoomHot(HttpGetLiveRoomHotTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(LIVE_ROOMINFO_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
					"Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V");

			if( listItem.size() > 0 ) {
				jItemArray = env->NewObjectArray(listItem.size(), cls, NULL);
				int i = 0;
				for(HotItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
					jstring juserId = env->NewStringUTF(itr->userId.c_str());
					jstring jnickName = env->NewStringUTF(itr->nickName.c_str());
					jstring jphotoUrl = env->NewStringUTF(itr->photoUrl.c_str());
					jstring jroomId = env->NewStringUTF(itr->roomId.c_str());
					jstring jroomName = env->NewStringUTF(itr->roomName.c_str());
					jstring jroomPhotoUrl = env->NewStringUTF(itr->roomPhotoUrl.c_str());
					jstring jcountry = env->NewStringUTF(itr->country.c_str());
					int liveroomStatus = ReviewStatusToInt(itr->status);

					jobject item = env->NewObject(cls, init,
							juserId,
							jnickName,
							jphotoUrl,
							jroomId,
							jroomName,
							jroomPhotoUrl,
							liveroomStatus,
							itr->fansNum,
							jcountry
							);

					env->SetObjectArrayElement(jItemArray, i, item);

					env->DeleteLocalRef(juserId);
					env->DeleteLocalRef(jnickName);
					env->DeleteLocalRef(jphotoUrl);
					env->DeleteLocalRef(jroomId);
					env->DeleteLocalRef(jroomName);
					env->DeleteLocalRef(jroomPhotoUrl);
					env->DeleteLocalRef(jcountry);

					env->DeleteLocalRef(item);
				}
			}
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += LIVE_ROOMINFO_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetLiveRoomList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomAllFansList( callback : %p, signature : %s )",
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

RequestGetLiveRoomHotCallback gRequestGetLiveRoomHotCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetHotLiveList
 * Signature: (IILcom/qpidnetwork/httprequest/OnGetLiveRoomListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetHotLiveList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomHotList(&gHttpRequestManager,
                                        gToken,
                                        start,
                                        step,
                                        &gRequestGetLiveRoomHotCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.7.获取礼物列表  ****************************************/

class RequestGetLiveRoomAllGiftListCallback : public IRequestGetLiveRoomAllGiftListCallback{
	void OnGetLiveRoomAllGiftList(HttpGetLiveRoomAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomAllGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(LIVE_ROOM_GIFT_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomAllGiftList( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
					"Ljava/lang/String;DZII)V");

			if( itemList.size() > 0 ) {
				jItemArray = env->NewObjectArray(itemList.size(), cls, NULL);
				int i = 0;
				for(GiftItemList::const_iterator itr = itemList.begin(); itr != itemList.end(); itr++, i++) {
					jstring jgiftId = env->NewStringUTF(itr->giftId.c_str());
					jstring jname = env->NewStringUTF(itr->name.c_str());
					jstring jsmallImgUrl = env->NewStringUTF(itr->smallImgUrl.c_str());
					jstring jimgUrl = env->NewStringUTF(itr->imgUrl.c_str());
					jstring jsrcUrl = env->NewStringUTF(itr->srcUrl.c_str());
					int giftType = GiftTypeToInt(itr->type);

					jobject item = env->NewObject(cls, init,
							jgiftId,
							jname,
							jsmallImgUrl,
							jimgUrl,
							jsrcUrl,
							itr->coins,
							itr->isMulti_click,
							giftType,
							itr->update_time
							);

					env->SetObjectArrayElement(jItemArray, i, item);

					env->DeleteLocalRef(jgiftId);
					env->DeleteLocalRef(jname);
					env->DeleteLocalRef(jsmallImgUrl);
					env->DeleteLocalRef(jimgUrl);
					env->DeleteLocalRef(jsrcUrl);

					env->DeleteLocalRef(item);
				}
			}
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += LIVE_ROOM_GIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAllGift", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomAllGiftList( callback : %p, signature : %s )",
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

RequestGetLiveRoomAllGiftListCallback gRequestGetLiveRoomAllGiftListCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetAllGiftList
 * Signature: (Lcom/qpidnetwork/httprequest/OnGetAllGiftCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetAllGiftList
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomAllGiftList(&gHttpRequestManager,
                                        gToken,
                                        &gRequestGetLiveRoomAllGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 3.8.获取直播间可发送的礼物列表  ****************************************/

class RequestGetLiveRoomGiftListByUserIdCallback : public IRequestGetLiveRoomGiftListByUserIdCallback{
	void OnGetLiveRoomGiftListByUserId(HttpGetLiveRoomGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomGiftListByUserId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

    	jobjectArray jItemArray = NULL;
    	jclass jItemCls = env->FindClass("java/lang/String");
    	if (NULL != jItemCls) {
    		jItemArray = env->NewObjectArray(itemList.size(), jItemCls, NULL);
    		if (NULL != jItemArray) {
    			int i = 0;
    			for(list<string>::const_iterator itr = itemList.begin();
    				itr != itemList.end();
    				itr++)
    			{
    				jstring jItem = env->NewStringUTF((*itr).c_str());
    				if (NULL != jItem) {
    					env->SetObjectArrayElement(jItemArray, i, jItem);
    					i++;
    				}
    				env->DeleteLocalRef(jItem);
    			}
    		}
    	}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;[Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetSendableGiftList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomGiftListByUserId( callback : %p, signature : %s )",
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

RequestGetLiveRoomGiftListByUserIdCallback gRequestGetLiveRoomGiftListByUserIdCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetSendableGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnGetSendableGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetSendableGiftList
  (JNIEnv *env, jclass cls, jstring roomId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomGiftListByUserId(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, roomId),
                                        &gRequestGetLiveRoomGiftListByUserIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.9.获取指定礼物详情  ****************************************/

class RequestGetLiveRoomGiftDetailCallback : public IRequestGetLiveRoomGiftDetailCallback{
	void OnGetLiveRoomGiftDetail(HttpGetLiveRoomGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomGiftItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomGiftDetail( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

    	jobject jItem = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(LIVE_ROOM_GIFT_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomGiftDetail( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
					"Ljava/lang/String;DZII)V");

			jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
			jstring jname = env->NewStringUTF(item.name.c_str());
			jstring jsmallImgUrl = env->NewStringUTF(item.smallImgUrl.c_str());
			jstring jimgUrl = env->NewStringUTF(item.imgUrl.c_str());
			jstring jsrcUrl = env->NewStringUTF(item.srcUrl.c_str());
			int giftType = GiftTypeToInt(item.type);

			jItem = env->NewObject(cls, init,
					jgiftId,
					jname,
					jsmallImgUrl,
					jimgUrl,
					jsrcUrl,
					item.coins,
					item.isMulti_click,
					giftType,
					item.update_time
					);

			env->DeleteLocalRef(jgiftId);
			env->DeleteLocalRef(jname);
			env->DeleteLocalRef(jsmallImgUrl);
			env->DeleteLocalRef(jimgUrl);
			env->DeleteLocalRef(jsrcUrl);
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += LIVE_ROOM_GIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetGiftDetail", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomGiftDetail( callback : %p, signature : %s )",
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

RequestGetLiveRoomGiftDetailCallback gRequestGetLiveRoomGiftDetailCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetGiftDetail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnGetGiftDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetGiftDetail
  (JNIEnv *env, jclass cls, jstring giftId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomGiftDetail(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, giftId),
                                        &gRequestGetLiveRoomGiftDetailCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.10.获取开播封面图列表  ****************************************/

class RequestGetLiveRoomPhotoListCallback : public IRequestGetLiveRoomPhotoListCallback{
	void OnGetLiveRoomPhotoList(HttpGetLiveRoomPhotoListTask* task, bool success, int errnum, const string& errmsg, const CoverPhotoItemList& itemList){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomPhotoList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(LIVE_ROOM_COVERPHOTO_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomPhotoList( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;IZ)V");

			if( itemList.size() > 0 ) {
				jItemArray = env->NewObjectArray(itemList.size(), cls, NULL);
				int i = 0;
				for(CoverPhotoItemList::const_iterator itr = itemList.begin(); itr != itemList.end(); itr++, i++) {
					jstring jphotoId = env->NewStringUTF(itr->photoId.c_str());
					jstring jphotoUrl = env->NewStringUTF(itr->photoUrl.c_str());
					int coverPhotoStatus = CoverPhotoStatusToInt(itr->status);

					jobject item = env->NewObject(cls, init,
							jphotoId,
							jphotoUrl,
							coverPhotoStatus,
							itr->isIn_use
							);

					env->SetObjectArrayElement(jItemArray, i, item);

					env->DeleteLocalRef(jphotoId);
					env->DeleteLocalRef(jphotoUrl);

					env->DeleteLocalRef(item);
				}
			}
		}

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += LIVE_ROOM_COVERPHOTO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetLiveCoverPhotoList", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomPhotoList( callback : %p, signature : %s )",
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

RequestGetLiveRoomPhotoListCallback gRequestGetLiveRoomPhotoListCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    GetLiveCoverPhotoList
 * Signature: (Lcom/qpidnetwork/httprequest/OnGetLiveCoverPhotoListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_GetLiveCoverPhotoList
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomPhotoList(&gHttpRequestManager,
                                        gToken,
                                        &gRequestGetLiveRoomPhotoListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.11. 添加开播封面图  ****************************************/

class RequestAddLiveRoomPhotoCallback : public IRequestAddLiveRoomPhotoCallback{
	void OnAddLiveRoomPhoto(HttpAddLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnAddLiveRoomPhoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnAddLiveRoomPhoto( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestAddLiveRoomPhotoCallback gRequestAddLiveRoomPhotoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    AddLiveCoverPhoto
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_AddLiveCoverPhoto
  (JNIEnv *env, jclass cls, jstring photoId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.AddLiveRoomPhoto(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, photoId),
                                        &gRequestAddLiveRoomPhotoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 3.12. 设置开播默认使用封面图  ****************************************/

class RequestSetUsingLiveRoomPhotoCallback : public IRequestSetUsingLiveRoomPhotoCallback{
	void OnSetUsingLiveRoomPhoto(HttpSetUsingLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnSetUsingLiveRoomPhoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnSetUsingLiveRoomPhoto( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestSetUsingLiveRoomPhotoCallback gRequestSetUsingLiveRoomPhotoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    SetDefaultUsedCoverPhoto
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_SetDefaultUsedCoverPhoto
  (JNIEnv *env, jclass cls, jstring photoId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.SetUsingLiveRoomPhoto(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, photoId),
                                        &gRequestSetUsingLiveRoomPhotoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 3.13. 删除开播封面图  ****************************************/

class RequestDelLiveRoomPhotoCallback : public IRequestDelLiveRoomPhotoCallback{
	void OnDelLiveRoomPhoto(HttpDelLiveRoomPhotoTast* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnDelLiveRoomPhoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnDelLiveRoomPhoto( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestDelLiveRoomPhotoCallback gRequestDelLiveRoomPhotoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniLiveShow
 * Method:    DeleteLiveCoverPhoto
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniLiveShow_DeleteLiveCoverPhoto
  (JNIEnv *env, jclass cls, jstring photoId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.DelLiveRoomPhoto(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, photoId),
                                        &gRequestDelLiveRoomPhotoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
