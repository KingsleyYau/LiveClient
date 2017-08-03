/*
 * JniGobalFunc.cpp
 *
 *  Created on: 2015-3-4
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include <common/KLog.h>
#include "JniCommonFunc.h"

JavaVM* gJavaVM;

string JString2String(JNIEnv* env, jstring str) {
	string result("");
	if (NULL != str) {
		const char* cpTemp = env->GetStringUTFChars(str, 0);
		result = cpTemp;
		env->ReleaseStringUTFChars(str, cpTemp);
	}
	return result;
}

void InitEnumHelper(JNIEnv *env, const char *path, jobject *objptr) {
	FileLog("androidcommon", "InitEnumHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("androidcommon", "InitEnumHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
    if( !constr ) {
    	FileLog("androidcommon", "InitEnumHelper( !constr )");
        return;
    }

    jobject obj = env->NewObject(cls, constr, NULL, 0);
    if( !obj ) {
    	FileLog("androidcommon", "InitEnumHelper( !obj )");
        return;
    }

    (*objptr) = env->NewGlobalRef(obj);
}

void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr) {
	FileLog("androidcommon", "InitClassHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("androidcommon", "InitClassHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
    if( !constr ) {
    	FileLog("androidcommon", "InitClassHelper( !constr )");
        constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
        if( !constr ) {
        	FileLog("androidcommon", "InitClassHelper( !constr )");
            return;
        }
        return;
    }

    jobject obj = env->NewObject(cls, constr);
    if( !obj ) {
    	FileLog("androidcommon", "InitClassHelper( !obj )");
        return;
    }

    (*objptr) = env->NewGlobalRef(obj);
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
