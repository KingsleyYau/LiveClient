/*
 * HttpRequestEnum.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 */

#ifndef REQUESTENUM_H_
#define REQUESTENUM_H_


typedef enum LoginType {
    LoginType_Unknow = -1,
    LoginType_Phone = 0,
    LoginType_Email =1,
} LoginType;

/*主播在线状态*/
typedef enum{
	ONLINE_STATUS_UNKNOWN = -1,
	ONLINE_STATUS_OFFLINE = 0,
	ONLINE_STATUS_LIVE = 1
} OnLineStatus;

typedef enum {
    HTTPROOMTYPE_NOLIVEROOM = 0,                  // 没有直播间
    HTTPROOMTYPE_FREEPUBLICLIVEROOM = 1,          // 免费公开直播间
    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM = 2,        // 付费公开直播间
    HTTPROOMTYPE_COMMONPRIVATELIVEROOM = 3,       // 普通私密直播间
    HTTPROOMTYPE_LUXURYPRIVATELIVEROOM = 4        // 豪华私密直播间
}HttpRoomType;

/*头像类型*/
typedef enum{
	PHOTOTYPE_UNKNOWN = -1,
	PHOTOTYPE_THUMB = 0,
	PHOTOTYPE_LARGE = 1
} PhotoType;

/*性别*/
typedef enum{
	GENDER_UNKNOWN = -1,
	GENDER_MALE = 0,
	GENDER_FEMALE = 1
} Gender;

/*图片类型*/
typedef enum{
    IMAGETYPE_UNKNOWN = 0,
    IMAGETYPE_USER = 1,
    IMAGETYPE_COVER = 2
} ImageType;

/*审核状态*/
typedef enum{
    EXAMINE_STATUS_UNKNOWN = 0,
    EXAMINE_STATUS_WAITING = 1,  // 待审核
    EXAMINE_STATUS_PASS    = 2,  // 通过
    EXAMINE_STATUS_REFUSE  = 3   // 否决
}ExamineStatus;

/*礼物类型*/
typedef enum{
    GIFTTYPE_UNKNOWN = 0,
    GIFTTYPE_COMMON = 1,   // 普通礼物
    GIFTTYPE_Heigh = 2  // 高级礼物（动画）
}GiftType;

typedef enum {
    EMOTICONTYPE_STANDARD = 0,      // Standard
    EMOTICONTYPE_ADVANCED = 1       // Advanced
}EmoticonType;

// 回复状态
typedef enum {
    HTTPREPLYTYPE_UNKNOWN = 0,              // 未知
    HTTPREPLYTYPE_UNCONFIRM = 1,            // 待确定
    HTTPREPLYTYPE_AGREE = 2,                // 已同意
    HTTPREPLYTYPE_REJECT = 3,               // 已拒绝
    HTTPREPLYTYPE_OUTTIME = 4,              // 已超时
    HTTPREPLYTYPE_CANCEL = 5,               // 观众/主播取消
    HTTPREPLYTYPE_ANCHORABSENT = 6,         // 主播缺席
    HTTPREPLYTYPE_FANSABSENT = 7,           // 观众缺席
    HTTPREPLYTYPE_COMFIRMED = 8             // 已完成
}HttpReplyType;

// 预约列表类型
typedef enum {
    BOOKINGLISTTYPE_WAITFANSHANDLEING = 0,          // 等待观众处理
    BOOKINGLISTTYPE_WAITANCHORHANDLEING = 1,        // 等待主播处理
    BOOKINGLISTTYPE_COMFIRMED = 2,                  // 已确认
    BOOKINGLISTTYPE_HISTORY = 3                     // 历史
    
} BookingListType;

// 预约回复状态
typedef enum {
    BOOKINGREPLYTYPE_UNKNOWN = 0,           // 未知
    BOOKINGREPLYTYPE_PENDING = 1,           // 待确定
    BOOKINGREPLYTYPE_ACCEPT  = 2,           // 已接受
    BOOKINGREPLYTYPE_REJECT  = 3,           // 已拒绝
    BOOKINGREPLYTYPE_OUTTIME = 4,           // 超时
    BOOKINGREPLYTYPE_CANCEL  = 5,           // 取消
    BOOKINGREPLYTYPE_ANCHORABSENT = 6,      // 主播缺席
    BOOKINGREPLYTYPE_FANSABSENT = 7,        // 观众缺席
    BOOKINGREPLYTYPE_COMFIRMED = 8          // 已完成
    
}BookingReplyType;

typedef enum {
    HTTPTALENTSTATUS_UNREPLY = 0,               // 未回复
    HTTPTALENTSTATUS_ACCEPT = 1,                // 已接受
    HTTPTALENTSTATUS_REJECT = 2                 // 拒绝
}HTTPTalentStatus;

typedef enum {
    BOOKTIMESTATUS_BOOKING = 0,             // 可预约
    BOOKTIMESTATUS_INVITEED = 1,            // 本人已邀请
    BOOKTIMESTATUS_COMFIRMED =2             // 本人已确认
}BookTimeStatus;

// 可用的直播间类型
typedef enum {
	USEROOMTYPE_LIMITLESS = 0,                  // 不限
	USEROOMTYPE_PUBLIC = 1,                     // 公开
	USEROOMTYPE_PRIVATE = 2                     // 私密
}UseRoomType;

// 主播类型
typedef enum {
    ANCHORTYPE_LIMITLESS = 0,                  // 不限
    ANCHORTYPE_APPOINTANCHOR = 1,              // 指定主播
    ANCHORTYPE_NOSEEANCHOR = 2                 //没看过直播的主播
}AnchorType;

typedef enum {
    CONTROLTYPE_UNKNOW = 0,               // 未知
    CONTROLTYPE_START = 1,                   // 开始
    CONTROLTYPE_CLOSE = 2                    // 关闭
}ControlType;

#endif
