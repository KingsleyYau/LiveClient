/*
 * RequestJniConvert.cpp
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#include "RequestJniConvert.h"
#include <common/CommonFunc.h>

int HTTPErrorTypeToInt(HTTP_LCC_ERR_TYPE errType)
{
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

int AnchorLevelTypeToInt(AnchorLevelType anchorLevelType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(AnchorLevelTypeArray); i++)
	{
		if (anchorLevelType == AnchorLevelTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int UserTypeToInt(UserType userType) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(UserTypeArray); i++)
	{
		if (userType == UserTypeArray[i]) {
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

int ImmediateInviteReplyTypeToInt(HttpReplyType replyType){
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


PromoAnchorType IntToPromoAnchorType(int value)
{
	return (PromoAnchorType)(value < _countof(PromoAnchorTypeArray) ? PromoAnchorTypeArray[value] : PromoAnchorTypeArray[0]);
}

int TalentInviteStatusToInt(HTTPTalentStatus talentStatus){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(TalentInviteStatusArray); i++)
	{
		if (talentStatus == TalentInviteStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int  BookInviteTimeStatusToInt(BookTimeStatus bookTimeStatus){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(BookInviteTimeStatusArray); i++)
	{
		if (bookTimeStatus == BookInviteTimeStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int  VoucherUseRoomTypeToInt(UseRoomType useRoomType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(VoucherUseRoomTypeArray); i++)
	{
		if (useRoomType == VoucherUseRoomTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int  VoucherAnchorTypeToInt(AnchorType voucherAnchorType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(VoucherAnchorTypeArray); i++)
	{
		if (voucherAnchorType == VoucherAnchorTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int LSHttpLiveChatInviteRiskTypeToInt(LSHttpLiveChatInviteRiskType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LSHttpLiveChatInviteRiskTypeArray); i++)
	{
		if (type == LSHttpLiveChatInviteRiskTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

ControlType IntToInteractiveOperateType(int value)
{
	return (ControlType)(value < _countof(InteractiveOperateTypeArray) ? InteractiveOperateTypeArray[value] : InteractiveOperateTypeArray[0]);
}


int HangoutInviteStatusToInt(HangoutInviteStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(HangoutInviteStatusArray); i++)
	{
		if (type == HangoutInviteStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

//Java层转底层枚举
HangoutAnchorListType IntToHangoutAnchorListType(int value) {
	return (HangoutAnchorListType)(value < _countof(HangoutAnchorListTypeArray) ? HangoutAnchorListTypeArray[value] : HangoutAnchorListTypeArray[0]);
}


//Java层转底层枚举
ProgramListType IntToProgramListType(int value) {
	return (ProgramListType)(value < _countof(ProgramListTypeArray) ? ProgramListTypeArray[value] : ProgramListTypeArray[0]);
}


int ProgramStatusToInt(ProgramStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(ProgramStatusArray); i++)
	{
		if (type == ProgramStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

//Java层转底层枚举
ShowRecommendListType IntToShowRecommendListType(int value) {
    return (ShowRecommendListType)(value < _countof(ShowRecommendListTypeArray) ? ShowRecommendListTypeArray[value] : ShowRecommendListTypeArray[0]);
}

int ProgramTicketStatusToInt(ProgramTicketStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(ProgramTicketStatusArray); i++)
	{
		if (type == ProgramTicketStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

// 底层状态转换JAVA坐标
int ComIMChatOnlineStatusToInt(IMChatOnlineStatus type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(ComIMChatOnlineStatusArray); i++)
	{
		if (type == ComIMChatOnlineStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int LSSendImgRiskTypeToInt(LSSendImgRiskType type) {
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LSSendImgRiskTypeArray); i++)
	{
		if (type == LSSendImgRiskTypeArray[i]) {
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

jintArray getInterestJavaIntArray(JNIEnv *env, const list<InterestType>& sourceList){
	jintArray jarray = env->NewIntArray(sourceList.size());
	if (NULL != jarray) {
		int i = 0;
		int length = sourceList.size();
		int *pArray = new int[length+1];
		for(list<InterestType>::const_iterator itr = sourceList.begin();
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

RegionIdType IntToRegionIdType(int value) {
	return (RegionIdType)(value < _countof(RegionIdTypeArray) ? RegionIdTypeArray[value] : RegionIdTypeArray[0]);
}

LSLoginSidType IntToLSLoginSidType(int value) {
	return (LSLoginSidType)(value < _countof(LSLoginSidTypeArray) ? LSLoginSidTypeArray[value] : LSLoginSidTypeArray[0]);
}

LSValidateCodeType IntToLSValidateCodeType(int value) {
    return (LSValidateCodeType)(value < _countof(LSValidateCodeTypeArray) ? LSValidateCodeTypeArray[value] : LSValidateCodeTypeArray[0]);
}

LSOrderType IntToLSOrderType(int value) {
	return (LSOrderType)(value < _countof(LSOrderTypeArray) ? LSOrderTypeArray[value] : LSOrderTypeArray[0]);
}

jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, LOGIN_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Z";
		signature += "[L";
		signature += SERVER_ITEM_CLASS;
		signature += ";";
		//signature += "ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "ILjava/lang/String;";
		signature += "Ljava/lang/String;ZI";
		signature += "Z";
		signature += "L";
		signature += USERPRIV_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				signature.c_str());
		if (NULL != init) {
			jstring juserId = env->NewStringUTF(item.userId.c_str());
			jstring jtoken = env->NewStringUTF(item.token.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
			jobjectArray jsvrArray = getServerArray(env, item.svrList);
			jint type = UserTypeToInt(item.userType);
			//jstring jqnMainAdUrl = env->NewStringUTF(item.qnMainAdUrl.c_str());
			//jstring jqnMainAdTitle = env->NewStringUTF(item.qnMainAdUrl.c_str());
			//jstring jqnMainAdId = env->NewStringUTF(item.qnMainAdTitle.c_str());

			//jstring jqnMainAdUrl = env->NewStringUTF("");
			//jstring jqnMainAdTitle = env->NewStringUTF("");
			//jstring jqnMainAdId = env->NewStringUTF("");

			jstring jgaUid = env->NewStringUTF(item.gaUid.c_str());
			jstring jsessionId = env->NewStringUTF(item.sessionId.c_str());
			jint jriskType = LSHttpLiveChatInviteRiskTypeToInt(item.liveChatInviteRiskType);
			jobject juserObj = getUserPrivItem(env, item.userPriv);
			/*
			jItem = env->NewObject(jItemCls, init,
								   juserId,
								   jtoken,
								   jnickName,
								   item.level,
								   item.experience,
								   jphotoUrl,
								   item.isPushAd,
								   jsvrArray,
								   type,
								   jqnMainAdUrl,
								   jqnMainAdTitle,
								   jqnMainAdId,
								   jgaUid,
								   jsessionId,
								   item.isLiveChatRisk,
								   jriskType,
								   !item.userPriv.hangoutPriv.isHangoutPriv,
								   juserObj
			);*/

			jItem = env->NewObject(jItemCls, init,
								   juserId,
								   jtoken,
								   jnickName,
								   item.level,
								   item.experience,
								   jphotoUrl,
								   item.isPushAd,
								   jsvrArray,
								   type,
								   jgaUid,
								   jsessionId,
								   item.isLiveChatRisk,
								   jriskType,
								   item.isHangoutRisk,
								   juserObj
			);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jtoken);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			//env->DeleteLocalRef(jqnMainAdUrl);
			//env->DeleteLocalRef(jqnMainAdTitle);
			//env->DeleteLocalRef(jqnMainAdId);
			env->DeleteLocalRef(jgaUid);
			env->DeleteLocalRef(jsessionId);
			if(NULL != jsvrArray){
				env->DeleteLocalRef(jsvrArray);
			}
			if(NULL != juserObj){
				env->DeleteLocalRef(juserObj);
			}
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getAdListItem(JNIEnv *env, const HttpLiveRoomInfoItem& item){
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, HOTLIST_ITEM_CLASS);
    jobject jprivItem = NULL;
    if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;I[II";
        signature += "L";
        signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += HTTP_AUTHORITY_ITEM_CLASS;
        signature += ";";
        signature += "I";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring juserId = env->NewStringUTF(item.userId.c_str());
			jstring jnickName = env->NewStringUTF(item.nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
			jstring jroomPhotoUrl = env->NewStringUTF(item.roomPhotoUrl.c_str());
			int jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
			int jroomType = LiveRoomTypeToInt(item.roomType);
			int janchorType = AnchorLevelTypeToInt(item.anchorType);
			jintArray jinterestArray = getInterestJavaIntArray(env, item.interest);
			jobject jProgramItem = NULL;
			if (item.showInfo != NULL) {
				jProgramItem = getProgramInfoItem(env, *(item.showInfo));
			}
			jprivItem = getHttpAuthorityItem(env, item.priv);
			jint jstatus = ComIMChatOnlineStatusToInt(item.chatOnlineStatus);
			jItem = env->NewObject(jItemCls, init,
								   juserId,
								   jnickName,
								   jphotoUrl,
								   jonlineStatus,
								   jroomPhotoUrl,
								   jroomType,
								   jinterestArray,
								   janchorType,
								   jProgramItem,
								   jprivItem,
								   jstatus
			);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jroomPhotoUrl);
			if(NULL != jinterestArray){
				env->DeleteLocalRef(jinterestArray);
			}
			if(NULL != jProgramItem){
				env->DeleteLocalRef(jProgramItem);
			}
		}

    }
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	if (NULL != jprivItem) {
       env->DeleteLocalRef(jprivItem);
    }
    return jItem;
}

jobject getHotListItem(JNIEnv *env, const HttpLiveRoomInfoItem* item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HOTLIST_ITEM_CLASS);
	jobject jprivItem = NULL;
	if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;I[II";
        signature += "L";
        signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += HTTP_AUTHORITY_ITEM_CLASS;
        signature += ";";
        signature += "I";
        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring juserId = env->NewStringUTF(item->userId.c_str());
			jstring jnickName = env->NewStringUTF(item->nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item->photoUrl.c_str());
			jstring jroomPhotoUrl = env->NewStringUTF(item->roomPhotoUrl.c_str());
			int jonlineStatus = AnchorOnlineStatusToInt(item->onlineStatus);
			int jroomType = LiveRoomTypeToInt(item->roomType);
			int janchorType = AnchorLevelTypeToInt(item->anchorType);
			jintArray jinterestArray = getInterestJavaIntArray(env, item->interest);
			jobject jProgramItem = NULL;
			if (item->showInfo != NULL) {
				jProgramItem = getProgramInfoItem(env, *(item->showInfo));
			}
			jprivItem = getHttpAuthorityItem(env, item->priv);
			jint jstatus = ComIMChatOnlineStatusToInt(item->chatOnlineStatus);
			jItem = env->NewObject(jItemCls, init,
								   juserId,
								   jnickName,
								   jphotoUrl,
								   jonlineStatus,
								   jroomPhotoUrl,
								   jroomType,
								   jinterestArray,
								   janchorType,
								   jProgramItem,
								   jprivItem,
								   jstatus
			);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jroomPhotoUrl);
			if(NULL != jinterestArray){
				env->DeleteLocalRef(jinterestArray);
			}
			if(NULL != jProgramItem){
				env->DeleteLocalRef(jProgramItem);
			}
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	if (NULL != jprivItem) {
    	env->DeleteLocalRef(jprivItem);
    }
	return jItem;
}

jobject getFollowingListItem(JNIEnv *env, const HttpFollowItem* item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, FOLLOWINGLIST_ITEM_CLASS);
	jobject privItem = NULL;
	if (NULL != jItemCls){
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;III[II";
        signature += "L";
        signature += PROGRAM_PROGRAMINFO_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += HTTP_AUTHORITY_ITEM_CLASS;
        signature += ";";
        signature += "I";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring juserId = env->NewStringUTF(item->userId.c_str());
			jstring jnickName = env->NewStringUTF(item->nickName.c_str());
			jstring jphotoUrl = env->NewStringUTF(item->photoUrl.c_str());
			jstring jroomPhotoUrl = env->NewStringUTF(item->roomPhotoUrl.c_str());
			int jonlineStatus = AnchorOnlineStatusToInt(item->onlineStatus);
			int jroomType = LiveRoomTypeToInt(item->roomType);
			jintArray jinterestArray = getInterestJavaIntArray(env, item->interest);
			int janchorType = AnchorLevelTypeToInt(item->anchorType);
			jobject jProgramItem = NULL;
			if (item->showInfo != NULL) {
				jProgramItem = getProgramInfoItem(env, *(item->showInfo));
			}
			privItem = getHttpAuthorityItem(env, item->priv);
			jint jstatus = ComIMChatOnlineStatusToInt(item->chatOnlineStatus);
			jItem = env->NewObject(jItemCls, init,
								   juserId,
								   jnickName,
								   jphotoUrl,
								   jonlineStatus,
								   jroomPhotoUrl,
								   item->loveLevel,
								   jroomType,
								   (int)item->addDate,
								   jinterestArray,
								   janchorType,
								   jProgramItem,
								   privItem,
								   jstatus
			);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jroomPhotoUrl);
			if(NULL != jinterestArray){
				env->DeleteLocalRef(jinterestArray);
			}
			if(NULL != jProgramItem){
				env->DeleteLocalRef(jProgramItem);
			}
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}

	if (NULL != privItem) {
    	env->DeleteLocalRef(privItem);
    }
	return jItem;
}

jobject getValidRoomItem(JNIEnv *env, const HttpGetRoomInfoItem::RoomItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, VALID_LIVEROOM_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;)V");
		if (NULL != init) {
			jstring jroomid = env->NewStringUTF(item.roomId.c_str());
			jstring jroomurl = env->NewStringUTF(item.roomUrl.c_str());
			jItem = env->NewObject(jItemCls, init,
								   jroomid,
								   jroomurl
			);
			env->DeleteLocalRef(jroomid);
			env->DeleteLocalRef(jroomurl);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getImmediateInviteItem(JNIEnv *env, const HttpInviteInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, IMMEDIATE_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
				"Ljava/lang/String;IILjava/lang/String;ZIIILjava/lang/String;)V");
		if (NULL != init) {
			jstring jinviteId = env->NewStringUTF(item.invitationId.c_str());
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

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getAudienceInfoItem(JNIEnv *env, const HttpLiveFansItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, AUDIENCE_INFO_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZ)V");
		if (NULL != init) {
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
								   jmountUrl,
								   item.level,
								   item.isHasTicket
			);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jmountId);
			env->DeleteLocalRef(jmountUrl);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getAudienceBaseInfoItem(JNIEnv *env, const HttpLiveFansInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, AUDIENCE_BASE_INFO_ITEM_CLASS);
	if (NULL != jItemCls){
		jmethodID init = env->GetMethodID(jItemCls, "<init>",
				"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
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
								   jriderUrl);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
			env->DeleteLocalRef(jphotoUrl);
			env->DeleteLocalRef(jriderId);
			env->DeleteLocalRef(jriderName);
			env->DeleteLocalRef(jriderUrl);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getGiftDetailItem(JNIEnv *env, const HttpGiftInfoItem& item){
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getSendableGiftItem(JNIEnv *env, const HttpGiftWithIdItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, SENDABLE_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;ZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jstring jsgiftId = env->NewStringUTF(item.giftId.c_str());
			jItem = env->NewObject(jItemCls, init,
								   jsgiftId,
								   item.isShow,
								   item.isPromo
			);
			env->DeleteLocalRef(jsgiftId);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getEmotionItem(JNIEnv *env, const HttpEmoticonInfoItem& item){
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getTalentItem(JNIEnv *env, const HttpGetTalentItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, TALENT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;D";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "I";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jtalentId = env->NewStringUTF(item.talentId.c_str());
            jstring jname = env->NewStringUTF(item.name.c_str());
			jstring jdecription = env->NewStringUTF(item.decription.c_str());
			jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
			jstring jgiftName = env->NewStringUTF(item.giftName.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jtalentId,
                                   jname,
                                   item.credit,
								   jdecription,
								   jgiftId,
								   jgiftName,
								   item.giftNum
            );
            env->DeleteLocalRef(jtalentId);
            env->DeleteLocalRef(jname);
			env->DeleteLocalRef(jdecription);
			env->DeleteLocalRef(jgiftId);
			env->DeleteLocalRef(jgiftName);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getTalentInviteItem(JNIEnv *env, const HttpGetTalentStatusItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, TALENT_INVITE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "DILjava/lang/String;";
		signature += "Ljava/lang/String;I";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jtalentInviteId = env->NewStringUTF(item.talentInviteId.c_str());
            jstring jtalentId = env->NewStringUTF(item.talentId.c_str());
            jstring jname = env->NewStringUTF(item.name.c_str());
            int jstatus = TalentInviteStatusToInt(item.status);
			jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
			jstring jgiftName = env->NewStringUTF(item.giftName.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jtalentInviteId,
                                   jtalentId,
                                   jname,
                                   item.credit,
                                   jstatus,
								   jgiftId,
								   jgiftName,
								   item.giftNum
            );
            env->DeleteLocalRef(jtalentInviteId);
            env->DeleteLocalRef(jtalentId);
            env->DeleteLocalRef(jname);
			env->DeleteLocalRef(jgiftId);
			env->DeleteLocalRef(jgiftName);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobject getEmotionCategoryItem(JNIEnv *env, const HttpEmoticonItem& item){
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
            jItem = env->NewObject(jItemCls, init,
                                   (int)item.type,
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getBookTimeItem(JNIEnv *env, const HttpGetCreateBookingInfoItem::BookTimeItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, BOOK_TIME_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;II)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jtimeId = env->NewStringUTF(item.timeId.c_str());
            int jbookTimeStatus = BookInviteTimeStatusToInt(item.status);
            jItem = env->NewObject(jItemCls, init,
                                   jtimeId,
                                   (int)item.time,
                                   jbookTimeStatus
            );
            env->DeleteLocalRef(jtimeId);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getBookGiftItem(JNIEnv *env, const HttpGetCreateBookingInfoItem::GiftItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, BOOK_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;[II)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jgiftId = env->NewStringUTF(item.giftId.c_str());

            int jDefaultNum = -1;
            int length = item.sendNumList.size();
            jintArray jchooserArray = env->NewIntArray(length);
            int i = 0;
            int *pArray = new int[length+1];
            for(HttpGetCreateBookingInfoItem::GiftNumList::const_iterator itr = item.sendNumList.begin(); itr != item.sendNumList.end(); itr++, i++) {
                *(pArray+i) = itr->num;
                if(itr->isDefault){
                    jDefaultNum = itr->num;
                }
            }
            env->SetIntArrayRegion(jchooserArray, 0, length, pArray);
            delete [] pArray;

            jItem = env->NewObject(jItemCls, init,
                                   jgiftId,
                                   jchooserArray,
                                   jDefaultNum
            );
            env->DeleteLocalRef(jgiftId);

            if(NULL != jchooserArray){
                env->DeleteLocalRef(jchooserArray);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getBookPhoneItem(JNIEnv *env, const HttpGetCreateBookingInfoItem::BookPhoneItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, BOOK_PHONE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jcountry = env->NewStringUTF(item.country.c_str());
            jstring jareaCode = env->NewStringUTF(item.areaCode.c_str());
            jstring jphoneNo= env->NewStringUTF(item.phoneNo.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jcountry,
                                   jareaCode,
                                   jphoneNo
            );
            env->DeleteLocalRef(jcountry);
            env->DeleteLocalRef(jareaCode);
            env->DeleteLocalRef(jphoneNo);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getPackageGiftItem(JNIEnv *env, const HttpBackGiftItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_GIFT_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;IIIIZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jgiftId,
                                   item.num,
                                   (int)item.grantedDate,
                                   (int)item.startValidDate,
                                   (int)item.expDate,
                                   item.read
            );
            env->DeleteLocalRef(jgiftId);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getPackageVoucherItem(JNIEnv *env, const HttpVoucherItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_VOUCHER_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II"
				"Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IIIZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jvoucherId = env->NewStringUTF(item.voucherId.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jphotoUrlMobile = env->NewStringUTF(item.photoUrlMobile.c_str());
            jstring jdesc = env->NewStringUTF(item.desc.c_str());
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring janchorNcikName = env->NewStringUTF(item.anchorNcikName.c_str());
            jstring janchorPhotoUrl = env->NewStringUTF(item.anchorPhotoUrl.c_str());
            int juseRoomType = VoucherUseRoomTypeToInt(item.useRoomType);
            int janchorType = VoucherAnchorTypeToInt(item.anchorType);
            jItem = env->NewObject(jItemCls, init,
                                   janchorPhotoUrl,
                                   jphotoUrl,
                                   jphotoUrlMobile,
                                   jdesc,
                                   juseRoomType,
                                   janchorType,
                                   janchorId,
                                   janchorNcikName,
                                   janchorPhotoUrl,
                                   (int)item.grantedDate,
                                   (int)item.startValidDate,
                                   (int)item.expDate,
                                   item.read
            );
            env->DeleteLocalRef(jvoucherId);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jphotoUrlMobile);
            env->DeleteLocalRef(jdesc);
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(janchorNcikName);
            env->DeleteLocalRef(janchorPhotoUrl);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getPackageRideItem(JNIEnv *env, const HttpRideItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_RIDE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IIIZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jrideId = env->NewStringUTF(item.rideId.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jname = env->NewStringUTF(item.name.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jrideId,
                                   jphotoUrl,
                                   jname,
                                   (int)item.grantedDate,
                                   (int)item.startValidDate,
                                   (int)item.expDate,
                                   item.read,
                                   item.isUse
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

jobject getSynConfigItem(JNIEnv *env, const HttpConfigItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_CONFIG_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "Ljava/lang/String;Ljava/lang/String;I";
        signature += "DLjava/lang/String;Ljava/lang/String;";
        signature += "D";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
            jstring jimServerUrl = env->NewStringUTF(item.imSvrUrl.c_str());
            jstring jhttpServerUrl = env->NewStringUTF(item.httpSvrUrl.c_str());
            jstring jaddCreditsUrl = env->NewStringUTF(item.addCreditsUrl.c_str());
            jstring janchorPage = env->NewStringUTF(item.anchorPage.c_str());
            jstring juserLevel = env->NewStringUTF(item.userLevel.c_str());
            jstring jintimacy = env->NewStringUTF(item.intimacy.c_str());
            jstring juserProtocol = env->NewStringUTF(item.userProtocol.c_str());
            jstring jshowDetailPage = env->NewStringUTF(item.showDetailPage.c_str());
            jstring jshowDescription = env->NewStringUTF(item.showDescription.c_str());
			jstring jhangoutCredirMsg = env->NewStringUTF(item.hangoutCredirMsg.c_str());
			jstring jloiH5Url = env->NewStringUTF(item.loiH5Url.c_str());
			jstring jemfH5Url = env->NewStringUTF(item.emfH5Url.c_str());
			jstring jpmStartNotice = env->NewStringUTF(item.pmStartNotice.c_str());
			jstring jpostStampUrl = env->NewStringUTF(item.postStampUrl.c_str());
			jstring jhttpSvrMobileUrl = env->NewStringUTF(item.httpSvrMobileUrl.c_str());
            jstring jsocketHost = env->NewStringUTF(item.socketHost.c_str());
            jstring jsocketHostDomain = env->NewStringUTF(item.socketHostDomain.c_str());
            jstring jchatVoiceHostUrl = env->NewStringUTF(item.chatVoiceHostUrl.c_str());
            jstring jsendLetter = env->NewStringUTF(item.sendLetter.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jimServerUrl,
                                   jhttpServerUrl,
                                   jaddCreditsUrl,
                                   janchorPage,
                                   juserLevel,
                                   jintimacy,
                                   juserProtocol,
                                   jshowDetailPage,
                                   jshowDescription,
								   jhangoutCredirMsg,
								   jloiH5Url,
								   jemfH5Url,
								   jpmStartNotice,
								   jpostStampUrl,
								   jhttpSvrMobileUrl,
								   jsocketHost,
								   jsocketHostDomain,
								   item.socketPort,
								   item.minBalanceForChat,
								   jchatVoiceHostUrl,
								   jsendLetter,
								   item.hangoutCreditPrice);
            env->DeleteLocalRef(jimServerUrl);
            env->DeleteLocalRef(jhttpServerUrl);
            env->DeleteLocalRef(jaddCreditsUrl);
            env->DeleteLocalRef(janchorPage);
            env->DeleteLocalRef(juserLevel);
            env->DeleteLocalRef(jintimacy);
            env->DeleteLocalRef(juserProtocol);
            env->DeleteLocalRef(jshowDetailPage);
            env->DeleteLocalRef(jshowDescription);
			env->DeleteLocalRef(jhangoutCredirMsg);
			env->DeleteLocalRef(jloiH5Url);
			env->DeleteLocalRef(jemfH5Url);
			env->DeleteLocalRef(jpmStartNotice);
			env->DeleteLocalRef(jpostStampUrl);
			env->DeleteLocalRef(jhttpSvrMobileUrl);
			env->DeleteLocalRef(jsocketHost);
			env->DeleteLocalRef(jsocketHostDomain);
            env->DeleteLocalRef(jchatVoiceHostUrl);
            env->DeleteLocalRef(jsendLetter);
        }


	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobjectArray getAdListArray(JNIEnv *env, const AdItemList& listItem) {
    jobjectArray jItemArray = NULL;
    jclass jItemCls = GetJClass(env, HOTLIST_ITEM_CLASS);
    if(NULL != jItemCls &&  listItem.size() > 0 ){
        jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
        int i = 0;
        for(AdItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
            jobject item = getAdListItem(env, (*itr));
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
    return jItemArray;
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getGiftArray(JNIEnv *env, const GiftItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, GIFT_DETAIL_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(GiftItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getGiftDetailItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getSendableGiftArray(JNIEnv *env, const GiftWithIdItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, SENDABLE_GIFT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(GiftWithIdItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getSendableGiftItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getTalentArray(JNIEnv *env, const TalentItemList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, TALENT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(TalentItemList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getTalentItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getBookTimeArray(JNIEnv *env, const HttpGetCreateBookingInfoItem::BookTimeList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, BOOK_TIME_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(HttpGetCreateBookingInfoItem::BookTimeList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getBookTimeItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getBookGiftArray(JNIEnv *env, const HttpGetCreateBookingInfoItem::GiftList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, BOOK_GIFT_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(HttpGetCreateBookingInfoItem::GiftList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getBookGiftItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobject getBookInviteConfigItem(JNIEnv *env, const HttpGetCreateBookingInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, BOOK_INVITE_CONFIG_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(D[L";
		signature += BOOK_TIME_ITEM_CLASS;
		signature += ";";
		signature += "[L";
		signature += BOOK_GIFT_ITEM_CLASS;
		signature += ";";
		signature += "L";
		signature += BOOK_PHONE_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jobjectArray jtimeArray = getBookTimeArray(env, item.bookTime);
            jobjectArray jbookGiftArray = getBookGiftArray(env, item.bookGift.giftList);
            jobject jbookPhone = getBookPhoneItem(env, item.bookPhone);
            jItem = env->NewObject(jItemCls, init,
                                   item.bookDeposit,
                                   jtimeArray,
                                   jbookGiftArray,
                                   jbookPhone
            );
            if(NULL != jtimeArray){
                env->DeleteLocalRef(jtimeArray);
            }
            if(NULL != jbookGiftArray){
                env->DeleteLocalRef(jbookGiftArray);
            }
            if(jbookPhone != NULL){
                env->DeleteLocalRef(jbookPhone);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getPackgetVoucherArray(JNIEnv *env, const VoucherList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_VOUCHER_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(VoucherList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getPackageVoucherItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getPackgetRideArray(JNIEnv *env, const RideList& listItem){
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_RIDE_ITEM_CLASS);
	if(NULL != jItemCls &&  listItem.size() > 0 ){
		jItemArray = env->NewObjectArray(listItem.size(), jItemCls, NULL);
		int i = 0;
		for(RideList::const_iterator itr = listItem.begin(); itr != listItem.end(); itr++, i++) {
			jobject item = getPackageRideItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobjectArray getServerArray(JNIEnv *env, const HttpLoginItem::SvrList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, SERVER_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HttpLoginItem::SvrList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getServerItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobject getServerItem(JNIEnv *env, const HttpLoginItem::SvrItem& item) {
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
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;

}

jobject getUserInfoItem(JNIEnv *env, const HttpUserInfoItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_USERINFO_ITEM_CLASS);
	if (NULL != jItemCls) {
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;IZZD";
		signature += "L";
		signature += OTHER_ANCHORINFO_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring juserId = env->NewStringUTF(item.userId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jcountry = env->NewStringUTF(item.country.c_str());
            jobject janchorInfo = getAnchorInfoItem(env, item.anchorInfo);
            jItem = env->NewObject(jItemCls, init, juserId, jnickName, jphotoUrl, item.age, jcountry,
                                   item.userLevel, item.isOnline, item.isAnchor, item.leftCredit, janchorInfo);
            env->DeleteLocalRef(juserId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jcountry);
            if(janchorInfo != NULL){
                env->DeleteLocalRef(janchorInfo);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getAnchorInfoItem(JNIEnv *env, const HttpAnchorInfoItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_ANCHORINFO_ITEM_CLASS);
	if (NULL != jItemCls) {
		string signature = "(Ljava/lang/String;IZLjava/lang/String;Ljava/lang/String;)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jaddress = env->NewStringUTF(item.address.c_str());
            jstring jintroduction = env->NewStringUTF(item.introduction.c_str());
            jstring jroomPhotoUrl = env->NewStringUTF(item.roomPhotoUrl.c_str());
            jint anchorType = AnchorLevelTypeToInt(item.anchorType);
            jItem = env->NewObject(jItemCls, init, jaddress, anchorType, item.isLive, jintroduction, jroomPhotoUrl);
            env->DeleteLocalRef(jaddress);
            env->DeleteLocalRef(jintroduction);
            env->DeleteLocalRef(jroomPhotoUrl);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}


jobject getBindAnchorItem(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_BIND_ANCHOR_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;II)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {

            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jint type = VoucherUseRoomTypeToInt(item.useRoomType);
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   type,
                                   (int)item.expTime
            );
            env->DeleteLocalRef(janchorId);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobjectArray getBindAnchorArray(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_BIND_ANCHOR_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HttpVoucherInfoItem::BindAnchorList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getBindAnchorItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}


jobject getVoucherInfoItem(JNIEnv *env, const HttpVoucherInfoItem& item){
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PACKAGE_VOUCHOR_AVAILABLE_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(II";
		signature += "[L";
		signature += PACKAGE_BIND_ANCHOR_ITEM_CLASS;
		signature += ";";
		signature += "II[Ljava/lang/String";
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jobjectArray jbingArray = getBindAnchorArray(env, item.bindAnchor);
            jclass jStringCls = env->FindClass("java/lang/String");
            jobjectArray jwatchedArray = env->NewObjectArray(item.watchedAnchor.size(), jStringCls, NULL);
            WatchAnchorList::const_iterator AnchorIdIter;
            int iIndex = 0;
            for (AnchorIdIter = item.watchedAnchor.begin();
                 AnchorIdIter != item.watchedAnchor.end();
                 AnchorIdIter++, iIndex++)
            {
                jstring janchorId = env->NewStringUTF((*AnchorIdIter).c_str());
                env->SetObjectArrayElement(jwatchedArray, iIndex, janchorId);
                env->DeleteLocalRef(janchorId);
            }
            jItem = env->NewObject(jItemCls, init,
                                   (int)item.onlypublicExpTime,
                                   (int)item.onlyprivateExpTime,
                                   jbingArray,
                                   (int)item.onlypublicNewExpTime,
                                   (int)item.onlyprivateNewExpTime,
                                   jwatchedArray
            );
            if(NULL != jbingArray){
                env->DeleteLocalRef(jbingArray);
            }
            if(NULL != jwatchedArray){
                env->DeleteLocalRef(jwatchedArray);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getHangoutAnchorInfoItem(JNIEnv *env, const HttpHangoutAnchorItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;";
		signature += "I";
		signature += "Ljava/lang/String;";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.photoUrl.c_str());
            jstring jcountry = env->NewStringUTF(item.country.c_str());
			jint jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
			jstring javatarImg = env->NewStringUTF(item.avatarImg.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   javatarImg,  // 头像
                                   item.age,
                                   jcountry,
								   jonlineStatus,
								   jphotoUrl   // 封面
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jcountry);
            env->DeleteLocalRef(javatarImg);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobjectArray getHangoutAnchorInfoArray(JNIEnv *env, const HangoutAnchorList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HangoutAnchorList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getHangoutAnchorInfoItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobject getHangoutGiftListItem(JNIEnv *env, const HttpHangoutGiftListItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUGIFTLIST_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "([Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/String;";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jobjectArray  jbuyforArray = getJavaStringArray(env, item.buyforList);
			jobjectArray  jnormalArray = getJavaStringArray(env, item.normalList);
			jobjectArray  jcelebratioArray = getJavaStringArray(env, item.celebrationList);
			jItem = env->NewObject(jItemCls, init,
								   jbuyforArray,
								   jnormalArray,
								   jcelebratioArray
			);
			if (NULL != jbuyforArray) {
				env->DeleteLocalRef(jbuyforArray);
			}
			if (NULL != jnormalArray) {
				env->DeleteLocalRef(jnormalArray);
			}
			if (NULL != jcelebratioArray) {
				env->DeleteLocalRef(jcelebratioArray);
			}

		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobjectArray getHangoutOnlineAnchorArray(JNIEnv *env, const HttpHangoutList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HttpHangoutList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getHangoutListItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}
jobject getHangoutListItem(JNIEnv *env, const HttpHangoutListItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;II";
		signature += "Ljava/lang/String;";
		signature += "[L";
		signature += HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring avatarImg = env->NewStringUTF(item.avatarImg.c_str());
			jstring jcoverImg = env->NewStringUTF(item.coverImg.c_str());
			jint jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
			jstring jinvitationMsg = env->NewStringUTF(item.invitationMsg.c_str());
			jobjectArray jItemArray = getFriendsInfoArray(env, item.friendsInfoList);
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   avatarImg,
                                   jcoverImg,
                                   jonlineStatus,
								   item.friendsNum,
								   jinvitationMsg,
								   jItemArray
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(avatarImg);
            env->DeleteLocalRef(jcoverImg);
            env->DeleteLocalRef(jinvitationMsg);
            if(jItemArray != NULL){
            	env->DeleteLocalRef(jItemArray);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}
jobjectArray getFriendsInfoArray(JNIEnv *env, const HttpFriendsInfoList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HttpFriendsInfoList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getHttpFriendsInfoItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}
jobject getHttpFriendsInfoItem(JNIEnv *env, const HttpFriendsInfoItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "ILjava/lang/String;I";
		signature += "Ljava/lang/String;";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
            jstring jnickName = env->NewStringUTF(item.nickName.c_str());
            jstring jphotoUrl = env->NewStringUTF(item.anchorImg.c_str());
            jstring jcountry = env->NewStringUTF("");
            //jstring jcountry = env->NewStringUTF(item.country.c_str());
			//jint jonlineStatus = AnchorOnlineStatusToInt(item.onlineStatus);
			jstring jcoverImg = env->NewStringUTF(item.coverImg.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   janchorId,
                                   jnickName,
                                   jphotoUrl,
                                   0,               // 没有，这个字段
                                   jcountry,              // 没有，这个字段
								   2,               // 没有，这个字段
								   jcoverImg
            );
            env->DeleteLocalRef(janchorId);
            env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(jphotoUrl);
            env->DeleteLocalRef(jcoverImg);
            env->DeleteLocalRef(jcountry);
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobjectArray getHangoutStatusArray(JNIEnv *env, const HttpHangoutStatusList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(HttpHangoutStatusList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getHttpHangoutStatusItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}
jobject getHttpHangoutStatusItem(JNIEnv *env, const HttpHangoutStatusItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(Ljava/lang/String;";
		signature += "[L";
		signature += HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS;
		signature += ";";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jliveRoomId = env->NewStringUTF(item.liveRoomId.c_str());
            jobjectArray jItemArray = getFriendsInfoArray(env, item.anchorList);

            jItem = env->NewObject(jItemCls, init,
                                   jliveRoomId,
                                   jItemArray
            );
            env->DeleteLocalRef(jliveRoomId);
            if(jItemArray != NULL){
                env->DeleteLocalRef(jItemArray);
            }
        }

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getProgramInfoItem(JNIEnv *env, const HttpProgramInfoItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, PROGRAM_PROGRAMINFO_ITEM_CLASS);
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
                                   ProgramStatusToInt(item.status),
                                   ProgramTicketStatusToInt(item.ticketStatus),
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

jobjectArray getProgramInfoArray(JNIEnv *env, const ProgramInfoList& list) {
	jobjectArray jItemArray = NULL;
	jclass jItemCls = GetJClass(env, PROGRAM_PROGRAMINFO_ITEM_CLASS);
	if(NULL != jItemCls &&  list.size() > 0 ){
		jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
		int i = 0;
		for(ProgramInfoList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
			jobject item = getProgramInfoItem(env, (*itr));
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItemArray;
}

jobject getMainNoReadNumItem(JNIEnv *env, const HttpMainNoReadNumItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_MAINUNREADNUM_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(III";
		signature += "III";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {

			jItem = env->NewObject(jItemCls, init,
								   item.showTicketUnreadNum,
								   item.loiUnreadNum,
								   item.emfUnreadNum,
								   item.privateMessageUnreadNum,
                                   item.bookingUnreadNum,
                                   item.backpackUnreadNum

			);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getValidSiteIdItem(JNIEnv *env, const HttpValidSiteIdItem& item){
	jobject jItem = NULL;
	jclass cls = GetJClass(env, LSVALIDSITEID_ITEM_CLASS);
	if( cls != NULL) {
		jmethodID init = env->GetMethodID(cls, "<init>", "("
				"I"
				"Z"
				")V"
		);

		if( init != NULL ) {
			jItem = env->NewObject(cls, init,
								   item.siteId,
								   item.isLive
			);

		}
	}

	if (NULL != cls) {
		env->DeleteLocalRef(cls);
	}
	return jItem;
}

jobjectArray getValidSiteIdListArray(JNIEnv *env, HttpValidSiteIdList siteIdList) {
	jobjectArray jItemArray = NULL;

	jclass jItemCls = GetJClass(env, LSVALIDSITEID_ITEM_CLASS);
	if (NULL != jItemCls && siteIdList.size() > 0) {
		jItemArray = env->NewObjectArray(siteIdList.size(), jItemCls, NULL);
		int i = 0;
		for(HttpValidSiteIdList::const_iterator itr = siteIdList.begin(); itr != siteIdList.end(); itr++, i++) {
			jobject item = getValidSiteIdItem(env, *itr);
			env->SetObjectArrayElement(jItemArray, i, item);
			env->DeleteLocalRef(item);
		}
	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}

	return jItemArray;
}

jobject getMyProfileItem(JNIEnv *env, const HttpProfileItem& item) {
	jobject jItem = NULL;
	jclass cls = GetJClass(env, OTHER_LSPROFILE_ITEM_CLASS);
	if( cls != NULL) {

		string signature = "(";
		signature += 		"Ljava/lang/String;"
				"I"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"

				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"
				"I"

				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"I"

				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"
				"Ljava/lang/String;"

				"I"
				"I"
				"Ljava/lang/String;"
				"I"

				"Ljava/lang/String;"
				"I"
				"I"

				"Ljava/lang/String;"
				"I"
				"Ljava/lang/String;"
				"I"

				"Ljava/util/ArrayList;"
				"I";
		signature += ")V";

		jmethodID init = env->GetMethodID(cls, "<init>", signature.c_str()
		);

		if( init != NULL ) {
			jstring manid = env->NewStringUTF(item.manid.c_str());
			jstring birthday = env->NewStringUTF(item.birthday.c_str());
			jstring firstname = env->NewStringUTF(item.firstname.c_str());
			jstring lastname = env->NewStringUTF(item.lastname.c_str());
			jstring email = env->NewStringUTF(item.email.c_str());

			jstring resume = env->NewStringUTF(item.resume.c_str());
			jstring resume_content = env->NewStringUTF(item.resume_content.c_str());

			jstring address1 = env->NewStringUTF(item.address1.c_str());
			jstring address2 = env->NewStringUTF(item.address2.c_str());
			jstring city = env->NewStringUTF(item.city.c_str());
			jstring province = env->NewStringUTF(item.province.c_str());
			jstring zipcode = env->NewStringUTF(item.zipcode.c_str());
			jstring telephone = env->NewStringUTF(item.telephone.c_str());
			jstring fax = env->NewStringUTF(item.fax.c_str());
			jstring alternate_email = env->NewStringUTF(item.alternate_email.c_str());
			jstring money = env->NewStringUTF(item.money.c_str());

			jstring photoURL = env->NewStringUTF(item.photoURL.c_str());
			jstring mobile = env->NewStringUTF(item.mobile.c_str());
			jstring landline = env->NewStringUTF(item.landline.c_str());
			jstring landline_ac = env->NewStringUTF(item.landline_ac.c_str());

			jclass jArrayList = env->FindClass("java/util/ArrayList");
			jmethodID jArrayListInit = env->GetMethodID(jArrayList, "<init>", "()V");
			jmethodID jArrayListAdd = env->GetMethodID(jArrayList, "add", "(Ljava/lang/Object;)Z");
			FileLog("httprequest", "Profile.Native::onGetMyProfile( "
							"jArrayList : %p, "
							"jArrayListInit : %p, "
							"jArrayListAdd : %p "
							")",
					jArrayList,
					jArrayListInit,
					jArrayListAdd
			);

			FileLog("httprequest", "Profile.Native::onGetMyProfile( "
							"item.interests.size() : %d "
							")",
					item.interests.size()
			);

			int i = 0;
			jobject jInterestList = NULL;
			jInterestList = env->NewObject(jArrayList, jArrayListInit);
			if( item.interests.size() > 0 ) {
				i = 0;
				for(list<string>::const_iterator itr = item.interests.begin(); itr != item.interests.end(); itr++, i++) {
					jstring value = env->NewStringUTF((*itr).c_str());
					env->CallBooleanMethod(jInterestList, jArrayListAdd, value);
					env->DeleteLocalRef(value);
				}
			}

			jItem = env->NewObject(cls, init,
								   manid,
								   item.age,
								   birthday,
								   firstname,
								   lastname,
								   email,

								   item.gender,
								   item.country,
								   item.marry,
								   item.height,
								   item.weight,
								   item.smoke,
								   item.drink,
								   item.language,
								   item.religion,
								   item.education,
								   item.profession,
								   item.ethnicity,
								   item.income,
								   item.children,

								   resume,
								   resume_content,
								   item.resume_status,

								   address1,
								   address2,
								   city,
								   province,
								   zipcode,
								   telephone,
								   fax,
								   alternate_email,
								   money,

								   item.v_id,
								   item.photo,
								   photoURL,
								   item.integral,

								   mobile,
								   item.mobile_cc,
								   item.mobile_status,

								   landline,
								   item.landline_cc,
								   landline_ac,
								   item.landline_status,

								   jInterestList,
								   item.zodiac
			);


			env->DeleteLocalRef(manid);
			env->DeleteLocalRef(birthday);
			env->DeleteLocalRef(firstname);
			env->DeleteLocalRef(lastname);
			env->DeleteLocalRef(email);
			env->DeleteLocalRef(resume);
			env->DeleteLocalRef(resume_content);
			env->DeleteLocalRef(address1);
			env->DeleteLocalRef(address2);
			env->DeleteLocalRef(city);
			env->DeleteLocalRef(province);
			env->DeleteLocalRef(zipcode);
			env->DeleteLocalRef(telephone);
			env->DeleteLocalRef(fax);
			env->DeleteLocalRef(alternate_email);
			env->DeleteLocalRef(money);
			env->DeleteLocalRef(photoURL);
			env->DeleteLocalRef(mobile);
			env->DeleteLocalRef(landline);
			env->DeleteLocalRef(landline_ac);

			if( jInterestList != NULL ) {
				env->DeleteLocalRef(jInterestList);
			}


		}
	}

	if (NULL != cls) {
		env->DeleteLocalRef(cls);
	}
	return jItem;
}

jobject getVersionCheckItem(JNIEnv *env, const HttpVersionCheckItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, OTHER_LSVERSIONCHECK_ITEM_CLASS);
	if (NULL != jItemCls){
		string signature = "(ILjava/lang/String;Ljava/lang/String;";
		signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		signature += "IZ";
		signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {

			jstring versionName = env->NewStringUTF(item.versionName.c_str());
			jstring versionDesc = env->NewStringUTF(item.versionDesc.c_str());
			jstring url = env->NewStringUTF(item.url.c_str());
			jstring storeUrl = env->NewStringUTF(item.storeUrl.c_str());
			jstring pubTime = env->NewStringUTF(item.pubTime.c_str());
			jItem = env->NewObject(jItemCls, init,
								   item.versionCode,
								   versionName,
								   versionDesc,
								   url,
								   storeUrl,
								   pubTime,
								   item.checkTime,
								   item.isForceUpdate

			);
			env->DeleteLocalRef(versionName);
			env->DeleteLocalRef(versionDesc);
			env->DeleteLocalRef(url);
			env->DeleteLocalRef(storeUrl);
			env->DeleteLocalRef(pubTime);
		}

	}
	if (NULL != jItemCls) {
		env->DeleteLocalRef(jItemCls);
	}
	return jItem;
}

jobject getHttpAuthorityItem(JNIEnv *env, const HttpAuthorityItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HTTP_AUTHORITY_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(ZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {

			jItem = env->NewObject(jItemCls, init,
								   item.privteLiveAuth,
								   item.bookingPriLiveAuth);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

jobject getUserPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserPrivItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, USERPRIV_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(";
		        signature += "L";
		        signature += LIVECHATPRIV_ITEM_CLASS;
		        signature += ";";
		        signature += "L";
		        signature += MAILPRIV_ITEM_CLASS;
		        signature += ";";
		        signature += "L";
		        signature += HANGOUTPRIV_ITEM_CLASS;
		        signature += ";";
		        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jobject liveChatObj = getLiveChatPrivItem(env, item.liveChatPriv);
			jobject mailObj = getMailPrivItem(env, item.mailPriv);
			jobject hangoutObj = getHangoutPrivItem(env, item.hangoutPriv);
			jItem = env->NewObject(jItemCls, init,
								   liveChatObj,
								   mailObj,
								   hangoutObj);
			    if (NULL != liveChatObj) {
                    env->DeleteLocalRef(liveChatObj);
                }
			    if (NULL != mailObj) {
                    env->DeleteLocalRef(mailObj);
                }
			    if (NULL != hangoutObj) {
                    env->DeleteLocalRef(hangoutObj);
                }
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}
jobject getLiveChatPrivItem(JNIEnv *env, const HttpLoginItem::HttpLiveChatPrivItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, LIVECHATPRIV_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(ZIZZ)V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
            jint jriskType = LSHttpLiveChatInviteRiskTypeToInt(item.liveChatInviteRiskType);
			jItem = env->NewObject(jItemCls, init,
								   item.isLiveChatPriv,
								   jriskType,
								   item.isSendLiveChatPhotoPriv,
								   item.isSendLiveChatVoicePriv);

		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}
jobject getUserSendMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserSendMailPrivItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, USERSENDMAILPRIV_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(IILjava/lang/String;";
		        signature += "Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
		        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
            jint jprivType = LSSendImgRiskTypeToInt(item.isPriv);
			jstring postStampMsg = env->NewStringUTF(item.postStampMsg.c_str());
			jstring coinMsg = env->NewStringUTF(item.coinMsg.c_str());
			jstring quickPostStampMsg = env->NewStringUTF(item.quickPostStampMsg.c_str());
			jstring quickCoinMsg = env->NewStringUTF(item.quickCoinMsg.c_str());
			jItem = env->NewObject(jItemCls, init,
								   jprivType,
								   item.maxImg,
								   postStampMsg,
								   coinMsg,
								   quickPostStampMsg,
								   quickCoinMsg);
			env->DeleteLocalRef(postStampMsg);
            env->DeleteLocalRef(coinMsg);
            env->DeleteLocalRef(quickPostStampMsg);
            env->DeleteLocalRef(quickCoinMsg);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}
jobject getMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpMailPrivItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, MAILPRIV_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Z";
		        signature += "L";
		        signature += USERSENDMAILPRIV_ITEM_CLASS;
		        signature += ";";
		        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jobject sendObj = getUserSendMailPrivItem(env, item.userSendMailImgPriv);
			jItem = env->NewObject(jItemCls, init,
								   item.userSendMailPriv,
								   sendObj);
			    if (NULL != sendObj) {
                    env->DeleteLocalRef(sendObj);
                }
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}
jobject getHangoutPrivItem(JNIEnv *env, const HttpLoginItem::HttpHangoutPrivItem& item) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, HANGOUTPRIV_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(Z";
		        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
			jItem = env->NewObject(jItemCls, init,
								   item.isHangoutPriv);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}