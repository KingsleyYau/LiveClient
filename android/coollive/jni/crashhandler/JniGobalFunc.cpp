/*
 * JniGobalFunc.cpp
 *
 *  Created on: 2015-3-4
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include <JniGobalFunc.h>

#include <common/KLog.h>

JavaVM* gJavaVM;

CallbackMap gCallbackMap;

JavaItemMap gJavaItemMap;

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
	FileLog("jni", "InitEnumHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("jni", "InitEnumHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
    if( !constr ) {
    	FileLog("jni", "InitEnumHelper( !constr )");
        return;
    }

    jobject obj = env->NewObject(cls, constr, NULL, 0);
    if( !obj ) {
    	FileLog("jni", "InitEnumHelper( !obj )");
        return;
    }

    (*objptr) = env->NewGlobalRef(obj);
}

void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr) {
	FileLog("jni", "InitClassHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("jni", "InitClassHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
    if( !constr ) {
    	FileLog("jni", "InitClassHelper( !constr )");
        constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
        if( !constr ) {
        	FileLog("jni", "InitClassHelper( !constr )");
            return;
        }
        return;
    }

    jobject obj = env->NewObject(cls, constr);
    if( !obj ) {
    	FileLog("jni", "InitClassHelper( !obj )");
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
	FileLog("crashhandler", "JNI_OnLoad( crashhandler )");
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLog("crashhandler", "JNI_OnLoad ( could not get JNI env )");
		return -1;
	}

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
