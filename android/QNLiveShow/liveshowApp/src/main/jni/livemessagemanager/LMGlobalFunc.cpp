/*
 * LMGlobalFunc.cpp
 *
 *  Created on: 2018-6-26
 *      Author: Hunter Mun
 */

#include "LMGlobalFunc.h"
#include <LiveMessageManManager.h>

JavaVM* gJavaVM = NULL;
JavaItemMap gJavaItemMap;

bool GetEnv(JNIEnv** env, bool* isAttachThread)
{
	*isAttachThread = false;
	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "GetEnv() begin, env:%p", env);
	jint iRet = JNI_ERR;
	iRet = gJavaVM->GetEnv((void**) env, JNI_VERSION_1_4);
	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "GetEnv() gJavaVM->GetEnv(&gEnv, JNI_VERSION_1_4), iRet:%d", iRet);
	if( iRet == JNI_EDETACHED ) {
		iRet = gJavaVM->AttachCurrentThread(env, NULL);
		*isAttachThread = (iRet == JNI_OK);
	}
	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "GetEnv() end, env:%p, gIsAttachThread:%d, iRet:%d", *env, *isAttachThread, iRet);
	return (iRet == JNI_OK);
}

bool ReleaseEnv(bool isAttachThread)
{
	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "ReleaseEnv(bool) begin, isAttachThread:%d", isAttachThread);
	if (isAttachThread) {
		gJavaVM->DetachCurrentThread();
	}
	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "ReleaseEnv(bool) end");
	return true;
}


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
	FileLog("LMClient", "InitClassHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("LMClient", "InitClassHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
    if( !constr ) {
    	FileLog("LMClient", "InitClassHelper( !constr )");
        constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
        if( !constr ) {
        	FileLog("LMClient", "InitClassHelper( !constr )");
            return;
        }
        return;
    }

    jobject obj = env->NewObject(cls, constr);
    if( !obj ) {
    	FileLog("IMClient", "InitClassHelper( !obj )");
        return;
    }

    (*objptr) = env->NewGlobalRef(obj);
}

void InsertJObjectClassToMap(JNIEnv* env, const char* classPath)
{
	jobject jTempObject;
	InitClassHelper(env, classPath, &jTempObject);
	gJavaItemMap.insert(JavaItemMap::value_type(classPath, jTempObject));
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
	FileLog("LMManager", "JNI_OnLoad( livemessagemanmanager-interface.so JNI_OnLoad )");
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLog("LMManager", "JNI_OnLoad ( could not get JNI env )");
		return -1;
	}

	//data object cls save
	InsertJObjectClassToMap(env, LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS);
	InsertJObjectClassToMap(env, LM_PRIVATE_PRIVATEMSGCONTACT_ITEM_CLASS);
	InsertJObjectClassToMap(env, LM_PRIVATE_PRIVATEMSG_ITEM_CLASS);
	InsertJObjectClassToMap(env, LM_PRIVATE_SYSTEMNOTICE_ITEM_CLASS);
	InsertJObjectClassToMap(env, LM_PRIVATE_WARNING_ITEM_CLASS);
	InsertJObjectClassToMap(env, LM_PRIVATE_TIMEMSG_ITEM_CLASS);

    return JNI_VERSION_1_4;
}
