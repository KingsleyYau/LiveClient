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
	HTTPREPLYTYPE_UNKNOWN,              // 未知
	HTTPREPLYTYPE_UNCONFIRM,            // 待确定
	HTTPREPLYTYPE_AGREE,                // 已同意
	HTTPREPLYTYPE_REJECT,               // 已拒绝
	HTTPREPLYTYPE_OUTTIME,              // 已超时
	HTTPREPLYTYPE_CANCEL,               // 观众/主播取消
	HTTPREPLYTYPE_ANCHORABSENT,         // 主播缺席
	HTTPREPLYTYPE_FANSABSENT,           // 观众缺席
	HTTPREPLYTYPE_COMFIRMED             // 已完成
};

// 底层状态转换JAVA坐标
int ImmediateInviteReplyTypeToInt(HttpReplyType giftType);

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
	BOOKINGREPLYTYPE_ANCHORABSENT,      // 主播缺席
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

/* 才艺邀请状态  */
static const int TalentInviteStatusArray[]{
	HTTPTALENTSTATUS_UNREPLY,               // 未回复
	HTTPTALENTSTATUS_ACCEPT,                // 已接受
	HTTPTALENTSTATUS_REJECT                 // 拒绝
};

// 底层状态转换JAVA坐标
int TalentInviteStatusToInt(HTTPTalentStatus talentStatus);

/* 预约邀请时段可预约状态 */
static const int BookInviteTimeStatusArray[]{
	BOOKTIMESTATUS_BOOKING,             // 可预约
	BOOKTIMESTATUS_INVITEED,            // 本人已邀请
	BOOKTIMESTATUS_COMFIRMED             // 本人已确认
};

// 底层状态转换JAVA坐标
int  BookInviteTimeStatusToInt(BookTimeStatus bookTimeStatus);

/* 预约邀请时段可预约状态 */
static const int VoucherUseRoomTypeArray[]{
	USEROOMTYPE_LIMITLESS,                  // 不限
	USEROOMTYPE_PUBLIC,                     // 公开
	USEROOMTYPE_PRIVATE                     // 私密
};

// 底层状态转换JAVA坐标
int  VoucherUseRoomTypeToInt(UseRoomType useRoomType);

/* 预约邀请时段可预约状态 */
static const int VoucherAnchorTypeArray[]{
	ANCHORTYPE_LIMITLESS,                  // 不限
	ANCHORTYPE_APPOINTANCHOR,              // 指定主播
	ANCHORTYPE_NOSEEANCHOR                 // 没看过直播的主播
};

// 底层状态转换JAVA坐标
int  VoucherAnchorTypeToInt(AnchorType voucherAnchorType);

/*视频活动操作类型*/
static const int InteractiveOperateTypeArray[] = {
	CONTROLTYPE_START,                   // 开始
	CONTROLTYPE_CLOSE                    // 关闭
};

//Java层转底层枚举
ControlType IntToInteractiveOperateType(int value);


//c++对象转Java对象
jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);
jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList);

jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item);

jobjectArray getHotListArray(JNIEnv *env, const HotItemList& listItem);
jobjectArray getFollowingListArray(JNIEnv *env, const FollowItemList& listItem);
jobjectArray getValidRoomArray(JNIEnv *env, const HttpGetRoomInfoItem::RoomItemList& listItem);
jobjectArray getImmediateInviteArray(JNIEnv *env, const InviteItemList& listItem);
jobjectArray getAudienceArray(JNIEnv *env, const HttpLiveFansList& listItem);
jobjectArray getGiftArray(JNIEnv *env, const GiftItemList& listItem);
jobjectArray getSendableGiftArray(JNIEnv *env, const GiftWithIdItemList& listItem);
jobject getGiftDetailItem(JNIEnv *env, const HttpGiftInfoItem& item);
jobjectArray getEmotionCategoryArray(JNIEnv *env, const EmoticonItemList& listItem);
jobjectArray getTalentArray(JNIEnv *env, const TalentItemList& listItem);
jobject getTalentInviteItem(JNIEnv *env, const HttpGetTalentStatusItem& item);
jobject getAudienceInfoItem(JNIEnv *env, const HttpLiveFansItem& item);

jobject getImmediateInviteItem(JNIEnv *env, const HttpInviteInfoItem& item);
jobjectArray getBookInviteArray(JNIEnv *env, const BookingPrivateInviteItemList& listItem);
jobject getBookInviteConfigItem(JNIEnv *env, const HttpGetCreateBookingInfoItem& item);

jobjectArray getPackgetGiftArray(JNIEnv *env, const BackGiftItemList& listItem);
jobjectArray getPackgetVoucherArray(JNIEnv *env, const VoucherList& listItem);
jobjectArray getPackgetRideArray(JNIEnv *env, const RideList& listItem);

jobject getSynConfigItem(JNIEnv *env, const HttpConfigItem& item);

#endif
