/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClientDef.h
 *   desc: IM客户端定义
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
    LCC_ERR_SUCCESS = 0,   // 成功
    LCC_ERR_FAIL = -10000, // 服务器返回失败结果

    // 客户端定义的错误
    LCC_ERR_PROTOCOLFAIL = -10001,   // 协议解析失败（服务器返回的格式不正确）
    LCC_ERR_CONNECTFAIL = -10002,    // 连接服务器失败/断开连接
    LCC_ERR_CHECKVERFAIL = -10003,   // 检测版本号失败（可能由于版本过低导致）
    LCC_ERR_SVRBREAK = -10004,       // 服务器踢下线
    LCC_ERR_INVITE_TIMEOUT = -10005, // 邀请超时
    // 服务器返回错误
    LCC_ERR_ROOM_FULL = 10023,  // 房间人满
    LCC_ERR_ROOM_CLOSE = 10029, // 房间已经关闭
    LCC_ERR_NO_CREDIT = 10025,  // 信用点不足
    // IM公用错误码
    LCC_ERR_NO_LOGIN = 10002,                // 未登录
    LCC_ERR_SYSTEM = 10003,                  // 系统错误
    LCC_ERR_TOKEN_EXPIRE = 10004,            // Token 过期了
    LCC_ERR_NOT_FOUND_ROOM = 10021,          // 进入房间失败 找不到房间信息or房间关闭
    LCC_ERR_CREDIT_FAIL = 10027,             // 远程扣费接口调用失败
    LCC_ERR_KICKOFF = 10037,                 // 被挤掉线 默认通知内容
    LCC_ERR_NO_AUTHORIZED = 10039,           //10021 不能操作 不是对应的userid
    LCC_ERR_LIVEROOM_NO_EXIST = 16104,       // 直播间不存在
    LCC_ERR_LIVEROOM_CLOSED = 16106,         // 直播间已关闭
    LCC_ERR_ANCHORID_INCONSISTENT = 16108,   // 主播id与直播场次的主播id不合
    LCC_ERR_CLOSELIVE_DATA_FAIL = 16110,     // 关闭直播场次,数据表操作出错
    LCC_ERR_CLOSELIVE_LACK_CODITION = 16122, // 主播立即关闭私密直播间, 不满足关闭条件
    // 其它错误码
    LCC_ERR_ENTER_ROOM_ERR = 10022,                    // 进入房间失败 数据库操作失败（添加记录or删除扣费记录）
    LCC_ERR_NOT_FIND_ANCHOR = 10026,                   // 主播机构信息找不到
    LCC_ERR_COUPON_FAIL = 10028,                       // 扣费信用点失败--扣除优惠券分钟数
    LCC_ERR_ENTER_ROOM_NO_AUTHORIZED = 10033,          // 进入私密直播间 不是对应的userid
    LCC_ERR_REPEAT_KICKOFF = 10038,                    // 被挤掉线 同一userid不通socket_id进入同一房间时
    LCC_ERR_ANCHOR_NO_ON_LIVEROOM = 10055,             // 改主播不存在公开直播间
    LCC_ERR_INCONSISTENT_ROOMTYPE = 10049,             // 赠送礼物失败、开始\结束推流失败 房间类型不符合
    LCC_ERR_INCONSISTENT_CREDIT_FAIL = 10053,          // 扣费信用点数值的错误，扣费失败
    LCC_ERR_REPEAT_END_STREAM = 10054,                 // 已结结束推流，不能重复操作
    LCC_ERR_REPEAT_BOOKING_KICKOFF = 10046,            // 重复立即预约该主播被挤掉线.
    LCC_ERR_NOT_IN_STUDIO = 15002,                     // You are not in the studio
    LCC_ERR_INCONSISTENT_LEVEL = 10047,                // 赠送礼物失败 用户等级不符合
    LCC_ERR_INCONSISTENT_LOVELEVEL = 10048,            // 赠送礼物失败 亲密度不符合
    LCC_ERR_LESS_THAN_GIFT = 10050,                    // 赠送礼物失败 拥有礼物数量不足
    LCC_ERR_SEND_GIFT_FAIL = 16144,                    // 发送礼物出错
    LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL = 16145,          // 发送礼物,男士级别不够
    LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL = 16146,      // 发送礼物,男士主播亲密度不够
    LCC_ERR_SEND_GIFT_NO_EXIST = 16147,                // 发送礼物,礼物不存在或已下架
    LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE = 16148, // 发送礼物,礼物级别限制与直播场次级别不符
    LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST = 16151,       // 主播发礼物,背包礼物不存在
    LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN = 16152,       // 主播发礼物,背包礼物数量不足
    LCC_ERR_SEND_GIFT_PARAM_ERR = 16153,               // 发礼物,参数错误
    LCC_ERR_SEND_TOAST_NOCAN = 15001,                  // 主播不能发送弹幕
    LCC_ERR_ANCHOR_OFFLINE = 10034,                    // 立即私密邀请失败 主播不在线 /*important*/
    LCC_ERR_ANCHOR_BUSY = 10035,                       // 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
    LCC_ERR_ANCHOR_PLAYING = 10056,                    // 主播正在私密直播中 /*important*/
    LCC_ERR_NOTCAN_CANCEL_INVITATION = 10036,          // 取消立即私密邀请失败 状态不是带确认 /*important*/
    LCC_ERR_NO_FOUND_CRONJOB = 10040,                  // cronjob 里找不到对应的定时器函数
    LCC_ERR_REPEAT_INVITEING_TALENT = 10052,           // 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/

} LCC_ERR_TYPE;

// 客户端端类型
typedef enum {
    CLIENTTYPE_IOS = 0,                // IOS 客户端
    CLIENTTYPE_ANDROID = 1,            // Android 客户端
    CLIENTTYPE_WEB = 2,                // Web端
    CLIENTTYPE_UNKNOW,                 // 未知
    CLIENTTYPE_BEGIN = CLIENTTYPE_IOS, // 有效范围起始值
    CLIENTTYPE_END = CLIENTTYPE_UNKNOW // 有效范围结束值
} ClientType;

// int 转换 CLIENT_TYPE
inline ClientType GetClientType(int value) {
    return CLIENTTYPE_BEGIN <= value && value < CLIENTTYPE_END ? (ClientType)value : CLIENTTYPE_UNKNOW;
}

// socket所在的页面
typedef enum {
    PAGENAMETYPE_UNKNOW = 0,         // 未知
    PAGENAMETYPE_HOMEPAGE = 1,       // 主播个人首页
    PAGENAMETYPE_LISTPAGE = 2,       // 列表页
    PAGENAMETYPE_BACKGROUNDPAGE = 3, // 主播后台
    PAGENAMETYPE_WAITPAGE = 4,       // 预约等待页
    PAGENAMETYPE_PUBLICPAGE = 5,     // 公开直播间页
    PAGENAMETYPE_PRIVATEPAGE = 6,    // 私密直播间页
    PAGENAMETYPE_MOVEPAGE = 7,       // 移动端
    PAGENAMETYPE_BEGIN = PAGENAMETYPE_UNKNOW,
    PAGENAMETYPE_END = PAGENAMETYPE_MOVEPAGE
} PageNameType;
// int 转换 PageNameType
inline PageNameType GetPageNameType(int value) {
    return PAGENAMETYPE_BEGIN <= value && value <= PAGENAMETYPE_END ? (PageNameType)value : PAGENAMETYPE_UNKNOW;
}

typedef enum {
    ROOMTYPE_NOLIVEROOM = 0,            // 没有直播间
    ROOMTYPE_FREEPUBLICLIVEROOM = 1,    // 免费公开直播间
    ROOMTYPE_COMMONPRIVATELIVEROOM = 2, // 普通私密直播间
    ROOMTYPE_CHARGEPUBLICLIVEROOM = 3,  // 付费公开直播间
    ROOMTYPE_LUXURYPRIVATELIVEROOM = 4, // 豪华私密直播间
    ROOMTYPE_UNKNOW,
    ROOMTYPE_BEGIN = ROOMTYPE_NOLIVEROOM,
    ROOMTYPE_END = ROOMTYPE_UNKNOW
} RoomType;

// int 转换 RoomType
inline RoomType GetRoomType(int value) {
    //    RoomType type = ROOMTYPE_NOLIVEROOM;
    //    switch (value) {
    //        case 1:{
    //            // 免费公开直播间
    //            type = ROOMTYPE_FREEPUBLICLIVEROOM;
    //        }break;
    //        case 2:{
    //            // 普通私密直播间
    //            type = ROOMTYPE_COMMONPRIVATELIVEROOM;
    //        }break;
    //        case 3:{
    //            // 付费公开直播间
    //            type = ROOMTYPE_CHARGEPUBLICLIVEROOM;
    //        }break;
    //        case 4:{
    //            // 豪华私密直播间
    //            type = ROOMTYPE_LUXURYPRIVATELIVEROOM;
    //        }break;
    //        default:
    //            break;
    //    }
    //    return type;
    return ROOMTYPE_BEGIN <= value && value < ROOMTYPE_END ? (RoomType)value : ROOMTYPE_UNKNOW;
}

typedef enum {
    REPLYTYPE_REJECT = 0, // 拒绝
    REPLYTYPE_AGREE = 1,  // 同意
    REPLYTYPE_UNKNOW,
    REPLYTYPE_BEGIN = REPLYTYPE_REJECT,
    REPLYTYPE_END = REPLYTYPE_UNKNOW
} ReplyType;

// int 转换 RoomType
inline ReplyType GetReplyType(int value) {
    return REPLYTYPE_BEGIN <= value && value < REPLYTYPE_END ? (ReplyType)value : REPLYTYPE_UNKNOW;
}

typedef enum {
    ANCHORREPLYTYPE_REJECT = 0,  // 拒绝
    ANCHORREPLYTYPE_AGREE = 1,   // 同意
    ANCHORREPLYTYPE_OUTTIME = 2, // 超时
    ANCHORREPLYTYPE_UNKNOW,
    ANCHORREPLYTYPE_BEGIN = ANCHORREPLYTYPE_REJECT,
    ANCHORREPLYTYPE_END = ANCHORREPLYTYPE_UNKNOW
} AnchorReplyType;

// int 转换 RoomType
inline AnchorReplyType GetAnchorReplyType(int value) {
    return ANCHORREPLYTYPE_BEGIN <= value && value < ANCHORREPLYTYPE_END ? (AnchorReplyType)value : ANCHORREPLYTYPE_UNKNOW;
}

typedef enum {
    TALENTSTATUS_UNKNOW = 0, // 未知
    TALENTSTATUS_AGREE = 1,  // 已接受
    TALENTSTATUS_REJECT = 2, // 拒绝
    TALENTSTATUS_BEGIN = TALENTSTATUS_UNKNOW,
    TALENTSTATUSE_END = TALENTSTATUS_REJECT
} TalentStatus;

// int 转换 RoomType
inline TalentStatus GetTalentStatus(int value) {
    return TALENTSTATUS_BEGIN <= value && value <= TALENTSTATUSE_END ? (TalentStatus)value : TALENTSTATUS_UNKNOW;
}

// 回复状态
typedef enum {
    IMREPLYTYPE_UNKNOWN = 0,              // 未知
    IMREPLYTYPE_UNCONFIRM = 1,            // 待确定
    IMREPLYTYPE_AGREE = 2,                // 已同意
    IMREPLYTYPE_REJECT = 3,               // 已拒绝
    IMREPLYTYPE_OUTTIME = 4,              // 已超时
    IMREPLYTYPE_CANCEL = 5,               // 观众/主播取消
    IMREPLYTYPE_ANCHORABSENT = 6,         // 主播缺席
    IMREPLYTYPE_FANSABSENT = 7,           // 观众缺席
    IMREPLYTYPE_COMFIRMED = 8             // 已完成
}IMReplyType;

// int 转换 RoomType
inline IMReplyType GetIMReplyType(int value) {
    return IMREPLYTYPE_UNKNOWN < value && value <= IMREPLYTYPE_COMFIRMED ? (IMReplyType)value : IMREPLYTYPE_UNKNOWN;
}

typedef enum {
    IMCONTROLTYPE_UNKNOW = 0,                   // 未知
    IMCONTROLTYPE_START = 1,                   // 开始
    IMCONTROLTYPE_CLOSE = 2                    // 关闭
}IMControlType;

// int 转换 IMControlType
inline IMControlType GetIMControlType(int value) {
    return IMCONTROLTYPE_UNKNOW < value && value <= IMCONTROLTYPE_CLOSE ? (IMControlType)value : IMCONTROLTYPE_UNKNOW;
}
