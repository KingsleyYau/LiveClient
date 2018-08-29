/*
 * IMEnumJniConvert.cpp
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#include "IMEnumJniConvert.h"

int IMErrorTypeToInt(LCC_ERR_TYPE errType)
{
	// 默认是LCC_ERR_PROTOCOLFAIL， 当没有这些枚举就是LCC_ERR_PROTOCOLFAIL
	int value = 2;
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

int IMSystemTypeToInt(IMSystemType type)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMSystemTypeArray); i++)
	{
		if (type == IMSystemTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

IMControlType IntToIMControlType(int value){
	return (IMControlType)(value < _countof(IMControlTypeArray) ? IMControlTypeArray[value] : IMControlTypeArray[0]);
}

// 底层状态转换JAVA坐标
int IMProgramNoticeTypeToInt(IMProgramNoticeType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMProgramNoticeTypeArray); i++)
	{
		if (type == IMProgramNoticeTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}


int IMProgramStatusToInt(IMProgramStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMProgramStatusArray); i++)
	{
		if (type == IMProgramStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int IMPublicRoomTypeToInt(IMPublicRoomType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMPublicRoomTypeArray); i++)
	{
		if (type == IMPublicRoomTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int IMProgramTicketStatusToInt(IMProgramTicketStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMProgramTicketStatusArray); i++)
	{
		if (type == IMProgramTicketStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int IMReplyInviteTypeToInt(IMReplyInviteType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMReplyInviteTypeTypeArray); i++)
	{
		if (type == IMReplyInviteTypeTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int LiveAnchorStatusToInt(LiveAnchorStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LiveAnchorStatusArray); i++)
	{
		if (type == LiveAnchorStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;

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
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getBookingReplyItem(JNIEnv *env, const BookingReplyItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_BOOKINGREPLY_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            int jinviteReplyType = InviteReplyTypeToInt(item.replyType);
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring javatarImg = env->NewStringUTF(item.avatarImg.c_str());
            jstring jmsg = env->NewStringUTF(item.msg.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jinviteId,
                                   jinviteReplyType,
                                   jroomId,
                                   janchorId,
                                   jnickName,
                                   javatarImg,
                                   jmsg
            );
            env->DeleteLocalRef(jinviteId);
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(javatarImg);
            env->DeleteLocalRef(jmsg);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
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
		signature += ";ZIZ[Ljava/lang/String;IDDILjava/lang/String;Ljava/lang/String;DIIZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());

        if (NULL != init) {

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
            jint jliveShowType = IMPublicRoomTypeToInt(item.liveShowType);
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
                                   jhonorImg,
                                   item.popPrice,
                                   item.useCoupon,
                                   jliveShowType,
								   item.isHasTalent
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getPackageUpdateGiftItem(JNIEnv *env, const GiftInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;I)V");

        if (NULL != init) {
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getPackageUpdateVoucherItem(JNIEnv *env, const VoucherInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_VOUCHER_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
        if (NULL != init) {
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getPackageUpdateRideItem(JNIEnv *env, const RideInfo& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PACKAGE_UPDATE_RIDE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
        if (NULL != init) {
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
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
        if (NULL != init) {
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getInviteItem(JNIEnv *env, const PrivateInviteItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
				"Ljava/lang/String;IILjava/lang/String;ZIIILjava/lang/String;)V");
        if (NULL != init) {
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

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
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
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItemArray;
}

jobject getScheduleRoomItem(JNIEnv *env, const ScheduleRoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_SCHEDULE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickname = env->NewStringUTF(item.nickName.c_str());
            jstring janchorImg = env->NewStringUTF(item.anchorImg.c_str());
            jstring janchorCoverImg = env->NewStringUTF(item.anchorCoverImg.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickname,
                                   janchorImg,
                                   janchorCoverImg,
                                   item.canEnterTime,
                                   item.leftSeconds,
                                   jroomId
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickname);
            env->DeleteLocalRef(janchorImg);
            env->DeleteLocalRef(janchorCoverImg);
            env->DeleteLocalRef(jroomId);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
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
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItemArray;
}

jobject getLoginRoomItem(JNIEnv *env, const LSLoginRoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_ROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   janchorId,
                                   jnickName
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobjectArray getLoginRoomArray(JNIEnv *env, const LSLoginRoomList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_ROOM_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(LSLoginRoomList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getLoginRoomItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItemArray;
}

jobject getOngoingShowItem(JNIEnv *env, const LSIMOngoingshowItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PROGRAM_ONGOINGSHOW_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(L";
		signature += IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
		signature += ";";
		signature += "ILjava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jmsg = env->NewStringUTF(item.msg.c_str());
            jint jtype = IMProgramNoticeTypeToInt(item.type);
            jobject jprogramItem = getIMProgramInfoItem(env, item.showInfo);
            jItem = env->NewObject(jItemCls, init,
                                   jprogramItem,
                                   jtype,
                                   jmsg
            );
            env->DeleteLocalRef(jmsg);
            env->DeleteLocalRef(jprogramItem);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobjectArray getOngoingShowArray(JNIEnv *env, const OngoingShowList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_PROGRAM_ONGOINGSHOW_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(OngoingShowList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getOngoingShowItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItemArray;
}

jobject getLoginItem(JNIEnv *env, const LoginReturnItem& item){
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_LOGIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(";
		signature += "[L";
		signature += IM_LOGIN_ROOM_ITEM_CLASS;
        signature += ";";
		signature += "[L";
		signature += IM_LOGIN_INVITE_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += IM_LOGIN_SCHEDULE_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += IM_PROGRAM_ONGOINGSHOW_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jobjectArray jroomArray = getLoginRoomArray(env, item.roomList);
            jobjectArray jinviteArray = getInviteArray(env, item.inviteList);
            jobjectArray jscheduleRoomArray = getScheduleRoomArray(env, item.scheduleRoomList);
            jobjectArray jongoingShowArray = getOngoingShowArray(env, item.ongoingShowList);
            jItem = env->NewObject(jItemCls, init,
                                   jroomArray,
                                   jinviteArray,
                                   jscheduleRoomArray,
                                   jongoingShowArray
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
            if(NULL != jongoingShowArray){
                env->DeleteLocalRef(jongoingShowArray);
            }
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}



jobject getIMProgramInfoItem(JNIEnv *env, const IMProgramItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PROGRAM_PROGRAMINFO_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;II";
		signature += "III";
		signature += "DII";
		signature += "ZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jshowLiveId = env->NewStringUTF(item.showLiveId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring janchorNickName = env->NewStringUTF(item.anchorNickName.c_str());
            jstring janchorAvatar = env->NewStringUTF(item.anchorAvatar.c_str());
            jstring jshowTitle = env->NewStringUTF(item.showTitle.c_str());
            jstring jshowIntroduce = env->NewStringUTF(item.showIntroduce.c_str());
            jstring jcover = env->NewStringUTF(item.cover.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jshowLiveId,
                                   janchorId,
                                   janchorNickName,
                                   janchorAvatar,
                                   jshowTitle,
                                   jshowIntroduce,
                                   jcover,
                                   item.approveTime,
                                   item.startTime,
                                   item.duration,
                                   item.leftSecToStart,
                                   item.leftSecToEnter,
                                   item.price,
                                   IMProgramStatusToInt(item.status),
                                   IMProgramTicketStatusToInt(item.ticketStatus),
                                   item.isHasFollow,
                                   item.isTicketFull
            );
            env->DeleteLocalRef(jshowLiveId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(janchorNickName);
            env->DeleteLocalRef(janchorAvatar);
            env->DeleteLocalRef(jshowTitle);
            env->DeleteLocalRef(jshowIntroduce);
            env->DeleteLocalRef(jcover);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getIMLoveLeveItem(JNIEnv *env, const IMLoveLevelItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMLOVELEVEL_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(ILjava/lang/String;Ljava/lang/String;";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
			jstring janchorName = env->NewStringUTF(item.anchorName.c_str());
			jItem = env->NewObject(jItemCls, init,
								   item.loveLevel,
								   janchorId,
								   janchorName
			);
			env->DeleteLocalRef(janchorId);
			env->DeleteLocalRef(janchorName);
		}

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getHangoutCommendItem(JNIEnv *env, const IMRecommendHangoutItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECOMMEND_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;ILjava/lang/String;";
		signature += "Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jfriendId = env->NewStringUTF(item.friendId.c_str());
            jstring jfriendNickName = env->NewStringUTF(item.friendNickName.c_str());
            jstring jfriendPhotoUrl = env->NewStringUTF(item.friendPhotoUrl.c_str());
            jstring jfriendCountry = env->NewStringUTF(item.friendCountry.c_str());
            jstring jrecommendId = env->NewStringUTF(item.recommendId.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   jfriendId,
                                   jfriendNickName,
                                   jfriendPhotoUrl,
                                   item.friendAge,
                                   jfriendCountry,
                                   jrecommendId
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jfriendId);
            env->DeleteLocalRef(jfriendNickName);
            env->DeleteLocalRef(jfriendPhotoUrl);
            env->DeleteLocalRef(jfriendCountry);
            env->DeleteLocalRef(jrecommendId);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getHangoutDealInviteItem(JNIEnv *env, const IMRecvDealInviteItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMDEALINVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I";
		signature += ")V";

		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jint jtype = IMReplyInviteTypeToInt(item.type);
            jItem = env->NewObject(jItemCls, init,
                                   jinviteId,
                                   jroomId,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   jtype
            );
            env->DeleteLocalRef(jinviteId);
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
        }

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}


jobject getIMGiftNumItem(JNIEnv *env, const IMGiftNumItem& item) {
    jobject jItem = NULL;

    jclass jItemCls = GetJClass(env, IM_HANGOUT_IMGIFTNUM_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;I)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jgiftId = env->NewStringUTF(item.giftId.c_str());

            jItem = env->NewObject(jItemCls, init,
                                   jgiftId,
                                   item.giftNum
            );
            env->DeleteLocalRef(jgiftId);
        }

    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobjectArray getGiftNumArray(JNIEnv *env, const GiftNumList& list) {
    jobjectArray jItemArray = NULL;
    jclass  jItemCls = GetJClass(env, IM_HANGOUT_IMGIFTNUM_ITEM_CLASS);
    if (NULL != jItemCls && list.size() > 0) {
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for (GiftNumList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getIMGiftNumItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteGlobalRef(item);
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItemArray;
}

jobject getIMRecvGiftItem(JNIEnv *env, const IMRecvGiftItem& item) {
    jobject jItem = NULL;

    jclass jItemCls = GetJClass(env, IM_HANGOUT_IMRECVBUYFORGIFT_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;";
        signature += "[L";
        signature += IM_HANGOUT_IMGIFTNUM_ITEM_CLASS;
        signature += ";)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
			jobjectArray  jbuyforList = getGiftNumArray(env, item.buyforList);
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
								   jbuyforList

            );
            env->DeleteLocalRef(juserId);

            if(NULL != jbuyforList){
                env->DeleteLocalRef(jbuyforList);
            }
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobjectArray getRecvGiftArray(JNIEnv *env, const RecvGiftList& list) {
    jobjectArray jItemArray = NULL;
    jclass  jItemCls = GetJClass(env, IM_HANGOUT_IMRECVBUYFORGIFT_ITEM_CLASS);
    if (NULL != jItemCls && list.size() > 0) {
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for (RecvGiftList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getIMRecvGiftItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteGlobalRef(item);
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItemArray;
}

jobject getOtherAnchorItem(JNIEnv *env, const IMOtherAnchorItem& item) {
    jobject jItem = NULL;

    jclass jItemCls = GetJClass(env, IM_HANGOUT_IMHANGOUTANCHOR_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "ILjava/lang/String;I";
        signature += "I[Ljava/lang/String;)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            jint janchorStatus = LiveAnchorStatusToInt(item.anchorStatus);
            jobjectArray jvideoUrl = getJavaStringArray(env, item.videoUrl);
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   janchorStatus,
                                   jinviteId,
                                   item.leftSeconds,
                                   item.loveLevel,
                                   jvideoUrl

            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jinviteId);
            if(NULL != jvideoUrl){
                env->DeleteLocalRef(jvideoUrl);
            }

        }

    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobjectArray getOtherAnchorItemArray(JNIEnv *env, const IMOtherAnchorItemList& list) {
    jobjectArray jItemArray = NULL;
    jclass  jItemCls = GetJClass(env, IM_HANGOUT_IMHANGOUTANCHOR_ITEM_CLASS);
    if (NULL != jItemCls && list.size() > 0) {
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for (IMOtherAnchorItemList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getOtherAnchorItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteGlobalRef(item);
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItemArray;
}

jobject getHangoutRoomItem(JNIEnv *env, const IMHangoutRoomItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMHANGOUTROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;II";
		signature += "D[Ljava/lang/String;";
		signature += "[L";
		signature += IM_HANGOUT_IMHANGOUTANCHOR_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += IM_HANGOUT_IMRECVBUYFORGIFT_ITEM_CLASS;
		signature += ";D";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		FileLog("IMClientJni", "OnEnterHangoutRoom() callback now1");
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jint jroomType = RoomTypeToInt(item.roomType);
			FileLog("IMClientJni", "OnEnterHangoutRoom() callback now2");
            jobjectArray jpushUrl = getJavaStringArray(env, item.pushUrl);
			FileLog("IMClientJni", "OnEnterHangoutRoom() callback now3");
			jobjectArray jotherAnchorList = getOtherAnchorItemArray(env, item.otherAnchorList);
			FileLog("IMClientJni", "OnEnterHangoutRoom() callback now4");
			jobjectArray jbuyforList = getRecvGiftArray(env, item.buyforList);
			FileLog("IMClientJni", "OnEnterHangoutRoom() callback now5");
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   jroomType,
                                   item.manLevel,
                                   item.manPushPrice,
								   jpushUrl,
								   jotherAnchorList,
								   jbuyforList,
								   item.credit
            );
            env->DeleteLocalRef(jroomId);
            if(NULL != jpushUrl){
                env->DeleteLocalRef(jpushUrl);
            }
			if(NULL != jotherAnchorList){
				env->DeleteLocalRef(jotherAnchorList);
			}
			if(NULL != jbuyforList){
				env->DeleteLocalRef(jbuyforList);
			}

        }
		FileLog("IMClientJni", "OnEnterHangoutRoom() callback now6");

	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject  getIMUserInfoItem(JNIEnv *env, const IMUserInfoItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMUSERINFO_ITEM_CLASS);
	if (NULL != jItemCls) {
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jriderId = env->NewStringUTF(item.riderId.c_str());
			jstring jriderName = env->NewStringUTF(item.riderName.c_str());
			jstring jriderUrl = env->NewStringUTF(item.riderUrl.c_str());
			jstring jhonorImg = env->NewStringUTF(item.honorImg.c_str());
			jItem = env->NewObject(jItemCls, init,
									jriderId,
									jriderName,
									jriderUrl,
									jhonorImg);
			env->DeleteLocalRef(jriderId);
			env->DeleteLocalRef(jriderName);
			env->DeleteLocalRef(jriderUrl);
			env->DeleteLocalRef(jhonorImg);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getRecvEnterHangoutRoomItem(JNIEnv *env, const IMRecvEnterRoomItem& item) {
	jobject jItem = NULL;

	jclass  jItemCls = GetJClass(env, IM_HANGOUT_IMRECVENTERROOM_ITEM_CLASS);
	if (NULL != jItemCls) {
		string  signature = "(Ljava/lang/String;ZLjava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;";
		signature += "L";
		signature += IM_HANGOUT_IMUSERINFO_ITEM_CLASS;
		signature += ";";
		signature += "[Ljava/lang/String;";
		signature += "[L";
		signature += IM_HANGOUT_IMGIFTNUM_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(item.roomId.c_str());
			jstring juserId = env->NewStringUTF(item.userId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
			jobject juserInfo = getIMUserInfoItem(env, item.userInfo);
			jobjectArray jpullUrl = getJavaStringArray(env, item.pullUrl);
			jobjectArray jbugForList = getGiftNumArray(env, item.bugForList);
			jItem = env->NewObject(jItemCls, init,
									jroomId,
								   	item.isAnchor,
									juserId,
								    jnickName,
								    jphotoUrl,
								    juserInfo,
								    jpullUrl,
								    jbugForList
									);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			if (NULL != juserInfo) {
				env->DeleteLocalRef(juserInfo);
			}
			if (NULL != jpullUrl) {
				env->DeleteLocalRef(jpullUrl);
			}
			if (NULL != jbugForList) {
				env->DeleteLocalRef(jbugForList);
			}
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return  jItem;
}

jobject getRecvLeaveHangoutRoomItem(JNIEnv *env, const IMRecvLeaveRoomItem& item) {
	jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, IM_HANGOUT_IMRECVLEAVEROOM_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Ljava/lang/String;ZLjava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I";
		signature += "Ljava/lang/String;)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
			jint jerrNo = IMErrorTypeToInt(item.errNo);
            jstring jerrMsg = env->NewStringUTF(item.errMsg.c_str());
            jItem = env->NewObject(jItemCls, init,
									jroomId,
									item.isAnchor,
									juserId,
									jnickName,
									jphotoUrl,
									jerrNo,
									jerrMsg);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jerrMsg);
        }
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getRecvHangoutGiftItem(JNIEnv *env, const IMRecvHangoutGiftItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMRECVHANGOUTGIFT_ITEM_CLASS);
	if (NULL != jItemCls) {
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "IZI";
		signature += "IIZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(item.roomId.c_str());
			jstring jfromId = env->NewStringUTF(item.fromId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jtoUid = env->NewStringUTF(item.toUid.c_str());
			jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
			jstring jgiftName = env->NewStringUTF(item.giftName.c_str());
			jItem = env->NewObject(jItemCls, init,
									jroomId,
									jfromId,
									jnickName,
									jtoUid,
									jgiftId,
									jgiftName,
									item.giftNum,
									item.isMultiClick,
									item.multiClickStart,
									item.multiClickEnd,
									item.multiClickId,
									item.isPrivate);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(jfromId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jtoUid);
			env->DeleteLocalRef(jgiftId);
			env->DeleteLocalRef(jgiftName);

		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
	return jItem;
}

jobject getKnockRequestItem(JNIEnv *env, const IMKnockRequestItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMRECVKNOCKREQUEST_ITEM_CLASS);
	if (NULL != jItemCls) {
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;ILjava/lang/String;";
		signature += "Ljava/lang/String;I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(item.roomId.c_str());
			jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
			jstring jcountry = env->NewStringUTF(item.country.c_str());
			jstring jknockId = env->NewStringUTF(item.knockId.c_str());
			jItem = env->NewObject(jItemCls, init,
									jroomId,
									janchorId,
									jnickName,
									jphotoUrl,
								    item.age,
									jcountry,
									jknockId,
			    					item.expire);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(janchorId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jcountry);
			env->DeleteLocalRef(jknockId);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getLackCreditHangoutItem(JNIEnv *env, const IMLackCreditHangoutItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMRECVLEAVEROOM_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Ljava/lang/String;ZLjava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I";
		signature += "Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(item.roomId.c_str());
			jstring juserId = env->NewStringUTF(item.anchorId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item.avatarImg.c_str());
			jint jerrNo = IMErrorTypeToInt(item.errNo);
			jstring jerrMsg = env->NewStringUTF(item.errMsg.c_str());
			jItem = env->NewObject(jItemCls, init,
								   jroomId,
								   true,
								   juserId,
								   jnickName,
								   jphotoUrl,
								   jerrNo,
								   jerrMsg);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jerrMsg);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getHangoutChatItem(JNIEnv *env, const IMRecvHangoutChatItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMHANGOUTMSG_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Ljava/lang/String;ILjava/lang/String;";
		signature += "Ljava/lang/String;[BLjava/lang/String;";
		signature += "[Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(item.roomId.c_str());
			jstring jfromId = env->NewStringUTF(item.fromId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			const char *pMessage = item.msg.c_str();
			int strLen = strlen(pMessage);
			jbyteArray byteArray = env->NewByteArray(strLen);
			env->SetByteArrayRegion(byteArray, 0, strLen, reinterpret_cast<const jbyte*>(pMessage));
			jstring jhonorUrl = env->NewStringUTF(item.honorUrl.c_str());
			jobjectArray jat = getJavaStringArray(env, item.at);
			jItem = env->NewObject(jItemCls, init,
								   jroomId,
								   item.level,
								   jfromId,
								   jnickName,
								   byteArray,
								   jhonorUrl,
								   jat);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(jfromId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jhonorUrl);
			if (NULL != byteArray) {
				env->DeleteLocalRef(byteArray);
			}
			if (NULL != jat) {
				env->DeleteLocalRef(jat);
			}
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getHangoutCountDownItem(JNIEnv *env, const string& roomId, const string& anchorId, int leftSecond) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_IMHANGOUTCOUNTDOWN_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Ljava/lang/String;Ljava/lang/String;I";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jroomId = env->NewStringUTF(roomId.c_str());
			jstring janchorId = env->NewStringUTF(anchorId.c_str());
			jItem = env->NewObject(jItemCls, init,
								   jroomId,
								   janchorId,
								   leftSecond);
			env->DeleteLocalRef(jroomId);
			env->DeleteLocalRef(janchorId);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}