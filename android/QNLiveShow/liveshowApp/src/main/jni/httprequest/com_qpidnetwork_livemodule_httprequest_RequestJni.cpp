/*
 * com_qpidnetwork_livemodule_httprequest_RequestJni.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJni.h"
#include "com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni.h"

#include <crashhandler/CrashHandler.h>
#include <common/IPAddress.h>
#include <common/md5.h>
#include <common/command.h>

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetLogDirectory
  (JNIEnv *env, jclass cls, jstring directory){

	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	KLog::SetLogDirectory(cpDirectory);
	HttpClient::SetLogDirectory(cpDirectory);
	CrashHandler::GetInstance()->SetLogDirectory(cpDirectory);

	GetPhoneInfo();

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetLogDirectory ( directory : %s ) ", cpDirectory);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetLogDirectory ( Android CPU ABI : %s ) ", GetPhoneCpuAbi().c_str());

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetVersionCode
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetVersionCode
  (JNIEnv *env, jclass cls, jstring version){
	const char *cpVersion = env->GetStringUTFChars(version, 0);
	gPhotoUploadRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gConfigRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gDomainRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);

	CrashHandler::GetInstance()->SetVersion(cpVersion);
	env->ReleaseStringUTFChars(version, cpVersion);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetCookiesDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetCookiesDirectory
  (JNIEnv *env, jclass cls, jstring directory){
	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	HttpClient::SetCookiesDirectory(cpDirectory);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetCookiesDirectory ( directory : %s ) ", cpDirectory);

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

/*
 * Class:     com_qpidnetwork_request_RequestJni
 * Method:    SetWebSite
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetWebSite
  (JNIEnv *env, jclass cls, jstring webSite) {
	const char *cpWebSite = env->GetStringUTFChars(webSite, 0);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetWebSite ( webSite : %s ) ", cpWebSite);

	gHttpRequestManager.SetWebSite(cpWebSite);

	env->ReleaseStringUTFChars(webSite, cpWebSite);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetPhotoUploadSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetPhotoUploadSite
  (JNIEnv *env, jclass cls, jstring uploadSite) {
	const char *cpUploadSite = env->GetStringUTFChars(uploadSite, 0);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetPhotoUploadSite ( uploadSite : %s ) ", cpUploadSite);

	gPhotoUploadRequestManager.SetWebSite(cpUploadSite);

	env->ReleaseStringUTFChars(uploadSite, cpUploadSite);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetConfigSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetConfigSite
  (JNIEnv *env, jclass cls, jstring configSite) {
	const char *cpConfigSite = env->GetStringUTFChars(configSite, 0);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetConfigSite ( configSite : %s ) ", cpConfigSite);

	gConfigRequestManager.SetWebSite(cpConfigSite);

	env->ReleaseStringUTFChars(configSite, cpConfigSite);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetDomainSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetDomainSite
		(JNIEnv *env, jclass cls, jstring domainSite) {
	const char *cpDomainSite = env->GetStringUTFChars(domainSite, 0);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetDomainSite ( domainSite : %s ) ", cpDomainSite);

	gDomainRequestManager.SetWebSite(cpDomainSite);

	env->ReleaseStringUTFChars(domainSite, cpDomainSite);
}

JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetAuthorization
          (JNIEnv *env, jclass cls, jstring user, jstring password) {
   	const char *cpUser = env->GetStringUTFChars(user, 0);
   	const char *cpPassword = env->GetStringUTFChars(password, 0);

   	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetAuthorization ( user : %s, cpPassword : %s) ", cpUser, cpPassword);

	gConfigRequestManager.SetAuthorization(cpUser, cpPassword);
    gDomainRequestManager.SetAuthorization(cpUser, cpPassword);
    gHttpRequestManager.SetAuthorization(cpUser, cpPassword);

   	env->ReleaseStringUTFChars(user, cpUser);
   	env->ReleaseStringUTFChars(password, cpPassword);
}


/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    StopRequest
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_StopRequest
  (JNIEnv *env, jclass cls, jlong requestId){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::StopRequest");
	gHttpRequestController.Stop(requestId);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    GetLocalMacMD5
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_GetLocalMacMD5
  (JNIEnv *env, jclass cls){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetLocalMacMD5 ");
	string macAddress = "";

	list<IpAddressNetworkInfo> infoList = IPAddress::GetNetworkInfoList();
	if( infoList.size() > 0 && infoList.begin() != infoList.end() ) {
		IpAddressNetworkInfo info = *(infoList.begin());
		macAddress = info.mac;
	}

	char deviceId[128] = {'\0'};
	memset(deviceId, '\0', sizeof(deviceId));
	GetMD5String(macAddress.c_str(), deviceId);

	return env->NewStringUTF(deviceId);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetDeviceId
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetDeviceId
  (JNIEnv *env, jclass cls, jstring deviceId){
	const char *cpDeviceId = env->GetStringUTFChars(deviceId, 0);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetDeviceId ( deviceId : %s ) ", cpDeviceId);
	CrashHandler::GetInstance()->SetDeviceId(cpDeviceId);
	env->ReleaseStringUTFChars(deviceId, cpDeviceId);
}


/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    CleanCookies
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_CleanCookies
  (JNIEnv *, jclass) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CleanCookies");
	HttpClient::CleanCookies();
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    GetCookiesItem
 * Signature: ()["com/qpidnetwork/livemodule/httprequest/item/CookiesItem";
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_GetCookiesItem
  (JNIEnv *env, jclass cls)
{
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() begin");
	jobjectArray jCookiesArray = NULL;
	list<CookiesItem> cookies = HttpClient::GetCookiesItem();
	jclass jItemCls = env->FindClass("com/qpidnetwork/livemodule/httprequest/item/CookiesItem");
	if(!jItemCls)
	{
		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() JNI jclass is NULL");
		return NULL;
	}

	jmethodID jItemMethod = env->GetMethodID(jItemCls, "<init>", "()V");
	if(!jItemMethod)
	{
		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() <init>ID is NULL end");
		env->DeleteLocalRef(jItemCls);
		return NULL;
	}

	jmethodID jItemInitMethod = env->GetMethodID(jItemCls,"init","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	if(!jItemInitMethod)
	{
		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() init()ID is NULL end");
		env->DeleteLocalRef(jItemCls);
		return NULL;
	}

	jCookiesArray = env->NewObjectArray(cookies.size(), jItemCls, NULL);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() JNI cookies.size:%d, jCookiesArray:%p", cookies.size(), jCookiesArray);

	if (NULL != jCookiesArray)
	{
		int i = 0;
		for (list<CookiesItem>::const_iterator iter = cookies.begin();
			 iter != cookies.end();
			 iter++, i++)
		{
			jstring domain = env->NewStringUTF((*iter).m_domain.c_str());
			jstring accessOtherWeb = env->NewStringUTF((*iter).m_accessOtherWeb.c_str());
			jstring symbol = env->NewStringUTF((*iter).m_symbol.c_str());
			jstring isSend = env->NewStringUTF((*iter).m_isSend.c_str());
			jstring expiresTime = env->NewStringUTF((*iter).m_expiresTime.c_str());
			jstring cName = env->NewStringUTF((*iter).m_cName.c_str());
			jstring value = env->NewStringUTF((*iter).m_value.c_str());
			jobject objCookiesItem       = env->NewObject(jItemCls, jItemMethod);
			if(!objCookiesItem)
			{
				FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() objCookiesItem is NULL end");
				env->DeleteLocalRef(jItemCls);
				env->DeleteLocalRef(jCookiesArray);
				return NULL;
			}
			env->CallVoidMethod(objCookiesItem, jItemInitMethod, domain, accessOtherWeb, symbol, isSend, expiresTime, cName, value);
			env->DeleteLocalRef(domain);
			env->DeleteLocalRef(accessOtherWeb);
			env->DeleteLocalRef(symbol);
			env->DeleteLocalRef(isSend);
			env->DeleteLocalRef(expiresTime);
			env->DeleteLocalRef(cName);
			env->DeleteLocalRef(value);
			env->SetObjectArrayElement(jCookiesArray, i, objCookiesItem);
		}
		env->DeleteLocalRef(jItemCls);
	}
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCookiesItem() JNI end");
	return jCookiesArray;
}


/*
 * Class:     com_qpidnetwork_request_RequestJni
 * Method:    SetProxy
 * Signature: (Ljava/lang/String;I)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetProxy
  (JNIEnv *env, jclass cls, jstring proxyUrl) {
	const char *cpProxyUrl = env->GetStringUTFChars(proxyUrl, 0);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetProxy ( proxyUrl : %s ) ", cpProxyUrl);

	HttpClient::SetProxy(cpProxyUrl);

	env->ReleaseStringUTFChars(proxyUrl, cpProxyUrl);
}


JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetAppId
  (JNIEnv *env, jclass cls, jstring appId) {
   	const char *cpAppId = env->GetStringUTFChars(appId, 0);
   	gPhotoUploadRequestManager.SetAppId(cpAppId);
   	gConfigRequestManager.SetAppId(cpAppId);
   	gDomainRequestManager.SetAppId(cpAppId);
   	gHttpRequestManager.SetAppId(cpAppId);
   	Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetAppId(env, cls, appId);
   	env->ReleaseStringUTFChars(appId, cpAppId);

 }





