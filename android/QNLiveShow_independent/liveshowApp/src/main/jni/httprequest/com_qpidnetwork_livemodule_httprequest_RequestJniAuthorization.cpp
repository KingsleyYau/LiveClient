/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.h"

/*********************************** 登录接口 ****************************************/

class RequestLoginCallback : public IRequestLoginCallback{
	void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRequestLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /* turn object to java object here */
        jobject jItem = getLoginItem(env, item);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

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
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRequestLogin( callback : %p, signature : %s )",
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

RequestLoginCallback gRequestLoginCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    Login
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_Login
  (JNIEnv *env, jclass cls, jstring manId, jstring userSid, jstring deviceId, jstring model, jstring manufacturer, jint regionId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Login( manId : %s, userSid : %s )",
            JString2String(env, manId).c_str(), JString2String(env, userSid).c_str());
    jlong taskId = -1;
    RegionIdType type = IntToRegionIdType(regionId);
    taskId = gHttpRequestController.Login(&gHttpRequestManager,
    									JString2String(env, manId),
                                        JString2String(env, userSid),
                                        JString2String(env, deviceId),
                                        JString2String(env, model),
                                        JString2String(env, manufacturer),
                                        type,
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

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnLogout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnLogout( callback : %p, signature : %s )",
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

RequestLogoutCallback gRequestLogoutCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    Logout
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_Logout
  (JNIEnv *env, jclass cls, jobject callback){

    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Logout()");
    jlong taskId = -1;
    taskId = gHttpRequestController.Logout(&gHttpRequestManager,
                                        &gRequestLogoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 上传push tokenId  ****************************************/

class RequestUpdateTokenIdCallback : public IRequestUpdateTokenIdCallback{
	void OnUpdateTokenId(HttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnUpdateTokenId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUpdateTokenId( callback : %p, signature : %s )",
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

RequestUpdateTokenIdCallback gRequestUpdateTokenIdCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    UploadPushTokenId
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_UploadPushTokenId
  (JNIEnv *env, jclass cls, jstring tokenId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UploadPushTokenId( tokenId : %s )",
            JString2String(env, tokenId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.UpdateTokenId(&gHttpRequestManager,
                                        JString2String(env, tokenId),
                                        &gRequestUpdateTokenIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.4.Facebook注册及登录（仅独立）  ****************************************/

class RequestOwnFackBookLoginCallback : public IRequestOwnFackBookLoginCallback{
	void OnOwnFackBookLogin(HttpOwnFackBookLoginTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnOwnFackBookLogin( success : %s, task : %p, sessionId : %s isAttachThread:%d )", success?"true":"false", task, sessionId.c_str(), isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestFackBookLogin", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnOwnFackBookLogin( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jsessionId = env->NewStringUTF(sessionId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jsessionId);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jsessionId);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestOwnFackBookLoginCallback gRequestOwnFackBookLoginCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    FackBookLogin
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestFackBookLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_FackBookLogin
		(JNIEnv *env, jclass cls, jstring fToken, jstring nickName, jstring utmReferrer, jstring model, jstring deviceId, jstring manufacturer, jstring inviteCode, jstring email, jstring passWord, jstring birthDay, jint  gender, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::FackBookLogin( fToken : %s ) "
					"nickName : %s"
					"utmReferrer : %s"
					"model : %s"
					"deviceId : %s"
					"manufacturer : %s"
					"inviteCode : %s"
					"email : %s"
					"passWord : %s"
					"birthDay : %s"
                    "gender : %d",
			JString2String(env, fToken).c_str(),
			JString2String(env, nickName).c_str(),
			JString2String(env, utmReferrer).c_str(),
			JString2String(env, model).c_str(),
			JString2String(env, deviceId).c_str(),
			JString2String(env, manufacturer).c_str(),
			JString2String(env, inviteCode).c_str(),
			JString2String(env, email).c_str(),
			JString2String(env, passWord).c_str(),
			JString2String(env, birthDay).c_str(),
            gender);
	jlong taskId = -1;
    GenderType jgender = IntToGenderTypeOperateType(gender);
	taskId = gHttpRequestController.OwnFackBookLogin(&gHttpRequestManager,
                                                     JString2String(env, fToken),
                                                     JString2String(env, nickName),
                                                     JString2String(env, utmReferrer),
                                                     JString2String(env, model),
													 JString2String(env, deviceId),
													 JString2String(env, manufacturer),
                                                     JString2String(env, inviteCode),
													 JString2String(env, email),
													 JString2String(env, passWord),
													 JString2String(env, birthDay),
                                                     jgender,
												     &gRequestOwnFackBookLoginCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.5.邮箱注册（仅独立）  ****************************************/

class RequestOwnRegisterCallback : public IRequestOwnRegisterCallback{
	void OnOwnRegister(HttpOwnRegisterTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnOwnRegister( success : %s, task : %p, sessionId : %s isAttachThread:%d )", success?"true":"false", task, sessionId.c_str(), isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestLSRegister", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnOwnRegister( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jsessionId = env->NewStringUTF(sessionId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jsessionId);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jsessionId);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestOwnRegisterCallback gRequestOwnRegisterCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSRegister
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestFackBookLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSRegister
		(JNIEnv *env, jclass cls, jstring email, jstring passWord, jint gender, jstring nickName, jstring birthDay, jstring inviteCode, jstring model, jstring deviceid, jstring manufacturer, jstring utmReferrer, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSRegister( ) "
					"email : %s"
					"passWord : %s"
					"gender : %d"
					"nickName : %s"
					"birthDay : %s"
					"inviteCode : %s"
					"model : %s"
					"deviceid : %s"
					"manufacturer : %s"
					"utmReferrer : %s ",
			JString2String(env, email).c_str(),
			JString2String(env, passWord).c_str(),
			gender,
			JString2String(env, nickName).c_str(),
			JString2String(env, birthDay).c_str(),
			JString2String(env, inviteCode).c_str(),
			JString2String(env, model).c_str(),
			JString2String(env, deviceid).c_str(),
			JString2String(env, manufacturer).c_str(),
			JString2String(env, utmReferrer).c_str());
	jlong taskId = -1;
    GenderType jgender = IntToGenderTypeOperateType(gender);
	taskId = gHttpRequestController.OwnRegister(&gHttpRequestManager,
													 JString2String(env, email),
													 JString2String(env, passWord),
                                                     jgender,
													 JString2String(env, nickName),
													 JString2String(env, birthDay),
													 JString2String(env, inviteCode),
													 JString2String(env, model),
													 JString2String(env, deviceid),
													 JString2String(env, manufacturer),
													 JString2String(env, utmReferrer),
													 &gRequestOwnRegisterCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.6.邮箱登录（仅独立）  ****************************************/

class RequestOwnEmailLoginCallback : public IRequestOwnEmailLoginCallback{
	void OnOwnEmailLogin(HttpOwnEmailLoginTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnOwnEmailLogin( success : %s, task : %p, sessionId : %s isAttachThread:%d )", success?"true":"false", task, sessionId.c_str(), isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestMailLogin", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnOwnEmailLogin( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jsessionId = env->NewStringUTF(sessionId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jsessionId);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jsessionId);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestOwnEmailLoginCallback gRequestOwnEmailLoginCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSMailLogin
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestMailLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSMailLogin
		(JNIEnv *env, jclass cls, jstring email, jstring passWord, jstring model, jstring deviceid, jstring manufacturer, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSMailLogin( ) "
					"email : %s"
					"passWord : %s"
					"model : %s"
					"deviceid : %s"
					"manufacturer : %s",
			JString2String(env, email).c_str(),
			JString2String(env, passWord).c_str(),
			JString2String(env, model).c_str(),
			JString2String(env, deviceid).c_str(),
			JString2String(env, manufacturer).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.OwnEmailLogin(&gHttpRequestManager,
												JString2String(env, email),
												JString2String(env, passWord),
												JString2String(env, model),
												JString2String(env, deviceid),
												JString2String(env, manufacturer),
												&gRequestOwnEmailLoginCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.7.找回密码（仅独立）  ****************************************/

class RequestOwnFindPasswordCallback : public IRequestOwnFindPasswordCallback{
	void OnOwnFindPassword(HttpOwnFindPasswordTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnOwnFindPassword( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onLSFindPassword", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnOwnFindPassword( callback : %p, signature : %s )",
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

RequestOwnFindPasswordCallback gRequestOwnFindPasswordCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSFindPassword
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSFindPasswordCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSFindPassword
		(JNIEnv *env, jclass cls, jstring sendMail, jstring checkCode, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSFindPassword( ) "
					"sendMail : %s"
					"chechCode : %s",
			JString2String(env, sendMail).c_str(),
	        JString2String(env, checkCode).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.OwnFindPassword(&gHttpRequestManager,
												  JString2String(env, sendMail),
												  JString2String(env, checkCode),
												  &gRequestOwnFindPasswordCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.8.检测邮箱注册状态（仅独立）  ****************************************/

class RequestOwnCheckMailRegistrationCallback : public IRequestOwnCheckMailRegistrationCallback{
	void OnOwnCheckMailRegistration(HttpOwnCheckMailRegistrationTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnOwnCheckMailRegistration( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onLSCheckMail", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnOwnCheckMailRegistration( callback : %p, signature : %s )",
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

RequestOwnCheckMailRegistrationCallback gRequestOwnCheckMailRegistrationCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSCheckMail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSCheckMailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSCheckMail
		(JNIEnv *env, jclass cls, jstring email, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSCheckMail( ) "
					"email : %s",
			JString2String(env, email).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.OwnCheckMail(&gHttpRequestManager,
													JString2String(env, email),
													&gRequestOwnCheckMailRegistrationCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.9.提交用户头像接口（仅独立）  ****************************************/

class RequestUploadPhotoCallback : public IRequestUploadPhotoCallback{
	void OnUploadPhoto(HttpUploadPhotoTask* task, bool success, int errnum, const string& errmsg, const string& photoUrl) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnUploadPhoto( success : %s, task : %p,  photoUrl : %s, isAttachThread:%d )", success?"true":"false", task, photoUrl.c_str(), isAttachThread);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onUploadPhoto", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUploadPhoto( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jphotoUrl);
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

RequestUploadPhotoCallback gRequestUploadPhotoCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSUploadPhoto
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestUploadPhotoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSUploadPhoto
		(JNIEnv *env, jclass cls, jstring photoUrl, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSCheckMail( ) "
					"photoUrl : %s",
			JString2String(env, photoUrl).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.OwnUploadPhoto(&gHttpRequestManager,
													JString2String(env, photoUrl),
													&gRequestUploadPhotoCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 2.10.获取验证码（仅独立）  ****************************************/

class RequestGetVerificationCodeCallback : public IRequestGetVerificationCodeCallback{
    void OnGetVerificationCode(HttpGetVerificationCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnGetVerificationCode( success : %s, task : %p,  len : %d, isAttachThread:%d )", success?"true":"false", task, len, isAttachThread);

        jbyteArray byteArray = env->NewByteArray(len);
        if( byteArray != NULL ) {
            env->SetByteArrayRegion(byteArray, 0, len, (const jbyte*) data);
        }
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;[B)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetVerificationCode", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetVerificationCode( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, byteArray);
                env->DeleteLocalRef(jerrmsg);
            }
        }
        if( byteArray != NULL ) {
            env->DeleteLocalRef(byteArray);
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestGetVerificationCodeCallback gRequestGetVerificationCodeCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    LSGetVerificationCode
 * Signature: (IZLcom/qpidnetwork/livemodule/httprequest/OnRequestGetVerificationCodeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_LSGetVerificationCode
        (JNIEnv * env, jclass cls, jint verifyType, jboolean useCode, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSGetVerificationCode( ) "
                    "verifyType : %d"
                    "useCode : %d",
                     verifyType,
                     useCode);
    jlong taskId = -1;
    VerifyCodeType jverifyType = IntToVerifyCodeTypeOperateType(verifyType);
    taskId = gHttpRequestController.GetVerificationCode(&gHttpRequestManager,
                                                        jverifyType,
                                                        useCode,
                                                   &gRequestGetVerificationCodeCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}