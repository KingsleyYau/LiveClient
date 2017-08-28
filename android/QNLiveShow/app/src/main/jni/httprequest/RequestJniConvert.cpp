/*
 * RequestJniConvert.cpp
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#include "RequestJniConvert.h"
#include <common/CommonFunc.h>

int AnchorOnlineStatusToInt(OnLineStatus onlineStatus)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorOnlineStatusArray); i++)
	{
		if (onlineStatus == AnchorOnlineStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int LiveRoomTypeToInt(HttpRoomType liveRoomType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LiveRoomTypeArray); i++)
	{
		if (liveRoomType == LiveRoomTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int GiftTypeToInt(GiftType giftType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(GiftTypeArray); i++)
	{
		if (giftType == GiftTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int ImmediateInviteReplyTypeToInt(ReplyType replyType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(ImmediateInviteReplyTypeArray); i++)
	{
		if (replyType == ImmediateInviteReplyTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int BookInviteStatusToInt(BookingReplyType replyType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(BookInviteStatusArray); i++)
	{
		if (replyType == BookInviteStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

BookingListType IntToBookInviteListType(int value)
{
	return (BookingListType)(value < _countof(BookInviteListTypeArray) ? BookInviteListTypeArray[value] : BookInviteListTypeArray[0]);
}

/**************************** c++转Java对象    ****************************************/

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

jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, LOGIN_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V");
		jstring juserId = env->NewStringUTF(item.userId.c_str());
		jstring jtoken = env->NewStringUTF(item.token.c_str());
		jstring jnickName = env->NewStringUTF(item.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jtoken,
					jnickName,
					item.level,
					item.experience,
					jphotoUrl
					);
        env->DeleteLocalRef(juserId);
        env->DeleteLocalRef(jtoken);
        env->DeleteLocalRef(jnickName);
        env->DeleteLocalRef(jphotoUrl);
	}
	return jItem;
}

jobject getHotListItem(JNIEnv *env, const HttpLiveRoomInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HOTLIST_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
		jstring juserId = env->NewStringUTF(item.userId.c_str());
		jstring jnickName = env->NewStringUTF(item.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		jstring jroomName = env->NewStringUTF(item.roomName.c_str());
		jstring jroomPhotoUrl = env->NewStringUTF(item.roomPhotoUrl.c_str());
		int jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
		int jroomType = LiveRoomTypeToInt(item.roomType);
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					jonlineStatus,
					jroomId,
					jroomName,
					jroomPhotoUrl,
					jroomType
					);
        env->DeleteLocalRef(juserId);
        env->DeleteLocalRef(jnickName);
        env->DeleteLocalRef(jphotoUrl);
        env->DeleteLocalRef(jroomId);
        env->DeleteLocalRef(jroomName);
        env->DeleteLocalRef(jroomPhotoUrl);
	}
	return jItem;
}

jobject getFollowingListItem(JNIEnv *env, const HttpFollowItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, FOLLOWINGLIST_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;III)V");
		jstring juserId = env->NewStringUTF(item.userId.c_str());
		jstring jnickName = env->NewStringUTF(item.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		jstring jroomName = env->NewStringUTF(item.roomName.c_str());
		jstring jroomPhotoUrl = env->NewStringUTF(item.roomPhotoUrl.c_str());
		int jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
		int jroomType = LiveRoomTypeToInt(item.roomType);
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					jonlineStatus,
					jroomId,
					jroomName,
					jroomPhotoUrl,
					item.loveLevel,
					jroomType,
					(int)item.addDate
					);
        env->DeleteLocalRef(juserId);
        env->DeleteLocalRef(jnickName);
        env->DeleteLocalRef(jphotoUrl);
        env->DeleteLocalRef(jroomId);
        env->DeleteLocalRef(jroomName);
        env->DeleteLocalRef(jroomPhotoUrl);
	}
	return jItem;
}

jobject getValidRoomItem(JNIEnv *env, const HttpGetRoomInfoItem::RoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, VALID_LIVEROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;)V");
		jstring jroomid = env->NewStringUTF(item.roomId.c_str());
		jstring jroomurl = env->NewStringUTF(item.roomUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					jroomid,
					jroomurl
					);
        env->DeleteLocalRef(jroomid);
        env->DeleteLocalRef(jroomurl);
	}
	return jItem;
}

jobject getImmediateInviteItem(JNIEnv *env, const HttpInviteInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IMMEDIATE_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
				"Ljava/lang/String;IILjava/lang/String;ZIIILjava/lang/String;)V");
		jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
		jstring jtoId = env->NewStringUTF(item.oppositeId.c_str());
		jstring joppositeNickname = env->NewStringUTF(item.oppositeNickName.c_str());
		jstring joppositePhotoUrl = env->NewStringUTF(item.oppositePhotoUrl.c_str());
		jstring joppositeCountry = env->NewStringUTF(item.oppositeCountry.c_str());
		int jreplyType = ImmediateInviteReplyTypeToInt(item.replyType);
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

jobject getAudienceInfoItem(JNIEnv *env, const HttpLiveFansItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, AUDIENCE_INFO_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
		jstring juserId = env->NewStringUTF(item.userId.c_str());
		jstring jnickName = env->NewStringUTF(item.nickName.c_str());
		jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
		jstring jmountId = env->NewStringUTF(item.mountId.c_str());
		jstring jmountUrl = env->NewStringUTF(item.mountUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					juserId,
					jnickName,
					jphotoUrl,
					jmountId,
					jmountUrl
					);
        env->DeleteLocalRef(juserId);
        env->DeleteLocalRef(jnickName);
        env->DeleteLocalRef(jphotoUrl);
        env->DeleteLocalRef(jmountId);
        env->DeleteLocalRef(jmountUrl);
	}
	return jItem;
}

jobject getGiftDetailItem(JNIEnv *env, const HttpGiftInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, GIFT_DETAIL_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
				"Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;DZIIII)V");
		jstring jid = env->NewStringUTF(item.giftId.c_str());
		jstring jname = env->NewStringUTF(item.name.c_str());
		jstring jsmallImgUrl = env->NewStringUTF(item.smallImgUrl.c_str());
		jstring jmiddleImgUrl = env->NewStringUTF(item.middleImgUrl.c_str());
		jstring jbigImageUrl = env->NewStringUTF(item.bigImgUrl.c_str());
		jstring jsrcFlashUrl = env->NewStringUTF(item.srcFlashUrl.c_str());
		jstring jsrcWebpUrl = env->NewStringUTF(item.srcwebpUrl.c_str());
		int jgiftType = GiftTypeToInt(item.type);
		jItem = env->NewObject(jItemCls, init,
					jid,
					jname,
					jsmallImgUrl,
					jmiddleImgUrl,
					jbigImageUrl,
					jsrcFlashUrl,
					jsrcWebpUrl,
					item.credit,
					item.multiClick,
					jgiftType,
					item.level,
					item.loveLevel,
					(int)item.updateTime
					);
        env->DeleteLocalRef(jid);
        env->DeleteLocalRef(jname);
        env->DeleteLocalRef(jsmallImgUrl);
        env->DeleteLocalRef(jmiddleImgUrl);
        env->DeleteLocalRef(jbigImageUrl);
        env->DeleteLocalRef(jsrcFlashUrl);
        env->DeleteLocalRef(jsrcWebpUrl);
	}
	return jItem;
}

jobject getNormalGiftItem(JNIEnv *env, const HttpGiftItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, NORMAL_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(L";
		signature += GIFT_DETAIL_ITEM_CLASS;
		signature += ";[I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jobject jgiftDetail = getGiftDetailItem(env, item.gift);
		jintArray jchooserArray = getJavaIntArray(env, item.sendNumList);
		jItem = env->NewObject(jItemCls, init,
					jgiftDetail,
					jchooserArray
					);
		if(NULL != jgiftDetail){
			env->DeleteLocalRef(jgiftDetail);
		}
		if(NULL != jchooserArray){
			env->DeleteLocalRef(jchooserArray);
		}
	}
	return jItem;
}

jobject getEmotionItem(JNIEnv *env, const HttpEmoticonInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, EMOTION_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;)V");
		jstring jemoSign = env->NewStringUTF(item.emoSign.c_str());
		jstring jemoUrl = env->NewStringUTF(item.emoUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					jemoSign,
					jemoUrl
					);
        env->DeleteLocalRef(jemoSign);
        env->DeleteLocalRef(jemoUrl);
	}
	return jItem;
}

jobjectArray getEmotionArray(JNIEnv *env, const EmoticonInfoItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, EMOTION_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(EmoticonInfoItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getEmotionItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobject getEmotionCategoryItem(JNIEnv *env, const HttpEmoticonItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, EMOTION_CATEGORY_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(ILjava/lang/String;[L";
		signature += EMOTION_ITEM_CLASS;
		signature += ";)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jstring jemotionErrorMsg = env->NewStringUTF(item.emoErrMsg.c_str());
		jobjectArray jemotionArray = getEmotionArray(env, item.emoList);
		jItem = env->NewObject(jItemCls, init,
					(int)item.emoType,
					jemotionErrorMsg,
					jemotionArray
					);
        env->DeleteLocalRef(jemotionErrorMsg);
        if(NULL != jemotionArray){
        	env->DeleteLocalRef(jemotionArray);
        }
	}
	return jItem;
}

jobject getBookInviteItem(JNIEnv *env, const HttpBookingPrivateInviteItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, BOOK_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIIILjava/lang/String;"
				"Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jstring jinviteId = env->NewStringUTF(item.inviteId.c_str());
		jstring jtoId = env->NewStringUTF(item.toId.c_str());
		jstring jfromId = env->NewStringUTF(item.fromId.c_str());
		jstring joppositePhotoUrl = env->NewStringUTF(item.oppositePhotoUrl.c_str());
		jstring joppositeNickname = env->NewStringUTF(item.oppositeNickName.c_str());
		jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
		jstring jgiftName = env->NewStringUTF(item.giftName.c_str());
		jstring jgiftBigImageUrl = env->NewStringUTF(item.giftBigImgUrl.c_str());
		jstring jgiftSmallImageUrl = env->NewStringUTF(item.giftSmallImgUrl.c_str());
		int jinviteStatus = BookInviteStatusToInt(item.replyType);
		jstring jroomId = env->NewStringUTF(item.roomId.c_str());
		jItem = env->NewObject(jItemCls, init,
					jinviteId,
					jtoId,
					jfromId,
					joppositePhotoUrl,
					joppositeNickname,
					item.read,
					item.intimacy,
					jinviteStatus,
					(int)item.bookTime,
					jgiftId,
					jgiftName,
					jgiftBigImageUrl,
					jgiftSmallImageUrl,
					item.giftNum,
					item.validTime,
					jroomId
					);
        env->DeleteLocalRef(jinviteId);
        env->DeleteLocalRef(jtoId);
        env->DeleteLocalRef(jfromId);
        env->DeleteLocalRef(joppositePhotoUrl);
        env->DeleteLocalRef(joppositeNickname);
        env->DeleteLocalRef(jgiftId);
        env->DeleteLocalRef(jgiftName);
        env->DeleteLocalRef(jgiftBigImageUrl);
        env->DeleteLocalRef(jgiftSmallImageUrl);
        env->DeleteLocalRef(jroomId);
	}
	return jItem;
}

jobject getPackageGiftItem(JNIEnv *env, const HttpBackGiftItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(L";
		signature += GIFT_DETAIL_ITEM_CLASS;
		signature += ";III[I)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		jobject jgiftItem = getGiftDetailItem(env, item.gift);
		jintArray jchooser = getJavaIntArray(env, item.sendNumList);
		jItem = env->NewObject(jItemCls, init,
					jgiftItem,
					item.num,
					item.grantedDate,
					item.expDate,
					jchooser
					);
        if(NULL != jgiftItem){
        	env->DeleteLocalRef(jgiftItem);
        }
        if(NULL != jchooser){
        	env->DeleteLocalRef(jchooser);
        }
	}
	return jItem;
}

jobject getSynConfigItem(JNIEnv *env, const HttpConfigItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_CONFIG_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;ILjava/lang/String;)V");
		jstring jimServerIp = env->NewStringUTF(item.imSvrIp.c_str());
		jstring jhttpServerIp = env->NewStringUTF(item.httpSvrIp.c_str());
		jstring juploadServerIp = env->NewStringUTF(item.uploadSvrIp.c_str());
		jstring jaddCreditsUrl = env->NewStringUTF(item.addCreditsUrl.c_str());
		jItem = env->NewObject(jItemCls, init,
					jimServerIp,
					item.imSvrPort,
					jhttpServerIp,
					item.httpSvrPort,
					juploadServerIp,
					item.uploadSvrPort,
					jaddCreditsUrl);
        env->DeleteLocalRef(jimServerIp);
        env->DeleteLocalRef(jhttpServerIp);
        env->DeleteLocalRef(juploadServerIp);
        env->DeleteLocalRef(jaddCreditsUrl);
	}
	return jItem;
}

jobjectArray getHotListArray(JNIEnv *env, const HotItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, HOTLIST_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(HotItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getHotListItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getFollowingListArray(JNIEnv *env, const FollowItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, FOLLOWINGLIST_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(FollowItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getFollowingListItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getValidRoomArray(JNIEnv *env, const HttpGetRoomInfoItem::RoomItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, VALID_LIVEROOM_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(HttpGetRoomInfoItem::RoomItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getValidRoomItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getImmediateInviteArray(JNIEnv *env, const InviteItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, IMMEDIATE_INVITE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(InviteItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getImmediateInviteItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getAudienceArray(JNIEnv *env, const HttpLiveFansList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, AUDIENCE_INFO_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(HttpLiveFansList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getAudienceInfoItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getNormalGiftArray(JNIEnv *env, const GiftItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, NORMAL_GIFT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(GiftItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getNormalGiftItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getEmotionCategoryArray(JNIEnv *env, const EmoticonItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, EMOTION_CATEGORY_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(EmoticonItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getEmotionCategoryItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getBookInviteArray(JNIEnv *env, const BookingPrivateInviteItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, BOOK_INVITE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(BookingPrivateInviteItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getBookInviteItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}

jobjectArray getPackgetGiftArray(JNIEnv *env, const BackGiftItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_GIFT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(BackGiftItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getPackageGiftItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	return jItemArray;
}
