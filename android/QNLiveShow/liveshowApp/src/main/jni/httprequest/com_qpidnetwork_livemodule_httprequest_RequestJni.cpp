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

	string cpDirectory = JString2String(env, directory);

	KLog::SetLogDirectory(cpDirectory);
	HttpClient::SetLogDirectory(cpDirectory);
	CrashHandler::GetInstance()->SetLogDirectory(cpDirectory);

	GetPhoneInfo();

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetLogDirectory ( directory : %s ) ", cpDirectory.c_str());
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetLogDirectory ( Android CPU ABI : %s ) ", GetPhoneCpuAbi().c_str());

}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetVersionCode
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetVersionCode
  (JNIEnv *env, jclass cls, jstring version){
	string cpVersion = JString2String(env, version);
	gPhotoUploadRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gConfigRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gDomainRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);

	CrashHandler::GetInstance()->SetVersion(cpVersion);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetCookiesDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetCookiesDirectory
  (JNIEnv *env, jclass cls, jstring directory){
	string cpDirectory = JString2String(env, directory);

	HttpClient::SetCookiesDirectory(cpDirectory);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSSetCookiesDirectory ( directory : %s ) ", cpDirectory.c_str());

}

/*
 * Class:     com_qpidnetwork_request_RequestJni
 * Method:    SetWebSite
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetWebSite
  (JNIEnv *env, jclass cls, jstring webSite) {
	string cpWebSite = JString2String(env, webSite);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetWebSite ( webSite : %s ) ", cpWebSite.c_str());

	gHttpRequestManager.SetWebSite(cpWebSite);
}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetPhotoUploadSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetPhotoUploadSite
  (JNIEnv *env, jclass cls, jstring uploadSite) {
	string cpUploadSite = JString2String(env, uploadSite);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetPhotoUploadSite ( uploadSite : %s ) ", cpUploadSite.c_str());

	gPhotoUploadRequestManager.SetWebSite(cpUploadSite);

}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetConfigSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetConfigSite
  (JNIEnv *env, jclass cls, jstring configSite) {
	string cpConfigSite = JString2String(env, configSite);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetConfigSite ( configSite : %s ) ", cpConfigSite.c_str());

	gConfigRequestManager.SetWebSite(cpConfigSite);

}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJni
 * Method:    SetDomainSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetDomainSite
		(JNIEnv *env, jclass cls, jstring domainSite) {
	string cpDomainSite = JString2String(env, domainSite);

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetDomainSite ( domainSite : %s ) ", cpDomainSite.c_str());

	gDomainRequestManager.SetWebSite(cpDomainSite);

}

JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetAuthorization
          (JNIEnv *env, jclass cls, jstring user, jstring password) {
   	string cpUser = JString2String(env, user);
   	string cpPassword = JString2String(env, password);

   	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetAuthorization ( user : %s, cpPassword : %s) ", cpUser.c_str(), cpPassword.c_str());

	gConfigRequestManager.SetAuthorization(cpUser, cpPassword);
    gDomainRequestManager.SetAuthorization(cpUser, cpPassword);
    gHttpRequestManager.SetAuthorization(cpUser, cpPassword);
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
	string cpDeviceId = JString2String(env, deviceId);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetDeviceId ( deviceId : %s ) ", cpDeviceId.c_str());
	CrashHandler::GetInstance()->SetDeviceId(cpDeviceId);
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
	string cpProxyUrl = JString2String(env, proxyUrl);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetProxy ( proxyUrl : %s ) ", cpProxyUrl.c_str());

	HttpClient::SetProxy(cpProxyUrl);

}


JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJni_SetAppId
  (JNIEnv *env, jclass cls, jstring appId) {
   	string cpAppId = JString2String(env, appId);
   	gPhotoUploadRequestManager.SetAppId(cpAppId);
   	gConfigRequestManager.SetAppId(cpAppId);
   	gDomainRequestManager.SetAppId(cpAppId);
   	gHttpRequestManager.SetAppId(cpAppId);
   	Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetAppId(env, cls, appId);

 }





