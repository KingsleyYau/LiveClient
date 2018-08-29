/*
 * com_qpidnetwork_anchor_httprequest_RequestJniProgram.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_anchor_httprequest_RequestJniProgram.h"

/*********************************** 7.1.获取节目列表 ****************************************/

class RequestAnchorGetProgramListCallback : public IRequestAnchorGetProgramListCallback {
	void OnAnchorGetProgramList(HttpAnchorGetProgramListTask* task, bool success, int errnum, const string& errmsg, const AnchorProgramInfoList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorGetProgramList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getProgramInfoArray(env, list);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PROGRAM_INFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetProgramList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetProgramLis( callback : %p, signature : %s )",
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

RequestAnchorGetProgramListCallback gRequestAnchorGetProgramListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetProgramList
 * Signature: (IIILcom/qpidnetwork/anchor/httprequest/OnGetProgramListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetProgramList
  (JNIEnv *env, jclass cls, jint type, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetProgramList( type : %d, start : %d, step: %d )",
            type, start, step);
    jlong taskId = -1;
    AnchorProgramListType jtype = IntToAnchorProgramListTypeOperateType(type);
    taskId = gHttpRequestController.AnchorGetProgramList(&gHttpRequestManager,
    									                 start,
    									                 step,
                                                         jtype,
                                                         &gRequestAnchorGetProgramListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 7.2.主播推荐好友给观众  ****************************************/

class RequestAnchorGetNoReadNumProgramCallback: public IRequestAnchorGetNoReadNumProgramCallback {
	void OnAnchorGetNoReadNumProgram(HttpAnchorGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorGetNoReadNumProgram( success : %s, task : %p, isAttachThread:%d, num: %d)", success?"true":"false", task, isAttachThread, num);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;I)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetNoReadNumProgram", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorGetNoReadNumProgram( callback : %p, signature : %s )",
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

RequestAnchorGetNoReadNumProgramCallback gRequestAnchorGetNoReadNumProgramCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetNoReadNumProgram
 * Signature: (Lcom/qpidnetwork/anchor/httprequest/OnGetNoReadNumProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetNoReadNumProgram
  (JNIEnv *env, jclass cls, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetNoReadNumProgram( )");
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorGetNoReadNumProgram(&gHttpRequestManager,
                                        &gRequestAnchorGetNoReadNumProgramCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 7.3.获取可进入的节目信息  ****************************************/

class RequestAnchorGetShowRoomInfoCallback : public IRequestAnchorGetShowRoomInfoCallback {
    void OnAnchorGetShowRoomInfo(HttpAnchorGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, HttpAnchorProgramInfoItem showInfo, const string& roomId) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorGetShowRoomInfo( success : %s, task : %p, isAttachThread:%d, rooomId : %s )", success?"true":"false", task, isAttachThread, roomId.c_str());

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        jobject jItemInfo = getProgramInfoItem(env, showInfo);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "L";
            signature += PROGRAM_INFO_ITEM_CLASS;
            signature += ";";
            signature += "Ljava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetShowRoomInfo", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorGetShowRoomInfo( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemInfo, jroomId);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
                if ( jItemInfo != NULL) {
                    env->DeleteLocalRef(jItemInfo);
                }
            }
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorGetShowRoomInfoCallback gRequestAnchorGetShowRoomInfoCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetShowRoomInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnGetShowRoomInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetShowRoomInfo
        (JNIEnv *env, jclass cls, jstring liveShowId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetShowRoomInfo() liveShowId: %s", JString2String(env, liveShowId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorGetShowRoomInfo(&gHttpRequestManager,
                                                    JString2String(env, liveShowId).c_str(),
                                                    &gRequestAnchorGetShowRoomInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 7.4.获取未结束的多人互动直播间列表  ****************************************/

class RequestAnchorCheckIsPlayProgramCallback : public IRequestAnchorCheckIsPlayProgramCallback {
    void OnAnchorCheckPublicRoomType(HttpAnchorCheckIsPlayProgramTask* task, bool success, int errnum, const string& errmsg, AnchorPublicRoomType liveShowType, const string& liveShowId) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorCheckPublicRoomType( success : %s, task : %p, isAttachThread:%d liveShowType:%d, liveShowId;%s)", success?"true":"false", task, isAttachThread, liveShowType, liveShowId.c_str());

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;ILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onCheckPublicRoomType", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAnchorCheckPublicRoomType( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                int jliveShowType =  AnchorPublicRoomTypeToInt(liveShowType);
                jstring jliveShowId = env->NewStringUTF(liveShowId.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jliveShowType, jliveShowId);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jliveShowId);
            }
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestAnchorCheckIsPlayProgramCallback gRequestAnchorCheckIsPlayProgramCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    CheckPublicRoomType
 * Signature: (Lcom/qpidnetwork/anchor/httprequest/OnCheckPublicRoomTypeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_CheckPublicRoomType
        (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CheckPublicRoomType( )");
    jlong taskId = -1;
    taskId = gHttpRequestController.AnchorCheckPublicRoomType(&gHttpRequestManager,
                                               &gRequestAnchorCheckIsPlayProgramCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}