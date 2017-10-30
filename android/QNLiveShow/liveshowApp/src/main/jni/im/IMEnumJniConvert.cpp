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

int IMInviteTypeToInt(IMReplyType replyType)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMInviteTypeArray); i++)
	{
		if (replyType == IMInviteTypeArray[i]) {
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

int AnchorReplyTypeToInt(AnchorReplyType replyType)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorReplyTypeArray); i++)
	{
		if (replyType == AnchorReplyTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int TalentInviteStatusToInt(TalentStatus talentInviteStatus)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(TalentInviteStatusArray); i++)
	{
		if (talentInviteStatus == TalentInviteStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

IMControlType IntToIMControlType(int value){
	return (IMControlType)(value < _countof(IMControlTypeArray) ? IMControlTypeArray[value] : IMControlTypeArray[0]);
}

jobject getRebateItem(JNIEnv *env, const RebateInfoItem& item){
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
			i++;
		}
		env->SetIntArrayRegion(jarray, 0, length, pArray);
		delete [] pArray;
	}
	return jarray;
}

jobject getRoomInItem(JNIEnv *env, const RoomInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOMIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;IDZI[II";
		signature += "L";
		signature += IM_REBATE_ITEM_CLASS;
		signature += ";ZIZ[Ljava/lang/String;IDDILjava/lang/String;Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());

		//videoList转Java数组
		jobjectArray videoUrlArray = getJavaStringArray(env, item.videoUrl);

		//emoTypeList 转Java数组
		jintArray emoTypeArray = getJavaIntArray(env, item.emoTypeList);

		//manUploadRtmpUrls转Java数组
		jobjectArray jmanUploadUrls = getJavaStringArray(env, item.manPushUrl);

		//获取rebate item
		jobject jrebateItem = getRebateItem(env, item.rebateInfo);

		jstring juserId = env->NewStringUTF(item.userId.c_str());
		jstring jnickName = env->NewStringUTF(item.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		int jroomType = RoomTypeToInt(item.roomType);
		jstring jhonorId = env->NewStringUTF(item.honorId.c_str());
		jstring jhonorImg = env->NewStringUTF(item.honorImg.c_str());
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					videoUrlArray,
					jroomId,
					jroomType,
					item.credit,
					item.usedVoucher,
					item.fansNum,
					emoTypeArray,
					item.loveLevel,
					jrebateItem,
					item.favorite,
					item.leftSeconds,
					item.waitStart,
					jmanUploadUrls,
					item.manlevel,
					item.roomPrice,
					item.manPushPrice,
					item.maxFansiNum,
					jhonorId,
					jhonorImg
					);
		env->DeleteLocalRef(juserId);
		env->DeleteLocalRef(jnickName);
		env->DeleteLocalRef(jphotoUrl);
		env->DeleteLocalRef(jroomId);
		env->DeleteLocalRef(jhonorId);
		env->DeleteLocalRef(jhonorImg);
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

jobject getPackageUpdateGiftItem(JNIEnv *env, const GiftInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;I)V");
		jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
		jstring jname = env->NewStringUTF(item.name.c_str());
		jItem = env->NewObject(jItemCls, init,
					jgiftId,
					jname,
					item.num
					);
        env->DeleteLocalRef(jgiftId);
        env->DeleteLocalRef(jname);
	}
	return jItem;
}

jobject getPackageUpdateVoucherItem(JNIEnv *env, const VoucherInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_VOUCHER_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
		jstring jvoucherId = env->NewStringUTF(item.voucherId.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jdesc = env->NewStringUTF(item.desc.c_str());
		jItem = env->NewObject(jItemCls, init,
					jvoucherId,
					jphotoUrl,
					jdesc
					);
        env->DeleteLocalRef(jvoucherId);
        env->DeleteLocalRef(jphotoUrl);
        env->DeleteLocalRef(jdesc);
	}
	return jItem;
}

jobject getPackageUpdateRideItem(JNIEnv *env, const RideInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_RIDE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
		jstring jrideId = env->NewStringUTF(item.rideId.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jname = env->NewStringUTF(item.name.c_str());
		jItem = env->NewObject(jItemCls, init,
					jrideId,
					jphotoUrl,
					jname
					);
        env->DeleteLocalRef(jrideId);
        env->DeleteLocalRef(jphotoUrl);
        env->DeleteLocalRef(jname);
	}
	return jItem;
}

jobject getPackageUpdateItem(JNIEnv *env, const BackpackInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(";
		signature += "L";
		signature += IM_PACKAGE_UPDATE_GIFT_ITEM_CLASS;
		signature += ";";
		signature += "L";
		signature += IM_PACKAGE_UPDATE_VOUCHER_ITEM_CLASS;
		signature += ";";
		signature += "L";
		signature += IM_PACKAGE_UPDATE_RIDE_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jobject jgiftItem = getPackageUpdateGiftItem(env, item.gift);
		jobject jvoucherItem = getPackageUpdateVoucherItem(env, item.voucher);
		jobject jrideItem = getPackageUpdateRideItem(env, item.ride);
		jItem = env->NewObject(jItemCls, init,
					jgiftItem,
					jvoucherItem,
					jrideItem
					);
		if(NULL != jgiftItem){
			env->DeleteLocalRef(jgiftItem);
		}
		if(NULL != jvoucherItem){
			env->DeleteLocalRef(jvoucherItem);
		}
		if(NULL != jrideItem){
			env->DeleteLocalRef(jrideItem);
		}
	}
	return jItem;
}

jobject getInviteItem(JNIEnv *env, const PrivateInviteItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
				"Ljava/lang/String;IILjava/lang/String;ZIIILjava/lang/String;)V");
		jstring jinviteId = env->NewStringUTF(item.invitationId.c_str());
		jstring jtoId = env->NewStringUTF(item.oppositeId.c_str());
		jstring joppositeNickname = env->NewStringUTF(item.oppositeNickName.c_str());
		jstring joppositePhotoUrl = env->NewStringUTF(item.oppositePhotoUrl.c_str());
		jstring joppositeCountry = env->NewStringUTF(item.oppositeCountry.c_str());
		int jreplyType = IMInviteTypeToInt(item.replyType);
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		jItem = env->NewObject(jItemCls, init,
					jinviteId,
					jtoId,
					joppositeNickname,
					joppositePhotoUrl,
					item.oppositeLevel,
					item.oppositeAge,
					joppositeCountry,
					item.read,
					(int)item.inviTime,
					jreplyType,
					item.validTime,
					jroomId
					);
        env->DeleteLocalRef(jinviteId);
        env->DeleteLocalRef(jtoId);
        env->DeleteLocalRef(joppositeNickname);
        env->DeleteLocalRef(joppositePhotoUrl);
        env->DeleteLocalRef(joppositeCountry);
        env->DeleteLocalRef(jroomId);
	}
	return jItem;
}

jobjectArray getInviteArray(JNIEnv *env, const InviteList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_INVITE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(InviteList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getInviteItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getScheduleRoomItem(JNIEnv *env, const ScheduleRoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_SCHEDULE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V");
		jstring janchorImg = env->NewStringUTF(item.anchorImg.c_str());
		jstring janchorCoverImg = env->NewStringUTF(item.anchorCoverImg.c_str());
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		jItem = env->NewObject(jItemCls, init,
					janchorImg,
					janchorCoverImg,
					item.canEnterTime,
					jroomId
					);
        env->DeleteLocalRef(janchorImg);
        env->DeleteLocalRef(janchorCoverImg);
        env->DeleteLocalRef(jroomId);
	}
	return jItem;
}

jobjectArray getScheduleRoomArray(JNIEnv *env, const ScheduleRoomList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_SCHEDULE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(ScheduleRoomList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getScheduleRoomItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}


jobject getLoginItem(JNIEnv *env, const LoginReturnItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(";
		signature += "[Ljava/lang/String;";
		signature += "[L";
		signature += IM_LOGIN_INVITE_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += IM_LOGIN_SCHEDULE_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jobjectArray jroomArray = getJavaStringArray(env, item.roomList);
		jobjectArray jinviteArray = getInviteArray(env, item.inviteList);
		jobjectArray jscheduleRoomArray = getScheduleRoomArray(env, item.scheduleRoomList);
		jItem = env->NewObject(jItemCls, init,
					jroomArray,
					jinviteArray,
					jscheduleRoomArray
					);
		if(NULL != jroomArray){
			env->DeleteLocalRef(jroomArray);
		}
		if(NULL != jinviteArray){
			env->DeleteLocalRef(jinviteArray);
		}
		if(NULL != jscheduleRoomArray){
			env->DeleteLocalRef(jscheduleRoomArray);
		}
	}
	return jItem;
}



