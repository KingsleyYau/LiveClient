/*
 * author: Alex
 *   date: 2018-11-9
 *   file: ILSLiveChatManManagerEnumDef.h
 *   desc: 将枚举类型和其他类型分开（方便ios的编译，防止混编出问题）
 */

#pragma once

#include <livechat/ILSLiveChatClientEnumDef.h>

// 聊天状态
typedef enum {
    LC_CHATTYPE_IN_CHAT_CHARGE,             // 收费
    LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET,     // 试聊券
    LC_CHATTYPE_INVITE,                         // 邀请
    LC_CHATTYPE_MANINVITE,                    // 男士已经发出邀请
    LC_CHATTYPE_OTHER,                         // 其它
} Chat_Type;

// 消息类型定义
typedef enum  {
    MT_Unknow,        // 未知类型
    MT_Text,        // 文本消息
    MT_Warning,        // 警告消息
    MT_Emotion,        // 高级表情
    MT_Voice,        // 语音
    MT_MagicIcon,   // 小高级表情
    MT_Photo,        // 私密照
    MT_Video,        // 微视频
    MT_System,        // 系统消息
    MT_Custom,        //自定义消息
} MessageType;

// 消息发送方向 类型
typedef enum  {
    SendType_Unknow,        // 未知类型
    SendType_Send,            // 发出
    SendType_Recv,            // 接收
    SendType_System,        // 系统
} SendType;

// 处理状态
typedef enum {
    StatusType_Unprocess,        // 未处理
    StatusType_Processing,        // 处理中
    StatusType_Fail,            // 发送失败
    StatusType_Finish,            // 发送完成/接收成功
} StatusType;

// 消息类型
typedef enum _CodeType
{
    MESSAGE,                // 使用m_message（默认）
    TRY_CHAT_END,            // 试聊结束
    NOT_SUPPORT_TEXT,        // 不支持文本消息
    NOT_SUPPORT_EMOTION,    // 不支持高级表情消息
    NOT_SUPPORT_VOICE,        // 不支持语音消息
    NOT_SUPPORT_PHOTO,        // 不支持私密照消息
    NOT_SUPPORT_MAGICICON,    // 不支持小高表消息
} CodeType;

// 消息类型
typedef enum _WarningCodeType {
    WARNING_MESSAGE,    // 使用m_message（默认）
    WARNING_NOMONEY,    // 余额不足
} WarningCodeType;

// 链接操作类型
typedef enum {
    Unknow,            // 默认/未知
    Rechange,        // 充值
} LinkOptType;

