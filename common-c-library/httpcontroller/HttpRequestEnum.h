/*
 * HttpRequestEnum.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 */

#ifndef REQUESTENUM_H_
#define REQUESTENUM_H_


// 处理结果
typedef enum {
    HTTP_LCC_ERR_SUCCESS = 0,   // 成功
    HTTP_LCC_ERR_FAIL = -10000, // 服务器返回失败结果
    
    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL = -10001,   // 协议解析失败（服务器返回的格式不正确）
    HTTP_LCC_ERR_CONNECTFAIL = -10002,    // 连接服务器失败/断开连接
    HTTP_LCC_ERR_CHECKVERFAIL = -10003,   // 检测版本号失败（可能由于版本过低导致）
    
    HTTP_LCC_ERR_SVRBREAK = -10004,       // 服务器踢下线
    HTTP_LCC_ERR_INVITE_TIMEOUT = -10005, // 邀请超时
    // 服务器返回错误
    HTTP_LCC_ERR_ROOM_FULL = 10023,   // 房间人满
    HTTP_LCC_ERR_NO_CREDIT = 10025,   // 信用点不足
    /* IM公用错误码 */
    HTTP_LCC_ERR_NO_LOGIN = 10002,   // 未登录
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
    USERTYPEA2 = 2          // A2类型
}UserType;

/*主播在线状态*/
typedef enum{
	ONLINE_STATUS_UNKNOWN = -1,
	ONLINE_STATUS_OFFLINE = 0,
	ONLINE_STATUS_LIVE = 1
} OnLineStatus;

typedef enum {
    HTTPROOMTYPE_NOLIVEROOM = 0,                  // 没有直播间
    HTTPROOMTYPE_FREEPUBLICLIVEROOM = 1,          // 免费公开直播间
    HTTPROOMTYPE_COMMONPRIVATELIVEROOM = 2,       // 普通私密直播间
    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM = 3,        // 付费公开直播间
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

/* 表情类型 */
typedef enum {
    EMOTICONACTIONTYPE_STATIC = 0,      // 静态表情
    EMOTICONACTIONTYPE_DYNAMIC = 1      // 动画表情
}EmoticonActionType;

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
    BOOKINGLISTTYPE_WAITFANSHANDLEING = 1,          // 等待观众处理
    BOOKINGLISTTYPE_WAITANCHORHANDLEING = 2,        // 等待主播处理
    BOOKINGLISTTYPE_COMFIRMED = 3,                  // 已确认
    BOOKINGLISTTYPE_HISTORY = 4                     // 历史
    
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
    BOOKTIMESTATUS_COMFIRMED = 2,           // 本人已确认
    BOOKTIMESTATUS_INVITEEDOTHER = 3        // 本人已邀请其它主播
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

typedef enum {
    ANCHORLEVELTYPE_UNKNOW = 0,             // 未知
    ANCHORLEVELTYPE_SILVER = 1,             // 白银
    ANCHORLEVELTYPE_GOLD = 2                // 黄金
}AnchorLevelType;

typedef enum {
    GENDERTYPE_UNKNOW = 0,              // 未知
    GENDERTYPE_MAN = 1,                 // 男
    GENDERTYPE_LADY = 2                 // nv
}GenderType;

typedef enum {
    SHARETYPE_OTHER = 0,              // 其它
    SHARETYPE_FACEBOOK = 1,           // Facebook
    SHARETYPE_TWITTER = 2             // Twitter
}ShareType;

typedef enum {
    SHAREPAGETYPE_UNKNOW = 0,                 // 未知
    SHAREPAGETYPE_ANCHOR = 1,                 // 主播资料页
    SHAREPAGETYPE_FREEROOM = 2                // 免费公开直播间
}SharePageType;

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
}AppStorePayCodeType;

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
    VERIFYCODETYPE_FINDPW = 1                             // “findpw”：找回密码
}VerifyCodeType;


typedef enum {
    REGIONIDTYPE_UNKNOW = 0,
    REGIONIDTYPE_CD = 4,
    REGIONIDTYPE_LD = 5,
    REGIONIDTYPE_AME = 6
}RegionIdType;

#endif
