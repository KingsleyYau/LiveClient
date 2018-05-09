/*
 * author: alex
 *   date: 2018-03-01
 *   file: IZBImClientDef.h
 *   desc: 主播IM客户端定义
 */

#pragma once

#include <ProtocolCommon/DeviceTypeDef.h>

#define SEQ_T unsigned int


/* 本地错误代码 */
#define IMLOCAL_ERROR_CODE_TIMEOUT			"LOCAL_ERROR_CODE_TIMEOUT"
#define IMLOCAL_ERROR_CODE_TIMEOUT_DESC		"Trouble connecting to the server, please try again later."
#define IMLOCAL_ERROR_CODE_PARSEFAIL			"LOCAL_ERROR_CODE_PARSEFAIL"
#define IMLOCAL_ERROR_CODE_PARSEFAIL_DESC		"Trouble connecting to the server, please try again later."
#define IMLOCAL_ERROR_CODE_FILEOPTFAIL		"LOCAL_ERROR_CODE_FILEOPTFAIL"
#define IMLOCAL_ERROR_CODE_FILEOPTFAIL_DESC	"Error encountered while writing your file storage."

/**
 * 服务器错误码
 */
/* 未登录 */
#define ERROR_CODE_MBCE0003			"0003"

/* 本地直播错误代码 */
#define IMLOCAL_LIVE_ERROR_CODE_SUCCESS			0
#define IMLOCAL_LIVE_ERROR_CODE_FAIL			1
#define IMLOCAL_LIVE_ERROR_CODE_TIMEOUT			2
#define IMLOCAL_LIVE_ERROR_CODE_PARSEFAIL       3

// 处理结果
typedef enum {
    ZBLCC_ERR_SUCCESS = 0,   // 成功
    ZBLCC_ERR_FAIL = -10000, // 服务器返回失败结果

    // 客户端定义的错误
    ZBLCC_ERR_PROTOCOLFAIL = -10001,   // 协议解析失败（服务器返回的格式不正确）
    ZBLCC_ERR_CONNECTFAIL = -10002,    // 连接服务器失败/断开连接
    ZBLCC_ERR_CHECKVERFAIL = -10003,   // 检测版本号失败（可能由于版本过低导致）
    ZBLCC_ERR_SVRBREAK = -10004,       // 服务器踢下线
    ZBLCC_ERR_INVITE_TIMEOUT = -10005, // 邀请超时
//    // 服务器返回错误
//    ZBLCC_ERR_ROOM_FULL = 10023,  // 房间人满
//    ZBLCC_ERR_ROOM_CLOSE = 10029, // 房间已经关闭
//    ZBLCC_ERR_NO_CREDIT = 10025,  // 信用点不足
    // IM公用错误码
    ZBLCC_ERR_NO_LOGIN = 10002,                // 未登录
    ZBLCC_ERR_SYSTEM = 10003,                  // 系统错误
    ZBLCC_ERR_TOKEN_EXPIRE = 10004,            // Token 过期了
    ZBLCC_ERR_NOT_FOUND_ROOM = 10021,          // 进入房间失败 找不到房间信息or房间关闭
    ZBLCC_ERR_CREDIT_FAIL = 10027,             // 远程扣费接口调用失败
    ZBLCC_ERR_ROOM_CLOSE = 10029, // 房间已经关闭
    ZBLCC_ERR_KICKOFF = 10037,                 // 被挤掉线 默认通知内容
    ZBLCC_ERR_NO_AUTHORIZED = 10039,           //10021 不能操作 不是对应的userid
    ZBLCC_ERR_LIVEROOM_NO_EXIST = 16104,       // 直播间不存在
    ZBLCC_ERR_LIVEROOM_CLOSED = 16106,         // 直播间已关闭
    ZBLCC_ERR_ANCHORID_INCONSISTENT = 16108,   // 主播id与直播场次的主播id不合
    ZBLCC_ERR_CLOSELIVE_DATA_FAIL = 16110,     // 关闭直播场次,数据表操作出错
    ZBLCC_ERR_CLOSELIVE_LACK_CODITION = 16122, // 主播立即关闭私密直播间, 不满足关闭条件
    ZBLCC_ERR_NOT_IN_STUDIO = 15002,           // You are not in the studio
    ZBLCC_ERR_NOT_FIND_ANCHOR = 10026,                   // 主播机构信息找不到
    ZBLCC_ERR_INCONSISTENT_LEVEL = 10047,                // 赠送礼物失败 用户等级不符合
    ZBLCC_ERR_INCONSISTENT_LOVELEVEL = 10048,            // 赠送礼物失败 亲密度不符合
    ZBLCC_ERR_INCONSISTENT_ROOMTYPE = 10049,             // 赠送礼物失败、开始\结束推流失败 房间类型不符合
    ZBLCC_ERR_LESS_THAN_GIFT = 10050,                    // 赠送礼物失败 拥有礼物数量不足
    ZBLCC_ERR_SEND_GIFT_FAIL = 16144,                    // 发送礼物出错
    ZBLCC_ERR_SEND_GIFT_LESSTHAN_LEVEL = 16145,          // 发送礼物,男士级别不够
    ZBLCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL = 16146,      // 发送礼物,男士主播亲密度不够
    ZBLCC_ERR_SEND_GIFT_NO_EXIST = 16147,                // 发送礼物,礼物不存在或已下架
    ZBLCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE = 16148, // 发送礼物,礼物级别限制与直播场次级别不符
    ZBLCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST = 16151,       // 主播发礼物,背包礼物不存在
    ZBLCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN = 16152,       // 主播发礼物,背包礼物数量不足
    ZBLCC_ERR_SEND_GIFT_PARAM_ERR = 16153,               // 发礼物,参数错误
//    // 其它错误码
//    ZBLCC_ERR_ENTER_ROOM_ERR = 10022,                    // 进入房间失败 数据库操作失败（添加记录or删除扣费记录）
//
//    ZBLCC_ERR_COUPON_FAIL = 10028,                       // 扣费信用点失败--扣除优惠券分钟数
//    ZBLCC_ERR_ENTER_ROOM_NO_AUTHORIZED = 10033,          // 进入私密直播间 不是对应的userid
//    ZBLCC_ERR_REPEAT_KICKOFF = 10038,                    // 被挤掉线 同一userid不通socket_id进入同一房间时
//    ZBLCC_ERR_ANCHOR_NO_ON_LIVEROOM = 10055,             // 改主播不存在公开直播间
//    ZBLCC_ERR_INCONSISTENT_CREDIT_FAIL = 10053,          // 扣费信用点数值的错误，扣费失败
//    ZBLCC_ERR_REPEAT_END_STREAM = 10054,                 // 已结结束推流，不能重复操作
//    ZBLCC_ERR_REPEAT_BOOKING_KICKOFF = 10046,            // 重复立即预约该主播被挤掉线.

//
//

//    ZBLCC_ERR_SEND_TOAST_NOCAN = 15001,                  // 主播不能发送弹幕
//    ZBLCC_ERR_ANCHOR_OFFLINE = 10034,                    // 立即私密邀请失败 主播不在线 /*important*/
//    ZBLCC_ERR_ANCHOR_BUSY = 10035,                       // 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
//    ZBLCC_ERR_ANCHOR_PLAYING = 10056,                    // 主播正在私密直播中 /*important*/
//    ZBLCC_ERR_NOTCAN_CANCEL_INVITATION = 10036,          // 取消立即私密邀请失败 状态不是带确认 /*important*/
//    ZBLCC_ERR_NO_FOUND_CRONJOB = 10040,                  // cronjob 里找不到对应的定时器函数
//    ZBLCC_ERR_REPEAT_INVITEING_TALENT = 10052,           // 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/
//    ZBLCC_ERR_RECV_REGULAR_CLOSE_ROOM = 10088,           // 用户接收正常关闭直播间

} ZBLCC_ERR_TYPE;

// 客户端端类型
typedef enum {
    ZBCLIENTTYPE_IOS = 0,                // IOS 客户端
    ZBCLIENTTYPE_ANDROID = 1,            // Android 客户端
    ZBCLIENTTYPE_WEB = 2,                // Web端
    ZBCLIENTTYPE_UNKNOW,                 // 未知
    ZBCLIENTTYPE_BEGIN = ZBCLIENTTYPE_IOS, // 有效范围起始值
    ZBCLIENTTYPE_END = ZBCLIENTTYPE_UNKNOW // 有效范围结束值
} ZBClientType;

// int 转换 CLIENT_TYPE
inline ZBClientType ZBGetClientType(int value) {
    return ZBCLIENTTYPE_BEGIN <= value && value < ZBCLIENTTYPE_END ? (ZBClientType)value : ZBCLIENTTYPE_UNKNOW;
}

// socket所在的页面
typedef enum {
    ZBPAGENAMETYPE_UNKNOW = 0,         // 未知
    ZBPAGENAMETYPE_HOMEPAGE = 1,       // 主播个人首页
    ZBPAGENAMETYPE_LISTPAGE = 2,       // 列表页
    ZBPAGENAMETYPE_BACKGROUNDPAGE = 3, // 主播后台
    ZBPAGENAMETYPE_WAITPAGE = 4,       // 预约等待页
    ZBPAGENAMETYPE_PUBLICPAGE = 5,     // 公开直播间页
    ZBPAGENAMETYPE_PRIVATEPAGE = 6,    // 私密直播间页
    ZBPAGENAMETYPE_MOVEPAGE = 7,       // 移动端
    ZBPAGENAMETYPE_BEGIN = ZBPAGENAMETYPE_UNKNOW,
    ZBPAGENAMETYPE_END = ZBPAGENAMETYPE_MOVEPAGE
} ZBPageNameType;
// int 转换 PageNameType
inline ZBPageNameType ZBGetPageNameType(int value) {
    return ZBPAGENAMETYPE_BEGIN <= value && value <= ZBPAGENAMETYPE_END ? (ZBPageNameType)value : ZBPAGENAMETYPE_UNKNOW;
}

typedef enum {
    ZBROOMTYPE_NOLIVEROOM = 0,            // 没有直播间
    ZBROOMTYPE_FREEPUBLICLIVEROOM = 1,    // 免费公开直播间
    ZBROOMTYPE_COMMONPRIVATELIVEROOM = 2, // 普通私密直播间
    ZBROOMTYPE_CHARGEPUBLICLIVEROOM = 3,  // 付费公开直播间
    ZBROOMTYPE_LUXURYPRIVATELIVEROOM = 4, // 豪华私密直播间
    ZBROOMTYPE_MULTIPLAYINTERACTIONLIVEROOM = 5, // 多人互动直播间
    ZBROOMTYPE_UNKNOW,
    ZBROOMTYPE_BEGIN = ZBROOMTYPE_NOLIVEROOM,
    ZBROOMTYPE_END = ZBROOMTYPE_UNKNOW
} ZBRoomType;

// int 转换 RoomType
inline ZBRoomType ZBGetRoomType(int value) {
    return ZBROOMTYPE_BEGIN <= value && value < ZBROOMTYPE_END ? (ZBRoomType)value : ZBROOMTYPE_UNKNOW;
}

typedef enum {
    ZBREPLYTYPE_REJECT = 0, // 拒绝
    ZBREPLYTYPE_AGREE = 1,  // 同意
    ZBREPLYTYPE_UNKNOW,
    ZBREPLYTYPE_BEGIN = ZBREPLYTYPE_REJECT,
    ZBREPLYTYPE_END = ZBREPLYTYPE_UNKNOW
} ZBReplyType;

// int 转换 RoomType
inline ZBReplyType ZBGetReplyType(int value) {
    return ZBREPLYTYPE_BEGIN <= value && value < ZBREPLYTYPE_END ? (ZBReplyType)value : ZBREPLYTYPE_UNKNOW;
}

typedef enum {
    ZBANCHORREPLYTYPE_REJECT = 0,  // 拒绝
    ZBANCHORREPLYTYPE_AGREE = 1,   // 同意
    ZBANCHORREPLYTYPE_OUTTIME = 2, // 超时
    ZBANCHORREPLYTYPE_UNKNOW,
    ZBANCHORREPLYTYPE_BEGIN = ZBANCHORREPLYTYPE_REJECT,
    ZBANCHORREPLYTYPE_END = ZBANCHORREPLYTYPE_UNKNOW
} ZBAnchorReplyType;

// int 转换 RoomType
inline ZBAnchorReplyType ZBGetAnchorReplyType(int value) {
    return ZBANCHORREPLYTYPE_BEGIN <= value && value < ZBANCHORREPLYTYPE_END ? (ZBAnchorReplyType)value : ZBANCHORREPLYTYPE_UNKNOW;
}

typedef enum {
    ZBTALENTSTATUS_UNKNOW = 0, // 未知
    ZBTALENTSTATUS_AGREE = 1,  // 已接受
    ZBTALENTSTATUS_REJECT = 2, // 拒绝
    ZBTALENTSTATUS_BEGIN = ZBTALENTSTATUS_UNKNOW,
    ZBTALENTSTATUSE_END = ZBTALENTSTATUS_REJECT
} ZBTalentStatus;

// int 转换 RoomType
inline ZBTalentStatus ZBGetTalentStatus(int value) {
    return ZBTALENTSTATUS_BEGIN <= value && value <= ZBTALENTSTATUSE_END ? (ZBTalentStatus)value : ZBTALENTSTATUS_UNKNOW;
}

// 回复状态
typedef enum {
    ZBIMREPLYTYPE_UNKNOWN = 0,              // 未知
    ZBIMREPLYTYPE_UNCONFIRM = 1,            // 待确定
    ZBIMREPLYTYPE_AGREE = 2,                // 已同意
    ZBIMREPLYTYPE_REJECT = 3,               // 已拒绝
    ZBIMREPLYTYPE_OUTTIME = 4,              // 已超时
    ZBIMREPLYTYPE_CANCEL = 5,               // 观众/主播取消
    ZBIMREPLYTYPE_ANCHORABSENT = 6,         // 主播缺席
    ZBIMREPLYTYPE_FANSABSENT = 7,           // 观众缺席
    ZBIMREPLYTYPE_COMFIRMED = 8             // 已完成
}ZBIMReplyType;

// int 转换 RoomType
inline ZBIMReplyType ZBGetIMReplyType(int value) {
    return ZBIMREPLYTYPE_UNKNOWN < value && value <= ZBIMREPLYTYPE_COMFIRMED ? (ZBIMReplyType)value : ZBIMREPLYTYPE_UNKNOWN;
}

typedef enum {
    ZBIMCONTROLTYPE_UNKNOW = 0,                   // 未知
    ZBIMCONTROLTYPE_START = 1,                   // 开始
    ZBIMCONTROLTYPE_CLOSE = 2                    // 关闭
}ZBIMControlType;

// int 转换 IMControlType
inline ZBIMControlType ZBGetIMControlType(int value) {
    return ZBIMCONTROLTYPE_UNKNOW < value && value <= ZBIMCONTROLTYPE_CLOSE ? (ZBIMControlType)value : ZBIMCONTROLTYPE_UNKNOW;
}

// 直播间公告类型
typedef enum {
    ZBIMSYSTEMTYPE_COMMON = 0,
    ZBIMSYSTEMTYPE_WARN = 1
}ZBIMSystemType;

// int 转换 IMSystemType
inline ZBIMSystemType ZBGetIMSystemType(int value) {
    return ZBIMSYSTEMTYPE_COMMON <= value && value <= ZBIMSYSTEMTYPE_WARN ? (ZBIMSystemType)value : ZBIMSYSTEMTYPE_COMMON;
}

// 直播间状态
typedef enum {
    ZBLIVESTATUS_UNKNOW = 0,            // 未知
    ZBLIVESTATUS_INIT = 1,              // 初始
    ZBLIVESTATUSE_RECIPROCALSTART = 2,  // 开始倒数中
    ZBLIVESTATUS_ONLINE = 3,            // 在线
    ZBLIVESTATUS_ARREARAGE = 4,         // 欠费中
    ZBLIVESTATUS_RECIPROCALEND = 5,     // 结束倒数中
    ZBLIVESTATUS_CLOSE = 6,             // 关闭
    ZBLIVESTATUS_BEGIN = ZBLIVESTATUS_UNKNOW,
    ZBLIVESTATUS_END = ZBLIVESTATUS_CLOSE
} ZBLiveStatus;

// int 转换 ZBLiveStatus
inline ZBLiveStatus ZBGetLiveStatus(int value) {
    return ZBLIVESTATUS_BEGIN < value && value <= ZBLIVESTATUS_END ? (ZBLiveStatus)value : ZBLIVESTATUS_UNKNOW;
}


// 主播状态
typedef enum {
    ANCHORSTATUS_INVITATION = 0,        // 邀请中
    ANCHORSTATUS_INVITECONFIRM = 1,     // 邀请已确认
    ANCHORSTATUS_KNOCKCONFIRM = 2,      // 敲门已确认
    ANCHORSTATUS_RECIPROCALENTER = 3,   // 倒数进入中
    ANCHORSTATUS_ONLINE = 4,            // 在线
    ANCHORSTATUS_UNKNOW,
    ANCHORSTATUS_BEGIN = ANCHORSTATUS_INVITATION,
    ANCHORSTATUS_END = ANCHORSTATUS_UNKNOW
} AnchorStatus;

// int 转换 AnchorStatus
inline AnchorStatus GetAnchorStatus(int value) {
    return ANCHORSTATUS_BEGIN <= value && value < ANCHORSTATUS_END ? (AnchorStatus)value : ANCHORSTATUS_UNKNOW;
}

// 敲门回复
typedef enum {
    IMANCHORKNOCKTYPE_UNKNOWN = 0,          // 未知
    IMANCHORKNOCKTYPE_AGREE = 2,            // 接受
    IMANCHORKNOCKTYPE_REJECT = 3,           // 拒绝
    IMANCHORKNOCKTYPE_OUTTIME = 4,          // 邀请超时
    IMANCHORKNOCKTYPE_CANCEL = 5,           // 主播取消邀请
    IMANCHORKNOCKTYPE_BEGIN = IMANCHORKNOCKTYPE_AGREE,
    IMANCHORKNOCKTYPE_END = IMANCHORKNOCKTYPE_CANCEL
} IMAnchorKnockType;

// int 转换 IMAnchorKnockType
inline IMAnchorKnockType GetIMAnchorKnockType(int value) {
    return IMANCHORKNOCKTYPE_BEGIN <= value && value <= IMANCHORKNOCKTYPE_END ? (IMAnchorKnockType)value : IMANCHORKNOCKTYPE_UNKNOWN;
}

// 邀请回复
typedef enum {
    IMANCHORREPLYINVITETYPE_UNKNOWN = 0,          // 未知
    IMANCHORREPLYINVITETYPE_AGREE = 2,            // 接受
    IMANCHORREPLYINVITETYPE_REJECT = 3,           // 拒绝
    IMANCHORREPLYINVITETYPEE_OUTTIME = 4,         // 邀请超时
    IMANCHORREPLYINVITETYPE_CANCEL = 5,           // 观众取消邀请
    IMANCHORREPLYINVITETYPE_BEGIN = IMANCHORREPLYINVITETYPE_AGREE,
    IMANCHORREPLYINVITETYPE_END = IMANCHORREPLYINVITETYPE_CANCEL
} IMAnchorReplyInviteType;

// int 转换 IMAnchorKnockType
inline IMAnchorReplyInviteType GetIMAnchorReplyInviteType(int value) {
    return IMANCHORREPLYINVITETYPE_BEGIN <= value && value <= IMANCHORREPLYINVITETYPE_END ? (IMAnchorReplyInviteType)value : IMANCHORREPLYINVITETYPE_UNKNOWN;
}

// 公开直播间类型
typedef enum {
    IMANCHORPUBLICROOMTYPE_UNKNOW = -1,              // 未知
    IMANCHORPUBLICROOMTYPE_COMMON = 0,              // 普通公开
    IMANCHORPUBLICROOMTYPE_PROGRAM = 1,              // 节目
    IMANCHORPUBLICROOMTYPE_BEGIN = IMANCHORPUBLICROOMTYPE_UNKNOW,
    IMANCHORPUBLICROOMTYPE_END = IMANCHORPUBLICROOMTYPE_PROGRAM
    
}IMAnchorPublicRoomType;

// int 转换 IMAnchorPublicRoomType
inline IMAnchorPublicRoomType GetIMAnchorPublicRoomType(int value) {
    return IMANCHORPUBLICROOMTYPE_BEGIN < value && value <= IMANCHORPUBLICROOMTYPE_END ? (IMAnchorPublicRoomType)value : IMANCHORPUBLICROOMTYPE_UNKNOW;
}

// 节目状态
typedef enum {
    IMANCHORPROGRAMSTATUS_UNKNOW = -1,              // 未知
    IMANCHORPROGRAMSTATUS_UNVERIFY = 0,             // 未审核
    IMANCHORPROGRAMSTATUS_VERIFYPASS = 1,           // 审核通过
    IMANCHORPROGRAMSTATUS_VERIFYREJECT = 2,         // 审核被拒
    IMANCHORPROGRAMSTATUS_PROGRAMEND = 3,           // 节目正常结束
    IMANCHORPROGRAMSTATUS_OUTTIME = 4,               // 节目已超时
    IMANCHORPROGRAMSTATUS_PROGRAMCALCEL = 5,         // 节目已取消
    
    IMANCHORPROGRAMSTATUS_BEGIN = IMANCHORPROGRAMSTATUS_UNKNOW,
    IMANCHORPROGRAMSTATUS_END = IMANCHORPROGRAMSTATUS_PROGRAMCALCEL
    
}IMAnchorProgramStatus;

// int 转换 IMAnchorProgramStatus
inline IMAnchorProgramStatus GetIMAnchorProgramStatus(int value) {
    return IMANCHORPROGRAMSTATUS_BEGIN < value && value <= IMANCHORPROGRAMSTATUS_END ? (IMAnchorProgramStatus)value : IMANCHORPROGRAMSTATUS_UNKNOW;
}
