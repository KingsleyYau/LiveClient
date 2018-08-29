/*
 * LMGlobalFunc.h
 *
 *  Created on: 2018-6-26
 *      Author: Hunter Mun
 */

#ifndef LMGLOBALFUNC_H_
#define LMGLOBALFUNC_H_

#include <jni.h>
#include <map>
#include <string>
#include <common/KLog.h>
#include "LMCallbackItemDef.h"
#include <common/KSafeMap.h>
using namespace std;

///* java callback object */
typedef KSafeMap<long, jobject> CallbackMap;
extern CallbackMap gCallbackMap;

typedef map<string, jobject> JavaItemMap;

extern JavaVM* gJavaVM;
extern JavaItemMap gJavaItemMap;

string JString2String(JNIEnv* env, jstring str);
void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr);
jclass GetJClass(JNIEnv* env, const char* classPath);

 /*保存获取Callback*/
 jobject getCallbackObjectByTask(long task);
 void putCallbackIntoMap(long task, jobject callBackObject);

bool GetEnv(JNIEnv** env, bool* isAttachThread);
bool ReleaseEnv(bool isAttachThread);


#endif
