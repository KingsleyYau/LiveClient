/*
 * GlobalFunc.h
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */

 #ifndef GOBALFUNC_H_
 #define GOBALFUNC_H_

 #include <jni.h>
 //#include <test.h>
 #include <httpclient/HttpRequestManager.h>
 #include <httpcontroller/HttpRequestController.h>
 #include "CallbackItemAndroidDef.h"
 #include <string>
 #include <list>

 using namespace std;

 extern JavaVM* gJavaVM;

 extern HttpRequestManager gHttpRequestManager;
 extern HttpRequestManager gPhotoUploadRequestManager;
 extern HttpRequestController gHttpRequestController;

 /* java callback object */
 typedef KSafeMap<long, jobject> CallbackMap;
 extern CallbackMap gCallbackMap;

 /* java data item */
 typedef map<string, jobject> JavaItemMap;
 extern JavaItemMap gJavaItemMap;

 string JString2String(JNIEnv* env, jstring str);
 void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr);
 jclass GetJClass(JNIEnv* env, const char* classPath);

 bool GetEnv(JNIEnv** env, bool* isAttachThread);
 bool ReleaseEnv(bool isAttachThread);

 /*保存获取Callback*/
 jobject getCallbackObjectByTask(long task);
 void putCallbackIntoMap(long task, jobject callBackObject);

 /* 保存全局token用作身份认证 */
 extern KMutex mTokenMutex;
 extern string gToken;
 void saveHttpToken(string token);
 string getHttpToken();

#include <common/KSafeMap.h>


 #endif /* GOBALFUNC_H_ */
