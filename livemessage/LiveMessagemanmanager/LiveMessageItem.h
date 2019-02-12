/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file:LiveMessageItem.h
 *   desc: 直播聊天消息item
 */

#pragma once

#include "LMPrivateMsgItem.h"
#include "LMWarningItem.h"
#include "LMSystemItem.h"
#include "LMTimeMsgItem.h"
#include "ILiveMessageDef.h"
#include <httpcontroller/HttpRequestController.h>
#include <ImClient/IImClient.h>

#include <string>
#include <list>
using namespace std;
typedef list<LMPrivateMsgSupportType>   PrivateSupportTypeList;
class Record;
class IAutoLock;
class LMUserItem;
class LiveMessageItem
{
public:

public:
    LiveMessageItem();
    virtual ~LiveMessageItem();

public:
    // 初始化,
    bool Init(
            int sendMsgId
            , int msgId
            , LMSendType sendType
            , const string& fromId
            , const string& toId
            , LMStatusType statusType);
    // http私信消息更新私信信息
    bool UpdateMessage(const HttpPrivateMsgItem& item, LMSendType sendType);
    // IM私信消息更新私信信息
    bool UpdateMessageFromIm(const IMPrivateMessageItem& item, LMSendType sendType);
    //发送私信消息更新私信信息
    bool UpdateMessageFromSend(const string& fromId, const string& toId, const string& message, int sendMsgId);
    // 设置sendMsgId
    bool SetSendMsgId(int sendMsgId);
    // 获取生成时间
    static long GetCreateTime();
    // 更新生成时间
    void RenewCreateTime();
    // 设置服务器当前数据库时间
    static void SetDbTime(long dbTime);
    // 把服务器时间转换为手机时间
    static long GetLocalTimeWithServerTime(long serverTime);
    // 设置私信类型列表
    static void SetSupportMsgTypeList(PrivateSupportTypeList supportList);

    // 设置发送item的处理状态
    void SetSendPrivateHandleStatus(LMStatusType status);
    // 重置所有成员变量
    void Clear();
    // 排序函数
    static bool Sort(const LiveMessageItem* item1, const LiveMessageItem* item2);
    // 判断是否是私信聊天类型
    bool IsLiveChatPrivateMsgType();
    
    // 判断是否支持私信类型
    bool IsSupportPrivateMsgType(LMPrivateMsgSupportType type);
    // IM 私信类型转LM私信类型
    LMPrivateMsgSupportType IMPrivateMsgTypeToLMPrivateMsgType(IMPrivateMsgType type);
    // HTTP 私信类型转LM私信类型
    LMPrivateMsgSupportType HTTPPrivateMsgTypeToLMPrivateMsgType(PrivateMsgType type);
    
    //------------------ 获取和设置Msgitem的私密属性 begin-------------
    // 设置私信item
    void SetPrivateMsgItem(LMPrivateMsgItem* thePrivateItem);
    // 获取私信item
    LMPrivateMsgItem* GetPrivateMsgItem() const;
    // 设置warning item
    void SetWarningItem(LMWarningItem* theWarningItem);
    // 获取警告item
    LMWarningItem* GetWarningItem() const;
    // 设置系统消息item
    void SetSystemItem(LMSystemItem* theSystemItem);
    // 获取系统消息item
    LMSystemItem* GetSystemItem() const;
    // 设置时间itm
    void SetTimeMsgItem(LMTimeMsgItem* theTimeMsgItem);
    // 获取时间消息item
    LMTimeMsgItem* GetTimeMsgItem() const;
    // 设置用户item
    void SetUserItem(LMUserItem* theUserItem);
    // 获取用户item
    LMUserItem* GetUserItem() const;
    //------------------ 获取和设置Msgitem的私密属性 end----------------
    
    
    // 状态加锁
    void Lock();
    // 状态解锁
    void Unlock();

public:
    int              m_sendMsgId;   // 本地消息ID （本地作为唯一标识符）
    int              m_msgId;       // 消息ID
    LMSendType       m_sendType;    // 消息发送方向
    string           m_fromId;      // 发送者ID
    string           m_toId;        // 接收者ID
//    string           m_nickName;    // 对方的昵称
//    string           m_avatarImg;   // 对方头像URL
    long             m_createTime;    // 接收/发送时间
    LMStatusType     m_statusType;    // 处理状态
    LCC_ERR_TYPE     m_sendErr;       // 发送的错误码
    LMMessageType    m_msgType;       // 消息类型
    //ProcResult        m_procResult;    // 处理(发送/接收/购买)结果
    
    IAutoLock*        m_updateLock;     // 消息修改锁(用于用户数据改变),一般用在外面，里面不加
    
private:
    LMPrivateMsgItem*   m_textItem;        // 私信item
    LMWarningItem*      m_warningItem;     // 警告item
    LMSystemItem*       m_systemItem;      // 系统消息item
    LMTimeMsgItem*      m_timeMsgItem;     // 时间消息item

    LMUserItem*         m_userItem;         // 用户item
    static long         m_diffTime;         // 服务器数据库当前时间
    static int          m_privateMsgSupportList;  // 私信支持类型组
    
};
typedef list<LiveMessageItem*>    LMMessageList;



