/*
 * author: Samson.Fan
 *   date: 2018-06-25
 *   file:ILiveMessageDef.h
 *   desc: 直播管理器定义
 */

#pragma once

#define LIVESHOW_LIVEMESSAGE_LOG            "LiveMessageManager"
#define PRIVATEMESSAGE_LIMIT 50
#define REQUEST_INVALIDREQUESTID    -1
#define PRIVATEMESSAGE_SYSTEM    "First 3 outgoing messages to each broadcaster is free, 0.05 credits for each extra message sent."

// 消息类型定义
typedef enum  {
    LMMT_Unknow,        // 未知类型
    LMMT_Text,          // 文本消息（包括普通表情）
    LMMT_SystemWarn,    // 系统警告
    LMMT_Time,          // 时间提示
    LMMT_Warning        // 警告提示
} LMMessageType;

// 消息发送方向 类型
typedef enum  {
    LMSendType_Unknow,        // 未知类型
    LMSendType_Send,            // 发出
    LMSendType_Recv,            // 接收
} LMSendType;

// 处理状态
typedef enum {
    LMStatusType_Unprocess,        // 未处理
    LMStatusType_Processing,      // 处理中
    LMStatusType_Fail,            // 发送失败
    LMStatusType_Finish,          // 发送完成/接收成功
} LMStatusType;

typedef enum {
    LMMessageListType_Unknow,       // 未知
    LMMessageListType_Refresh,      // 刷新
    LMMessageListType_More,         // 更多
    LMMessageListType_Update        // 更新
}LMMessageListType;

typedef enum {
    LMRequstHandleType_Unknow,       // 未知
    LMRequstHandleType_Processing,   // 请求中
    LMRequstHandleType_Finish        // 请求完成
}LMRequstHandleType;

// 消息类型定义
typedef enum  {
    LMWarningType_Unknow,
    LMWarningType_NoCredit          // 点数不足警告
} LMWarningType;

typedef enum {
    LMPMSType_Unknow = 0,
    LMPMSType_Text = (1 << 0),
    LMPMSType_Dynamic = (1 << 1)
}LMPrivateMsgSupportType;

typedef enum {
    LMSystemType_Unknow,
    LMSystemType_NoMore
} LMSystemType;

