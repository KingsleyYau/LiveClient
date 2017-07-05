/*
 * IMEnumJniConvert.cpp
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#include "IMEnumJniConvert.h"

int IMErrorTypeToInt(LCC_ERR_TYPE errType)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMErrorTypeArray); i++)
	{
		if (errType == IMErrorTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

jobject getFansItem(JNIEnv *env, const RoomTopFan& topFanItem){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOM_FANS_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
		jstring juserId = env->NewStringUTF(topFanItem.userId.c_str());
		jstring jnickName = env->NewStringUTF(topFanItem.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(topFanItem.photoUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl
					);
		env->DeleteLocalRef(juserId);
		env->DeleteLocalRef(jnickName);
		env->DeleteLocalRef(jphotoUrl);
	}
	return jItem;
}

jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList){
	jobjectArray array = NULL;
	jclass jItemCls = env->FindClass("java/lang/String");
	if (NULL != jItemCls) {
		array = env->NewObjectArray(sourceList.size(), jItemCls, NULL);
		if (NULL != array) {
			int i = 0;
			for(list<string>::const_iterator itr = sourceList.begin();
				itr != sourceList.end();
				itr++)
			{
				jstring jItem = env->NewStringUTF((*itr).c_str());
				if (NULL != jItem) {
					env->SetObjectArrayElement(array, i, jItem);
					i++;
				}
				env->DeleteLocalRef(jItem);
			}
		}
	}
	return array;
}

jobjectArray getRoomFansArray(JNIEnv *env, const RoomTopFanList& fansList){
	jobjectArray array = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOM_FANS_ITEM_CLASS);
	if (NULL != jItemCls) {
		array = env->NewObjectArray(fansList.size(), jItemCls, NULL);
		if (NULL != array) {
			int i = 0;
			for(RoomTopFanList::const_iterator itr = fansList.begin();
				itr != fansList.end();
				itr++)
			{
				jobject jItem = getFansItem(env, (*itr));
				if (NULL != jItem) {
					env->SetObjectArrayElement(array, i, jItem);
					i++;
				}
				env->DeleteLocalRef(jItem);
			}
		}
	}

	return array;
}

jobject getRoomInfoItem(JNIEnv *env, const string& userId, const string& nickName, const string& photoUrl,
		const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fansList){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOM_INFO_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;II";
		signature += "[L";
		signature += IM_ROOM_FANS_ITEM_CLASS;
		signature += ";)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());

		//videoList转Java数组
		jobjectArray videoUrlArray = getJavaStringArray(env, videoUrls);

		//fanslist 转Java数组
		jobjectArray fansArray = getRoomFansArray(env, fansList);

		jstring juserId = env->NewStringUTF(userId.c_str());
		jstring jnickName = env->NewStringUTF(nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
		jstring jcountry = env->NewStringUTF(country.c_str());
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					jcountry,
					videoUrlArray,
					fansNum,
					contribute,
					fansArray
					);
		env->DeleteLocalRef(juserId);
		env->DeleteLocalRef(jnickName);
		env->DeleteLocalRef(jphotoUrl);
		env->DeleteLocalRef(jcountry);
		if(NULL != videoUrlArray){
			env->DeleteLocalRef(videoUrlArray);
		}
		if(NULL != fansArray){
			env->DeleteLocalRef(fansArray);
		}
	}
	return jItem;
}


