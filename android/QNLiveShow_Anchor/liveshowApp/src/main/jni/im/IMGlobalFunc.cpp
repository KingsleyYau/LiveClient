/*
 * IMGlobalFunc.cpp
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#include "IMGlobalFunc.h"

JavaVM* gJavaVM = NULL;
JavaItemMap gJavaItemMap;

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
	FileLog("IMClient", "InitClassHelper( path : %s )", path);
    jclass cls = env->FindClass(path);
    if( !cls ) {
    	FileLog("IMClient", "InitClassHelper( !cls )");
        return;
    }

    jmethodID constr = env->GetMethodID(cls, "<init>", "()V");
    if( !constr ) {
    	FileLog("IMClient", "InitClassHelper( !constr )");
        constr = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;I)V");
        if( !constr ) {
        	FileLog("IMClient", "InitClassHelper( !constr )");
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
	FileLog("IMClient", "JNI_OnLoad( im-interface.so JNI_OnLoad )");
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLog("IMClient", "JNI_OnLoad ( could not get JNI env )");
		return -1;
	}

	//data object cls save
	InsertJObjectClassToMap(env, IM_LOGIN_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_LOGIN_INVITE_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_LOGIN_SCHEDULE_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_LOGIN_ROOM_ITEM_CLASS);

	InsertJObjectClassToMap(env, IM_ROOMIN_ITEM_CLASS);

	InsertJObjectClassToMap(env, IM_HANGOUT_GIFTNUM_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_RECVGIFT_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_OtherAnchor_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_HANGOUTROOM_ITEM_CLASS);

    InsertJObjectClassToMap(env, IM_HANGOUT_ANCHORITEM_ITEM_CLASS);
    InsertJObjectClassToMap(env, IM_HANGOUT_HANGOUTINVITE_ITEM_CLASS);

	InsertJObjectClassToMap(env, IM_HANGOUT_HANGOUTRECOMMEND_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_KNOCKREQUEST_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_OTHERINVITE_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_DEALINVITE_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_USERINFO_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_RECVENTERROOM_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_RECVLEAVEROOM_ITEM_CLASS);
	InsertJObjectClassToMap(env, IM_HANGOUT_RECVHANGOUTGIFT_ITEM_CLASS);

	InsertJObjectClassToMap(env, IM_PROGRAM_PROGRAMINFO_ITEM_CLASS);


	return JNI_VERSION_1_4;
}
