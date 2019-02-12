/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniProgram.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniProgram.h"

/*********************************** 9.1.获取节目列表未读  ****************************************/

class RequestGetNoReadNumProgramCallback : public IRequestGetNoReadNumProgramCallback {
	void OnGetNoReadNumProgram(HttpGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetNoReadNumProgram( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;I)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetNoReadNumProgram", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetNoReadNumProgramCallback( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, num);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetNoReadNumProgramCallback gRequestGetNoReadNumProgramCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetNoReadNumProgram
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetNoReadNumProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetNoReadNumProgram
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetNoReadNumProgram()");
	jlong taskId = -1;
	taskId = gHttpRequestController.GetNoReadNumProgram(&gHttpRequestManager,
															&gRequestGetNoReadNumProgramCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 9.2.获取节目列表  ****************************************/

class RequestGetProgramListCallback : public IRequestGetProgramListCallback{
	void OnGetProgramList(HttpGetProgramListTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetProgramList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getProgramInfoArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetProgramList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetProgramList( callback : %p, signature : %s )",
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

RequestGetProgramListCallback gRequestGetProgramListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetProgramList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetProgramListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetProgramList
		(JNIEnv *env, jclass cls, jint type, jint start, jint step, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetProgramList( type : %d, start : %d, step : %d)",
            type, start, step);
	jlong taskId = -1;
    ProgramListType jtype = IntToProgramListType(type);
	taskId = gHttpRequestController.GetProgramList(&gHttpRequestManager,
                                                   jtype,
                                                   start,
                                                   step,
												  &gRequestGetProgramListCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 9.3.购买节目 ****************************************/

class RequestBuyProgramCallback : public IRequestBuyProgramCallback{
	void OnBuyProgram(HttpBuyProgramTask* task, bool success, int errnum, const string& errmsg, double leftCredit) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnBuyProgram( success : %s, task : %p, isAttachThread:%d, left : %f )", success?"true":"false", task, isAttachThread, leftCredit);


		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;D)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onBuyProgram", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnBuyProgram( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, leftCredit);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestBuyProgramCallback gRequestBuyProgramCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    BuyProgram
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnBuyProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_BuyProgram
		(JNIEnv *env, jclass cls, jstring liveShowId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::BuyProgram( liveShowId : %s)",
			JString2String(env, liveShowId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.BuyProgram(&gHttpRequestManager,
												 JString2String(env, liveShowId),
												 &gRequestBuyProgramCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 9.4.关注/取消关注节目  ****************************************/

class RequestChangeFavouriteCallback : public IRequestChangeFavouriteCallback{
	void OnFollowShow(HttpChangeFavouriteTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnFollowShow( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onFollowShow", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnFollowShow( callback : %p, signature : %s )",
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

RequestChangeFavouriteCallback gRequestChangeFavouriteCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    FollowShow
 * Signature: (Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnChangeFavouriteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_FollowShow
		(JNIEnv *env, jclass cls, jstring liveShowId, jboolean isCancel, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::FollowShow() liveShowId:%s isCancel:%d", JString2String(env, liveShowId).c_str(), isCancel);
	jlong taskId = -1;
	taskId = gHttpRequestController.FollowShow(&gHttpRequestManager,
                                               JString2String(env, liveShowId),
                                               isCancel,
                                               &gRequestChangeFavouriteCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 9.5.获取可进入的节目信息  ****************************************/

class RequestGetShowRoomInfoCallback : public IRequestGetShowRoomInfoCallback{
    void OnGetShowRoomInfo(HttpGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpProgramInfoItem& item, const string& roomId, const HttpAuthorityItem& priv) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetShowRoomInfo( success : %s, task : %p, isAttachThread:%d  roomId:%s oneonone:%d booking:%d)", success?"true":"false", task, isAttachThread, roomId.c_str(), priv.privteLiveAuth, priv.bookingPriLiveAuth);

        jobject jItem = getProgramInfoItem(env, item);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

        jobject jprivItem = getHttpAuthorityItem(env, priv);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "L";
            signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
            signature += ";Ljava/lang/String;";
            signature += "L";
            signature += HTTP_AUTHORITY_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetShowRoomInfo", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetShowRoomInfo( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem, jroomId, jprivItem);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
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

RequestGetShowRoomInfoCallback gRequestGetShowRoomInfoCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetShowRoomInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetShowRoomInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetShowRoomInfo
        (JNIEnv *env, jclass cls, jstring liveShowId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetShowRoomInfo() liveShowId:%s", JString2String(env, liveShowId).c_str());
    jlong taskId = -1;
	taskId = gHttpRequestController.GetShowRoomInfo(&gHttpRequestManager,
                                                    JString2String(env, liveShowId),
												    &gRequestGetShowRoomInfoCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 9.6.获取节目推荐列表 ****************************************/

class RequestShowListWithAnchorIdTCallback : public IRequestShowListWithAnchorIdTCallback{
    void OnShowListWithAnchorId(HttpShowListWithAnchorIdTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnShowListWithAnchorId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobjectArray jItemArray = getProgramInfoArray(env, list);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "[L";
            signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onShowListWithAnchorId", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnShowListWithAnchorId( callback : %p, signature : %s )",
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

RequestShowListWithAnchorIdTCallback gRequestShowListWithAnchorIdTCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    ShowListWithAnchorId
 * Signature: (IIILjava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnShowListWithAnchorIdCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_ShowListWithAnchorId
        (JNIEnv *env, jclass cls, jint type, jint start, jint step, jstring anchorId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::ShowListWithAnchorId( type : %d, start : %d, step : %d anchorID:%s)",
            type, start, step, JString2String(env, anchorId).c_str());
    jlong taskId = -1;
    ShowRecommendListType jtype = IntToShowRecommendListType(type);
    taskId = gHttpRequestController.ShowListWithAnchorId(&gHttpRequestManager,
                                                   JString2String(env, anchorId),
                                                   start,
                                                   step,
                                                   jtype,
                                                   &gRequestShowListWithAnchorIdTCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}