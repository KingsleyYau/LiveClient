/*
 * JniCommonFunc.h
 *
 *  Created on: 2015-3-4
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef JNICOMMONFUNC_H_
#define JNICOMMONFUNC_H_

#include <jni.h>

#include <common/KSafeMap.h>

#include <string>
#include <list>
using namespace std;

extern JavaVM* gJavaVM;

string JString2String(JNIEnv* env, jstring str);
void InitEnumHelper(JNIEnv *env, const char *path, jobject *objptr);
void InitClassHelper(JNIEnv *env, const char *path, jobject *objptr);

bool GetEnv(JNIEnv** env, bool* isAttachThread);
bool ReleaseEnv(bool isAttachThread);

#endif /* JNICOMMONFUNC_H_ */
