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

/*直播间状态转换*/
static const int HTTPErrorTypeArray[] = {
		ZBHTTP_LCC_ERR_SUCCESS,   		// 成功
		ZBHTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果

	    // 客户端定义的错误
		ZBHTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）
		ZBHTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接
		ZBHTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）

		ZBHTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线
		ZBHTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时
	    // 服务器返回错误
        ZBHTTP_LCC_ERR_INSUFFICIENT_PARAM, // Insufficient parameters or parameter error (未传action参数或action参数不正确)
		ZBHTTP_LCC_ERR_NO_LOGIN,   		// 未登录
		ZBHTTP_LCC_ERR_SYSTEM,     		// 系统错误
		ZBHTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了
		ZBHTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭
		ZBHTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败
		ZBHTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭
		ZBHTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容
		ZBHTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid
		ZBHTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在
		ZBHTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭
		ZBHTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合
		ZBHTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错
		ZBHTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件
        ZBHTTP_LCC_ERR_VERIFICATIONCODE,     // 验证码错误(1)
        ZBHTTP_LCC_ERR_CANCEL_FAIL_INVITE, // 取消失败，观众已接受(16205)
        ZBHTTP_ERR_IDENTITY_FAILURE,       // 身份失效(16173)
		ZBHTTP_LCC_ERR_VIEWER_OPEN_KNOCK   // 观众已开门(10137)
};

// 底层状态转换JAVA坐标
int HTTPErrorTypeToInt(ZBHTTP_LCC_ERR_TYPE errType);

/* 礼物类型  */
static const int ZBGiftTypeArray[]{
        ZBGIFTTYPE_UNKNOWN,
        ZBGIFTTYPE_COMMON,   	// 普通礼物
        ZBGIFTTYPE_HEIGH,   	// 高级礼物（动画）
		ZBGIFTTYPE_BAR,   		// 吧台礼物
		ZBGIFTTYPE_CELEBRATE   	// 庆祝礼物
};

// 底层状态转换JAVA坐标
int GiftTypeToInt(ZBGiftType giftType);

/* 礼物类型  */
static const int ZBEMOTICONTYPEArray[]{
        ZBEMOTICONTYPE_STANDARD,     //  Standard:0
        ZBEMOTICONTYPE_ADVANCED       //  Advanced:1
};

// 底层状态转换JAVA坐标
int EmoTiconTypeToInt(ZBEmoticonType emoType);

/*回复才艺类型*/
static const int TalentReplyTypeArray[] = {
        ZBTALENTREPLYTYPE_UNKNOWN,              // 未知
        ZBTALENTREPLYTYPE_AGREE,                 // 同意
        ZBTALENTREPLYTYPE_REJECT                 // 拒绝
};

// Java层转底层枚举(性别)
ZBTalentReplyType IntToTalentReplyTypeOperateType(int value);

/*预约邀请列表类型*/
static const int ZBBookInviteListTypeArray[] = {
        ZBBOOKINGLISTTYPE_WAITANCHORHANDLEING,        // 等待主播处理
        ZBBOOKINGLISTTYPE_WAITFANSHANDLEING,          // 等待观众处理
        ZBBOOKINGLISTTYPE_COMFIRMED,                  // 已确认
        ZBBOOKINGLISTTYPE_HISTORY                     // 历史
};

//Java层转底层枚举
ZBBookingListType IntToBookInviteListType(int value);


/* 预约邀请处理状态 */
static const int ZBBookInviteStatusArray[]{
        ZBBOOKINGREPLYTYPE_UNKNOWN,           // 未知
        ZBBOOKINGREPLYTYPE_PENDING,           // 待确定
        ZBBOOKINGREPLYTYPE_ACCEPT,           // 已接受
        ZBBOOKINGREPLYTYPE_REJECT,           // 已拒绝
        ZBBOOKINGREPLYTYPE_OUTTIME,           // 超时
        ZBBOOKINGREPLYTYPE_CANCEL,           // 取消
        ZBBOOKINGREPLYTYPE_ANCHORABSENT,      // 主播缺席
        ZBBOOKINGREPLYTYPE_FANSABSENT,        // 观众缺席
        ZBBOOKINGREPLYTYPE_COMFIRMED          // 已完成
};

// 底层状态转换JAVA坐标
int BookInviteStatusToInt(ZBBookingReplyType replyType);

/*直播间类型*/
static const int ZBLiveRoomTypeArray[] = {
        ZBHTTPROOMTYPE_NOLIVEROOM,                  	// 没有直播间
        ZBHTTPROOMTYPE_FREEPUBLICLIVEROOM,          	// 免费公开直播间
        ZBHTTPROOMTYPE_COMMONPRIVATELIVEROOM,       	// 普通私密直播间
        ZBHTTPROOMTYPE_CHARGEPUBLICLIVEROOM,        	// 付费公开直播间
        ZBHTTPROOMTYPE_LUXURYPRIVATELIVEROOM,        	// 豪华私密直播间
		ZBHTTPROOMTYPE_MULTIPLAYINTERACTIONLIVEROOM		// 多人互动直播间
};

// 底层状态转换JAVA坐标
int LiveRoomTypeToInt(ZBHttpRoomType liveRoomType);

/*直播间类型*/
static const int AnchorMultiKnockTypeArray[] = {
        ANCHORMULTIKNOCKTYPE_UNKNOW,                    // 未知
        ANCHORMULTIKNOCKTYPE_PENDING,                   // 待确定
        ANCHORMULTIKNOCKTYPE_ACCEPT,                    // 已接受
        ANCHORMULTIKNOCKTYPE_REJECT,                    // 已拒绝
        ANCHORMULTIKNOCKTYPE_OUTTIME                    // 超时
};

// 底层状态转换JAVA坐标
int AnchorMultiKnockTypeToInt(AnchorMultiKnockType type);

/*自动邀请状态类型*/
static const int ZBSetPushTypeArray[] = {
        ZBSETPUSHTYPE_CLOSE,              // 关闭
        ZBSETPUSHTYPE_START,              // 启动
};

// Java层转底层枚举(性别)
ZBSetPushType IntToSetPushTypeOperateType(int value);

/*多人互动回复结果*/
static const int AnchorMultiplayerReplyTypeArray[] = {
		ANCHORMULTIPLAYERREPLYTYPE_AGREE,              // 关闭
		ANCHORMULTIPLAYERREPLYTYPE_REJECT              // 启动
};
// Java层转底层枚举(性别)
AnchorMultiplayerReplyType IntToAnchorMultiplayerReplyTypeOperateType(int value);


/*节目列表类型*/
static const int AnchorProgramListTypeArray[] = {
		ANCHORPROGRAMLISTTYPE_UNKNOW,           // 未知
		ANCHORPROGRAMLISTTYPE_UNVERIFY,         // 待审核
		ANCHORPROGRAMLISTTYPE_VERIFYPASS,       // 已通过审核且未开播
		ANCHORPROGRAMLISTTYPE_VERIFYREJECT,     // 被拒绝
		ANCHORPROGRAMLISTTYPE_HISTORY           // 历史
};
// Java层转底层枚举(性别)
AnchorProgramListType IntToAnchorProgramListTypeOperateType(int value);

/*节目状态*/
static const int AnchorProgramStatusArray[] = {
        ANCHORPROGRAMSTATUS_UNVERIFY,             // 未审核
        ANCHORPROGRAMSTATUS_VERIFYPASS,           // 审核通过
        ANCHORPROGRAMSTATUS_VERIFYREJECT,         // 审核被拒
        ANCHORPROGRAMSTATUS_PROGRAMEND,           // 节目正常结束
        ANCHORPROGRAMSTATUS_PROGRAMCALCEL,        // 节目已取消
        ANCHORPROGRAMSTATUS_OUTTIME               // 节目已超时
};

// 底层状态转换JAVA坐标
int AnchorProgramStatusToInt(AnchorProgramStatus type);


/*公开直播间类型*/
static const int AnchorPublicRoomTypeArray[] = {
        ANCHORPUBLICROOMTYPE_UNKNOW,           // 未知
        ANCHORPUBLICROOMTYPE_OPEN,              // 公开
        ANCHORPUBLICROOMTYPE_PROGRAM            // 节目
};

// 底层状态转换JAVA坐标
int AnchorPublicRoomTypeToInt(AnchorPublicRoomType type);

/*多人朋友类型*/
static const int AnchorFriendTypeArray[] = {
		ANCHORFRIENDTYPE_REQUESTING,   // 请求中
		ANCHORFRIENDTYPE_YES,           // 是
		ANCHORFRIENDTYPE_NO           // 否
};

// 底层状态转换JAVA坐标
int AnchorFriendTypeToInt(AnchorFriendType type);

/*在线状态*/
static const int AnchorOnlineStatusArray[] = {
		ANCHORONLINESTATUS_UNKNOW,     // 未知
		ANCHORONLINESTATUS_OFF,         // 离线
		ANCHORONLINESTATUS_ON          // 在线
};

// 底层状态转换JAVA坐标
int AnchorOnlineStatusToInt(AnchorOnlineStatus type);

//c++对象转Java对象
jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);
jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList);
//jintArray getInterestJavaIntArray(JNIEnv *env, const list<InterestType>& sourceList);

jobject getLoginItem(JNIEnv *env, const ZBHttpLoginItem& item);

jobjectArray getAudienceArray(JNIEnv *env, const ZBHttpLiveFansList& listItem);
jobject getAudienceInfoItem(JNIEnv *env, const ZBHttpLiveFansItem& item);

jobject getAudienceBaseInfoItem(JNIEnv *env, const ZBHttpLiveFansInfoItem& item);

jobjectArray getGiftArray(JNIEnv *env, const ZBGiftItemList& listItem);
jobject getGiftDetailItem(JNIEnv *env, const ZBHttpGiftInfoItem& item);

jobjectArray getGiftLimitNumArray(JNIEnv *env, const ZBHttpGiftLimitNumItemList& listItem);
jobject getGiftLimitNumItem(JNIEnv *env, const ZBHttpGiftLimitNumItem& item);

jobjectArray getEmotionCategoryArray(JNIEnv *env, const ZBEmoticonItemList& listItem);

jobjectArray getBookInviteArray(JNIEnv *env, const ZBBookingPrivateInviteItemList& listItem);

jobject getSynConfigItem(JNIEnv *env, const ZBHttpConfigItem& item);

jobjectArray getServerArray(JNIEnv *env, const ZBSvrList& list);
jobject getServerItem(JNIEnv *env, const ZBHttpSvrItem& item);

jobjectArray getAnchorArray(JNIEnv *env, const HttpAnchorItemList& listItem);
jobject getAnchorInfoItem(JNIEnv *env, const HttpAnchorItem& item);

jobjectArray getAnchorBaseInfoArray(JNIEnv *env, const HttpAnchorBaseInfoItemList& listItem);
jobject getAnchorBaseInfoItem(JNIEnv *env, const HttpAnchorBaseInfoItem& item);

jobjectArray getAnchorHangoutArray(JNIEnv *env, const HttpAnchorHangoutItemList& listItem);
jobject getAnchorHangoutItem(JNIEnv *env, const HttpAnchorHangoutItem& item);

jobject getAnchorHangoutGiftListItem(JNIEnv *env, const HttpAnchorHangoutGiftListItem& item);
jobjectArray getAnchorGiftNumArray(JNIEnv *env, const HttpAnchorGiftNumItemList& listItem);
jobject getAnchorGiftNumItem(JNIEnv *env, const HttpAnchorGiftNumItem& item);

jobject getAnchorFriendItem(JNIEnv *env, const HttpAnchorFriendItem& item);

jobject getProgramInfoItem(JNIEnv *env, const HttpAnchorProgramInfoItem& item);
jobjectArray getProgramInfoArray(JNIEnv *env, const AnchorProgramInfoList& list);


#endif
