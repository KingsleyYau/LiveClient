/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LiveMessageItem.cpp
 *   desc: 直播聊天消息item
 */

#include "LiveMessageItem.h"
#include "LMUserItem.h"
#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
#include <common/IAutoLock.h>

//using namespace lcmm;

#define PRIVATEMESSAGE_NOTSUPPORTED "(Message of this type is not supported)"


long LiveMessageItem::m_diffTime = 0;
int LiveMessageItem::m_privateMsgSupportList = 0;

LiveMessageItem::LiveMessageItem()
{
    m_sendMsgId = -1;
    m_msgId = -1;
    m_sendType = LMSendType_Unknow;
    m_fromId = "";
    m_toId = "";
    m_createTime = 0;
    m_statusType = LMStatusType_Unprocess;
    m_msgType = LMMT_Unknow;
    //m_inviteType = INVITE_TYPE_CHAT;
    m_sendErr = LCC_ERR_SUCCESS;
    
    m_textItem = NULL;
    m_userItem = NULL;
    m_warningItem = NULL;     // 警告item
    m_systemItem = NULL;      // 系统消息item
    
    m_updateLock = IAutoLock::CreateAutoLock();
    if (NULL != m_updateLock) {
        m_updateLock->Init(IAutoLock::IAutoLockType_Recursive);
    }
    
}

LiveMessageItem::~LiveMessageItem()
{
    Clear();
}

// 初始化
bool LiveMessageItem::Init(
                            int sendMsgId
                            , int msgId
                            , LMSendType sendType
                            , const string& fromId
                            , const string& toId
                            , LMStatusType statusType)
{
    bool result = false;

    m_msgId = msgId;
    m_sendType = sendType;
    m_fromId = fromId;
    m_toId = toId;
    m_statusType = statusType;

    m_createTime = GetCreateTime();
    result = true;

    return result;
}

// 更新私信信息
bool LiveMessageItem::UpdateMessage(const HttpPrivateMsgItem& item, LMSendType sendType) {
    bool result = false;
    m_msgId = item.msgId;
    m_sendType = sendType;
    m_fromId = item.fromId;
    m_toId = item.toId;
    m_createTime = GetLocalTimeWithServerTime(item.addTime);
    m_statusType = LMStatusType_Finish;
    
    if (m_textItem == NULL) {
        LMPrivateMsgItem* privateItem = new LMPrivateMsgItem();
        string msg = item.content;
        if (!IsSupportPrivateMsgType(HTTPPrivateMsgTypeToLMPrivateMsgType(item.msgType))) {
            msg = PRIVATEMESSAGE_NOTSUPPORTED;
        }
        privateItem->Init(msg, sendType == LMSendType_Send);
        SetPrivateMsgItem(privateItem);
    }
    result = true;
    return result;
}

// 更新私信信息
bool LiveMessageItem::UpdateMessageFromIm(const IMPrivateMessageItem& item, LMSendType sendType) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::UpdateMessageFromIm(item.sendTime:ll%d m_diffTime:%lld)begin", item.sendTime,  m_diffTime);
    bool result = false;
    m_msgId = item.msgId;
    m_sendType = sendType;
    m_fromId = item.fromId;
    m_toId = item.toId;
    m_createTime = GetLocalTimeWithServerTime(item.sendTime);
    m_statusType = LMStatusType_Finish;
    if (m_textItem == NULL) {
        LMPrivateMsgItem* privateItem = new LMPrivateMsgItem();
        string msg = item.msg;
        if (!IsSupportPrivateMsgType(IMPrivateMsgTypeToLMPrivateMsgType(item.msgType))) {
            msg = PRIVATEMESSAGE_NOTSUPPORTED;
        }
        privateItem->Init(msg, sendType == LMSendType_Send);
        SetPrivateMsgItem(privateItem);
    }
    result = true;
    return result;
}

//发送私信消息更新私信信息
bool LiveMessageItem::UpdateMessageFromSend(const string& fromId, const string& toId, const string& message, int sendMsgId) {
    bool result = false;
    m_msgId = -1;
    SetSendMsgId(sendMsgId);
    m_sendType = LMSendType_Send;
    m_fromId = fromId;
    m_toId = toId;
    m_createTime = GetCreateTime();
    m_statusType = LMStatusType_Processing;
    m_sendErr = LCC_ERR_SUCCESS;
    if (m_textItem == NULL) {
        LMPrivateMsgItem* privateItem = new LMPrivateMsgItem();
        privateItem->Init(message, true);
        SetPrivateMsgItem(privateItem);
    }
    result = true;
    return result;
}

// 设置sendMsgId
bool LiveMessageItem::SetSendMsgId(int sendMsgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetSendMsgId(sendMsgId:%d LiveMessageItem:%p) begin", sendMsgId, this);
    bool result = false;
    if (m_sendMsgId < 0) {
        m_sendMsgId = sendMsgId;
        result = true;
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetSendMsgId(sendMsgId:%d LiveMessageItem:%p result:%d) end", sendMsgId, this, result);
    return result;
}

// 获取生成时间
long LiveMessageItem::GetCreateTime()
{
    return (long)(getCurrentTime() / 1000);
}

// 更新生成时间
void LiveMessageItem::RenewCreateTime()
{
    m_createTime = GetCreateTime();
}

// 设置服务器当前数据库时间
void LiveMessageItem::SetDbTime(long dbTime)
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetDbTime(m_diffTime:%ld etCreateTime():%lld dbTime:%lld) begin", m_diffTime, GetCreateTime(), dbTime);
    m_diffTime = GetCreateTime() - dbTime;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetDbTime(m_diffTime:%ld ) end", m_diffTime);
}

// 设置私信类型列表
 void LiveMessageItem::SetSupportMsgTypeList(PrivateSupportTypeList supportList) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetSupportMsgTypeList(supportList.size():%d) begin", supportList.size());
     for (PrivateSupportTypeList::iterator iter= supportList.begin(); iter != supportList.end(); iter++) {
         m_privateMsgSupportList |= (int)(*iter);
         }

    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::SetSupportMsgTypeList(m_privateMsgSupportList:%d) begin", m_privateMsgSupportList);
}

// 把服务器时间转换为手机时间
long LiveMessageItem::GetLocalTimeWithServerTime(long serverTime)
{
    long synServerTime = 0;
    if(m_diffTime > 0){
        /*同步服务器时间成功*/
        synServerTime = serverTime + m_diffTime;
    }else {
        /*同步服务器时间失败，使用默认时间*/
        synServerTime = serverTime;
    }
    return synServerTime;
}

// 设置发送item的处理状态
void LiveMessageItem::SetSendPrivateHandleStatus(LMStatusType status) {
    m_statusType = status;
}

// 重置所有成员变量
void LiveMessageItem::Clear()
{
    m_sendMsgId = -1;
    m_msgId = -1;
    m_sendType = LMSendType_Unknow;
    m_fromId = "";
    m_toId = "";
    m_createTime = 0;
    m_statusType = LMStatusType_Unprocess;
    m_msgType = LMMT_Unknow;

    if (m_textItem != NULL) {
        delete m_textItem;
        m_textItem = NULL;
    }
    if (m_systemItem != NULL) {
        delete m_systemItem;
        m_systemItem = NULL;
    }
    if (m_warningItem != NULL) {
        delete m_warningItem;
        m_warningItem = NULL;
    }

    m_userItem = NULL;
}

bool LiveMessageItem::Sort(const LiveMessageItem* item1, const LiveMessageItem* item2)
{
    // true排前面，false排后面
    bool result = false;

    if (item1->m_createTime == item2->m_createTime)
    {
        result = item1->m_msgId < item2->m_msgId;
    }
    else
    {
        result = item1->m_createTime < item2->m_createTime;
    }

    return result;
}

// 判断是否是私信聊天类型
bool LiveMessageItem::IsLiveChatPrivateMsgType() {
    bool result = false;
    switch (m_msgType) {
        case LMMT_Text:
            result = true;
            break;
            
        case LMMT_Warning:
            break;
        case LMMT_SystemWarn:
            break;
        case LMMT_Time:
            break;
            
        default:
            break;
    }
    return result;
}

// 判断是否支持私信类型
bool LiveMessageItem::IsSupportPrivateMsgType(LMPrivateMsgSupportType type) {
    bool result = false;
    result = m_privateMsgSupportList & (int)type;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageItem::IsSupportPrivateMsgType(type:%d result:%d) end", type, result);
    return result;
}

// IM 私信类型转LM私信类型
LMPrivateMsgSupportType LiveMessageItem::IMPrivateMsgTypeToLMPrivateMsgType(IMPrivateMsgType type) {
    LMPrivateMsgSupportType supportType = (LMPrivateMsgSupportType)type;
    return supportType;
}
// HTTP 私信类型转LM私信类型
LMPrivateMsgSupportType LiveMessageItem::HTTPPrivateMsgTypeToLMPrivateMsgType(PrivateMsgType type) {
    LMPrivateMsgSupportType supportType = (LMPrivateMsgSupportType)type;
    return supportType;
}


//------------------ 获取和设置Msgitem的私密属性 begin-------------
// 设置私信item
void LiveMessageItem::SetPrivateMsgItem(LMPrivateMsgItem* thePrivateItem)
{
    if (m_msgType == LMMT_Unknow
        && thePrivateItem != NULL)
    {
        m_textItem = thePrivateItem;
        m_msgType = LMMT_Text;
    }
}

// 获取文本item
LMPrivateMsgItem* LiveMessageItem::GetPrivateMsgItem() const
{
    return m_textItem;
}

// 设置warning item
void LiveMessageItem::SetWarningItem(LMWarningItem* theWarningItem) {
    if (m_msgType == LMMT_Unknow
        && theWarningItem != NULL) {
        m_warningItem = theWarningItem;
        m_msgType = LMMT_Warning;
    }
}

// 获取警告item
LMWarningItem* LiveMessageItem::GetWarningItem() const {
    return m_warningItem;
}

// 设置系统消息item
void LiveMessageItem::SetSystemItem(LMSystemItem* theSystemItem) {
    if (m_msgType == LMMT_Unknow
        && theSystemItem != NULL) {
        m_systemItem = theSystemItem;
        m_msgType = LMMT_SystemWarn;
    }
}

// 获取系统消息item
LMSystemItem* LiveMessageItem::GetSystemItem() const {
    return m_systemItem;
}

// 设置时间itm
void LiveMessageItem::SetTimeMsgItem(LMTimeMsgItem* theTimeMsgItem) {
    if (m_msgType == LMMT_Unknow
        & theTimeMsgItem != NULL) {
        m_timeMsgItem = theTimeMsgItem;
        m_msgType = LMMT_Time;
    }
}

// 获取时间消息item
LMTimeMsgItem* LiveMessageItem::GetTimeMsgItem() const {
    return m_timeMsgItem;
}

// 设置用户item
void LiveMessageItem::SetUserItem(LMUserItem* theUserItem) {
    m_userItem = theUserItem;
}

// 获取用户item
LMUserItem* LiveMessageItem::GetUserItem() const{
    return m_userItem;
}
//------------------ 获取和设置Msgitem的私密属性 end----------------

// 状态加锁
void LiveMessageItem::Lock() {
    if (NULL != m_updateLock) {
        m_updateLock->Lock();
    }
}
// 状态解锁
void LiveMessageItem::Unlock() {
    if (NULL != m_updateLock) {
        m_updateLock->Unlock();
    }
}


