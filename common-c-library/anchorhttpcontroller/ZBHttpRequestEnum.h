/*
 * ZBHttpRequestEnum.h
 *
 *  Created on: 2018-2-26
 *      Author: Alex.shum
 */

#ifndef ZBHTTPREQUESTENUM_H_
#define ZBHTTPREQUESTENUM_H_


// 处理结果
typedef enum {
    ZBHTTP_LCC_ERR_SUCCESS = 0,   // 成功
    ZBHTTP_LCC_ERR_FAIL = -10000, // 服务器返回失败结果
    
    // 客户端定义的错误
    ZBHTTP_LCC_ERR_PROTOCOLFAIL = -10001,   // 协议解析失败（服务器返回的格式不正确）
    ZBHTTP_LCC_ERR_CONNECTFAIL = -10002,    // 连接服务器失败/断开连接
    ZBHTTP_LCC_ERR_CHECKVERFAIL = -10003,   // 检测版本号失败（可能由于版本过低导致）
    
    ZBHTTP_LCC_ERR_SVRBREAK = -10004,       // 服务器踢下线
    ZBHTTP_LCC_ERR_INVITE_TIMEOUT = -10005, // 邀请超时
    // 服务器返回错误
    ZBHTTP_LCC_ERR_INSUFFICIENT_PARAM = 10001,   // Insufficient parameters or parameter error (未传action参数或action参数不正确)
    ZBHTTP_LCC_ERR_NO_LOGIN = 10002,   // Need to login. (未登录)
    ZBHTTP_LCC_ERR_SYSTEM = 10003,       // Error. (系统错误)
    ZBHTTP_LCC_ERR_TOKEN_EXPIRE = 10004, // Token expire, need to login again.(Token 过期了)
    ZBHTTP_LCC_ERR_NOT_FOUND_ROOM = 10021, // room is not found. (进入房间失败 找不到房间信息or房间关闭)
    ZBHTTP_LCC_ERR_CREDIT_FAIL = 10027, // 远程扣费接口调用失败.（扣费信用点失败）
    ZBHTTP_LCC_ERR_ROOM_CLOSE = 10029,  // the room is closed. ( 房间已经关闭 /*important*/)
    ZBHTTP_LCC_ERR_KICKOFF     = 10037, // Sorry, you have been kickoff. (被挤掉线 默认通知内容)
    ZBHTTP_LCC_ERR_NO_AUTHORIZED = 10039, // you are not authorized.(不能操作 不是对应的userid)
    ZBHTTP_LCC_ERR_LIVEROOM_NO_EXIST = 16104, // 直播间不存在
    ZBHTTP_LCC_ERR_LIVEROOM_CLOSED = 16106, // 直播间已关闭
    ZBHTTP_LCC_ERR_ANCHORID_INCONSISTENT = 16108, // 主播id与直播场次的主播id不合
    ZBHTTP_LCC_ERR_CLOSELIVE_DATA_FAIL = 16110, // 关闭直播场次,数据表操作出错
    ZBHTTP_LCC_ERR_CLOSELIVE_LACK_CODITION = 16122, // 主播立即关闭私密直播间, 不满足关闭条件
    ZBHTTP_ERR_IDENTITY_FAILURE = 16173,        // 身份失效
    ZBHTTP_LCC_ERR_VERIFICATIONCODE        = 1,     // 验证码错误
    ZBHTTP_LCC_ERR_CANCEL_FAIL_INVITE = 16205, // 取消失败，观众已接受
    
//    /* 其它错误码*/
//    HTTP_LCC_ERR_USED_OUTLOG = 10051, // 退出登录 (用户主动退出登录)
//    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION = 10036, // 取消立即私密邀请失败 状态不是带确认 /*important*/
//    HTTP_LCC_ERR_NOT_FIND_ANCHOR = 10026, // 主播机构信息找不到
//    HTTP_LCC_ERR_NOTCAN_REFUND = 10032, // 立即私密退点失败，已经定时扣费不能退点
//    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO = 10024, // 找不到price_setting表信息
//    HTTP_LCC_ERR_ANCHOR_BUSY = 10035, // 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
//    HTTP_LCC_ERR_CHOOSE_TIME_ERR = 10042, // 预约时间错误 /*important*/
//    HTTP_LCC_ERR_BOOK_EXIST = 10043, // 用户预约时间段已经存在预约 /*important*/
//    HTTP_LCC_ERR_BIND_PHONE = 10064, // 手机号码已绑定
//    HTTP_LCC_ERR_RETRY_PHONE = 10065, // 请稍后再重试
//    HTTP_LCC_ERR_MORE_TWENTY_PHONE = 10066, // 60分钟内验证超过20次，请24小时后再试
//    HTTP_LCC_ERR_UPDATE_PHONE_FAIL = 10067, // 更新失败
//    HTTP_LCC_ERR_ANCHOR_OFFLIVE = 10059,       // 主播不在线，不能操作
//    HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING = 10072, // 观众已同意预约
//    HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING = 10073, // 预约邀请已超时（当观众拒绝时）
//    HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING = 10078,   // 预约邀请已超时（当观众同意时）
//    HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX = 61001,     // Facebook没有邮箱（需要提交邮箱）
//    HTTP_LCC_ERR_FACEBOOK_EXIST_QN_MAILBOX = 61002, // Facebook邮箱已在QN注册（需要换邮箱）
//    HTTP_LCC_ERR_FACEBOOK_EXIST_LS_MAILBOX = 61003,  // Facebook邮箱已在直播独立站注册（需要输入密码）
//    HTTP_LCC_ERR_FACEBOOK_TOKEN_INVALID = 61004,     // Facebook token无效登录失败
//    HTTP_LCC_ERR_FACEBOOK_PARAMETER_FAIL = 61005,    // 参数错误
//    HTTP_LCC_ERR_FACEBOOK_ALREADY_REGISTER = 61006,  // Facebook帐号已在QN注册（提示错误）
//    HTTP_LCC_ERR_MAILREGISTER_EXIST_QN_MAILBOX = 62001,          // 邮箱已在QN注册
//    HTTP_LCC_ERR_MAILREGISTER_EXIST_LS_MAILBOX = 62002,          // 邮箱已在直播独立站注册
//    HTTP_LCC_ERR_MAILREGISTER_LESS_THAN_EIGHTEEN = 62003,        // 年龄小于18岁
//    HTTP_LCC_ERR_MAILREGISTER_PARAMETER_FAIL = 62004,            // 参数错误
//    HTTP_LCC_ERR_MAILLOGIN_PASSWORD_INCORRECT = 63001,           // 密码不正确
//    HTTP_LCC_ERR_MAILLOGIN_NOREGISTER_MAIL = 63002,              // 邮箱未注册
//    HTTP_LCC_ERR_FINDPASSWORD_NOREGISTER_MAIL = 64001,           // 邮箱未注册
//    HTTP_LCC_ERR_FINDPASSWORD_VERIFICATION_WRONG = 4,            // 验证码错误
    ZBHTTP_LCC_ERR_FORCED_TO_UPDATE = -22334,                      // 强制更新，这里时本地返回的，仅用于ios
    ZBHTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE = -22335,                 // 其他设备登录，这里时本地返回的，仅用于ios
//    HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN = -22336         // 其他设备登录，这里时本地返回的，仅用于ios
 } ZBHTTP_LCC_ERR_TYPE;


typedef enum {
    ZBHTTPROOMTYPE_NOLIVEROOM = 0,                  // 没有直播间
    ZBHTTPROOMTYPE_FREEPUBLICLIVEROOM = 1,          // 免费公开直播间
    ZBHTTPROOMTYPE_COMMONPRIVATELIVEROOM = 2,       // 普通私密直播间
    ZBHTTPROOMTYPE_CHARGEPUBLICLIVEROOM = 3,        // 付费公开直播间
    ZBHTTPROOMTYPE_LUXURYPRIVATELIVEROOM = 4,        // 豪华私密直播间
    ZBHTTPROOMTYPE_MULTIPLAYINTERACTIONLIVEROOM = 5  // 多人互动直播间
}ZBHttpRoomType;

/*礼物类型*/
typedef enum{
    ZBGIFTTYPE_UNKNOWN = 0,
    ZBGIFTTYPE_COMMON = 1,      // 普通礼物
    ZBGIFTTYPE_HEIGH = 2,       // 高级礼物（动画）
    ZBGIFTTYPE_BAR = 3,         // 吧台礼物
    ZBGIFTTYPE_CELEBRATE = 4    // 庆祝礼物
}ZBGiftType;

typedef enum {
    ZBEMOTICONTYPE_STANDARD = 0,      // Standard
    ZBEMOTICONTYPE_ADVANCED = 1       // Advanced
}ZBEmoticonType;

/*回复才艺类型*/
typedef enum{
    ZBTALENTREPLYTYPE_UNKNOWN = 0,  // 未知
    ZBTALENTREPLYTYPE_AGREE = 1,    // 同意
    ZBTALENTREPLYTYPE_REJECT = 2    // 拒绝
}ZBTalentReplyType;

/* 表情类型 */
typedef enum {
    ZBEMOTICONACTIONTYPE_STATIC = 0,      // 静态表情
    ZBEMOTICONACTIONTYPE_DYNAMIC = 1      // 动画表情
}ZBEmoticonActionType;

// 预约列表类型
typedef enum {
    ZBBOOKINGLISTTYPE_WAITANCHORHANDLEING = 1,        // 等待主播处理
    ZBBOOKINGLISTTYPE_WAITFANSHANDLEING = 2,          // 等待观众处理
    ZBBOOKINGLISTTYPE_COMFIRMED = 3,                  // 已确认
    ZBBOOKINGLISTTYPE_HISTORY = 4                     // 历史
} ZBBookingListType;

// 预约回复状态
typedef enum {
    ZBBOOKINGREPLYTYPE_UNKNOWN = 0,           // 未知
    ZBBOOKINGREPLYTYPE_PENDING = 1,           // 待确定
    ZBBOOKINGREPLYTYPE_ACCEPT  = 2,           // 已接受
    ZBBOOKINGREPLYTYPE_REJECT  = 3,           // 已拒绝
    ZBBOOKINGREPLYTYPE_OUTTIME = 4,           // 超时
    ZBBOOKINGREPLYTYPE_CANCEL  = 5,           // 取消
    ZBBOOKINGREPLYTYPE_ANCHORABSENT = 6,      // 主播缺席
    ZBBOOKINGREPLYTYPE_FANSABSENT = 7,        // 观众缺席
    ZBBOOKINGREPLYTYPE_COMFIRMED = 8          // 已完成
    
}ZBBookingReplyType;

//自动邀请状态
typedef enum {
    ZBSETPUSHTYPE_CLOSE = 0,                   // 关闭
    ZBSETPUSHTYPE_START = 1                    // 启动
}ZBSetPushType;

//多人互动回复结果
typedef enum {
    ANCHORMULTIPLAYERREPLYTYPE_AGREE = 0,                   // 接受
    ANCHORMULTIPLAYERREPLYTYPE_REJECT = 1                    // 拒绝
} AnchorMultiplayerReplyType;

//多人互动敲门状态
typedef enum {
    ANCHORMULTIKNOCKTYPE_UNKNOW = 0,                   // 未知
    ANCHORMULTIKNOCKTYPE_PENDING = 1,                  // 待确定
    ANCHORMULTIKNOCKTYPE_ACCEPT = 2,                   // 已接受
    ANCHORMULTIKNOCKTYPE_REJECT = 3,                   // 已拒绝
    ANCHORMULTIKNOCKTYPE_OUTTIME = 4,                  // 超时
} AnchorMultiKnockType;

// 节目状态
typedef enum {
    ANCHORPROGRAMSTATUS_UNKNOW = -1,              // 未知
    ANCHORPROGRAMSTATUS_UNVERIFY = 0,             // 未审核
    ANCHORPROGRAMSTATUS_VERIFYPASS = 1,           // 审核通过
    ANCHORPROGRAMSTATUS_VERIFYREJECT = 2,         // 审核被拒
    ANCHORPROGRAMSTATUS_PROGRAMEND = 3,           // 节目正常结束
    ANCHORPROGRAMSTATUS_OUTTIME = 4,              // 节目已超时
    ANCHORPROGRAMSTATUS_PROGRAMCALCEL = 5         // 节目已取消
    
    
}AnchorProgramStatus;

// 节目列表类型
typedef enum {
    ANCHORPROGRAMLISTTYPE_UNKNOW = 0,           // 未知
    ANCHORPROGRAMLISTTYPE_UNVERIFY = 1,         // 待审核
    ANCHORPROGRAMLISTTYPE_VERIFYPASS = 2,       // 已通过审核且未开播
    ANCHORPROGRAMLISTTYPE_VERIFYREJECT = 3,     // 被拒绝
    ANCHORPROGRAMLISTTYPE_HISTORY = 4           // 历史
}AnchorProgramListType;

// 公开直播间类型
typedef enum {
    ANCHORPUBLICROOMTYPE_UNKNOW = -1,           // 未知
    ANCHORPUBLICROOMTYPE_OPEN = 0,              // 公开
    ANCHORPUBLICROOMTYPE_PROGRAM = 1            // 节目
    
}AnchorPublicRoomType;

#endif
