/*
 * com_qpidnetwork_httprequest_RequestJniUserInfo.cpp
 *
 *  Created on: 2017-5-25
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_httprequest_RequestJniUserInfo.h"
#include "RequestJniConvert.h"


/*********************************** 4.1.获取用户头像接口 ****************************************/

class RequestGetLiveRoomUserPhotoCallback : public IRequestGetLiveRoomUserPhotoCallback{
	void OnGetLiveRoomUserPhoto(HttpGetLiveRoomUserPhotoTask* task, bool success, int errnum, const string& errmsg, const string& photoUrl){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomUserPhoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetUserPhoto", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomUserPhoto( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jphotoUrl);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jphotoUrl);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetLiveRoomUserPhotoCallback gRequestGetLiveRoomUserPhotoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniUserInfo
 * Method:    GetUserPhotoInfo
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/httprequest/OnGetUserPhotoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniUserInfo_GetUserPhotoInfo
  (JNIEnv *env, jclass cls, jstring userId, jint photoType, jobject callback){

    jlong taskId = -1;
    PhotoType type = IntToPhotoType(photoType);
    taskId = gHttpRequestController.GetLiveRoomUserPhoto(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, userId),
                                        type,
                                        &gRequestGetLiveRoomUserPhotoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.2.获取用户个人资料 ****************************************/

class RequestGetLiveRoomModifyInfoCallback : public IRequestGetLiveRoomModifyInfoCallback{
	void OnGetLiveRoomModifyInfo(HttpGetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomPersonalInfoItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomModifyInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /* turn object to java object here */
        jobject jItem = NULL;
        JavaItemMap::const_iterator itr = gJavaItemMap.find(USERINFO_ITEM_CLASS);
        if( itr != gJavaItemMap.end() ) {
            jclass cls = env->GetObjectClass(itr->second);
            if( cls != NULL) {
                jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V");

                FileLog("httprequest", "LiveChat.Native::UserInfoItem( GetMethodID <init> : %p )", init);

                jstring jphotoId = env->NewStringUTF(item.photoId.c_str());
                jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
                jstring jnickName = env->NewStringUTF(item.nickName.c_str());
                int gender = GenderToInt(item.gender);
                jstring jbirthday = env->NewStringUTF(item.birthday.c_str());

                if( init != NULL ) {
                    jItem = env->NewObject(cls, init,
                    		jphotoId,
                    		jphotoUrl,
                    		jnickName,
                    		gender,
                    		jbirthday
                            );
                    FileLog("httprequest", "LiveChat.Native::OnGetLiveRoomModifyInfo( NewObject: %p)", jItem);
                }
                env->DeleteLocalRef(jphotoId);
                env->DeleteLocalRef(jphotoUrl);
                env->DeleteLocalRef(jnickName);
                env->DeleteLocalRef(jbirthday);
            }
        }

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += USERINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetProfile", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomModifyInfo( callback : %p, signature : %s )",
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

RequestGetLiveRoomModifyInfoCallback gRequestGetLiveRoomModifyInfoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniUserInfo
 * Method:    GetUserProfile
 * Signature: (Lcom/qpidnetwork/httprequest/OnGetProfileCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniUserInfo_GetUserProfile
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomModifyInfo(&gHttpRequestManager,
                                        gToken,
                                        &gRequestGetLiveRoomModifyInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 4.3.编辑个人信息  ****************************************/

class RequestSetLiveRoomModifyInfoCallback : public IRequestSetLiveRoomModifyInfoCallback{
	void OnSetLiveRoomModifyInfo(HttpSetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnSetLiveRoomModifyInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnSetLiveRoomModifyInfo( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);;
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestSetLiveRoomModifyInfoCallback gRequestSetLiveRoomModifyInfoCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniUserInfo
 * Method:    EditUserProfile
 * Signature: (Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniUserInfo_EditUserProfile
  (JNIEnv *env, jclass cls, jstring photoUrl, jstring nickName, jint gender, jstring birthday, jobject callback){

    jlong taskId = -1;
    Gender genderType = IntToGender(gender);
    taskId = gHttpRequestController.SetLiveRoomModifyInfo(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, photoUrl),
                                        JString2String(env, nickName),
                                        genderType,
                                        JString2String(env, birthday),
                                        &gRequestSetLiveRoomModifyInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
