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
	    HTTP_LCC_ERR_SUCCESS,   		// 成功
	    HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果

	    // 客户端定义的错误
	    HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）
	    HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接
	    //HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）

	    //HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线
	    //HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时
	    // 服务器返回错误
	    HTTP_LCC_ERR_ROOM_FULL,   		// 房间人满
	    HTTP_LCC_ERR_NO_CREDIT,   		// 信用点不足
	    /* IM公用错误码 */
	    HTTP_LCC_ERR_NO_LOGIN,   		// 未登录
	    HTTP_LCC_ERR_SYSTEM,     		// 系统错误
	    HTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了
	    HTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭
	    HTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败

	    HTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭
	    HTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容
	    HTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid
	    HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在
	    HTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭

	    HTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合
	    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错
	    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件
	    /* 其它错误码*/
	    HTTP_LCC_ERR_USED_OUTLOG, 				// 退出登录 (用户主动退出登录)
	    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/
	    HTTP_LCC_ERR_NOT_FIND_ANCHOR, 			// 主播机构信息找不到
	    HTTP_LCC_ERR_NOTCAN_REFUND, 			// 立即私密退点失败，已经定时扣费不能退点
	    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO, 		// 找不到price_setting表信息

        HTTP_LCC_ERR_ANCHOR_BUSY,			  	// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
	    HTTP_LCC_ERR_CHOOSE_TIME_ERR, 			// 预约时间错误 /*important*/
	    HTTP_LCC_ERR_BOOK_EXIST, 				// 用户预约时间段已经存在预约 /*important*/
	    HTTP_LCC_ERR_BIND_PHONE, 				// 手机号码已绑定
        HTTP_LCC_ERR_RETRY_PHONE, 				// 请稍后再重试

        HTTP_LCC_ERR_MORE_TWENTY_PHONE, 		// 60分钟内验证超过20次，请24小时后再试
	    HTTP_LCC_ERR_UPDATE_PHONE_FAIL, 		// 更新失败
	    HTTP_LCC_ERR_ANCHOR_OFFLIVE,            // 主播不在线，不能操作
		HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING, 	// 观众已同意预约
		HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING, 	// 预约邀请已超时（当观众拒绝时）

		HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING,   	// 预约邀请已超时（当观众同意时）

		/* 换站的错误码和域名的错误吗*/
        HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT,      // 帐号或密码不正确
        HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION ,      // 需要验证码 和 MBCE21002: Please enter the verification code.
        HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG,      // 验证码不正确 和 MBCE21003:The verification code is wrong
        HTTP_LCC_ERR_TLOGIN_SID_NULL,                // sid无效
        HTTP_LCC_ERR_TLOGIN_SID_OUTTIME,             // sid超时

        HTTP_LCC_ERR_DEMAIN_NO_FIND_MAIL,            // MBCE21001：(没有找到匹配的邮箱。)
        HTTP_LCC_ERR_DEMAIN_CURRENT_PASSWORD_WRONG,  // MBCE13001：Sorry, the current password you entered is wrong!
        HTTP_LCC_ERR_DEMAIN_ALL_FIELDS_WRONG,       // MBCE13002：Please check if all fields are filled and correct!
        HTTP_LCC_ERR_DEMAIN_THE_OPERATION_FAILED,       // MBCE13003：The operation failed  /mobile/changepwd.ph
        HTTP_LCC_ERR_DEMAIN_PASSWORD_FORMAT_WRONG,      // MBCE13004：Password format error

        HTTP_LCC_ERR_DEMAIN_NO_FIND_USERID,         // MBCE11001：(QpidNetWork男士会员ID未找到) /mobile/myprofile.php
        HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_ERR,        // MBCE12001：Data update error. ( 数据更新失败)  /mobile/updatepro.php
        HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY ,            // MBCE12002:( 更新失败：Key不存在。)  /mobile/updatepro.php
        HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE,            // MBCE12003：( 更新失败：Value值没有改变。)
        HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE,            // MBCE12004：( 更新失败：Value值检测没通过。)

        HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG,            // MBCE12005：update info_desc_log
        HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG,            // MBCE12006：insert into info_desc_log
        HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID,   // MBCE12007：update info_desc_log set group_id
        HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS,                       // MBCE22001：(APP安装记录已存在。)
        HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY,                     // 主播无立即私密邀请权限(17002)
            /* 信件*/
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买图片使用邮票支付时，邮票不足，但信用点可用(17213)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买图片使用邮票支付时，邮票不足，且信用点不足(17214)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买图片使用信用点支付时，信用点不足，但邮票可用(17215)(调用13.7.购买信件附件接口)

        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT6,          // 购买图片使用信用点支付时，信用点不足，且邮票不足(17216)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME,                     // 照片已过期(17217)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买视频使用邮票支付时，邮票不足，但信用点可用(17218)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买视频使用邮票支付时，邮票不足，且信用点不足(17219)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买视频使用信用点支付时，信用点不足，但邮票可用(17220)(调用13.7.购买信件附件接口)

        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买视频使用信用点支付时，信用点不足，且邮票不足(17221)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME,                                // 视频已过期(17222)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP,                         // 信用点或者邮票不足(17208):(调用13.4.信件详情接口, 调用13.5.发送信件接口)
        HTTP_LCC_ERR_EXIST_HANGOUT,                                        // 当前会员已在hangout直播间（调用8.11.获取当前会员Hangout直播状态接口）
};

// 底层状态转换JAVA坐标
int HTTPErrorTypeToInt(HTTP_LCC_ERR_TYPE errType);

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
	    HTTPROOMTYPE_COMMONPRIVATELIVEROOM,       // 普通私密直播间
	    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM,        // 付费公开直播间
	    HTTPROOMTYPE_LUXURYPRIVATELIVEROOM,       // 豪华私密直播间
	    HTTPROOMTYPE_HANGOUTLIVEROOM              // Hangout直播间
};

// 底层状态转换JAVA坐标
int LiveRoomTypeToInt(HttpRoomType liveRoomType);

/*主播VIP类型*/
static const int AnchorLevelTypeArray[] = {
	    ANCHORLEVELTYPE_UNKNOW,             // 未知
	    ANCHORLEVELTYPE_SILVER,             // 白银
	    ANCHORLEVELTYPE_GOLD                // 黄金
};
int AnchorLevelTypeToInt(AnchorLevelType anchorLevelType);

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
	GIFTTYPE_COMMON,    // 普通礼物
	GIFTTYPE_Heigh,     // 高级礼物（动画）
    GIFTTYPE_BAR,       // 吧台礼物
    GIFTTYPE_CELEBRATE  // 庆祝礼物
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
	HTTPTALENTSTATUS_REJECT,                // 拒绝
	HTTPTALENTSTATUS_OUTTIME,				// 已超时
	HTTPTALENTSTATUS_CANCEL					// 已取消
};

// 底层状态转换JAVA坐标
int TalentInviteStatusToInt(HTTPTalentStatus talentStatus);

/* 预约邀请时段可预约状态 */
static const int BookInviteTimeStatusArray[]{
	BOOKTIMESTATUS_BOOKING,             // 可预约
	BOOKTIMESTATUS_INVITEED,            // 本人已邀请
	BOOKTIMESTATUS_COMFIRMED,           // 本人已确认
	BOOKTIMESTATUS_INVITEEDOTHER		// 本人已邀请其它主播
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

/*观众用户类型（1：A1类型 2：A2类型） （A1类型：仅可看付费公开及豪华私密直播间， A2类型:可看所有直播间）*/
static const int LSHttpLiveChatInviteRiskTypeArray[] = {
		LSHTTP_LIVECHATINVITE_RISK_NOLIMIT,    // 不作任何限制
		LSHTTP_LIVECHATINVITE_RISK_LIMITSEND,    // 限制发送信息
		LSHTTP_LIVECHATINVITE_RISK_LIMITREV,    // 限制接受邀请
		LSHTTP_LIVECHATINVITE_RISK_LIMITALL    // 收发全部限制
};
int LSHttpLiveChatInviteRiskTypeToInt(LSHttpLiveChatInviteRiskType type);

/*观众用户类型（1：A1类型 2：A2类型） （A1类型：仅可看付费公开及豪华私密直播间， A2类型:可看所有直播间）*/
static const int UserTypeArray[] = {
		USERTYPEUNKNOW,             // 未知
		USERTYPEA1,             // A1类型：仅可看付费公开及豪华私密直播间
		USERTYPEA2                // A2类型:可看所有直播间
};
int UserTypeToInt(UserType userType);

/*视频活动操作类型*/
static const int InteractiveOperateTypeArray[] = {
	CONTROLTYPE_START,                   // 开始
	CONTROLTYPE_CLOSE                    // 关闭
};

//Java层转底层枚举
ControlType IntToInteractiveOperateType(int value);

/*获取界面的类型*/
static const int PromoAnchorTypeArray[] = {
	    PROMOANCHORTYPE_UNKNOW,                             // 未知
	    PROMOANCHORTYPE_LIVEROOM,                           // 直播间
	    PROMOANCHORTYPE_ANCHORPERSONAL                     // 主播个人页
};
//Java层转底层枚举
PromoAnchorType IntToPromoAnchorType(int value);


/*地区ID的类型*/
static const int RegionIdTypeArray[] = {
        REGIONIDTYPE_UNKNOW,                             // 未知
        REGIONIDTYPE_CD,                           		 // CD
        REGIONIDTYPE_LD,		                     	 // LD
        REGIONIDTYPE_AME
};
//Java层转底层枚举
RegionIdType IntToRegionIdType(int value);

/*多人邀请类型 */
static const int HangoutInviteStatusArray[] = {
		HANGOUTINVITESTATUS_UNKNOW,             // 未知
		HANGOUTINVITESTATUS_PENDING,            // 待确定
		HANGOUTINVITESTATUS_ACCEPT,             // 已接受
		HANGOUTINVITESTATUS_REJECT,				// 已拒绝
		HANGOUTINVITESTATUS_OUTTIME,			// 已超时
		HANGOUTINVITESTATUS_CANCLE,             // 观众取消邀
		HANGOUTINVITESTATUS_NOCREDIT,           // 余额不足
		HANGOUTINVITESTATUS_BUSY                // 主播繁忙
};
int HangoutInviteStatusToInt(HangoutInviteStatus type);

/*列表类型*/
static const int HangoutAnchorListTypeArray[] = {
		HANGOUTANCHORLISTTYPE_UNKNOW,                    // 未知
		HANGOUTANCHORLISTTYPE_FOLLOW,                   // 已关注
		HANGOUTANCHORLISTTYPE_WATCHED,		            // Watched(看过的)
		HANGOUTANCHORLISTTYPE_FRIEND,					// 主播好友
        HANGOUTANCHORLISTTYPE_ONLINEANCHOR              // 在线主播
};
//Java层转底层枚举
HangoutAnchorListType IntToHangoutAnchorListType(int value);


/*列表类型*/
static const int ProgramListTypeArray[] = {
		PROGRAMLISTTYPE_UNKNOW,             // 未知
		PROGRAMLISTTYPE_STARTTIEM,          // 按节目开始时间排序
		PROGRAMLISTTYPE_VERIFYTIEM,         // 按节目审核时间排序
		PROGRAMLISTTYPE_FEATURE,            // 按广告排序
		PROGRAMLISTTYPE_BUYTICKET,          // 已购票列表
        PROGRAMLISTTYPE_HISTORY            // 购票历史列表
};
//Java层转底层枚举
ProgramListType IntToProgramListType(int value);

/*节目状态类型 */
static const int ProgramStatusArray[] = {
		PROGRAMSTATUS_UNVERIFY,             // 未审核
		PROGRAMSTATUS_VERIFYPASS,           // 审核通过
		PROGRAMSTATUS_VERIFYREJECT,         // 审核被拒
		PROGRAMSTATUS_PROGRAMEND,           // 节目正常结束
		PROGRAMSTATUS_PROGRAMCALCEL,        // 节目已取消
		PROGRAMSTATUS_OUTTIME               // 节目已超时
};
int ProgramStatusToInt(ProgramStatus type);

/*节目推荐列表类型*/
static const int ShowRecommendListTypeArray[] = {
		SHOWRECOMMENDLISTTYPE_UNKNOW,                    // 未知
		SHOWRECOMMENDLISTTYPE_ENDRECOMMEND,              // 直播结束推荐<包括指定主播及其它主播
		SHOWRECOMMENDLISTTYPE_PERSONALRECOMMEND,         // 主播个人节目推荐<仅包括指定主播>
		SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND           // 不包括指定主播
};
//Java层转底层枚举
ShowRecommendListType IntToShowRecommendListType(int value);

/*节目购票状态 */
static const int ProgramTicketStatusArray[] = {
		PROGRAMTICKETSTATUS_NOBUY,      // 未购票
		PROGRAMTICKETSTATUS_BUYED,      // 已购票
		PROGRAMTICKETSTATUS_OUT         // 已退票
};
int ProgramTicketStatusToInt(ProgramTicketStatus type);

/*主播在线状态状态*/
static const int LSLoginSidTypeArray[] = {
    LSLOGINSIDTYPE_UNKNOW,    // 未知
    LSLOGINSIDTYPE_QNLOGIN,       // QN登录成功返回的
    LSLOGINSIDTYPE_LSLOGIN        // 直播登录成功返回的
};
//Java层转底层枚举
LSLoginSidType IntToLSLoginSidType(int value);

/*验证码类型*/
static const int LSValidateCodeTypeArray[] = {
		LSVALIDATECODETYPE_UNKNOW,    // 未知
		LSVALIDATECODETYPE_LOGIN,       // login：登录获取
		LSVALIDATECODETYPE_FINDPW        // 找回密码获取
};
//Java层转底层枚举
LSValidateCodeType IntToLSValidateCodeType(int value);

/*验证码类型*/
static const int LSOrderTypeArray[] = {
		LSORDERTYPE_CREDIT,      // 信用点
		LSORDERTYPE_MONTHFEE,    // 月费服务
		LSORDERTYPE_STAMP        // 邮票
};
//Java层转底层枚举
LSOrderType IntToLSOrderType(int value);

/*主播状态类型*/
static const int ComIMChatOnlineStatusArray[] = {
    IMCHATONLINESTATUS_UNKNOW,    // 未知
    IMCHATONLINESTATUS_OFF,      // 离线
    IMCHATONLINESTATUS_ONLINE   // 在线

};

// 底层状态转换JAVA坐标
int ComIMChatOnlineStatusToInt(IMChatOnlineStatus type);

/*发送信件权限类型*/
static const int LSSendImgRiskTypeArray[] = {
		LSSENDIMGRISKTYPE_NORMAL,           // 正常
		LSSENDIMGRISKTYPE_ONLYFREE,         // 只能发免费
		LSSENDIMGRISKTYPE_ONLYPAYMENT,      // 只能发付费
		LSSENDIMGRISKTYPE_NOSEND            // 不能发照片
};
int LSSendImgRiskTypeToInt(LSSendImgRiskType type);

//c++对象转Java对象
jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);
jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList);
jintArray getInterestJavaIntArray(JNIEnv *env, const list<InterestType>& sourceList);

jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item);


jobjectArray getAdListArray(JNIEnv *env, const AdItemList& listItem);
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
jobject getAudienceBaseInfoItem(JNIEnv *env, const HttpLiveFansInfoItem& item);
jobjectArray getServerArray(JNIEnv *env, const HttpLoginItem::SvrList& list);
jobject getServerItem(JNIEnv *env, const HttpLoginItem::SvrItem& item);

jobject getUserInfoItem(JNIEnv *env, const HttpUserInfoItem& item);
jobject getAnchorInfoItem(JNIEnv *env, const HttpAnchorInfoItem& item);

jobject getBindAnchorItem(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorItem& item);
jobjectArray getBindAnchorArray(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorList& list);
jobject getVoucherInfoItem(JNIEnv *env, const HttpVoucherInfoItem& item);

jobject getHangoutAnchorInfoItem(JNIEnv *env, const HttpHangoutAnchorItem& item);
jobjectArray getHangoutAnchorInfoArray(JNIEnv *env, const HangoutAnchorList& list);
jobject getHangoutGiftListItem(JNIEnv *env, const HttpHangoutGiftListItem& item);
jobjectArray getHangoutOnlineAnchorArray(JNIEnv *env, const HttpHangoutList& list);
jobject getHangoutListItem(JNIEnv *env, const HttpHangoutListItem& item);
jobjectArray getFriendsInfoArray(JNIEnv *env, const HttpFriendsInfoList& list);
jobject getHttpFriendsInfoItem(JNIEnv *env, const HttpFriendsInfoItem& item);
jobjectArray getHangoutStatusArray(JNIEnv *env, const HttpHangoutStatusList& list);
jobject getHttpHangoutStatusItem(JNIEnv *env, const HttpHangoutStatusItem& item);

jobject getProgramInfoItem(JNIEnv *env, const HttpProgramInfoItem& item);
jobjectArray getProgramInfoArray(JNIEnv *env, const ProgramInfoList& list);

jobject getMainNoReadNumItem(JNIEnv *env, const HttpMainNoReadNumItem& item);

jobjectArray getValidSiteIdListArray(JNIEnv *env, HttpValidSiteIdList siteIdList);

jobject getMyProfileItem(JNIEnv *env, const HttpProfileItem& item);

jobject getVersionCheckItem(JNIEnv *env, const HttpVersionCheckItem& item);

jobject getHttpAuthorityItem(JNIEnv *env, const HttpAuthorityItem& item);

// 用户权限item
jobject getUserPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserPrivItem& item);
jobject getLiveChatPrivItem(JNIEnv *env, const HttpLoginItem::HttpLiveChatPrivItem& item);
jobject getUserSendMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserSendMailPrivItem& item);
jobject getMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpMailPrivItem& item);
jobject getHangoutPrivItem(JNIEnv *env, const HttpLoginItem::HttpHangoutPrivItem& item);

#endif
