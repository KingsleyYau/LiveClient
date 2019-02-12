/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMUserItem.cpp
 *   desc: 直播用户item
 */

#include "LMUserItem.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

string LMUserItem::m_privateNotice = "";
LMUserItem::LMUserItem()
{
    m_refreshMark = true;
	m_userId = "";
	m_userName = "";
    m_imageUrl = "";
	m_onlineStatus = ONLINE_STATUS_UNKNOWN;
	m_lastMsg = "";
	m_updateTime = 0;
	m_unreadNum = 0;
	m_isAnchor = false;
    
    m_minMsgId = -1;         // 在列表中最小msgId
    m_maxMsgId = -1;         // 在列表中最大的msgId
    m_maxRecvMsgId = -1;
    m_maxReadMsgId = -1;
    m_maxSuccessReadmsgId = -1;
    
	m_tryingSend = false;
	m_order = 0;
    
    
    m_requestHandleType = LMRequstHandleType_Unknow;
    
    m_isHasMoreMsg = true;
    
	m_msgListLock = IAutoLock::CreateAutoLock();
	if (NULL != m_msgListLock) {
		m_msgListLock->Init();
	}

	m_sendMsgListLock = IAutoLock::CreateAutoLock();
	if (NULL != m_sendMsgListLock) {
		m_sendMsgListLock->Init();
	}
    
   	m_statusLock = IAutoLock::CreateAutoLock();
    if (NULL != m_statusLock) {
        m_statusLock->Init(IAutoLock::IAutoLockType_Recursive);
    }
    
    m_requestListLock = IAutoLock::CreateAutoLock();
    if (NULL != m_requestListLock) {
        m_requestListLock->Init();
    }
    
}

LMUserItem::~LMUserItem()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::~LMUserItem() begin");
	ClearMsgList();
	IAutoLock::ReleaseAutoLock(m_msgListLock);
	IAutoLock::ReleaseAutoLock(m_sendMsgListLock);
    IAutoLock::ReleaseAutoLock(m_statusLock);
    IAutoLock::ReleaseAutoLock(m_requestListLock);
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::~LMUserItem() end");
}

// 聊天消息列表加锁
void LMUserItem::LockMsgList()
{
	if (NULL != m_msgListLock) {
		m_msgListLock->Lock();
	}
}

// 聊天消息列表解徜
void LMUserItem::UnlockMsgList()
{
	if (NULL != m_msgListLock) {
		m_msgListLock->Unlock();
	}
}

// 待发送消息列表加锁
void LMUserItem::LockSendMsgList()
{
	if (NULL != m_sendMsgListLock) {
		m_sendMsgListLock->Lock();
	}
}

// 待发送消息列表解锁
void LMUserItem::UnlockSendMsgList()
{
	if (NULL != m_sendMsgListLock) {
		m_sendMsgListLock->Unlock();
	}
}


// 状态加锁
void LMUserItem::Lock() {
    if (NULL != m_statusLock) {
        m_statusLock->Lock();
    }
}

// 状态解锁
void LMUserItem::Unlock() {
    if (NULL != m_statusLock) {
        m_statusLock->Unlock();
    }
}

// 请求列表加锁
void LMUserItem::LockRequestList() {
    if (NULL != m_requestListLock) {
        m_requestListLock->Lock();
    }
}
// 请求列表解锁
void LMUserItem::UnlockRequestList() {
    if (NULL != m_requestListLock) {
        m_requestListLock->Unlock();
    }
}

// 设置请求的处理状态
void LMUserItem::SetHandleRequestType(LMRequstHandleType type) {
    m_requestHandleType = type;
}

LMRequstHandleType LMUserItem::GetHandleRequestType() {
    return m_requestHandleType;
}

bool LMUserItem::AddRequestMap(int requestId, LMMessageListType type) {
    bool result = false;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::AddRequestMap(userId:%s, m_requestList.size:%d, type:%d, requestId:%d) begin", m_userId.c_str(), m_requestMap.size(), type, requestId);
    LockRequestList();
    bool isHas = false;
    // 这个是被动更新请求
    //if (type == LMMessageListType_Update) {
        for (RequestPrivateMsgMap::const_iterator iter = m_requestMap.begin(); iter != m_requestMap.end(); iter++) {
            if (type == (*iter).second) {
                isHas = true;
                break;
            }
        }
    //}

    if (!isHas) {
        m_requestMap.insert(RequestPrivateMsgMap::value_type(requestId, type));
    }
    
    UnlockRequestList();
    result = !isHas;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::AddRequestMap(userId:%s, m_requestList.size:%d , result:%d) end", m_userId.c_str(), m_requestMap.size(), result);
    return result;
}

// 获取最新的私信请求（返回ture 可以请求， false 为不能请求（可能本用户已经在请求私信请求接口中， 也可能没有请求队列））
bool  LMUserItem::GetNewRequest(string& toId, string& startMsg, PrivateMsgOrderType& order, int& limit, int& reqId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetNewRequest(userItem:%p userId:%s) begin", this, m_userId.c_str());
    bool result = false;
    toId = m_userId;
    LMMessageListType type = LMMessageListType_Unknow;
    int startMsgInt = -1;
    LockRequestList();
    RequestPrivateMsgMap::iterator iter = m_requestMap.begin();
    if (iter != m_requestMap.end()) {
        type = (*iter).second;
        reqId = (*iter).first;
    }

    UnlockRequestList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetNewRequest(userItem:%p userId:%s) m_requestList.size();%d, type:%d m_requestHandleType:%d reqId:%d m_refreshMark:%d begin", this, m_userId.c_str(), m_requestMap.size(), type, m_requestHandleType, reqId, m_refreshMark);
    // 判断是否有私信请求没有完成
    if (m_requestHandleType != LMRequstHandleType_Processing) {
        if (type == LMMessageListType_Refresh) {
            if (m_refreshMark) {
                if (m_maxMsgId >= 0) {
                    order = PRIVATEMSGORDERTYPE_NEW;
                    limit = 0;
                }
                startMsgInt = m_maxMsgId;
                result = true;
            }

        }
        else if (type == LMMessageListType_More) {
            if (m_minMsgId >= 0) {
                order = PRIVATEMSGORDERTYPE_OLD;
                startMsgInt = m_minMsgId;
               
            }
            result = true;
        }
        else if (type == LMMessageListType_Update) {
            if (m_refreshMark) {
                if (m_maxMsgId >= 0) {
                    order = PRIVATEMSGORDERTYPE_NEW;
                    limit = 0;
                }
                startMsgInt = m_maxMsgId;
                result = true;
            }
        }
    }
    if (startMsgInt >= 0) {
        char temp[16];
        snprintf(temp, sizeof(temp), "%d", startMsgInt);
        startMsg = temp;
    }

    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetNewRequest(userItem:%p userId:%s, result:%d toId:%s startMsg:%s order:%d limit:%d, type:%d m_refreshMark:%d) end", this, m_userId.c_str(), result, toId.c_str(), startMsg.c_str(), order, limit, type, m_refreshMark);
    return result;
}

// 处理上层接收到的私信消息
LiveMessageItem* LMUserItem::GetRecvPrivateMsg(const IMPrivateMessageItem& item) {
FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetRecvPrivateMsg(item.msgId:%d Mm_maxRecvMsgId:%d)begin", item.msgId,  m_maxRecvMsgId);
    bool isHasItem = false;
    LiveMessageItem* MsgItem = NULL;
    LockMsgList();
    // 判断在本地消息列表中是否存在
    for (LMMessageList::iterator iter = m_msgList.begin();
         iter != m_msgList.end();
         iter++) {
        if (item.msgId == (*iter)->m_msgId) {
            MsgItem = (*iter);
            isHasItem = true;
            break;
        }
    }
    
   // 判断是否在接收私信消息列表中存在
    if (!isHasItem) {
        for (LMMessageList::iterator handleIter = m_handleMsgList.begin();
             handleIter != m_handleMsgList.end();
             handleIter++) {
            if (item.msgId == (*handleIter)->m_msgId) {
                MsgItem = (*handleIter);
                isHasItem = true;
                break;
            }
        }
    }
    
    if (!isHasItem) {
        MsgItem = new LiveMessageItem();
        MsgItem->SetUserItem(this);
        MsgItem->Lock();
        MsgItem->UpdateMessageFromIm(item, LMSendType_Recv);
        MsgItem->Unlock();
        m_maxRecvMsgId = MsgItem->m_msgId;
        m_handleMsgList.push_back(MsgItem);
    }
    
    UnlockMsgList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetRecvPrivateMsg(item.msgId:%d Mm_maxRecvMsgId:%d)end", item.msgId,  m_maxRecvMsgId);
    return MsgItem;
}

// 获取重发的发送私信的消息item, userId为用户userId，
LMMessageList LMUserItem::GetRepeatSendPrivateMsg(int sendMsgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetRepeatSendPrivateMsg(sendMsgId:%d)begin, m_msgList.size:%d", sendMsgId, m_msgList.size());
    LMMessageList msgList;
    LiveMessageItem* MsgItem = NULL;
    LockMsgList();
    for (LMMessageList::const_iterator iter = m_msgList.begin(); iter != m_msgList.end(); iter++) {
        if ( (*iter)->m_sendMsgId == sendMsgId) {
            MsgItem = (*iter);
            break;
        }
    }
    UnlockMsgList();
    if (NULL != MsgItem) {
        MsgItem->Lock();
        MsgItem->UpdateMessageFromSend(MsgItem->m_fromId, m_userId, MsgItem->GetPrivateMsgItem()->m_message, MsgItem->m_sendMsgId);
        MsgItem->Unlock();
        LockMsgList();
        m_msgList.remove(MsgItem);
        m_msgList.push_back(MsgItem);
        SetUserItemLastMsg(MsgItem->m_createTime, MsgItem->GetPrivateMsgItem()->m_message);
        UnlockMsgList();
        msgList = AgainInsertTimeMsgList();
    }
       FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetRepeatSendPrivateMsg(sendMsgId:%d)end, m_msgList.size:%d", sendMsgId, m_msgList.size());
    return msgList;
}

// 设置插入msgList队列的最大和最大值
void LMUserItem::SetInsertListMsgIdMinAndMax(int msgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::SetInsertListMsgIdMinAndMax(im_minMsgId:%d m_maxMsgId:%d)begin", m_minMsgId,  m_maxMsgId);
    if (msgId >= 0) {
        if (m_minMsgId < 0) {
            m_minMsgId = msgId;
        } else {
            m_minMsgId = (m_minMsgId <= msgId ? m_minMsgId : msgId);
        }
        if (m_maxMsgId < 0) {
            m_maxMsgId = msgId;
        } else {
            m_maxMsgId = (m_maxMsgId >= msgId ? m_maxMsgId : msgId);
        }
    }
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::SetInsertListMsgIdMinAndMax(m_minMsgId:%d m_maxMsgId:%d)end", m_minMsgId,  m_maxMsgId);
}



// 判断是否需要插入
bool LMUserItem::IsInsertTimeMsgItem(LiveMessageItem* msg1, LiveMessageItem* msg2) {
    bool result = false;
    if (msg1 == NULL) {
        result = true;
    } else {

        if (msg1->GetTimeMsgItem()) {
            if (msg1->GetTimeMsgItem()->m_msgTime > msg2->m_createTime) {
                //diffTime = msg1->m_createTime - msg2->m_createTime;
                result = true;
            } else {
                if(msg2->m_createTime - msg1->GetTimeMsgItem()->m_msgTime >= 10*60 ) {
                    result = true;
                }
            }
        }
    }
    return result;
}

// 插入其他本地消息（如系统提示，余额不足）
LiveMessageItem* LMUserItem::InsertOtherMessage(LMMessageType msgType, const string& message, LMWarningType warnType, long updateTime, LMSystemType systemType) {
    LiveMessageItem* msgItem = new LiveMessageItem;
    msgItem->Init(-1, -1, LMSendType_Recv, m_userId, "", LMStatusType_Finish);
    msgItem->SetUserItem(this);
    switch (msgType) {
        case LMMT_SystemWarn:{
            LMSystemItem* systemItem = new LMSystemItem;
            systemItem->Init(message, systemType);
            msgItem->SetSystemItem(systemItem);
        }
            break;
        case LMMT_Time:{
            LMTimeMsgItem* timeMsgItem = new LMTimeMsgItem;
            timeMsgItem->Init(updateTime);
            msgItem->SetTimeMsgItem(timeMsgItem);
        }
            break;
        case LMMT_Warning:
        {
            LMWarningItem* warningItem = new LMWarningItem;
            warningItem->Init(warnType);
            msgItem->SetWarningItem(warningItem);
        }
            break;
        default:
            break;
    }
    return msgItem;
}

// 私信列表重新插入时间item
LMMessageList LMUserItem::AgainInsertTimeMsgList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::AgainInsertTimeMsgList()begin, m_msgList.size:%d", m_msgList.size());
    LMMessageList msgList;
    LockMsgList();
    for (LMMessageList::const_iterator iter = m_msgList.begin(); iter != m_msgList.end();) {
        LMMessageList::const_iterator iter_e = iter++;
        LiveMessageItem* msgItem = (*iter_e);
        if (msgItem->m_msgType == LMMT_Time) {
            m_msgList.remove(msgItem);
            delete (msgItem);
            msgItem = NULL;
        }
    }
    LiveMessageItem* tempItem = m_msgList.front();
    //LiveMessageItem* tempItem = NULL;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::AgainInsertTimeMsgList()begin, m_msgList.size:%d", m_msgList.size());
    for (LMMessageList::const_iterator iterItem = m_msgList.begin(); iterItem != m_msgList.end(); iterItem++) {
        LiveMessageItem* msgItem = (*iterItem);
        bool isInsert = false;
        if (tempItem == msgItem) {
            if (msgItem->IsLiveChatPrivateMsgType()) {
                isInsert = true;
            } else {
                tempItem = NULL;
            }
        } else {
            isInsert = IsInsertTimeMsgItem(tempItem, msgItem);
        }
        if (isInsert) {
            LiveMessageItem* insertItem = InsertOtherMessage(LMMT_Time, "", LMWarningType_Unknow, msgItem->m_createTime);
            msgList.push_back(insertItem);
            tempItem = insertItem;
        }
        msgList.push_back(msgItem);
        
    }
    m_msgList.clear();
    for (LMMessageList::const_iterator tempIter = msgList.begin(); tempIter != msgList.end(); tempIter++) {
        m_msgList.push_back(*tempIter);
    }
    
    UnlockMsgList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::AgainInsertTimeMsgList()end, m_msgList.size:%d msgList:%d",  m_msgList.size(), msgList.size());
    return msgList;
}

// 获取私信队列最近一个timeitem（是否是从后面算起）
LiveMessageItem* LMUserItem::GetMsgListLastTimeItme(bool isFromBack) {
    LiveMessageItem* tmpItem = NULL;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetMsgListLastTimeItme()begin, m_msgList.size:%d isFromBack:%d", m_msgList.size(), isFromBack);
    if (isFromBack) {
        for (LMMessageList::reverse_iterator iter = m_msgList.rbegin();
             iter != m_msgList.rend();
             iter++) {
            if ((*iter)->m_msgType == LMMT_Time) {
                tmpItem = (*iter);
                break;
            }
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::GetMsgListLastTimeItme()end, m_msgList.size:%d", m_msgList.size());
    return tmpItem;
    
}

// 设置最新用户消息
void LMUserItem::SetUserItemLastMsg(long time, const string& msg) {
    if (m_updateTime < time) {
        m_updateTime = time;
        m_lastMsg = msg;
    }

}

// 插入待发队列
void LMUserItem::InsertSendingList(LiveMessageItem* msgItem) {
    //LockSendMsgList();
    m_sendMsgList.push_back(msgItem);
    //UnlockSendMsgList();
}

// 设置私信聊天界面没有聊天记录时的提示
void LMUserItem::SetPrivateNotice(const string& privateNotice) {
    m_privateNotice = privateNotice;
}

// -------------- 私信联系人列表用户信息 公开操作 begin --------------------------------
// 根据UserInfo更新私信信息
bool LMUserItem::UpdateWithUserInfo(const string& userId, const string& nickName, const string& avatarImg, const string& msg, long sysTime, OnLineStatus onLineStatus, bool isAnchor, long diffTime, bool isUpdateMark)
{
    bool result = false;
    if ( m_userId.length() > 0 && m_userId == userId) {
        if (nickName.length() > 0) {
            m_userName = nickName;
        }
        if (avatarImg.length() > 0) {
            m_imageUrl = avatarImg;
        }
        if (onLineStatus != ONLINE_STATUS_UNKNOWN) {
            m_onlineStatus = onLineStatus;
        }
//        if (msg.length() > 0) {
//            m_lastMsg = msg;
//        }
        SetLastUpdateTime(isUpdateMark, sysTime, diffTime, msg);
        m_isAnchor =isAnchor;
        result = true;
    }
    return result;
}

// 设置没读数
void LMUserItem::SetUnreadNum(int num) {
    m_unreadNum = num;
}

// 设置最后更新时间
void LMUserItem::SetLastUpdateTime(bool isUpdateMark, long sysTime, long diffTime, const string& msg) {
    if (isUpdateMark) {
        SetUserItemLastMsg(sysTime + diffTime, msg);
        //m_updateTime = (sysTime + diffTime ) ;
    } else {
        m_UnsnyUpdateTime = sysTime;
    }
}

// 判断是否要请求设置最大msgId已读
bool LMUserItem::IsSetMaxReadMsgId(int& msgId) {
    bool result = false;
    Lock();
    if(m_maxReadMsgId < m_maxMsgId) {
        result = true;
        m_maxReadMsgId = m_maxMsgId;
        msgId = m_maxReadMsgId;
    }
    Unlock();
    return result;
}

// 根据接口成功是否更新已读和设置已读最大msgId
void LMUserItem::UpdateReadMsgId(bool success) {
    if (success) {
        m_maxSuccessReadmsgId = m_maxReadMsgId;
    } else {
        m_maxReadMsgId = m_maxSuccessReadmsgId;
    }
}

// 内部更新没读数
void LMUserItem::UpdateUnreadNum() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateUnreadNum(m_maxSuccessReadmsgId:%d m_refreshMark:%d m_unreadNum:%d) begin", m_maxSuccessReadmsgId, m_refreshMark, m_unreadNum);
    if (m_maxSuccessReadmsgId > 0 && !m_refreshMark) {
        LockMsgList();
        int unReadNum = 0;
        for (LMMessageList::const_iterator iter = m_msgList.begin(); iter != m_msgList.end(); iter++) {
            if ((*iter)->IsLiveChatPrivateMsgType() && (*iter)->m_sendType == LMSendType_Recv && (*iter)->m_msgId > m_maxSuccessReadmsgId) {
                unReadNum++;
            }
        }
        m_unreadNum = unReadNum;
        UnlockMsgList();
    }
     FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateUnreadNum(m_maxSuccessReadmsgId:%d m_refreshMark:%d m_unreadNum:%d) end", m_maxSuccessReadmsgId, m_refreshMark, m_unreadNum);
}

// -------------- 私信联系人列表用户信息 公开操作 end ------------------------------------------------------------------------------------------------------------

// -------------- 私信消息列表 公开操作 begin --------------------------------
// 获取聊天记录列表（已按时间排序）
LMMessageList LMUserItem::GetMsgList()
{
	LockMsgList();
    LMMessageList tempList;
    for(LMMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        LiveMessageItem* item = *itr;
        tempList.push_back(item);
    }
	UnlockMsgList();
	return tempList;
}

// 清除所有聊天记录
void LMUserItem::ClearMsgList()
{
    LockMsgList();
    
    for (LMMessageList::iterator iter = m_msgList.begin();
         iter != m_msgList.end();
         iter ++)
    {
        LiveMessageItem* item = *iter;
        
        (*iter)->Clear();
        delete (*iter);
    }
    m_msgList.clear();
    UnlockMsgList();
}

// 根据消息ID获取LCMessageItem
LiveMessageItem* LMUserItem::GetMsgItemWithId(int msgId)
{
    LiveMessageItem* item = NULL;
    
    LockMsgList();
    
    for (LMMessageList::iterator iter = m_msgList.begin();
         iter != m_msgList.end();
         iter++)
    {
        if ((*iter)->m_msgId == msgId) {
            item = (*iter);
        }
    }
    
    UnlockMsgList();
    
    return item;
}

// 根据发送消息ID获取LCMessageItem
LiveMessageItem* LMUserItem::GetSendMsgItemWithId(int sendMsgId)  {
    LiveMessageItem* item = NULL;
    LockMsgList();
    for (LMMessageList::iterator iter = m_msgList.begin();
         iter != m_msgList.end();
         iter++)
    {
        if ((*iter)->m_sendMsgId == sendMsgId) {
            item = (*iter);

        }
    }
    UnlockMsgList();
    return item;
}

// 排序插入聊天记录
LMMessageList LMUserItem::InsertMsgList(LiveMessageItem* item)
{
    LMMessageList msgList;
    bool isHas = false;
    LockMsgList();
    for(LMMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        if (item == (*itr)) {
            isHas = true;
            break;
        }
    }
    
    if (!isHas) {
        //因为（m_handleMsgList 里面的item 和 m_msgList不会同时存在的，所以当m_msgList不存在时，m_handleMsgList就会存在item） 删除消息,插入消息
        m_handleMsgList.remove(item);
        SetInsertListMsgIdMinAndMax(item->m_msgId);
        LiveMessageItem* msg1 = GetMsgListLastTimeItme(true);
        bool isInsert = IsInsertTimeMsgItem(msg1, item);
        if (isInsert) {
            LiveMessageItem* InsertItem = InsertOtherMessage(LMMT_Time, "", LMWarningType_Unknow, item->m_createTime);
            if (InsertItem != NULL) {
                m_msgList.push_back(InsertItem);
                msgList.push_back(InsertItem);
            }
        }
        m_msgList.push_back(item);
        msgList.push_back(item);
    }
    
    UnlockMsgList();
    
    return msgList;
}

// 创建发送私信的消息item
LMMessageList LMUserItem::GetSendPrivateMsg(const string& userId, const string& message, int sendMsgId) {
    LMMessageList msgList;
    LiveMessageItem* MsgItem = new LiveMessageItem();
    if (NULL != MsgItem) {
        MsgItem->SetUserItem(this);
        MsgItem->Lock();
        MsgItem->UpdateMessageFromSend(userId, m_userId, message, sendMsgId);
//        m_updateTime = MsgItem->m_createTime;
//        m_lastMsg = MsgItem->GetPrivateMsgItem()->m_message;
        SetUserItemLastMsg(MsgItem->m_createTime, MsgItem->GetPrivateMsgItem()->m_message);
        MsgItem->Unlock();
        LockMsgList();
        LiveMessageItem* msg1 = GetMsgListLastTimeItme(true);
        bool isInsert = IsInsertTimeMsgItem(msg1, MsgItem);
        if (isInsert) {
            LiveMessageItem* InsertItem = InsertOtherMessage(LMMT_Time, "", LMWarningType_Unknow, MsgItem->m_createTime);
            if (InsertItem != NULL) {
                m_msgList.push_back(InsertItem);
                msgList.push_back(InsertItem);
            }
        }
        m_msgList.push_back(MsgItem);
        msgList.push_back(MsgItem);
        UnlockMsgList();
//        LockSendMsgList();
//        m_sendMsgList.push_back(MsgItem);
//        UnlockSendMsgList();
    }
    
    return msgList;
}

// 更新私信队列
LMMessageList LMUserItem::UpdateMessageList(const HttpPrivateMsgList& list,LMMessageListType& type, bool success, LMMessageList& moreList) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateMessageList(list.size():%d ) begin", list.size());
    LMMessageList tempList;
    int MaxMsgId = -1;
    LiveMessageItem* tempMsgItem = NULL;
    
    RequestPrivateMsgMap::iterator iter = m_requestMap.begin();
    if (iter != m_requestMap.end()) {
        type = (*iter).second;
        int reqId = (*iter).first;
        if (type == LMMessageListType_Refresh || type == LMMessageListType_Update) {
            tempMsgItem = GetMsgListLastTimeItme(true);
        }
        LockMsgList();
        if (success && list.size() < PRIVATEMESSAGE_LIMIT) {
            bool result = false;
            if (m_msgList.size() > 0) {
                if (m_msgList.front()->GetSystemItem() == NULL) {
                    for (LMMessageList::const_iterator itr= m_msgList.begin(); itr != m_msgList.end(); itr++) {
                        if ((*itr)->GetPrivateMsgItem() != NULL && (*itr)->m_statusType == LMStatusType_Finish) {
                            result = true;
                            break;
                        }
                    }
                    
                } else {
                    result = true;
                }
            }
            if (!result) {
                LiveMessageItem* InsertItem = InsertOtherMessage(LMMT_SystemWarn, m_privateNotice, LMWarningType_Unknow);
                if (InsertItem != NULL) {
                    moreList.push_back(InsertItem);
                    InsertMessageMore(moreList);
                    m_isHasMoreMsg = false;
                }
            }
        }
        UnlockMsgList();
        for (HttpPrivateMsgList::const_iterator iter = list.begin();
             iter != list.end();
             iter++) {
            //FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateMessageList(list.size();%d MaxMsgId:%d msgId:%d msgType:%d) begin", list.size(), MaxMsgId, ((*iter).msgId), (*iter).msgType);
            if (MaxMsgId < ((*iter).msgId)) {
                MaxMsgId = ((*iter).msgId);
            }
            LiveMessageItem* MsgItem = GetNewLiveMessageItem(*iter);
            if (MsgItem != NULL) {
                bool isInsert = IsInsertTimeMsgItem(tempMsgItem, MsgItem);
                if (isInsert) {
                    LiveMessageItem* InsertItem = InsertOtherMessage(LMMT_Time, "", LMWarningType_Unknow, MsgItem->m_createTime);
                    if (InsertItem != NULL) {
                        tempList.push_back(InsertItem);
                        tempMsgItem = InsertItem;
                    }
                }
                
                tempList.push_back(MsgItem);
            }
        }
        
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateMessageList(list.size();%d MaxMsgId:%d, m_maxRecvMsgId:%d type:%d m_refreshMark:%d)", list.size(),  MaxMsgId, m_maxRecvMsgId, type, m_refreshMark);
        if (success) {
            switch (type) {
                case LMMessageListType_Refresh:
                {
                    LockMsgList();
                    if (m_refreshMark) {
                        m_refreshMark = ((MaxMsgId >= m_maxRecvMsgId && MaxMsgId >= m_maxMsgId) ? false : true);
                        if (success && list.size() <= 0 ) {
                            m_refreshMark = false;
                        }
                        
                    }
                    InsertMessageRefresh(tempList);
                    UnlockMsgList();
                    
                }
                    break;
                    
                case LMMessageListType_More:
                {
                    LiveMessageItem* tempItem = m_msgList.front();
                    if (tempItem != NULL && tempItem->m_msgType != LMMT_SystemWarn) {
                        if (tempList.size() == 0) {
                            LiveMessageItem* InsertItem = InsertOtherMessage(LMMT_SystemWarn, m_privateNotice, LMWarningType_Unknow);
                            m_isHasMoreMsg = false;
                            tempList.push_back(InsertItem);
                        }
                    }
                    LockMsgList();
                    if (m_refreshMark) {
                        m_refreshMark = ((MaxMsgId >= m_maxRecvMsgId) ? false : true);
                    }
                    InsertMessageMore(tempList);
                    UnlockMsgList();
                }
                    break;
                    
                case LMMessageListType_Update:
                {
                    
                    LockMsgList();
                    if (m_refreshMark) {
                        m_refreshMark = ((MaxMsgId >= m_maxRecvMsgId && MaxMsgId >= m_maxMsgId) ? false : true);
                        if (success && list.size() <= 0 ) {
                            m_refreshMark = false;
                        }
                    }
                    InsertMessageRefresh(tempList);
                    
                    
                    UnlockMsgList();
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
        LockRequestList();
        m_requestMap.erase(iter);
        UnlockRequestList();
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserItem::UpdateMessageList(list.size();%d MaxMsgId:%d, m_maxRecvMsgId:%d m_refreshMark:%d) end", list.size(), MaxMsgId, m_maxRecvMsgId, m_refreshMark);
    return tempList;
}

// -------------- 私信消息列表 公开操作 end --------------------------------

// 比较函数
bool LMUserItem::Sort(LMUserItem* item1, LMUserItem* item2)
{
	// true在前，false在后
	bool result = false;

	item1->LockMsgList();
	item2->LockMsgList();

    // 更是最后时间排序
    result = item1->m_updateTime >= item2->m_updateTime;
    
	item2->UnlockMsgList();
	item1->UnlockMsgList();

	return result;
}

// 将http的私信转换为liveMessageItem
LiveMessageItem* LMUserItem::GetNewLiveMessageItem(const HttpPrivateMsgItem& item) {
    LiveMessageItem* MsgItem = NULL;
    bool isSend = (item.toId == m_userId);
    LockMsgList();
    bool isHasItem = false;
    if (!isSend) {
        for (LMMessageList::iterator iter = m_handleMsgList.begin();
             iter != m_handleMsgList.end();
             iter++) {
            if (item.msgId == (*iter)->m_msgId) {
                MsgItem = (*iter);
                isHasItem = true;
                m_handleMsgList.remove((*iter));
                break;
            }
        }
    } else {
        for (LMMessageList::iterator msgIter = m_msgList.begin();
             msgIter != m_msgList.end();
             msgIter++) {
            if (item.msgId == (*msgIter)->m_msgId) {
                MsgItem = (*msgIter);
                isHasItem = true;
                break;
            }
        }
    }

    UnlockMsgList();
    LMSendType type = isSend ? LMSendType_Send : LMSendType_Recv;
    if (!isHasItem) {
        MsgItem = new LiveMessageItem();
        MsgItem->SetUserItem(this);
        MsgItem->Init(-1, item.msgId, type, item.fromId, item.toId, LMStatusType_Finish);
    }

    MsgItem->Lock();
    MsgItem->UpdateMessage(item, type);
    MsgItem->Unlock();
    return MsgItem;
}

// 将刷新的消息列表插入本地消息列表
void LMUserItem::InsertMessageRefresh(LMMessageList& msgList) {
    for (LMMessageList::iterator iter = msgList.begin();
         iter != msgList.end();
         iter++) {
        SetInsertListMsgIdMinAndMax((*iter)->m_msgId);
        m_msgList.push_back(*iter);
    }
}

// 将更多的消息列表插入本地消息列表
void LMUserItem::InsertMessageMore(LMMessageList& msgList) {
//    for (LMMessageList::iterator iter = msgList.begin();
//         iter != msgList.end();
//         iter++) {
//        SetInsertListMsgIdMinAndMax((*iter)->m_msgId);
//        m_msgList.push_front(*iter);
//    }
    for (LMMessageList::reverse_iterator iter = msgList.rbegin();
         iter != msgList.rend();
         iter++) {
        SetInsertListMsgIdMinAndMax((*iter)->m_msgId);
        m_msgList.push_front(*iter);
    }
}
