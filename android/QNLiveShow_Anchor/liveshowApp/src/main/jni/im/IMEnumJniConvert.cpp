/*
 * IMEnumJniConvert.cpp
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#include "IMEnumJniConvert.h"

int IMErrorTypeToInt(ZBLCC_ERR_TYPE errType)
{
	// 默认是HTTP_LCC_ERR_FAIL，当服务器返回未知的错误码时
	int value = 1;
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

int IMInviteTypeToInt(ZBIMReplyType replyType)
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

int RoomTypeToInt(ZBRoomType roomType)
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

// 底层状态转换JAVA坐标
int LiveStatusToInt(ZBLiveStatus status) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(tLiveStatusArray); i++)
	{
		if (status == tLiveStatusArray[i]) {
            value = i;
			break;
		}
	}
	return value;
}

int InviteReplyTypeToInt(ZBReplyType replyType)
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

int AnchorReplyTypeToInt(ZBAnchorReplyType replyType)
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

int TalentInviteStatusToInt(ZBTalentStatus talentInviteStatus)
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

int IMSystemTypeToInt(ZBIMSystemType type)
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

ZBIMControlType IntToIMControlType(int value){
	return (ZBIMControlType)(value < _countof(IMControlTypeArray) ? IMControlTypeArray[value] : IMControlTypeArray[0]);
}

// 底层状态转换JAVA坐标
int IMControlTypeToInt(ZBIMControlType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMControlTypeArray); i++)
	{
		if (type == IMControlTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}


int AnchorStatusToInt(AnchorStatus roomType) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorStatusArray); i++)
	{
		if (roomType == AnchorStatusArray[i]) {
			value = i + 1;
			break;
		}
	}
	return value;
}

int AnchorKnockTypeToInt(IMAnchorKnockType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorKnockTypeArray); i++)
	{
		if (type == AnchorKnockTypeArray[i]) {
			value = i ;
			break;
		}
	}
	return value;
}

// 底层状态转换JAVA坐标
int AnchorReplyInviteTypeToInt(IMAnchorReplyInviteType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorReplyInviteTypeArray); i++)
	{
		if (type == AnchorReplyInviteTypeArray[i]) {
			value = i ;
			break;
		}
	}
	return value;
}

// 底层状态转换JAVA坐标
int IMAnchorPublicRoomTypeToInt(IMAnchorPublicRoomType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMAnchorPublicRoomTypeArray); i++)
	{
		if (type == IMAnchorPublicRoomTypeArray[i]) {
			value = i ;
			break;
		}
	}
	return value;
}

// 底层状态转换JAVA坐标
int IMAnchorProgramStatusToInt(IMAnchorProgramStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(IMAnchorProgramStatusArray); i++)
	{
		if (type == IMAnchorProgramStatusArray[i]) {
			value = i ;
			break;
		}
	}
	return value;
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

jobject getRoomInItem(JNIEnv *env, const ZBRoomInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_ROOMIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;I[Ljava/lang/String;II[Ljava/lang/String;IIZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());

        if (NULL != init) {
            jobjectArray pushUrlArray = getJavaStringArray(env, item.pushUrl);
            jobjectArray pullUrlArray = getJavaStringArray(env, item.pullUrl);
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            int jroomType = RoomTypeToInt(item.roomType);
            int jstatus = LiveStatusToInt(item.status);
            int jliveShowType = IMAnchorPublicRoomTypeToInt(item.liveShowType);
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jroomId,
                                   jroomType,
                                   pushUrlArray,
                                   item.leftSeconds,
                                   item.maxFansiNum,
                                   pullUrlArray,
                                   jstatus,
                                   jliveShowType,
                                   item.priv.isHasOneOnOneAuth,
                                   item.priv.isHasBookingAuth
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jroomId);
            if(NULL != pushUrlArray){
                env->DeleteLocalRef(pushUrlArray);
            }
            if(NULL != pullUrlArray){
                env->DeleteLocalRef(pullUrlArray);
            }
        }

	}
	return jItem;
}


jobject getInviteItem(JNIEnv *env, const ZBPrivateInviteItem& item){
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
	return jItem;
}

jobjectArray getInviteArray(JNIEnv *env, const ZBInviteList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_INVITE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(ZBInviteList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getInviteItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getScheduleRoomItem(JNIEnv *env, const ZBScheduleRoomItem& item){
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
	return jItem;
}

jobjectArray getScheduleRoomArray(JNIEnv *env, const ZBScheduleRoomList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_SCHEDULE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(ZBScheduleRoomList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getScheduleRoomItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getLoginRoomItem(JNIEnv *env, const ZBLSLoginRoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_ROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;I)V");
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            int jroomType = RoomTypeToInt(item.roomType);
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   jroomType
            );
            env->DeleteLocalRef(jroomId);
        }
	}
	return jItem;
}

jobjectArray getLoginRoomArray(JNIEnv *env, const ZBLSLoginRoomList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_LOGIN_ROOM_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(ZBLSLoginRoomList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getLoginRoomItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getLoginItem(JNIEnv *env, const ZBLoginReturnItem& item){
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
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (init != NULL) {
            jobjectArray jroomArray = getLoginRoomArray(env, item.roomList);
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
	}
	return jItem;
}


jobject getAnchorGiftNumItem(JNIEnv *env, const AnchorGiftNumItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_GIFTNUM_ITEM_CLASS);
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
	return jItem;
}

jobjectArray getAnchorGiftNumArray(JNIEnv *env, const AnchorGiftNumList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_GIFTNUM_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(AnchorGiftNumList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getAnchorGiftNumItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getAnchorRecvGiftItem(JNIEnv *env, const AnchorRecvGiftItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECVGIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;";
		signature += "[L";
		signature += IM_HANGOUT_GIFTNUM_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jobjectArray videoUrlArray = getAnchorGiftNumArray(env, item.buyforList);
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   videoUrlArray
            );
            env->DeleteLocalRef(juserId);
            if(NULL != videoUrlArray){
                env->DeleteLocalRef(videoUrlArray);
            }
        }
	}
	return jItem;
}

jobjectArray getAnchorRecvGiftItemArray(JNIEnv *env, const AnchorRecvGiftList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECVGIFT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(AnchorRecvGiftList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getAnchorRecvGiftItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getOtherAnchorItem(JNIEnv *env, const OtherAnchorItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_OtherAnchor_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;III[Ljava/lang/String;)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            int janchorStatus = AnchorStatusToInt(item.anchorStatus);
            jobjectArray videoUrlArray = getJavaStringArray(env, item.videoUrl);
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   janchorStatus,
                                   item.leftSeconds,
                                   item.loveLevel,
                                   videoUrlArray
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            if(NULL != videoUrlArray){
                env->DeleteLocalRef(videoUrlArray);
            }
        }

	}
	return jItem;
}

jobjectArray getOtherAnchorItemArray(JNIEnv *env, const OtherAnchorItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IM_HANGOUT_OtherAnchor_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(OtherAnchorItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getOtherAnchorItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getHangoutRoomItem(JNIEnv *env, const AnchorHangoutRoomItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_HANGOUTROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;I[Ljava/lang/String;[Ljava/lang/String;";
		signature += "[L";
		signature += IM_HANGOUT_OtherAnchor_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += IM_HANGOUT_RECVGIFT_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            int jroomType = RoomTypeToInt(item.roomType);
            jstring jmanId = env->NewStringUTF(item.manId.c_str());
            jstring jmanNickName = env->NewStringUTF(item.manNickName.c_str());
            jstring jmanPhotoUrl = env->NewStringUTF(item.manPhotoUrl.c_str());
            jobjectArray manVideoUrlArray = getJavaStringArray(env, item.manVideoUrl);
            jobjectArray pushUrlArray = getJavaStringArray(env, item.pushUrl);
            jobjectArray jotherAnchorListArray = getOtherAnchorItemArray(env, item.otherAnchorList);
            jobjectArray jbuyforListArray = getAnchorRecvGiftItemArray(env, item.buyforList);
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   jroomType,
                                   jmanId,
                                   jmanNickName,
                                   jmanPhotoUrl,
                                   item.manLevel,
                                   manVideoUrlArray,
                                   pushUrlArray,
                                   jotherAnchorListArray,
                                   jbuyforListArray
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(jmanId);
            env->DeleteLocalRef(jmanNickName);
            env->DeleteLocalRef(jmanPhotoUrl);
            if(NULL != manVideoUrlArray){
                env->DeleteLocalRef(manVideoUrlArray);
            }
            if(NULL != pushUrlArray){
                env->DeleteLocalRef(pushUrlArray);
            }
            if(NULL != jotherAnchorListArray){
                env->DeleteLocalRef(jotherAnchorListArray);
            }
            if(NULL != jbuyforListArray){
                env->DeleteLocalRef(jbuyforListArray);
            }
        }


	}
	return jItem;
}

jobject getAnchorItem(JNIEnv *env, const AnchorItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, IM_HANGOUT_ANCHORITEM_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring janchorNickName = env->NewStringUTF(item.anchorNickName.c_str());
            jstring janchorPhotoUrl = env->NewStringUTF(item.anchorPhotoUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   janchorNickName,
                                   janchorPhotoUrl
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(janchorNickName);
            env->DeleteLocalRef(janchorPhotoUrl);
        }

    }
    return jItem;
}

jobjectArray getAnchorItemArray(JNIEnv *env, const AnchorItemList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, IM_HANGOUT_ANCHORITEM_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(AnchorItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAnchorItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}


jobject getHangoutInviteItem(JNIEnv *env, const AnchorHangoutInviteItem& item) {
    jobject jItem = NULL;

    jclass jItemCls = GetJClass(env, IM_HANGOUT_HANGOUTINVITE_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "[L";
        signature += IM_HANGOUT_ANCHORITEM_ITEM_CLASS;
        signature += ";";
        signature += "I)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jobjectArray jlistArray = getAnchorItemArray(env, item.anchorList);
            jItem = env->NewObject(jItemCls, init,
                                   jinviteId,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   jlistArray,
                                   item.expire
            );
            env->DeleteLocalRef(jinviteId);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            if(NULL != jlistArray){
                env->DeleteLocalRef(jlistArray);
            }
        }

    }
    return jItem;
}


jobject getHangoutCommendItem(JNIEnv *env, const IMAnchorRecommendHangoutItem& item) {
	jobject jItem = NULL;

    jclass jItemCls = GetJClass(env, IM_HANGOUT_HANGOUTRECOMMEND_ITEM_CLASS);
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
    return jItem;
}

jobject getDealKnockRequestItem(JNIEnv *env, const IMAnchorKnockRequestItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_KNOCKREQUEST_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jknockId = env->NewStringUTF(item.knockId.c_str());
            jint jtype = AnchorKnockTypeToInt(item.type);
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   jknockId,
                                   jtype
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jknockId);
        }

	}
	return jItem;
}

jobject getOtherInviteItem(JNIEnv *env, const IMAnchorRecvOtherInviteItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_OTHERINVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jinviteId,
                                   jroomId,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   item.expire
            );
            env->DeleteLocalRef(jinviteId);
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
        }

	}
	return jItem;
}

jobject getDealInviteItem(JNIEnv *env, const IMAnchorRecvDealInviteItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_DEALINVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jint jtype = AnchorReplyInviteTypeToInt(item.type);
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
	return jItem;
}

jobject getUserInfoItem(JNIEnv *env, const IMAnchorUserInfoItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_USERINFO_ITEM_CLASS);
	if (NULL != jItemCls){
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
                                   jhonorImg
            );
            env->DeleteLocalRef(jriderId);
            env->DeleteLocalRef(jriderName);
            env->DeleteLocalRef(jriderUrl);
            env->DeleteLocalRef(jhonorImg);
        }

	}
	return jItem;
}

jobject getEnterHangoutRoomItem(JNIEnv *env, const IMAnchorRecvEnterRoomItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECVENTERROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;ZLjava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;";
		signature += "L";
        signature += IM_HANGOUT_USERINFO_ITEM_CLASS;
        signature += ";[Ljava/lang/String;";
		signature += "[L";
		signature += IM_HANGOUT_GIFTNUM_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jobject juserInfo = getUserInfoItem(env, item.userInfo);
            jobjectArray jpushUrlArray = getJavaStringArray(env, item.pullUrl);
            jobjectArray jbuyforListArray = getAnchorGiftNumArray(env, item.bugForList);
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   item.isAnchor,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   juserInfo,
                                   jpushUrlArray,
                                   jbuyforListArray

            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);

            if(NULL != juserInfo){
                env->DeleteLocalRef(juserInfo);
            }

            if(NULL != jpushUrlArray){
                env->DeleteLocalRef(jpushUrlArray);
            }

            if(NULL != jbuyforListArray){
                env->DeleteLocalRef(jbuyforListArray);
            }

        }

	}
	return jItem;
}


jobject getLeaveHangoutRoomItem(JNIEnv *env, const IMAnchorRecvLeaveRoomItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECVLEAVEROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;ZLjava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I";
		signature += "Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jerrMsg = env->NewStringUTF(item.errMsg.c_str());
            int errType = IMErrorTypeToInt(item.errNo);
            jItem = env->NewObject(jItemCls, init,
                                   jroomId,
                                   item.isAnchor,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   errType,
                                   jerrMsg
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jerrMsg);
        }

	}
	return jItem;
}

jobject getHangoutGiftItem(JNIEnv *env, const IMAnchorRecvGiftItem& item) {
	jobject jItem = NULL;

	jclass jItemCls = GetJClass(env, IM_HANGOUT_RECVHANGOUTGIFT_ITEM_CLASS);
	if (NULL != jItemCls){
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
                                   item.isPrivate
            );
            env->DeleteLocalRef(jroomId);
            env->DeleteLocalRef(jfromId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jtoUid);
            env->DeleteLocalRef(jgiftId);
            env->DeleteLocalRef(jgiftName);
        }

	}
	return jItem;
}

jobject getIMProgramInfoItem(JNIEnv *env, const IMAnchorProgramInfoItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IM_PROGRAM_PROGRAMINFO_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;I";
		signature += "III";
		signature += "IDI";
		signature += "IIZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jshowLiveId = env->NewStringUTF(item.showLiveId.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jshowTitle = env->NewStringUTF(item.showTitle.c_str());
            jstring jshowIntroduce = env->NewStringUTF(item.showIntroduce.c_str());
            jstring jcover = env->NewStringUTF(item.cover.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jshowLiveId,
                                   janchorId,
                                   jshowTitle,
                                   jshowIntroduce,
                                   jcover,
                                   item.approveTime,
                                   item.startTime,
                                   item.duration,
                                   item.leftSecToStart,
                                   item.leftSecToEnter,
                                   item.price,
                                   IMAnchorProgramStatusToInt(item.status),
                                   item.ticketNum,
                                   item.followNum,
                                   item.isTicketFull
            );
            env->DeleteLocalRef(jshowLiveId);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jshowTitle);
            env->DeleteLocalRef(jshowIntroduce);
            env->DeleteLocalRef(jcover);
        }

	}
	return jItem;
}


