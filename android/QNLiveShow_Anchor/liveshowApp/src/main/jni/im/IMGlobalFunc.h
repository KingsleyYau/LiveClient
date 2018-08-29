/*
 * IMGlobalFunc.h
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#ifndef IMGLOBALFUNC_H_
#define IMGLOBALFUNC_H_

#include <jni.h>
#include <map>
#include <string>
#include <common/KLog.h>
#include "IMCallbackItemDef.h"
using namespace std;

typedef map<string, jobject> JavaItemMap;

extern JavaVM* gJavaVM;
extern JavaItemMap gJavaItemMap;

string JString2String(JNIEnv* env, jstring str);
void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr);
jclass GetJClass(JNIEnv* env, const char* classPath);

bool GetEnv(JNIEnv** env, bool* isAttachThread);
bool ReleaseEnv(bool isAttachThread);


#endif
