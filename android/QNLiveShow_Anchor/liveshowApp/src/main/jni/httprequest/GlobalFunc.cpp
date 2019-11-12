/*
 * GobalFunc.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"


JavaVM* gJavaVM;

CallbackMap gCallbackMap;

JavaItemMap gJavaItemMap;

HttpRequestManager gHttpRequestManager;

HttpRequestManager gPhotoUploadRequestManager;

HttpRequestManager gConfigRequestManager;

ZBHttpRequestController gHttpRequestController;

KMutex mTokenMutex;
string gToken;

 string JString2String(JNIEnv* env, jstring str) {
 	string result("");
 	if (NULL != str) {
 		const char* cpTemp = env->GetStringUTFChars(str, 0);
 		result = cpTemp;
 		env->ReleaseStringUTFChars(str, cpTemp);
 	}
 	return result;
 }


 void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr) {
 	FileLog("httprequest", "InitClassHelper( path : %s )", path);
     jclass cls = env->FindClass(path);
     if( !cls ) {
     	FileLog("httprequest", "InitClassHelper( !cls )");
         return;
     }

     jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
     if( !constr ) {
     	FileLog("httprequest", "InitClassHelper( !constr )");
         constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
         if( !constr ) {
         	FileLog("httprequest", "InitClassHelper( !constr )");
             return;
         }
         return;
     }

     jobject obj = env->NewObject(cls, constr);
     if( !obj ) {
     	FileLog("httprequest", "InitClassHelper( !obj )");
         return;
     }

     (*objptr) = env->NewGlobalRef(obj);
 }


 jclass GetJClass(JNIEnv* env, const char* classPath)
 {
 	jclass jCls = NULL;
 	JavaItemMap::iterator itr = gJavaItemMap.find(classPath);
 	if( itr != gJavaItemMap.end() ) {
 		jobject jItemObj = itr->second;
 		jCls = env->GetObjectClass(jItemObj);
 	}
 	return jCls;
 }

 /* JNI_OnLoad */
 jint JNI_OnLoad(JavaVM* vm, void* reserved) {
 	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::JNI_OnLoad( httprequest.so JNI_OnLoad )");
 	gJavaVM = vm;

 	// Get JNI
 	JNIEnv* env;
 	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                            JNI_VERSION_1_4)) {
 		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::JNI_OnLoad ( could not get JNI env )");
 		return -1;
 	}

 	HttpClient::Init();

 	//gHttpRequestManager.SetHostManager(&gHttpRequestHostManager);

 	//	InitEnumHelper(env, COUNTRY_ITEM_CLASS, &gCountryItem);

 	/* 2.认证模块 */
 	jobject jLoginItem;
 	InitClassHelper(env, LOGIN_ITEM_CLASS, &jLoginItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(LOGIN_ITEM_CLASS, jLoginItem));

 	jobject jServerItem;
 	InitClassHelper(env, SERVER_ITEM_CLASS, &jServerItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(SERVER_ITEM_CLASS, jServerItem));

 	/* 3.直播间模块  */

 	jobject jImmediateInviteItem;
 	InitClassHelper(env, IMMEDIATE_INVITE_ITEM_CLASS, &jImmediateInviteItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(IMMEDIATE_INVITE_ITEM_CLASS, jImmediateInviteItem));

 	jobject jAudienceInfoItem;
 	InitClassHelper(env, AUDIENCE_INFO_ITEM_CLASS, &jAudienceInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(AUDIENCE_INFO_ITEM_CLASS, jAudienceInfoItem));

 	jobject jAudienceBaseInfoItem;
 	InitClassHelper(env, AUDIENCE_BASE_INFO_ITEM_CLASS, &jAudienceBaseInfoItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(AUDIENCE_BASE_INFO_ITEM_CLASS, jAudienceBaseInfoItem));


 	jobject jGiftDetailItem;
 	InitClassHelper(env, GIFT_DETAIL_ITEM_CLASS, &jGiftDetailItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(GIFT_DETAIL_ITEM_CLASS, jGiftDetailItem));

     jobject jGiftLimitNumItem;
     InitClassHelper(env, GIFT_LIMIT_NUM_ITEM_CLASS, &jGiftLimitNumItem);
     gJavaItemMap.insert(JavaItemMap::value_type(GIFT_LIMIT_NUM_ITEM_CLASS, jGiftLimitNumItem));

 	jobject jEmotionCategoryItem;
 	InitClassHelper(env, EMOTION_CATEGORY_ITEM_CLASS, &jEmotionCategoryItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(EMOTION_CATEGORY_ITEM_CLASS, jEmotionCategoryItem));

 	jobject jEmotionItem;
 	InitClassHelper(env, EMOTION_ITEM_CLASS, &jEmotionItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(EMOTION_ITEM_CLASS, jEmotionItem));

  	jobject jPushRoomInfoItem;
  	InitClassHelper(env, PUSH_ROOM_INFO_ITEM_CLASS, &jPushRoomInfoItem);
  	gJavaItemMap.insert(JavaItemMap::value_type(PUSH_ROOM_INFO_ITEM_CLASS, jPushRoomInfoItem));

  	jobject jPushRoomAudInfoItem;
  	InitClassHelper(env, PUSH_ROOM_AUD_INFO_ITEM_CLASS, &jPushRoomAudInfoItem);
  	gJavaItemMap.insert(JavaItemMap::value_type(PUSH_ROOM_AUD_INFO_ITEM_CLASS, jPushRoomAudInfoItem));

 	/* 4.个人信息模块    */
 	jobject jBookInviteItem;
 	InitClassHelper(env, BOOK_INVITE_ITEM_CLASS, &jBookInviteItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(BOOK_INVITE_ITEM_CLASS, jBookInviteItem));


 	/* 6.其他    */
 	jobject jConfigItem;
 	InitClassHelper(env, OTHER_CONFIG_ITEM_CLASS, &jConfigItem);
 	gJavaItemMap.insert(JavaItemMap::value_type(OTHER_CONFIG_ITEM_CLASS, jConfigItem));

	/* 7.多人互动直播间    */
	jobject jAnchorInfoItem;
	InitClassHelper(env, ANCHOR_INFO_ITEM_CLASS, &jAnchorInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(ANCHOR_INFO_ITEM_CLASS, jAnchorInfoItem));

	jobject jAnchorBaseInfoItem;
	InitClassHelper(env, ANCHOR_BASE_INFO_ITEM_CLASS, &jAnchorBaseInfoItem);
	gJavaItemMap.insert(JavaItemMap::value_type(ANCHOR_BASE_INFO_ITEM_CLASS, jAnchorBaseInfoItem));

    jobject jAnchorHangoutItem;
    InitClassHelper(env, ANCHOR_HANGOUT_ITEM_CLASS, &jAnchorHangoutItem);
    gJavaItemMap.insert(JavaItemMap::value_type(ANCHOR_HANGOUT_ITEM_CLASS, jAnchorHangoutItem));

	jobject jAnchorHangoutGiftListItem;
	InitClassHelper(env, ANCHOR_HANGOUT_GIFTLIST_ITEM_CLASS, &jAnchorHangoutGiftListItem);
	gJavaItemMap.insert(JavaItemMap::value_type(ANCHOR_HANGOUT_GIFTLIST_ITEM_CLASS, jAnchorHangoutGiftListItem));


	 /* 8.节目    */
	 jobject jProgramInfoItem;
	 InitClassHelper(env, PROGRAM_INFO_ITEM_CLASS, &jProgramInfoItem);
	 gJavaItemMap.insert(JavaItemMap::value_type(PROGRAM_INFO_ITEM_CLASS, jProgramInfoItem));

 	return JNI_VERSION_1_4;
 }

 bool GetEnv(JNIEnv** env, bool* isAttachThread)
 {
 	*isAttachThread = false;
 	jint iRet = JNI_ERR;
 	iRet = gJavaVM->GetEnv((void**) env, JNI_VERSION_1_4);
 	if( iRet == JNI_EDETACHED ) {
 		iRet = gJavaVM->AttachCurrentThread(env, NULL);
 		*isAttachThread = (iRet == JNI_OK);
 	}

 	return (iRet == JNI_OK);
 }

 bool ReleaseEnv(bool isAttachThread)
 {
 	if (isAttachThread) {
 		gJavaVM->DetachCurrentThread();
 	}
 	return true;
 }

 /**
  * 根据Task Id 取回Callback object
  * @param Task Id
  */
 jobject getCallbackObjectByTask(long task){
     jobject callBackObject = NULL;
 	gCallbackMap.Lock();
 	CallbackMap::iterator callbackItr = gCallbackMap.Find(task);
 	if(callbackItr != gCallbackMap.End()){
 		callBackObject = callbackItr->second;
 	}
 	gCallbackMap.Erase((long)task);
 	gCallbackMap.Unlock();
 	return callBackObject;
 }

 /**
  * 存储callback object 到全局Map中，用于回调时取回使用
  * @param task  task id
  * @param callBackObject callback对象
  */
 void putCallbackIntoMap(long task, jobject callBackObject){
     gCallbackMap.Lock();
     gCallbackMap.Insert(task, callBackObject);
     gCallbackMap.Unlock();
 }

 /**
  * 存储Http认证Token
  */
 void saveHttpToken(string token){
	 mTokenMutex.lock();
	 gToken = token;
	 mTokenMutex.unlock();
 }

 /**
  * 去除httpToken
  */
 string getHttpToken(){
	 return gToken;
 }
