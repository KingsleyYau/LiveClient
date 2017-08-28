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

int RoomTypeToInt(RoomType roomType)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(RoomTypeArray); i++)
	{
		if (roomType == RoomTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int InviteReplyTypeToInt(ReplyType replyType)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(InviteReplyTypeArray); i++)
	{
		if (replyType == InviteReplyTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

jobject getRebateItem(JNIEnv *env, const RebateInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_REBATE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(DIDI)V");
		jItem = env->NewObject(jItemCls, init,
					item.curCredit,
					item.curTime,
					item.preCredit,
					item.preTime
					);
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

jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList){
	jintArray jarray = env->NewIntArray(sourceList.size());
	if (NULL != jarray) {
		int i = 0;
		int length = sourceList.size();
		int *pArray = new int[length+1];
		for(list<int>::const_iterator itr = sourceList.begin();
			itr != sourceList.end();
			itr++)
		{
			*(pArray+i) = (*itr);
		}
		env->SetIntArrayRegion(jarray, 0, length, pArray);
		delete [] pArray;
	}
	return jarray;
}

jobject getRoomInItem(JNIEnv *env, const string& userId, const string& nickName,const string& photoUrl, const list<string>& videoUrls,
		RoomType roomType, double credit, bool usedVoucher, int fansNum, list<int> emoTypeList, int loveLevel, const RebateInfo& item, bool favorite,
		int leftSeconds, bool waitStart, const list<string>& manPushUrls, int manLevel){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOMIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;IDZI[II";
		signature += "L";
		signature += IM_REBATE_ITEM_CLASS;
		signature += ";ZIZ[Ljava/lang/String;I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());

		//videoList转Java数组
		jobjectArray videoUrlArray = getJavaStringArray(env, videoUrls);

		//emoTypeList 转Java数组
		jintArray emoTypeArray = getJavaIntArray(env, emoTypeList);

		//manUploadRtmpUrls转Java数组
		jobjectArray jmanUploadUrls = getJavaStringArray(env, manPushUrls);

		//获取rebate item
		jobject jrebateItem = getRebateItem(env, item);

		jstring juserId = env->NewStringUTF(userId.c_str());
		jstring jnickName = env->NewStringUTF(nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
		int jroomType = RoomTypeToInt(roomType);
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					videoUrlArray,
					jroomType,
					credit,
					usedVoucher,
					fansNum,
					emoTypeArray,
					loveLevel,
					jrebateItem,
					favorite,
					leftSeconds,
					waitStart,
					jmanUploadUrls,
					manLevel
					);
		env->DeleteLocalRef(juserId);
		env->DeleteLocalRef(jnickName);
		env->DeleteLocalRef(jphotoUrl);
		if(NULL != videoUrlArray){
			env->DeleteLocalRef(videoUrlArray);
		}
		if(NULL != emoTypeArray){
			env->DeleteLocalRef(emoTypeArray);
		}
		if(NULL != jmanUploadUrls){
			env->DeleteLocalRef(jmanUploadUrls);
		}
		if(NULL != jrebateItem){
			env->DeleteLocalRef(jrebateItem);
		}
	}
	return jItem;
}


