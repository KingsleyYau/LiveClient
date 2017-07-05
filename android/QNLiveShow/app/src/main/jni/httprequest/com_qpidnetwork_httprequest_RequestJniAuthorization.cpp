/*
 * com_qpidnetwork_httprequest_RequestJniAuthorization.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include <common/command.h>
#include "com_qpidnetwork_httprequest_RequestJniAuthorization.h"

/*********************************** 验证手机号有效性 ****************************************/

class RequestRegisterCheckPhoneCallback : public IRequestRegisterCheckPhoneCallback{
	void OnRegisterCheckPhone(HttpRegisterCheckPhoneTask* task, bool success, int errnum, const string& errmsg, bool isRegistered){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onVerifyPhoneNumber( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Z)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onVerifyPhoneNumber", signature.c_str());
			FileLog("httprequest", "JNI::onVerifyPhoneNumber( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, isRegistered);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestRegisterCheckPhoneCallback gRequestRegisterCheckPhoneCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    VerifyPhoneNumber
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnVerifyPhoneNumberCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_VerifyPhoneNumber
  (JNIEnv *env, jclass cls, jstring phoneNumber, jstring areaNo, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.RegisterCheckPhone(&gHttpRequestManager,
                                        JString2String(env, phoneNumber),
                                        JString2String(env, areaNo),
                                        &gRequestRegisterCheckPhoneCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 获取手机验证码 ****************************************/

class RequestRegisterGetSMSCodeCallback : public IRequestRegisterGetSMSCodeCallback{
	void OnRegisterGetSMSCode(HttpRegisterGetSMSCodeTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnRegisterGetSMSCode( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnRegisterGetSMSCode( callback : %p, signature : %s )",
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

RequestRegisterGetSMSCodeCallback gRequestRegisterGetSMSCodeCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    GetRegisterVerifyCode
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_GetRegisterVerifyCode
  (JNIEnv *env, jclass cls, jstring phoneNumber, jstring areaNo, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.RegisterGetSMSCode(&gHttpRequestManager,
                                        JString2String(env, phoneNumber),
                                        JString2String(env, areaNo),
                                        &gRequestRegisterGetSMSCodeCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 手机号码注册接口 ****************************************/

class RequestRegisterPhoneCallback : public IRequestRegisterPhoneCallback{
	void OnRegisterPhone(HttpRegisterPhoneTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnRegisterPhone( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnRegisterPhone( callback : %p, signature : %s )",
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

RequestRegisterPhoneCallback gRequestRegisterPhoneCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    PhoneNumberRegister
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_PhoneNumberRegister
  (JNIEnv *env, jclass cls, jstring phoneNumber, jstring areaNo, jstring verifyCode, jstring password, jstring deviceId, jobject callback){

    jlong taskId = -1;
    string strModel = GetPhoneModel();
    string strManufacturer = GetPhoneManufacturer();

    taskId = gHttpRequestController.RegisterPhone(&gHttpRequestManager,
                                        JString2String(env, phoneNumber),
                                        JString2String(env, areaNo),
                                        JString2String(env, verifyCode),
                                        JString2String(env, password),
                                        JString2String(env, deviceId),
                                        strModel,
                                        strManufacturer,
                                        &gRequestRegisterPhoneCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 登录接口 ****************************************/

class RequestLoginCallback : public IRequestLoginCallback{
	void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onRequestLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /* save token */
		saveHttpToken(item.token);
		FileLog("httprequest", "JNI::onRequestLogin saveToken token: %s", gToken.c_str());

        /* turn object to java object here */
        jobject jItem = NULL;
        JavaItemMap::const_iterator itr = gJavaItemMap.find(LOGIN_ITEM_CLASS);
        if( itr != gJavaItemMap.end() ) {
            jclass cls = env->GetObjectClass(itr->second);
            if( cls != NULL) {
                jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
                		"ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;ZZ)V");

                FileLog("httprequest", "LiveChat.Native::LoginItem( GetMethodID <init> : %p )", init);

                jstring juserId = env->NewStringUTF(item.userId.c_str());
                jstring jtoken = env->NewStringUTF(item.token.c_str());
                jstring jnickName = env->NewStringUTF(item.nickName.c_str());
                jstring jcountry = env->NewStringUTF(item.country.c_str());
                jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
                jstring jsign = env->NewStringUTF(item.sign.c_str());

                if( init != NULL ) {
                    jItem = env->NewObject(cls, init,
                            juserId,
                            jtoken,
                            jnickName,
                            item.level,
                            jcountry,
                            jphotoUrl,
                            jsign,
                            item.anchor,
                            item.modifyinfo
                            );
                    FileLog("httprequest", "LiveChat.Native::onRequestLogin( NewObject: %p)", jItem);
                }
                env->DeleteLocalRef(juserId);
                env->DeleteLocalRef(jtoken);
                env->DeleteLocalRef(jnickName);
                env->DeleteLocalRef(jcountry);
                env->DeleteLocalRef(jphotoUrl);
                env->DeleteLocalRef(jsign);
            }
        }

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += LOGIN_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestLogin", signature.c_str());
			FileLog("httprequest", "JNI::onRequestLogin( callback : %p, signature : %s )",
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

RequestLoginCallback gRequestLoginCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    LoginWithPhoneNumber
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLcom/qpidnetwork/httprequest/OnRequestLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_LoginWithPhoneNumber
  (JNIEnv *env, jclass cls, jstring phoneNumber, jstring areaNo, jstring password, jstring deviceId, jboolean autoLogin, jobject callback){

    jlong taskId = -1;
    string strModel = GetPhoneModel();
    string strManufacturer = GetPhoneManufacturer();

    taskId = gHttpRequestController.Login(&gHttpRequestManager,
    									0,
                                        JString2String(env, phoneNumber),
                                        JString2String(env, areaNo),
                                        JString2String(env, password),
                                        JString2String(env, deviceId),
                                        strModel,
                                        strManufacturer,
                                        autoLogin,
                                        &gRequestLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 注销  ****************************************/

class RequestLogoutCallback : public IRequestLogoutCallback{
	void OnLogout(HttpLogoutTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnLogout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnLogout( callback : %p, signature : %s )",
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

RequestLogoutCallback gRequestLogoutCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    Logout
 * Signature: (Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_Logout
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.Logout(&gHttpRequestManager,
                                        gToken,
                                        &gRequestLogoutCallback);

    /*清除本地Token*/
    saveHttpToken("");
    FileLog("httprequest", "JNI::Logout clear token");

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 上传push tokenId  ****************************************/

class RequestUpdateLiveRoomTokenIdCallback : public IRequestUpdateLiveRoomTokenIdCallback{
	void OnUpdateLiveRoomTokenId(HttpUpdateLiveRoomTokenIdTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnUpdateLiveRoomTokenId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnUpdateLiveRoomTokenId( callback : %p, signature : %s )",
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

RequestUpdateLiveRoomTokenIdCallback gRequestUpdateLiveRoomTokenIdCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniAuthorization
 * Method:    UploadPushTokenId
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniAuthorization_UploadPushTokenId
  (JNIEnv *env, jclass cls, jstring tokenId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.UpdateLiveRoomTokenId(&gHttpRequestManager,
                                        gToken,
                                        JString2String(env, tokenId),
                                        &gRequestUpdateLiveRoomTokenIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

