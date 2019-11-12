/*
 * RequestJniConvert.cpp
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#include "RequestJniConvert.h"
#include <common/CommonFunc.h>

int HTTPErrorTypeToInt(ZBHTTP_LCC_ERR_TYPE errType)
{
    // 默认是HTTP_LCC_ERR_FAIL，当服务器返回未知的错误码时
	int value = 1;
	int i = 0;
	for (i = 0; i < _countof(HTTPErrorTypeArray); i++)
	{
		if (errType == HTTPErrorTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int GiftTypeToInt(ZBGiftType giftType){
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(ZBGiftTypeArray); i++)
    {
        if (giftType == ZBGiftTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

int EmoTiconTypeToInt(ZBEmoticonType emoType) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(ZBEMOTICONTYPEArray); i++)
    {
        if (emoType == ZBEMOTICONTYPEArray[i]) {
            value = i + 1;
            break;
        }
    }
    return value;
}

// Java层转底层枚举(性别)
ZBTalentReplyType IntToTalentReplyTypeOperateType(int value) {
    return (ZBTalentReplyType)(value < _countof(TalentReplyTypeArray) ? TalentReplyTypeArray[value] : TalentReplyTypeArray[0]);
}

ZBBookingListType IntToBookInviteListType(int value)
{
    return (ZBBookingListType)(value < _countof(ZBBookInviteListTypeArray) ? ZBBookInviteListTypeArray[value] : ZBBookInviteListTypeArray[0]);
}

int BookInviteStatusToInt(ZBBookingReplyType replyType){
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(ZBBookInviteStatusArray); i++)
    {
        if (replyType == ZBBookInviteStatusArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

int LiveRoomTypeToInt(ZBHttpRoomType liveRoomType){
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(ZBLiveRoomTypeArray); i++)
    {
        if (liveRoomType == ZBLiveRoomTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int AnchorMultiKnockTypeToInt(AnchorMultiKnockType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(AnchorMultiKnockTypeArray); i++)
    {
        if (type == AnchorMultiKnockTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

int AnchorFriendTypeToInt(AnchorFriendType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(AnchorFriendTypeArray); i++)
    {
        if (type == AnchorFriendTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
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
			i++;
		}
		env->SetIntArrayRegion(jarray, 0, length, pArray);
		delete [] pArray;
	}
	return jarray;
}

ZBSetPushType IntToSetPushTypeOperateType(int value) {


    return (ZBSetPushType)(value > 0 && (value < (_countof(ZBSetPushTypeArray) + 1)) ? ZBSetPushTypeArray[value - 1] : ZBSetPushTypeArray[0]);

}

// Java层转底层枚举(性别)
AnchorMultiplayerReplyType IntToAnchorMultiplayerReplyTypeOperateType(int value) {
    return (AnchorMultiplayerReplyType)(value > 0 && (value < (_countof(AnchorMultiplayerReplyTypeArray) + 1)) ? AnchorMultiplayerReplyTypeArray[value - 1] : AnchorMultiplayerReplyTypeArray[0]);
}

// Java层转底层枚举(性别)
AnchorProgramListType IntToAnchorProgramListTypeOperateType(int value) {
    return (AnchorProgramListType)(value < _countof(AnchorProgramListTypeArray) ? AnchorProgramListTypeArray[value] : AnchorProgramListTypeArray[0]);
}

// 底层状态转换JAVA坐标
int AnchorProgramStatusToInt(AnchorProgramStatus type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(AnchorProgramStatusArray); i++)
    {
        if (type == AnchorProgramStatusArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int AnchorPublicRoomTypeToInt(AnchorPublicRoomType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(AnchorPublicRoomTypeArray); i++)
    {
        if (type == AnchorPublicRoomTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int AnchorOnlineStatusToInt(AnchorOnlineStatus type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(AnchorOnlineStatusArray); i++)
    {
        if (type == AnchorOnlineStatusArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

//jintArray getInterestJavaIntArray(JNIEnv *env, const list<InterestType>& sourceList){
//	jintArray jarray = env->NewIntArray(sourceList.size());
//	if (NULL != jarray) {
//		int i = 0;
//		int length = sourceList.size();
//		int *pArray = new int[length+1];
//		for(list<InterestType>::const_iterator itr = sourceList.begin();
//			itr != sourceList.end();
//			itr++)
//		{
//			*(pArray+i) = (*itr);
//			i++;
//		}
//		env->SetIntArrayRegion(jarray, 0, length, pArray);
//		delete [] pArray;
//	}
//	return jarray;
//}

jobject getLoginItem(JNIEnv *env, const ZBHttpLoginItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, LOGIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				signature.c_str());
        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jtoken = env->NewStringUTF(item.token.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   jtoken,
                                   jnickName,
                                   jphotoUrl
            );
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jtoken);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
        }

	}
	return jItem;
}

jobjectArray getAudienceArray(JNIEnv *env, const ZBHttpLiveFansList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, AUDIENCE_INFO_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBHttpLiveFansList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAudienceInfoItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getAudienceInfoItem(JNIEnv *env, const ZBHttpLiveFansItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, AUDIENCE_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Z)V");
        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jmountId = env->NewStringUTF(item.mountId.c_str());
            jstring jmountName = env->NewStringUTF(item.mountName.c_str());
            jstring jmountUrl = env->NewStringUTF(item.mountUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   jmountId,
                                   jmountUrl,
                                   item.level,
                                   jmountName,
                                   item.isHasTicket
            );
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jmountId);
            env->DeleteLocalRef(jmountUrl);
            env->DeleteLocalRef(jmountName);
        }

    }
    return jItem;
}

jobject getAudienceBaseInfoItem(JNIEnv *env, const ZBHttpLiveFansInfoItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, AUDIENCE_BASE_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");

        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jriderId = env->NewStringUTF(item.riderId.c_str());
            jstring jriderName = env->NewStringUTF(item.riderName.c_str());
            jstring jriderUrl = env->NewStringUTF(item.riderUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   jriderId,
                                   jriderName,
                                   jriderUrl,
                                   item.level);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jriderId);
            env->DeleteLocalRef(jriderName);
            env->DeleteLocalRef(jriderUrl);
        }

    }
    return jItem;
}

jobjectArray getGiftArray(JNIEnv *env, const ZBGiftItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, GIFT_DETAIL_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBGiftItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getGiftDetailItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getGiftDetailItem(JNIEnv *env, const ZBHttpGiftInfoItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, GIFT_DETAIL_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
                "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;DZIII[III)V");
        if (NULL != init) {
            jstring jid = env->NewStringUTF(item.giftId.c_str());
            jstring jname = env->NewStringUTF(item.name.c_str());
            jstring jsmallImgUrl = env->NewStringUTF(item.smallImgUrl.c_str());
            jstring jmiddleImgUrl = env->NewStringUTF(item.middleImgUrl.c_str());
            jstring jbigImageUrl = env->NewStringUTF(item.bigImgUrl.c_str());
            jstring jsrcFlashUrl = env->NewStringUTF(item.srcFlashUrl.c_str());
            jstring jsrcWebpUrl = env->NewStringUTF(item.srcwebpUrl.c_str());
            int jgiftType = GiftTypeToInt(item.type);
            jintArray jgiftChooser = getJavaIntArray(env, item.sendNumList);
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
                                   jgiftChooser,
                                   (int)item.updateTime,
                                   item.playTime
            );
            env->DeleteLocalRef(jid);
            env->DeleteLocalRef(jname);
            env->DeleteLocalRef(jsmallImgUrl);
            env->DeleteLocalRef(jmiddleImgUrl);
            env->DeleteLocalRef(jbigImageUrl);
            env->DeleteLocalRef(jsrcFlashUrl);
            env->DeleteLocalRef(jsrcWebpUrl);
            if(NULL != jgiftChooser){
                env->DeleteLocalRef(jgiftChooser);
            }
        }

    }
    return jItem;
}

jobjectArray getGiftLimitNumArray(JNIEnv *env, const ZBHttpGiftLimitNumItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, GIFT_LIMIT_NUM_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBHttpGiftLimitNumItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getGiftLimitNumItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getGiftLimitNumItem(JNIEnv *env, const ZBHttpGiftLimitNumItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, GIFT_LIMIT_NUM_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;I)V");
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

jobject getEmotionItem(JNIEnv *env, const ZBHttpEmoticonInfoItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, EMOTION_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V");
        if (NULL != init) {
            jstring jemoId = env->NewStringUTF(item.emoId.c_str());
            jstring jemoSign = env->NewStringUTF(item.emoSign.c_str());
            jstring jemoUrl = env->NewStringUTF(item.emoUrl.c_str());
            jstring jemoIconUrl = env->NewStringUTF(item.emoIconUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jemoId,
                                   jemoSign,
                                   jemoUrl,
                                   (int)item.emoType,
                                   jemoIconUrl
            );
            env->DeleteLocalRef(jemoId);
            env->DeleteLocalRef(jemoSign);
            env->DeleteLocalRef(jemoUrl);
            env->DeleteLocalRef(jemoIconUrl);
        }

    }
    return jItem;
}

jobjectArray getEmotionArray(JNIEnv *env, const ZBEmoticonInfoItemList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, EMOTION_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBEmoticonInfoItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getEmotionItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getEmotionCategoryItem(JNIEnv *env, const ZBHttpEmoticonItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, EMOTION_CATEGORY_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[L";
        signature += EMOTION_ITEM_CLASS;
        signature += ";)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jemotionTagName = env->NewStringUTF(item.name.c_str());
            jstring jemotionErrorMsg = env->NewStringUTF(item.errMsg.c_str());
            jstring jemotionTagUrl = env->NewStringUTF(item.emoUrl.c_str());
            jobjectArray jemotionArray = getEmotionArray(env, item.emoList);
            jint type = EmoTiconTypeToInt(item.type);
            jItem = env->NewObject(jItemCls, init,
                                   type,
                                   jemotionTagName,
                                   jemotionErrorMsg,
                                   jemotionTagUrl,
                                   jemotionArray
            );
            env->DeleteLocalRef(jemotionTagName);
            env->DeleteLocalRef(jemotionErrorMsg);
            env->DeleteLocalRef(jemotionTagUrl);
            if(NULL != jemotionArray){
                env->DeleteLocalRef(jemotionArray);
            }
        }

    }
    return jItem;
}

jobjectArray getEmotionCategoryArray(JNIEnv *env, const ZBEmoticonItemList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, EMOTION_CATEGORY_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBEmoticonItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getEmotionCategoryItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getBookInviteItem(JNIEnv *env, const ZBHttpBookingPrivateInviteItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, BOOK_INVITE_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIIILjava/lang/String;"
                "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jinviteId = env->NewStringUTF(item.invitationId.c_str());
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

    }
    return jItem;
}


jobjectArray getBookInviteArray(JNIEnv *env, const ZBBookingPrivateInviteItemList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, BOOK_INVITE_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(ZBBookingPrivateInviteItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getBookInviteItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}


jobject getSynConfigItem(JNIEnv *env, const ZBHttpConfigItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, OTHER_CONFIG_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;";
        signature += "[L";
        signature += SERVER_ITEM_CLASS;
        signature += ";Ljava/lang/String;";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jimServerUrl = env->NewStringUTF(item.imSvrUrl.c_str());
            jstring jhttpServerUrl = env->NewStringUTF(item.httpSvrUrl.c_str());
            jstring jmePageUrl = env->NewStringUTF(item.mePageUrl.c_str());
            jstring jmanPageUrl = env->NewStringUTF(item.manPageUrl.c_str());
            jstring jminAvailableMsg = env->NewStringUTF(item.minAvailableMsg.c_str());
            jstring jnewestMsg = env->NewStringUTF(item.newestMsg.c_str());
            jstring jdownloadAppUrl = env->NewStringUTF(item.downloadAppUrl.c_str());
            jobjectArray jsvrArray = getServerArray(env, item.svrList);
            jstring jshowDetailPage = env->NewStringUTF(item.showDetailPage.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jimServerUrl,
                                   jhttpServerUrl,
                                   jmePageUrl,
                                   jmanPageUrl,
                                   item.minAavilableVer,
                                   jminAvailableMsg,
                                   item.newestVer,
                                   jnewestMsg,
                                   jdownloadAppUrl,
                                   jsvrArray,
                                   jshowDetailPage
            );
            env->DeleteLocalRef(jimServerUrl);
            env->DeleteLocalRef(jhttpServerUrl);
            env->DeleteLocalRef(jmePageUrl);
            env->DeleteLocalRef(jmanPageUrl);
            env->DeleteLocalRef(jminAvailableMsg);
            env->DeleteLocalRef(jnewestMsg);
            env->DeleteLocalRef(jdownloadAppUrl);
            env->DeleteLocalRef(jshowDetailPage);
            if(NULL != jsvrArray){
                env->DeleteLocalRef(jsvrArray);
            }
        }

    }
    return jItem;
}

jobjectArray getServerArray(JNIEnv *env, const ZBSvrList& list) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, SERVER_ITEM_CLASS);
    if(NULL != jItemCls &&  list.size() > 0 ){
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for(ZBSvrList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getServerItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getServerItem(JNIEnv *env, const ZBHttpSvrItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, SERVER_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jsvrId = env->NewStringUTF(item.svrId.c_str());
            jstring jtUrl = env->NewStringUTF(item.tUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jsvrId,
                                   jtUrl
            );
            env->DeleteLocalRef(jsvrId);
            env->DeleteLocalRef(jtUrl);
        }

    }
    return jItem;

}


jobjectArray getAnchorArray(JNIEnv *env, const HttpAnchorItemList& listItem){
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_INFO_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(HttpAnchorItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAnchorInfoItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getAnchorInfoItem(JNIEnv *env, const HttpAnchorItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;II)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jcountry = env->NewStringUTF(item.country.c_str());
            jint jtype =  AnchorOnlineStatusToInt(item.onlineStatus);

            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   item.age,
                                   jcountry,
                                   0,
                                   jtype
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jcountry);
        }

    }
    return jItem;
}

jobjectArray getAnchorBaseInfoArray(JNIEnv *env, const HttpAnchorBaseInfoItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_BASE_INFO_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(HttpAnchorBaseInfoItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAnchorBaseInfoItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getAnchorBaseInfoItem(JNIEnv *env, const HttpAnchorBaseInfoItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_BASE_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
        }


    }
    return jItem;
}

jobjectArray getAnchorHangoutArray(JNIEnv *env, const HttpAnchorHangoutItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_HANGOUT_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(HttpAnchorHangoutItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAnchorHangoutItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getAnchorHangoutItem(JNIEnv *env, const HttpAnchorHangoutItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_HANGOUT_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "[L";
        signature += ANCHOR_BASE_INFO_ITEM_CLASS;
        signature += ";";
        signature += "Ljava/lang/String;";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          signature.c_str());
        if (NULL != init) {
            jobjectArray jItemArray = getAnchorBaseInfoArray(env, item.anchorList);
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jroomId = env->NewStringUTF(item.roomId.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   jnickName,
                                   jphotoUrl,
                                   jItemArray,
                                   jroomId);
            if(jItemArray != NULL){
                env->DeleteLocalRef(jItemArray);
            }
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jroomId);

        }

    }
    return jItem;
}

jobject getAnchorHangoutGiftListItem(JNIEnv *env, const HttpAnchorHangoutGiftListItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_HANGOUT_GIFTLIST_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "([L";
        signature += GIFT_LIMIT_NUM_ITEM_CLASS;
        signature += ";";
        signature += "[L";
        signature += GIFT_LIMIT_NUM_ITEM_CLASS;
        signature += ";";
        signature += "[L";
        signature += GIFT_LIMIT_NUM_ITEM_CLASS;
        signature += ";";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          signature.c_str());
        if (NULL != init) {
            jobjectArray jbuyforListArray = getAnchorGiftNumArray(env, item.buyforList);
            jobjectArray jnormalListArray = getAnchorGiftNumArray(env, item.normalList);
            jobjectArray jcelebrationListArray = getAnchorGiftNumArray(env, item.celebrationList);
            jItem = env->NewObject(jItemCls, init,
                                   jbuyforListArray,
                                   jnormalListArray,
                                   jcelebrationListArray);
            if(jbuyforListArray != NULL){
                env->DeleteLocalRef(jbuyforListArray);
            }
            if(jnormalListArray != NULL){
                env->DeleteLocalRef(jnormalListArray);
            }
            if(jcelebrationListArray != NULL){
                env->DeleteLocalRef(jcelebrationListArray);
            }
        }

    }
    return jItem;
}

jobjectArray getAnchorGiftNumArray(JNIEnv *env, const HttpAnchorGiftNumItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, GIFT_LIMIT_NUM_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(HttpAnchorGiftNumItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAnchorGiftNumItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getAnchorGiftNumItem(JNIEnv *env, const HttpAnchorGiftNumItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, GIFT_LIMIT_NUM_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;I)V");
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

jobject getAnchorFriendItem(JNIEnv *env, const HttpAnchorFriendItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, ANCHOR_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        jmethodID init = env->GetMethodID(jItemCls, "<init>",
                                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;II)V");
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.avatar.c_str());
            jstring jcountry = env->NewStringUTF(item.country.c_str());
            jint jfriendType = AnchorFriendTypeToInt(item.isFriend);

            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   item.age,
                                   jcountry,
                                   jfriendType,
                                   0
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jcountry);
        }

    }
    return jItem;
}

jobject getProgramInfoItem(JNIEnv *env, const HttpAnchorProgramInfoItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, PROGRAM_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "Ljava/lang/String;Ljava/lang/String;I";
        signature += "III";
        signature += "IDI";
        signature += "IIZ)V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
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
                               AnchorProgramStatusToInt(item.status),
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
    return jItem;
}

jobjectArray getProgramInfoArray(JNIEnv *env, const AnchorProgramInfoList& list) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, PROGRAM_INFO_ITEM_CLASS);
    if(NULL != jItemCls &&  list.size() > 0 ){
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for(AnchorProgramInfoList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getProgramInfoItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    return jItemArray;
}

jobject getCurrentRoomUserItem(JNIEnv *env, const ZBHttpUserInfoItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, PUSH_ROOM_AUD_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;";   // userId
        signature += "Ljava/lang/String;";          // nickName
        signature += "Ljava/lang/String;";           // photoUrl
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        jstring juserId = env->NewStringUTF(item.userId.c_str());
        jstring jnickName = env->NewStringUTF(item.nickName.c_str());
        jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
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

jobject getCurrentRoomItem(JNIEnv *env, const ZBHttpCurrentRoomItem& item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, PUSH_ROOM_INFO_ITEM_CLASS);
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;";   // anchorId
        signature += "Ljava/lang/String;";          // roomId
        signature += "I";                           // roomType
        signature += "L";
        signature += PUSH_ROOM_AUD_INFO_ITEM_CLASS; // userInfo
        signature += ";";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
        jstring jroomId = env->NewStringUTF(item.roomId.c_str());
        jint jroomType = LiveRoomTypeToInt(item.roomType);
        jobject juserInfo = getCurrentRoomUserItem(env, item.userInfo);
        jItem = env->NewObject(jItemCls, init,
                               janchorId,
                               jroomId,
                               jroomType,
                               juserInfo
        );
        env->DeleteLocalRef(janchorId);
        env->DeleteLocalRef(jroomId);
        if(juserInfo != NULL){
           env->DeleteLocalRef(juserInfo);
        }
    }
    return jItem;
}