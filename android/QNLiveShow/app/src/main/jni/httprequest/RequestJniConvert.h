/*
 * RequestJniConvert.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#ifndef REQUESTJNICONVERT_H_
#define REQUESTJNICONVERT_H_

#include "GlobalFunc.h"

/*主播在线状态状态*/
static const int AnchorOnlineStatusArray[] = {
	ONLINE_STATUS_UNKNOWN,
	ONLINE_STATUS_OFFLINE,
	ONLINE_STATUS_LIVE
};

// 底层状态转换JAVA坐标
int AnchorOnlineStatusToInt(OnLineStatus liveRoomStatus);

/*直播间类型*/
static const int LiveRoomTypeArray[] = {
	    HTTPROOMTYPE_NOLIVEROOM,                  // 没有直播间
	    HTTPROOMTYPE_FREEPUBLICLIVEROOM,          // 免费公开直播间
	    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM,        // 付费公开直播间
	    HTTPROOMTYPE_COMMONPRIVATELIVEROOM,       // 普通私密直播间
	    HTTPROOMTYPE_LUXURYPRIVATELIVEROOM        // 豪华私密直播间
};

// 底层状态转换JAVA坐标
int LiveRoomTypeToInt(HttpRoomType liveRoomType);

/*立即私密邀请处理状态*/
static const int ImmediateInviteReplyTypeArray[]{
	REPLYTYPE_UNKNOWN,              // 未知
	REPLYTYPE_UNCONFIRM,            // 待确定
	REPLYTYPE_AGREE,                // 已同意
	REPLYTYPE_REJECT,               // 已拒绝
	REPLYTYPE_OUTTIME               // 已超时
};

// 底层状态转换JAVA坐标
int ImmediateInviteReplyTypeToInt(ReplyType giftType);

/* 礼物类型  */
static const int GiftTypeArray[]{
	GIFTTYPE_UNKNOWN,
	GIFTTYPE_COMMON,   // 普通礼物
	GIFTTYPE_Heigh  // 高级礼物（动画）
};

// 底层状态转换JAVA坐标
int GiftTypeToInt(GiftType giftType);

/* 预约邀请处理状态 */
static const int BookInviteStatusArray[]{
	BOOKINGREPLYTYPE_UNKNOWN,           // 未知
	BOOKINGREPLYTYPE_PENDING,           // 待确定
	BOOKINGREPLYTYPE_ACCEPT,           // 已接受
	BOOKINGREPLYTYPE_REJECT,           // 已拒绝
	BOOKINGREPLYTYPE_OUTTIME,           // 超时
	BOOKINGREPLYTYPE_CANCEL,           // 取消
	BOOKINGREPLYTYPE_ANCHORABSENt,      // 主播缺席
	BOOKINGREPLYTYPE_FANSABSENT,        // 观众缺席
	BOOKINGREPLYTYPE_COMFIRMED          // 已完成
};

/*预约邀请列表类型*/
static const int BookInviteListTypeArray[] = {
	BOOKINGLISTTYPE_WAITFANSHANDLEING,          // 等待观众处理
	BOOKINGLISTTYPE_WAITANCHORHANDLEING,        // 等待主播处理
	BOOKINGLISTTYPE_COMFIRMED,                  // 已确认
	BOOKINGLISTTYPE_HISTORY                     // 历史
};

//Java层转底层枚举
BookingListType IntToBookInviteListType(int value);

// 底层状态转换JAVA坐标
int BookInviteStatusToInt(BookingReplyType replyType);

//c++对象转Java对象
jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);
jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList);
jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item);
jobjectArray getHotListArray(JNIEnv *env, const HotItemList& listItem);
jobjectArray getFollowingListArray(JNIEnv *env, const FollowItemList& listItem);
jobjectArray getValidRoomArray(JNIEnv *env, const HttpGetRoomInfoItem::RoomItemList& listItem);
jobjectArray getImmediateInviteArray(JNIEnv *env, const InviteItemList& listItem);
jobjectArray getAudienceArray(JNIEnv *env, const HttpLiveFansList& listItem);
jobjectArray getNormalGiftArray(JNIEnv *env, const GiftItemList& listItem);
jobject getGiftDetailItem(JNIEnv *env, const HttpGiftInfoItem& item);
jobjectArray getEmotionCategoryArray(JNIEnv *env, const EmoticonItemList& listItem);
jobject getImmediateInviteItem(JNIEnv *env, const HttpInviteInfoItem& item);
jobjectArray getBookInviteArray(JNIEnv *env, const BookingPrivateInviteItemList& listItem);
jobjectArray getPackgetGiftArray(JNIEnv *env, const BackGiftItemList& listItem);
jobject getSynConfigItem(JNIEnv *env, const HttpConfigItem& item);

#endif
