/*
 * HttpRequestEnum.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 */

#ifndef REQUESTENUM_H_
#define REQUESTENUM_H_

#include <common_item/CommonItemDef.h>

#define HTTP_OTHER_SYNCONFIG_CL                "0"
#define HTTP_OTHER_SYNCONFIG_IDA               "1"
#define HTTP_OTHER_SYNCONFIG_CD                "4"
#define HTTP_OTHER_SYNCONFIG_LA                "5"
#define HTTP_OTHER_SYNCONFIG_AD                "6"
#define HTTP_OTHER_SYNCONFIG_LIVE              "41"
#define HTTP_OTHER_SYNCONFIG_PAYMENT           "99"


#define HTTP_STRING_ERROR_NOLOGIN              "MBCE0003"
#define HTTP_STRING_ERROR_NOMATCHMAIL          "MBCE21001"              // 没有找到匹配的邮箱
#define HTTP_STRING_ERROR_NOENTERCODE          "MBCE21002"              // Please enter the verification code
#define HTTP_STRING_ERROR_CODEERROR            "MBCE21003"             // The verification code is wrong
#define HTTP_STRING_ERROR_CURRENTPASSWORD      "MBCE13001"
#define HTTP_STRING_ERROR_ALLFIELDS            "MBCE13002"
#define HTTP_STRING_ERROR_THEOPERATIONFSILED   "MBCE13003"
#define HTTP_STRING_ERROR_PASSWORDFORMAT       "MBCE13004"
#define HTTP_STRING_ERROR_DATAUPDATE           "MBCE12001"
#define HTTP_STRING_ERROR_NOEXISTKEY           "MBCE12002"
#define HTTP_STRING_ERROR_UNCHANGEVALUE         "MBCE12003"
#define HTTP_STRING_ERROR_UNPASSVALUE           "MBCE12004"
#define HTTP_STRING_ERROR_UPDATEINFODESCLOG     "MBCE12005"
#define HTTP_STRING_ERROR_INSERTINFODESCLOG     "MBCE12006"
#define HTTP_STRING_ERROR_UPDATEINFODESCLOGSETGROUPID             "MBCE12007"
#define HTTP_STRING_ERROR_APPEXISTLOGS             "MBCE22001"       // (APP安装记录已存在。)

#define PROFILE_WEIGHT_BEGINVALUE    5
#define PROFILE_HEIGHT_BEGINVALUE    12
#define PROFILE_ETHNICITY_BEGINVALUE    1

// 处理结果
typedef enum {
    HTTP_LCC_ERR_SUCCESS = 0,   // 成功
    HTTP_LCC_ERR_FAIL = -10000, // 服务器返回失败结果
    
    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL = -10001,   // 协议解析失败（服务器返回的格式不正确）
    HTTP_LCC_ERR_CONNECTFAIL = -10002,    // 连接服务器失败/断开连接
    //HTTP_LCC_ERR_CHECKVERFAIL = -10003,   // 检测版本号失败（可能由于版本过低导致）
    
    //HTTP_LCC_ERR_SVRBREAK = -10004,       // 服务器踢下线
    //HTTP_LCC_ERR_INVITE_TIMEOUT = -10005, // 邀请超时
    // 服务器返回错误
    HTTP_LCC_ERR_ROOM_FULL = 10023,   // 房间人满
    HTTP_LCC_ERR_NO_CREDIT = 10025,   // 信用点不足
    
    /* IM公用错误码 */
    HTTP_LCC_ERR_NO_LOGIN = 10002,   // 未登录 域名的MBCE0003：Need to login. (未登录)
    HTTP_LCC_ERR_SYSTEM = 10003,     // 系统错误
    HTTP_LCC_ERR_TOKEN_EXPIRE = 10004, // Token 过期了
    HTTP_LCC_ERR_NOT_FOUND_ROOM = 10021, // 进入房间失败 找不到房间信息or房间关闭
    HTTP_LCC_ERR_CREDIT_FAIL = 10027, // 远程扣费接口调用失败
    
    HTTP_LCC_ERR_ROOM_CLOSE = 10029,  // 房间已经关闭
    HTTP_LCC_ERR_KICKOFF     = 10037, // 被挤掉线 默认通知内容
    HTTP_LCC_ERR_NO_AUTHORIZED = 10039, // 不能操作 不是对应的userid
    HTTP_LCC_ERR_LIVEROOM_NO_EXIST = 16104, // 直播间不存在
    HTTP_LCC_ERR_LIVEROOM_CLOSED = 16106, // 直播间已关闭
    
    HTTP_LCC_ERR_ANCHORID_INCONSISTENT = 16108, // 主播id与直播场次的主播id不合
    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL = 16110, // 关闭直播场次,数据表操作出错
    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION = 16122, // 主播立即关闭私密直播间, 不满足关闭条件
    /* 其它错误码*/
    HTTP_LCC_ERR_USED_OUTLOG = 10051, // 退出登录 (用户主动退出登录)
    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION = 10036, // 取消立即私密邀请失败 状态不是带确认 /*important*/
    HTTP_LCC_ERR_NOT_FIND_ANCHOR = 10026, // 主播机构信息找不到
    HTTP_LCC_ERR_NOTCAN_REFUND = 10032, // 立即私密退点失败，已经定时扣费不能退点
    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO = 10024, // 找不到price_setting表信息
    
    HTTP_LCC_ERR_ANCHOR_BUSY = 10035, // 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
    HTTP_LCC_ERR_CHOOSE_TIME_ERR = 10042, // 预约时间错误 /*important*/
    HTTP_LCC_ERR_BOOK_EXIST = 10043, // 用户预约时间段已经存在预约 /*important*/
    HTTP_LCC_ERR_BIND_PHONE = 10064, // 手机号码已绑定
    HTTP_LCC_ERR_RETRY_PHONE = 10065, // 请稍后再重试
    
    HTTP_LCC_ERR_MORE_TWENTY_PHONE = 10066, // 60分钟内验证超过20次，请24小时后再试
    HTTP_LCC_ERR_UPDATE_PHONE_FAIL = 10067, // 更新失败
    HTTP_LCC_ERR_ANCHOR_OFFLIVE = 10059,       // 主播不在线，不能操作
    HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING = 10072, // 观众已同意预约
    HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING = 10073, // 预约邀请已超时（当观众拒绝时）
    
    HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING = 10078,   // 预约邀请已超时（当观众同意时）
    
    
    /* 独立的错误码*/
    HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX = 61001,     // Facebook没有邮箱（需要提交邮箱）
    HTTP_LCC_ERR_FACEBOOK_EXIST_QN_MAILBOX = 61002, // Facebook邮箱已在QN注册（需要换邮箱）
    HTTP_LCC_ERR_FACEBOOK_EXIST_LS_MAILBOX = 61003,  // Facebook邮箱已在直播独立站注册（需要输入密码）
    HTTP_LCC_ERR_FACEBOOK_TOKEN_INVALID = 61004,     // Facebook token无效登录失败
    HTTP_LCC_ERR_FACEBOOK_PARAMETER_FAIL = 61005,    // 参数错误
    
    HTTP_LCC_ERR_FACEBOOK_ALREADY_REGISTER = 61006,  // Facebook帐号已在QN注册（提示错误）
    HTTP_LCC_ERR_MAILREGISTER_EXIST_QN_MAILBOX = 62001,          // 邮箱已在QN注册
    HTTP_LCC_ERR_MAILREGISTER_EXIST_LS_MAILBOX = 62002,          // 邮箱已在直播独立站注册
    HTTP_LCC_ERR_MAILREGISTER_LESS_THAN_EIGHTEEN = 62003,        // 年龄小于18岁
    HTTP_LCC_ERR_MAILREGISTER_PARAMETER_FAIL = 62004,            // 参数错误
    
    HTTP_LCC_ERR_MAILLOGIN_PASSWORD_INCORRECT = 63001,           // 密码不正确
    HTTP_LCC_ERR_MAILLOGIN_NOREGISTER_MAIL = 63002,              // 邮箱未注册
    HTTP_LCC_ERR_FINDPASSWORD_NOREGISTER_MAIL = 64001,           // 邮箱未注册
    HTTP_LCC_ERR_FINDPASSWORD_VERIFICATION_WRONG = 4,            // 验证码错误
    
    /* 换站的错误码和域名的错误吗*/
    HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT = 200006,      // 帐号或密码不正确
    HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION = 200003,      // 需要验证码 和 MBCE21002: Please enter the verification code.
    HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG = 200004,      // 验证码不正确 和 MBCE21003:The verification code is wrong
    HTTP_LCC_ERR_TLOGIN_SID_NULL = 200017,                // sid无效
    HTTP_LCC_ERR_TLOGIN_SID_OUTTIME = 200018,             // sid超时
    
    HTTP_LCC_ERR_DEMAIN_NO_FIND_MAIL = 921001,            // MBCE21001：(没有找到匹配的邮箱。)
    HTTP_LCC_ERR_DEMAIN_CURRENT_PASSWORD_WRONG = 913001,  // MBCE13001：Sorry, the current password you entered is wrong!
    HTTP_LCC_ERR_DEMAIN_ALL_FIELDS_WRONG = 913002,       // MBCE13002：Please check if all fields are filled and correct!
    HTTP_LCC_ERR_DEMAIN_THE_OPERATION_FAILED = 913003,       // MBCE13003：The operation failed  /mobile/changepwd.ph
    HTTP_LCC_ERR_DEMAIN_PASSWORD_FORMAT_WRONG = 913004,      // MBCE13004：Password format error
    
    HTTP_LCC_ERR_DEMAIN_NO_FIND_USERID = 911001,         // MBCE11001：(QpidNetWork男士会员ID未找到) /mobile/myprofile.php
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_ERR = 912001,        // MBCE12001：Data update error. ( 数据更新失败)  /mobile/updatepro.php
    HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY = 912002,            // MBCE12002:( 更新失败：Key不存在。)  /mobile/updatepro.php
    HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE = 912003,            // MBCE12003：( 更新失败：Value值没有改变。)
    HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE = 912004,            // MBCE12004：( 更新失败：Value值检测没通过。)
    
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG = 912005,            // MBCE12005：update info_desc_log
    HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG = 912006,            // MBCE12006：insert into info_desc_log
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID = 912007,   // MBCE12007：update info_desc_log set group_id
    HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS = 912008,                       // MBCE22001：(APP安装记录已存在。)
    HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY = 17002,                   // 主播无立即私密邀请权限(17002)

    /* 信件*/
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT = 17213,          // 购买图片使用邮票支付时，邮票不足，但信用点可用(17213)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT = 17214,          // 购买图片使用邮票支付时，邮票不足，且信用点不足(17214)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP = 17215,          // 购买图片使用信用点支付时，信用点不足，但邮票可用(17215)(调用13.7.购买信件附件接口)
    
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT = 17216,          // 购买图片使用信用点支付时，信用点不足，且邮票不足(17216)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME = 17217,                     // 照片已过期(17217)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT = 17218,          // 购买视频使用邮票支付时，邮票不足，但信用点可用(17218)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT = 17219,          // 购买视频使用邮票支付时，邮票不足，且信用点不足(17219)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP = 17220,          // 购买视频使用信用点支付时，信用点不足，但邮票可用(17220)(调用13.7.购买信件附件接口)
    
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT = 17221,          // 购买视频使用信用点支付时，信用点不足，且邮票不足(17221)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME = 17222,                                // 视频已过期(17222)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP = 17208,                         // 信用点或者邮票不足(17208):(调用13.4.信件详情接口, 调用13.5.发送信件接口)
    HTTP_LCC_ERR_EXIST_HANGOUT = 18003,                                        // 当前会员已在hangout直播间（调用8.11.获取当前会员Hangout直播状态接口）
    
    /* SayHi */
    HTTP_LCC_ERR_SAYHI_MAN_NO_PRIV = 17401,                     // 男士无权限(17401)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_LADY_NO_PRIV = 17402,                    // 女士无权限(174012)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI = 17403,         // 主播发过意向信（返回值补充"errdata":{"id":"意向信ID"}）(17403)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI = 17404,          // 男士发过SayHi（返回值补充"errdata":{"id":"sayHi ID"}）(17404)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_ALREADY_CONTACT = 17405,                 // 男士主播已建立联系(17405)(调用14.4.发送SayHi接口)
    
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_NUM_DAY = 17406,               // 男士每日数量限制(17406)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_REPLY = 17407,    // 男士总数量限制-有主播回复(17407)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_UNREPLY = 17408,  // 男士总数量限制-无主播回复(17408)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_NO_EXIST = 17409,                        // sayHi不存在（17409）（调用14.8.获取SayHi回复详情）
    HTTP_LCC_ERR_SAYHI_RESPONSE_NO_EXIST = 17410,               // sayHi回复不存在（17410）（调用14.8.获取SayHi回复详情）
    
    HTTP_LCC_ERR_SAYHI_READ_NO_CREDIT = 17411,                  // sayHi购买阅读信用点或邮票不足（17411）（调用14.8.获取SayHi回复详情）
    
    /* IOS本地 */
    HTTP_LCC_ERR_FORCED_TO_UPDATE = -22334,                      // 强制更新，这里时本地返回的，仅用于ios
    HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE = -22335,                 // 其他设备登录，这里时本地返回的，仅用于ios
    HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN = -22336         // 其他设备登录，这里时本地返回的，仅用于ios
 } HTTP_LCC_ERR_TYPE;

typedef enum LoginType {
    LoginType_Unknow = -1,
    LoginType_Phone = 0,
    LoginType_Email =1,
} LoginType;

typedef enum UserType {
    USERTYPEUNKNOW = 0,     // 未知
    USERTYPEA1 = 1,         // A1类型
    USERTYPEA2 = 2,          // A2类型
    USERTYPE_BEGIN = USERTYPEUNKNOW,
    USERTYPE_END = USERTYPEA2
}UserType;

// int 转换 UserType
inline UserType GetIntToUserType(int value) {
    return USERTYPE_BEGIN <= value && value <= USERTYPE_END ? (UserType)value : USERTYPEUNKNOW;
}

/*主播在线状态*/
typedef enum{
	ONLINE_STATUS_UNKNOWN = -1,
	ONLINE_STATUS_OFFLINE = 0,
	ONLINE_STATUS_LIVE = 1,
    ONLINE_STATUS_BEGIN = ONLINE_STATUS_UNKNOWN,
    ONLINE_STATUS_END = ONLINE_STATUS_LIVE
} OnLineStatus;

// int 转换 UserType
inline OnLineStatus GetIntToOnLineStatus(int value) {
    return ONLINE_STATUS_BEGIN <= value && value <= ONLINE_STATUS_END ? (OnLineStatus)value : ONLINE_STATUS_UNKNOWN;
}

typedef enum {
    HTTPROOMTYPE_NOLIVEROOM = 0,                  // 没有直播间
    HTTPROOMTYPE_FREEPUBLICLIVEROOM = 1,          // 免费公开直播间
    HTTPROOMTYPE_COMMONPRIVATELIVEROOM = 2,       // 普通私密直播间
    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM = 3,        // 付费公开直播间
    HTTPROOMTYPE_LUXURYPRIVATELIVEROOM = 4,       // 豪华私密直播间
    HTTPROOMTYPE_HANGOUTLIVEROOM = 5,             // Hangout直播间
    HTTPROOMTYPE_BEGIN = HTTPROOMTYPE_NOLIVEROOM,
    HTTPROOMTYPE_END = HTTPROOMTYPE_HANGOUTLIVEROOM,
}HttpRoomType;

// int 转换 HttpRoomType
inline HttpRoomType GetIntToHttpRoomType(int value) {
    return HTTPROOMTYPE_BEGIN <= value && value <= HTTPROOMTYPE_END ? (HttpRoomType)value : HTTPROOMTYPE_NOLIVEROOM;
}

/*头像类型*/
typedef enum{
	PHOTOTYPE_UNKNOWN = -1,
	PHOTOTYPE_THUMB = 0,
	PHOTOTYPE_LARGE = 1,
    PHOTOTYPE_BEGIN = PHOTOTYPE_UNKNOWN,
    PHOTOTYPE_END = PHOTOTYPE_LARGE
} PhotoType;

// int 转换 PhotoType
inline PhotoType GetIntToPhotoType(int value) {
    return PHOTOTYPE_BEGIN <= value && value <= PHOTOTYPE_END ? (PhotoType)value : PHOTOTYPE_UNKNOWN;
}

/*性别*/
typedef enum{
	GENDER_UNKNOWN = -1,
	GENDER_MALE = 0,
	GENDER_FEMALE = 1,
    GENDER_BEGIN = GENDER_UNKNOWN,
    GENDER_END = GENDER_FEMALE
} Gender;

// int 转换 Gender
inline Gender GetIntToGender(int value) {
    return GENDER_BEGIN <= value && value <= GENDER_END ? (Gender)value : GENDER_UNKNOWN;
}

/*图片类型*/
typedef enum{
    IMAGETYPE_UNKNOWN = 0,
    IMAGETYPE_USER = 1,
    IMAGETYPE_COVER = 2,
    IMAGETYPE_BEGIN = IMAGETYPE_UNKNOWN,
    IMAGETYPE_END = IMAGETYPE_COVER
} ImageType;

// int 转换 ImageType
inline ImageType GetIntToImageType(int value) {
    return IMAGETYPE_BEGIN <= value && value <= IMAGETYPE_END ? (ImageType)value : IMAGETYPE_UNKNOWN;
}


/*审核状态*/
typedef enum{
    EXAMINE_STATUS_UNKNOWN = 0,
    EXAMINE_STATUS_WAITING = 1,  // 待审核
    EXAMINE_STATUS_PASS    = 2,  // 通过
    EXAMINE_STATUS_REFUSE  = 3,   // 否决
    EXAMINE_STATUS_BEGIN = EXAMINE_STATUS_UNKNOWN,
    EXAMINE_STATUS_END = EXAMINE_STATUS_REFUSE
}ExamineStatus;

// int 转换 ExamineStatus
inline ExamineStatus GetIntToExamineStatus(int value) {
    return EXAMINE_STATUS_BEGIN <= value && value <= EXAMINE_STATUS_END ? (ExamineStatus)value : EXAMINE_STATUS_UNKNOWN;
}

/*礼物类型*/
typedef enum{
    GIFTTYPE_UNKNOWN = 0,
    GIFTTYPE_COMMON = 1,   // 普通礼物
    GIFTTYPE_Heigh = 2,     // 高级礼物（动画）
    GIFTTYPE_BAR = 3,       // 吧台礼物
    GIFTTYPE_CELEBRATE = 4,  // 庆祝礼物
    GIFTTYPE_BEGIN = GIFTTYPE_UNKNOWN,
    GIFTTYPE_END = GIFTTYPE_CELEBRATE
}GiftType;

// int 转换 GiftType
inline GiftType GetIntToGiftType(int value) {
    return GIFTTYPE_BEGIN <= value && value <= GIFTTYPE_END ? (GiftType)value : GIFTTYPE_UNKNOWN;
}

typedef enum {
    EMOTICONTYPE_STANDARD = 0,      // Standard
    EMOTICONTYPE_ADVANCED = 1,       // Advanced
    EMOTICONTYPE_BEGIN = EMOTICONTYPE_STANDARD,
    EMOTICONTYPE_END = EMOTICONTYPE_ADVANCED
}EmoticonType;

// int 转换 EmoticonType
inline EmoticonType GetIntToEmoticonType(int value) {
    return EMOTICONTYPE_BEGIN <= value && value <= EMOTICONTYPE_END ? (EmoticonType)value : EMOTICONTYPE_STANDARD;
}

/* 表情类型 */
typedef enum {
    EMOTICONACTIONTYPE_STATIC = 0,      // 静态表情
    EMOTICONACTIONTYPE_DYNAMIC = 1,      // 动画表情
    EMOTICONACTIONTYPE_BEGIN = EMOTICONACTIONTYPE_STATIC,
    EMOTICONACTIONTYPE_END = EMOTICONACTIONTYPE_DYNAMIC
}EmoticonActionType;

// int 转换 EmoticonActionType
inline EmoticonActionType GetIntToEmoticonActionType(int value) {
    return EMOTICONACTIONTYPE_BEGIN <= value && value <= EMOTICONACTIONTYPE_END ? (EmoticonActionType)value : EMOTICONACTIONTYPE_STATIC;
}

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
    HTTPREPLYTYPE_COMFIRMED = 8,             // 已完成
    HTTPREPLYTYPE_BEGIN = HTTPREPLYTYPE_UNKNOWN,
    HTTPREPLYTYPE_END = HTTPREPLYTYPE_COMFIRMED
}HttpReplyType;

// int 转换 HttpReplyType
inline HttpReplyType GetIntToHttpReplyType(int value) {
    return HTTPREPLYTYPE_BEGIN <= value && value <= HTTPREPLYTYPE_END ? (HttpReplyType)value : HTTPREPLYTYPE_UNKNOWN;
}

// 预约列表类型
typedef enum {
    BOOKINGLISTTYPE_WAITFANSHANDLEING = 1,          // 等待观众处理
    BOOKINGLISTTYPE_WAITANCHORHANDLEING = 2,        // 等待主播处理
    BOOKINGLISTTYPE_COMFIRMED = 3,                  // 已确认
    BOOKINGLISTTYPE_HISTORY = 4,                     // 历史
    BOOKINGLISTTYPE_BEGIN = BOOKINGLISTTYPE_WAITFANSHANDLEING,
    BOOKINGLISTTYPE_END = BOOKINGLISTTYPE_HISTORY
    
} BookingListType;

// int 转换 BookingListType
inline BookingListType GetIntToBookingListType(int value) {
    return BOOKINGLISTTYPE_BEGIN <= value && value <= BOOKINGLISTTYPE_END ? (BookingListType)value : BOOKINGLISTTYPE_WAITFANSHANDLEING;
}

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
    BOOKINGREPLYTYPE_COMFIRMED = 8,          // 已完成
    BOOKINGREPLYTYPE_BEGIN = BOOKINGREPLYTYPE_UNKNOWN,
    BOOKINGREPLYTYPE_END = BOOKINGREPLYTYPE_COMFIRMED
    
}BookingReplyType;

// int 转换 BookingReplyType
inline BookingReplyType GetIntToBookingReplyType(int value) {
    return BOOKINGREPLYTYPE_BEGIN <= value && value <= BOOKINGREPLYTYPE_END ? (BookingReplyType)value : BOOKINGREPLYTYPE_UNKNOWN;
}

typedef enum {
    HTTPTALENTSTATUS_UNREPLY = 0,               // 未回复
    HTTPTALENTSTATUS_ACCEPT = 1,                // 已接受
    HTTPTALENTSTATUS_REJECT = 2,                // 拒绝
    HTTPTALENTSTATUS_OUTTIME = 3,               // 已超时
    HTTPTALENTSTATUS_CANCEL = 4,                // 已取消
    HTTPTALENTSTATUS_BEGIN = HTTPTALENTSTATUS_UNREPLY,
    HTTPTALENTSTATUS_END = HTTPTALENTSTATUS_CANCEL
}HTTPTalentStatus;

// int 转换 HTTPTalentStatus
inline HTTPTalentStatus GetIntToHTTPTalentStatus(int value) {
    return HTTPTALENTSTATUS_BEGIN <= value && value <= HTTPTALENTSTATUS_END ? (HTTPTalentStatus)value : HTTPTALENTSTATUS_UNREPLY;
}

typedef enum {
    BOOKTIMESTATUS_BOOKING = 0,             // 可预约
    BOOKTIMESTATUS_INVITEED = 1,            // 本人已邀请
    BOOKTIMESTATUS_COMFIRMED = 2,           // 本人已确认
    BOOKTIMESTATUS_INVITEEDOTHER = 3,        // 本人已邀请其它主播
    BOOKTIMESTATUS_BEGIN = BOOKTIMESTATUS_BOOKING,
    BOOKTIMESTATUS_END = BOOKTIMESTATUS_INVITEEDOTHER
}BookTimeStatus;

// int 转换 BookTimeStatus
inline BookTimeStatus GetIntToBookTimeStatus(int value) {
    return BOOKTIMESTATUS_BEGIN <= value && value <= BOOKTIMESTATUS_END ? (BookTimeStatus)value : BOOKTIMESTATUS_BOOKING;
}

// 可用的直播间类型
typedef enum {
	USEROOMTYPE_LIMITLESS = 0,                  // 不限
	USEROOMTYPE_PUBLIC = 1,                     // 公开
	USEROOMTYPE_PRIVATE = 2,                     // 私密
    USEROOMTYPE_BEGIN = USEROOMTYPE_LIMITLESS,
    USEROOMTYPE_END = USEROOMTYPE_PRIVATE
}UseRoomType;
// int 转换 UseRoomType
inline UseRoomType GetIntToUseRoomType(int value) {
    return USEROOMTYPE_BEGIN <= value && value <= USEROOMTYPE_END ? (UseRoomType)value : USEROOMTYPE_LIMITLESS;
}

// 主播类型
typedef enum {
    ANCHORTYPE_LIMITLESS = 0,                  // 不限
    ANCHORTYPE_APPOINTANCHOR = 1,              // 指定主播
    ANCHORTYPE_NOSEEANCHOR = 2,                 //没看过直播的主播
    ANCHORTYPE_BEGIN = ANCHORTYPE_LIMITLESS,
    ANCHORTYPE_END = ANCHORTYPE_NOSEEANCHOR
}AnchorType;

// int 转换 AnchorType
inline AnchorType GetIntToAnchorType(int value) {
    return ANCHORTYPE_BEGIN <= value && value <= ANCHORTYPE_END ? (AnchorType)value : ANCHORTYPE_LIMITLESS;
}

typedef enum {
    CONTROLTYPE_UNKNOW = 0,               // 未知
    CONTROLTYPE_START = 1,                   // 开始
    CONTROLTYPE_CLOSE = 2,                    // 关闭
    CONTROLTYPE_BEGIN = CONTROLTYPE_UNKNOW,
    CONTROLTYPE_END = CONTROLTYPE_CLOSE
}ControlType;

// int 转换 ControlType
inline ControlType GetIntToControlType(int value) {
    return CONTROLTYPE_BEGIN <= value && value <= CONTROLTYPE_END ? (ControlType)value : CONTROLTYPE_UNKNOW;
}

typedef enum {
    ANCHORLEVELTYPE_UNKNOW = 0,             // 未知
    ANCHORLEVELTYPE_SILVER = 1,             // 白银
    ANCHORLEVELTYPE_GOLD = 2,                // 黄金
    ANCHORLEVELTYPE_BEGIN = ANCHORLEVELTYPE_UNKNOW,
    ANCHORLEVELTYPE_END = ANCHORLEVELTYPE_GOLD
}AnchorLevelType;

// int 转换 AnchorLevelType
inline AnchorLevelType GetIntToAnchorLevelType(int value) {
    return ANCHORLEVELTYPE_BEGIN <= value && value <= ANCHORLEVELTYPE_END ? (AnchorLevelType)value : ANCHORLEVELTYPE_UNKNOW;
}

typedef enum {
    GENDERTYPE_UNKNOW = 0,              // 未知
    GENDERTYPE_MAN = 1,                 // 男
    GENDERTYPE_LADY = 2,                 // nv
    GENDERTYPE_BEGIN = GENDERTYPE_UNKNOW,
    GENDERTYPE_END = GENDERTYPE_LADY
}GenderType;

// int 转换 GenderType
inline GenderType GetIntToGenderType(int value) {
    return GENDERTYPE_BEGIN <= value && value <= GENDERTYPE_END ? (GenderType)value : GENDERTYPE_UNKNOW;
}

typedef enum {
    SHARETYPE_OTHER = 0,              // 其它
    SHARETYPE_FACEBOOK = 1,           // Facebook
    SHARETYPE_TWITTER = 2,             // Twitter
    SHARETYPE_BEGIN = SHARETYPE_OTHER,
    SHARETYPE_END = SHARETYPE_TWITTER
}ShareType;

// int 转换 ShareType
inline ShareType GetIntToShareType(int value) {
    return SHARETYPE_BEGIN <= value && value <= SHARETYPE_END ? (ShareType)value : SHARETYPE_OTHER;
}

typedef enum {
    SHAREPAGETYPE_UNKNOW = 0,                 // 未知
    SHAREPAGETYPE_ANCHOR = 1,                 // 主播资料页
    SHAREPAGETYPE_FREEROOM = 2,                // 免费公开直播间
    SHAREPAGETYPE_BEGIN = SHAREPAGETYPE_UNKNOW,
    SHAREPAGETYPE_END = SHAREPAGETYPE_FREEROOM
}SharePageType;

// int 转换 SharePageType
inline SharePageType GetIntToSharePageType(int value) {
    return SHAREPAGETYPE_BEGIN <= value && value <= SHAREPAGETYPE_END ? (SharePageType)value : SHAREPAGETYPE_UNKNOW;
}

typedef enum {
    INTERESTTYPE_UNKNOW = 0,                        // 0:未知
    INTERESTTYPE_GOINGTORESTAURANTS = 1,            // 1:Going to Restaurants
    INTERESTTYPE_COOKING = 2,                       // 2:Cooking
    INTERESTTYPE_TRAVAEL = 3,                       // 3:Travel
    INTERESTTYPE_HIKING = 4,                        // 4:Hiking/ourdoor activities
    INTERESTTYPE_DANCING = 5,                       // 5:Dancing
    INTERESTTYPE_WATCHINGMOVIES = 6,                // 6:Watching movies
    INTERESTTYPE_SHOPPING = 7,                      // 7:Shopping
    INTERESTTYPE_HAVINGPETS = 8,                    // 8:Having pets
    INTERESTTYPE_READING = 9,                       // 9:Reading
    INTERESTTYPE_SPORTS = 10,                       // 10:Sports/exercise
    INTERESTTYPE_PLAYINGCARDS = 11,                 // 11:Playing cards/chess
    INTERESTTYPE_MUSIC = 12,                        // 12:Music/play instruments
    INTERESTTYPE_NOINTEREST,                        // 没有兴趣
    INTERESTTYPE_BEGIN = INTERESTTYPE_UNKNOW,    // 有效范围起始值
    INTERESTTYPE_END = INTERESTTYPE_NOINTEREST      // 有效范围结束值
}InterestType;

// int 转换 CLIENT_TYPE
inline InterestType GetInterestType(int value) {
    return INTERESTTYPE_BEGIN < value && value < INTERESTTYPE_END ? (InterestType)value : INTERESTTYPE_NOINTEREST;
}

// 获取界面的类型
typedef enum {
    PROMOANCHORTYPE_UNKNOW = 0,                             // 未知
    PROMOANCHORTYPE_LIVEROOM = 1,                           // 直播间
    PROMOANCHORTYPE_ANCHORPERSONAL = 2,                     // 主播个人页
    PROMOANCHORTYPE_BEGIN = PROMOANCHORTYPE_UNKNOW,         // 有效范围起始值
    PROMOANCHORTYPE_END = PROMOANCHORTYPE_ANCHORPERSONAL    // 有效范围结束值
}PromoAnchorType;

// int 转换 PromoAnchorType
inline PromoAnchorType GetPromoAnchorType(int value) {
    return PROMOANCHORTYPE_BEGIN < value && value <= PROMOANCHORTYPE_END ? (PromoAnchorType)value : PROMOANCHORTYPE_UNKNOW;
}

// AppStore支付完成返回的状态code
typedef enum {
    APPSTOREPAYTYPE_UNKNOW = 0,                             // 未知
    APPSTOREPAYTYPE_PAYSUCCES = 1,                           // 支付成功
    APPSTOREPAYTYPE_PAYFAIL = 2,                     // 支付失败
    APPSTOREPAYTYPE_PAYRECOVERY = 3,                     // 恢复交易(仅非消息及自动续费商品)
    APPSTOREPAYTYPE_NOIMMEDIATELYPAY = 4,                     // 无法立即支付
    APPSTOREPAYTYPE_BEGIN = APPSTOREPAYTYPE_UNKNOW,
    APPSTOREPAYTYPE_END = APPSTOREPAYTYPE_NOIMMEDIATELYPAY
}AppStorePayCodeType;

// int 转换 AppStorePayCodeType
inline AppStorePayCodeType GetIntToAppStorePayCodeType(int value) {
    return APPSTOREPAYTYPE_BEGIN <= value && value <= APPSTOREPAYTYPE_END ? (AppStorePayCodeType)value : APPSTOREPAYTYPE_UNKNOW;
}

// 昵称审核状态
typedef enum {
    NICKNAMEVERIFYSTATUS_FINISH = 0,                             // 审核完成
    NICKNAMEVERIFYSTATUS_HANDLDING = 1                           // 审核中
}NickNameVerifyStatus;

// int 转换 PromoAnchorType
inline NickNameVerifyStatus GetNickNameVerifyStatus(int value) {
    return NICKNAMEVERIFYSTATUS_FINISH <= value && value <= NICKNAMEVERIFYSTATUS_HANDLDING ? (NickNameVerifyStatus)value : NICKNAMEVERIFYSTATUS_HANDLDING;
}

// 头像审核状态
typedef enum {
    PHOTOVERIFYSTATUS_NOPHOTO_AND_FINISH = 0,                             // 没有头像及审核成功
    PHOTOVERIFYSTATUS_HANDLDING = 1,                                      // 审核中
    PHOTOVERIFYSTATUS_NOPASS = 2,                                         // 不合格
}PhotoVerifyStatus;

// int 转换 PromoAnchorType
inline PhotoVerifyStatus GetPhotoVerifyStatus(int value) {
    return PHOTOVERIFYSTATUS_NOPHOTO_AND_FINISH <= value && value <= PHOTOVERIFYSTATUS_NOPASS ? (PhotoVerifyStatus)value : PHOTOVERIFYSTATUS_HANDLDING;
}

// 验证码种类
typedef enum {
    VERIFYCODETYPE_LOGIN = 0,                             // “login”：登录
    VERIFYCODETYPE_FINDPW = 1,                             // “findpw”：找回密码
    VERIFYCODETYPE_BEGIN = VERIFYCODETYPE_LOGIN,
    VERIFYCODETYPE_END = VERIFYCODETYPE_FINDPW
}VerifyCodeType;

// int 转换 VerifyCodeType
inline VerifyCodeType GetIntToVerifyCodeType(int value) {
    return VERIFYCODETYPE_BEGIN <= value && value <= VERIFYCODETYPE_END ? (VerifyCodeType)value : VERIFYCODETYPE_LOGIN;
}


typedef enum {
    REGIONIDTYPE_UNKNOW = 0,
    REGIONIDTYPE_CD = 4,
    REGIONIDTYPE_LD = 5,
    REGIONIDTYPE_AME = 6,
    REGIONIDTYPE_BEGIN = REGIONIDTYPE_CD,
    REGIONIDTYPE_END = REGIONIDTYPE_AME
}RegionIdType;

// int 转换 RegionIdType
inline RegionIdType GetIntToRegionIdType(int value) {
    return REGIONIDTYPE_BEGIN <= value && value <= REGIONIDTYPE_END ? (RegionIdType)value : REGIONIDTYPE_UNKNOW;
}

typedef enum {
    HANGOUTANCHORLISTTYPE_UNKNOW = 0,           // 未知
    HANGOUTANCHORLISTTYPE_FOLLOW = 1,           // 已关注
    HANGOUTANCHORLISTTYPE_WATCHED = 2,          // Watched(看过的)
    HANGOUTANCHORLISTTYPE_FRIEND = 3,           // 主播好友
    HANGOUTANCHORLISTTYPE_ONLINEANCHOR = 4,      // 在线主播
    HANGOUTANCHORLISTTYPE_BEGIN = HANGOUTANCHORLISTTYPE_UNKNOW,
    HANGOUTANCHORLISTTYPE_END = HANGOUTANCHORLISTTYPE_ONLINEANCHOR
    
}HangoutAnchorListType;

// int 转换 HangoutAnchorListType
inline HangoutAnchorListType GetIntToHangoutAnchorListType(int value) {
    return HANGOUTANCHORLISTTYPE_BEGIN <= value && value <= HANGOUTANCHORLISTTYPE_END ? (HangoutAnchorListType)value : HANGOUTANCHORLISTTYPE_UNKNOW;
}

typedef enum {
    HANGOUTINVITESTATUS_UNKNOW = 0,             // 未知
    HANGOUTINVITESTATUS_PENDING = 1,            // 待确定
    HANGOUTINVITESTATUS_ACCEPT = 2,             // 已接受
    HANGOUTINVITESTATUS_REJECT = 3,            // 已拒绝
    HANGOUTINVITESTATUS_OUTTIME = 4,            // 已超时
    HANGOUTINVITESTATUS_CANCLE = 5,             // 观众取消邀
    HANGOUTINVITESTATUS_NOCREDIT = 6,           // 余额不足
    HANGOUTINVITESTATUS_BUSY = 7,               // 主播繁忙
    HANGOUTINVITESTATUS_BEGIN = HANGOUTINVITESTATUS_UNKNOW,
    HANGOUTINVITESTATUS_END = HANGOUTINVITESTATUS_BUSY
    
}HangoutInviteStatus;

// int 转换 HangoutInviteStatus
inline HangoutInviteStatus GetIntToHangoutInviteStatus(int value) {
    return HANGOUTINVITESTATUS_BEGIN <= value && value <= HANGOUTINVITESTATUS_END ? (HangoutInviteStatus)value : HANGOUTINVITESTATUS_UNKNOW;
}

// 节目列表类型
typedef enum {
    PROGRAMLISTTYPE_UNKNOW = 0,             // 未知
    PROGRAMLISTTYPE_STARTTIEM = 1,          // 按节目开始时间排序
    PROGRAMLISTTYPE_VERIFYTIEM = 2,         // 按节目审核时间排序
    PROGRAMLISTTYPE_FEATURE = 3,           // 按广告排序
    PROGRAMLISTTYPE_BUYTICKET = 4,          // 已购票列表
    PROGRAMLISTTYPE_HISTORY = 5,             // 购票历史列表
    PROGRAMLISTTYPE_BEGIN = PROGRAMLISTTYPE_UNKNOW,
    PROGRAMLISTTYPE_END = PROGRAMLISTTYPE_HISTORY
    
}ProgramListType;

// int 转换 ProgramListType
inline ProgramListType GetIntToProgramListType(int value) {
    return PROGRAMLISTTYPE_BEGIN <= value && value <= PROGRAMLISTTYPE_END ? (ProgramListType)value : PROGRAMLISTTYPE_UNKNOW;
}

typedef enum {
    PROGRAMSTATUS_UNKNOW = -1,              // 未知
    PROGRAMSTATUS_UNVERIFY = 0,             // 未审核
    PROGRAMSTATUS_VERIFYPASS = 1,           // 审核通过
    PROGRAMSTATUS_VERIFYREJECT = 2,         // 审核被拒
    PROGRAMSTATUS_PROGRAMEND = 3,           // 节目正常结束
    PROGRAMSTATUS_OUTTIME = 4,               // 节目已超时
    PROGRAMSTATUS_PROGRAMCALCEL = 5,        // 节目已取消
    PROGRAMSTATUS_BEGIN = PROGRAMSTATUS_UNKNOW,
    PROGRAMSTATUS_END = PROGRAMSTATUS_PROGRAMCALCEL

}ProgramStatus;

// int 转换 ProgramStatus
inline ProgramStatus GetIntToProgramStatus(int value) {
    return PROGRAMSTATUS_BEGIN <= value && value <= PROGRAMSTATUS_END ? (ProgramStatus)value : PROGRAMSTATUS_UNKNOW;
}

// 节目推荐列表类型
typedef enum {
    SHOWRECOMMENDLISTTYPE_UNKNOW = 0,                    // 未知
    SHOWRECOMMENDLISTTYPE_ENDRECOMMEND = 1,              // 直播结束推荐<包括指定主播及其它主播
    SHOWRECOMMENDLISTTYPE_PERSONALRECOMMEND = 2,         // 主播个人节目推荐<仅包括指定主播>
    SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND =  3,           // 不包括指定主播
    SHOWRECOMMENDLISTTYPE_BEGIN = SHOWRECOMMENDLISTTYPE_UNKNOW,
    SHOWRECOMMENDLISTTYPE_END = SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND

}ShowRecommendListType;

// int 转换 ShowRecommendListType
inline ShowRecommendListType GetIntToShowRecommendListType(int value) {
    return SHOWRECOMMENDLISTTYPE_BEGIN <= value && value <= SHOWRECOMMENDLISTTYPE_END ? (ShowRecommendListType)value : SHOWRECOMMENDLISTTYPE_UNKNOW;
}

// 购票状态
typedef enum {
    PROGRAMTICKETSTATUS_UNKNOW = -1,    // 未知
    PROGRAMTICKETSTATUS_NOBUY = 0,      // 未购票
    PROGRAMTICKETSTATUS_BUYED = 1,      // 已购票
    PROGRAMTICKETSTATUS_OUT = 2,        // 已退票
    PROGRAMTICKETSTATUS_BEGIN = PROGRAMTICKETSTATUS_UNKNOW,
    PROGRAMTICKETSTATUS_END = PROGRAMTICKETSTATUS_OUT

}ProgramTicketStatus;

// int 转换 ProgramTicketStatus
inline ProgramTicketStatus GetIntToProgramTicketStatus(int value) {
    return PROGRAMTICKETSTATUS_BEGIN <= value && value <= PROGRAMTICKETSTATUS_END ? (ProgramTicketStatus)value : PROGRAMTICKETSTATUS_UNKNOW;
}

// 私信消息排序类型
typedef enum {
    PRIVATEMSGORDERTYPE_UNKNOW = -1,    // 未知
    PRIVATEMSGORDERTYPE_OLD = 0,      // 获取更多旧消息
    PRIVATEMSGORDERTYPE_NEW = 1,      // 获取所有最新消息
    PRIVATEMSGORDERTYPE_BEGIN = PRIVATEMSGORDERTYPE_UNKNOW,
    PRIVATEMSGORDERTYPE_END = PRIVATEMSGORDERTYPE_NEW
    
}PrivateMsgOrderType;

// int 转换 ProgramTicketStatus
inline PrivateMsgOrderType GetIntToPrivateMsgOrderType(int value) {
    return PRIVATEMSGORDERTYPE_BEGIN <= value && value <= PRIVATEMSGORDERTYPE_END ? (PrivateMsgOrderType)value : PRIVATEMSGORDERTYPE_UNKNOW;
}

// 私信消息排序类型
typedef enum {
    PRIVATEMSGTYPE_UNKNOW = 0,    // 未知
    PRIVATEMSGTYPE_TEXT = 1,      // 私信文本
    PRIVATEMSGTYPE_Dynamic = 2,   // 动态
    PRIVATEMSGTYPE_BEGIN = PRIVATEMSGTYPE_UNKNOW,
    PRIVATEMSGTYPE_END = PRIVATEMSGTYPE_Dynamic
    
}PrivateMsgType;

// int 转换 ProgramTicketStatus
inline PrivateMsgType GetIntToPrivateMsgType(int value) {
    return PRIVATEMSGTYPE_BEGIN <= value && value <= PRIVATEMSGTYPE_END ? (PrivateMsgType)value : PRIVATEMSGTYPE_UNKNOW;
}

// 站点类型定义
typedef enum {
    HTTP_OTHER_SITE_ALL = 0,        // All
    HTTP_OTHER_SITE_CL = 1,        // ChnLove
    HTTP_OTHER_SITE_IDA = 2,        // iDateAsia
    HTTP_OTHER_SITE_CD = 4,        // CharmingDate
    HTTP_OTHER_SITE_LA = 8,        // LatamDate
    HTTP_OTHER_SITE_AD = 16,        // AsiaDear
    HTTP_OTHER_SITE_LIVE = 32,   // CharmLive
    HTTP_OTHER_SITE_PAYMENT = 64, // 支付中心
    HTTP_OTHER_SITE_UNKNOW = HTTP_OTHER_SITE_ALL,    // Unknow
} HTTP_OTHER_SITE_TYPE;

// 体重转code/code转体重
inline int WeightToCode(int value) {
    return value > 0 ? value - PROFILE_WEIGHT_BEGINVALUE : value;
}
inline int CodeToWeight(int code) {
    return code > 0 ? code + PROFILE_WEIGHT_BEGINVALUE : code;
}
// 身高转code/code转身高
inline int HeightToCode(int value) {
    return value > 0 ? value - PROFILE_HEIGHT_BEGINVALUE : value;
}
inline int CodeToHeight(int code) {
    return code > 0 ? code + PROFILE_HEIGHT_BEGINVALUE : code;
}
// 人种转code/code转人种
inline int EthnicityToCode(int value) {
    return value > 0 ? value - PROFILE_ETHNICITY_BEGINVALUE : value;
}
inline int CodeToEthnicity(int code) {
    return code > 0 ? code + PROFILE_ETHNICITY_BEGINVALUE : code;
}


// 登录Sid类型
typedef enum {
    LSLOGINSIDTYPE_UNKNOW = 0,    // 未知
    LSLOGINSIDTYPE_QNLOGIN = 1,       // QN登录成功返回的
    LSLOGINSIDTYPE_LSLOGIN = 2        // 直播登录成功返回的
}LSLoginSidType;

// 验证码类型
typedef enum {
    LSVALIDATECODETYPE_UNKNOW = 0,    // 未知
    LSVALIDATECODETYPE_LOGIN = 1,       // login：登录获取
    LSVALIDATECODETYPE_FINDPW = 2        // 找回密码获取
}LSValidateCodeType;

// 购买产品类型
typedef enum {
    LSORDERTYPE_CREDIT = 0,    // 信用点
    LSORDERTYPE_MONTHFEE = 5,  // 月费服务
    LSORDERTYPE_STAMP = 7,      // 邮票
    LSORDERTYPE_BEGIN = LSORDERTYPE_CREDIT,
    LSORDERTYPE_END = LSORDERTYPE_STAMP
}LSOrderType;

// 聊天邀请风控类型
typedef enum {
    LSHTTP_LIVECHATINVITE_RISK_NOLIMIT     = 0,    // 不作任何限制
    LSHTTP_LIVECHATINVITE_RISK_LIMITSEND   = 1,    // 限制发送信息
    LSHTTP_LIVECHATINVITE_RISK_LIMITREV    = 2,    // 限制接受邀请
    LSHTTP_LIVECHATINVITE_RISK_LIMITALL    = 3,    // 收发全部限制
    LSHTTP_LIVECHATINVITE_RISK_BEGIN       = LSHTTP_LIVECHATINVITE_RISK_NOLIMIT,    // 有效范围起始值
    LSHTTP_LIVECHATINVITE_RISK_END         = LSHTTP_LIVECHATINVITE_RISK_LIMITALL,    // 有效范围结束值
} LSHttpLiveChatInviteRiskType;
// int 转换 LIVECHATINVITE_RISK_TYPE
inline LSHttpLiveChatInviteRiskType GetLSHttpliveChatInviteRiskType(int value) {
    return LSHTTP_LIVECHATINVITE_RISK_BEGIN <= value && value <= LSHTTP_LIVECHATINVITE_RISK_END ? (LSHttpLiveChatInviteRiskType)value : LSHTTP_LIVECHATINVITE_RISK_NOLIMIT;
}

// 查询信件类型
typedef enum {
    LSLETTERTAG_UNKNOW = 0,    // 信用点
    LSLETTERTAG_ALL = 1,
    LSLETTERTAG_UNREAD = 2,
    LSLETTERTAG_UNREPLIED = 3,
    LSLETTERTAG_REPLIED = 4,
    LSLETTERTAG_FOLLOW = 5,
    LSLETTERTAG_BEGIN = LSLETTERTAG_UNKNOW,
    LSLETTERTAG_END = LSLETTERTAG_FOLLOW,
}LSLetterTag;

// emf类型
typedef enum {
    LSEMFTYPE_UNKNOW = 0,
    LSEMFTYPE_INBOX = 1,
    LSEMFTYPE_OUTBOX = 2,
    LSEMFTYPE_BEGIN = LSEMFTYPE_UNKNOW,
    LSEMFTYPE_END = LSEMFTYPE_OUTBOX,
}LSEMFType;

// 付费类型
typedef enum {
    LSPAYFEESTATUS_UNPAID = 0,
    LSPAYFEESTATUS_PAID = 1,
    LSPAYFEESTATUS_OVERTIME = 2,
    LSPAYFEESTATUS_BEGIN = LSPAYFEESTATUS_UNPAID,
    LSPAYFEESTATUS_END = LSPAYFEESTATUS_OVERTIME,
}LSPayFeeStatus;

// int 转换 LIVECHATINVITE_RISK_TYPE
inline LSPayFeeStatus GetLSPayFeeStatus(int value) {
    return LSPAYFEESTATUS_BEGIN <= value && value <= LSPAYFEESTATUS_END ? (LSPayFeeStatus)value : LSPAYFEESTATUS_UNPAID;
}

// 付费类型
typedef enum {
    LSLETTERCOMSUMETYPE_UNKNOW = 0,
    LSLETTERCOMSUMETYPE_CREDIT = 1,
    LSLETTERCOMSUMETYPE_STAMP = 2,
    LSLETTERCOMSUMETYPE_BEGIN = LSLETTERCOMSUMETYPE_UNKNOW,
    LSLETTERCOMSUMETYPE_END = LSLETTERCOMSUMETYPE_STAMP,
}LSLetterComsumeType;

// 是否有权限发送信件
typedef enum {
    LSSENDIMGRISKTYPE_NORMAL = 0,
    LSSENDIMGRISKTYPE_ONLYFREE = 1,
    LSSENDIMGRISKTYPE_ONLYPAYMENT = 2,
    LSSENDIMGRISKTYPE_NOSEND = 3,
    LSSENDIMGRISKTYPE_BEGIN = LSSENDIMGRISKTYPE_NORMAL,
    LSSENDIMGRISKTYPE_END = LSSENDIMGRISKTYPE_NOSEND,
}LSSendImgRiskType;

// int 转换 LIVECHATINVITE_RISK_TYPE
inline LSSendImgRiskType GetLSSendImgRiskType(int value) {
    return LSSENDIMGRISKTYPE_BEGIN <= value && value <= LSSENDIMGRISKTYPE_END ? (LSSendImgRiskType)value : LSSENDIMGRISKTYPE_NORMAL;
}

// SayHi列表类型
typedef enum {
    LSSAYHILISTTYPE_UNKOWN = 0,
    LSSAYHILISTTYPE_UNREAD = 1,
    LSSAYHILISTTYPE_LATEST = 2,
    LSSAYHILISTTYPE_BEGIN = LSSAYHILISTTYPE_UNKOWN,
    LSSAYHILISTTYPE_END = LSSAYHILISTTYPE_LATEST,
}LSSayHiListType;

// int 转换 LIVECHATINVITE_RISK_TYPE
inline int GetLSSayHiListTypeWithInt(LSSayHiListType type) {
    int value = 1;
    switch (type) {
        case LSSAYHILISTTYPE_UNREAD:
            value = 1;
            break;
        case LSSAYHILISTTYPE_LATEST:
            value = 2;
            break;
        default:
            break;
    }
    return value;
}

// SayHi详情类型
typedef enum {
    LSSAYHIDETAILTYPE_UNKOWN = 0,
    LSSAYHIDETAILTYPE_EARLIEST = 1,
    LSSAYHIDETAILTYPE_LATEST = 2,
    LSSAYHIDETAILTYPE_UNREAD = 3,
    LSSAYHIDETAILTYPE_BEGIN = LSSAYHIDETAILTYPE_UNKOWN,
    LSSAYHIDETAILTYPE_END = LSSAYHIDETAILTYPE_UNREAD,
}LSSayHiDetailType;

// int 转换 LIVECHATINVITE_RISK_TYPE
inline int GetLSSayHiDetailTypeWithInt(LSSayHiDetailType type) {
    int value = 1;
    switch (type) {
        case LSSAYHIDETAILTYPE_EARLIEST:
            value = 1;
            break;
        case LSSAYHIDETAILTYPE_LATEST:
            value = 2;
            break;
        case LSSAYHIDETAILTYPE_UNREAD:
            value = 3;
            break;
        default:
            break;
    }
    return value;
}

#endif

