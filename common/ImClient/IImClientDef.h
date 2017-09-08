/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClientDef.h
 *   desc: IM客户端定义
 */

#pragma once

#include <ProtocolCommon/DeviceTypeDef.h>

#define SEQ_T unsigned int

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
    LCC_ERR_ROOM_FULL = 10023,   // 房间人满
    LCC_ERR_ROOM_CLOSE = 10029,  // 房间已经关闭
    LCC_ERR_NO_CREDIT = 10025,   // 信用点不足
    LCC_ERR_PRI_LIVING = -10006, // 主播正在私密直播中

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
    ROOMTYPE_CHARGEPUBLICLIVEROOM = 2,  // 付费公开直播间
    ROOMTYPE_COMMONPRIVATELIVEROOM = 3, // 普通私密直播间
    ROOMTYPE_LUXURYPRIVATELIVEROOM = 4, // 豪华私密直播间
    ROOMTYPE_UNKNOW,
    ROOMTYPE_BEGIN = ROOMTYPE_NOLIVEROOM,
    ROOMTYPE_END = ROOMTYPE_UNKNOW
} RoomType;

// int 转换 RoomType
inline RoomType GetRoomType(int value) {
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
