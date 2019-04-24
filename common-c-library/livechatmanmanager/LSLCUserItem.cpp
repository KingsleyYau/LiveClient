/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCUserItem.cpp
 *   desc: LiveChat用户item
 */

#include "LSLCUserItem.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

LSLCUserItem::LSLCUserItem()
{
	m_userId = "";
	m_userName = "";
	m_sexType = USER_SEX_FEMALE;
	m_clientType = CLIENT_ANDROID;
	m_statusType = USTATUS_OFFLINE_OR_HIDDEN;
	m_chatType = LC_CHATTYPE_OTHER;
	m_inviteId = "";
	m_tryingSend = false;
	m_order = 0;
    m_isOpenCam = false;
    
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
    
}

LSLCUserItem::~LSLCUserItem()
{
	ClearMsgList();
	IAutoLock::ReleaseAutoLock(m_msgListLock);
	IAutoLock::ReleaseAutoLock(m_sendMsgListLock);
    IAutoLock::ReleaseAutoLock(m_statusLock);
}

// 聊天消息列表加锁
void LSLCUserItem::LockMsgList()
{
	if (NULL != m_msgListLock) {
		m_msgListLock->Lock();
	}
}

// 聊天消息列表解徜
void LSLCUserItem::UnlockMsgList()
{
	if (NULL != m_msgListLock) {
		m_msgListLock->Unlock();
	}
}

// 待发送消息列表加锁
void LSLCUserItem::LockSendMsgList()
{
	if (NULL != m_sendMsgListLock) {
		m_sendMsgListLock->Lock();
	}
}

// 待发送消息列表解锁
void LSLCUserItem::UnlockSendMsgList()
{
	if (NULL != m_sendMsgListLock) {
		m_sendMsgListLock->Unlock();
	}
}

// 状态加锁
void LSLCUserItem::Lock() {
    if (NULL != m_statusLock) {
        m_statusLock->Lock();
    }
}

// 状态解锁
void LSLCUserItem::Unlock() {
    if (NULL != m_statusLock) {
        m_statusLock->Unlock();
    }
}

// 根据UserInfo更新信息
void LSLCUserItem::UpdateWithUserInfo(const UserInfoItem& item)
{
    m_userName = item.userName;
    m_imageUrl = item.imgUrl;
    m_sexType = item.sexType;
    m_clientType = item.clientType;
    m_statusType = item.status;
    m_order = item.orderValue;
}

// 获取聊天记录列表（已按时间排序）
LCMessageList LSLCUserItem::GetMsgList(string inviteId)
{
	LockMsgList();
//	LCMessageList tempList = m_msgList;
    LCMessageList tempList;
    
    string getInviteId = inviteId;
    if( inviteId.length() == 0 ) {
        getInviteId = m_inviteId;
    }
    
    for(LCMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        LSLCMessageItem* item = *itr;
        bool bFlag = false;

        if( getInviteId == item->m_inviteId ) {
            bFlag = true;
        }
        
        if( bFlag ) {
            tempList.push_back(item);
        }
    }
	UnlockMsgList();
	return tempList;
}


// 根据PhotoId和photo发送方向判断是否是同一个msgItem
void LSLCUserItem::isSamePhotoId(LSLCMessageItem* messageItem)
{
    
    // messageItem判断是否是私密照
    if(messageItem->m_msgType == MT_Photo)
    {
        
//        // 图片列表
        LCMessageList PhotoList;
        // 找出所有男士和女士发出的图片消息
        for (LCMessageList::iterator iter = m_msgList.begin();
             iter != m_msgList.end();
             iter++)
        {
            LSLCMessageItem* item = (*iter);
            if (item->m_msgType == MT_Photo
                && NULL != item->GetPhotoItem()
                && !item->GetPhotoItem()->m_photoId.empty())
            {
                PhotoList.push_back(item);
            }
        }
        
        
        // 遍历消息列表
        for (LCMessageList::iterator iter = PhotoList.begin();
             iter != PhotoList.end();
             iter++)
        {
            LSLCMessageItem* item = (*iter);
            // 判断item是否是私密照
            if (item->m_msgType == MT_Photo
                && NULL != item->GetPhotoItem()
                && !item->GetPhotoItem()->m_photoId.empty())
            {
                // 根据PhotoId和photo发送方向判断是否是同一个msgItem
                if (item->GetPhotoItem()->m_photoId == messageItem->GetPhotoItem()->m_photoId && item->m_sendType == messageItem->m_sendType) {
                    if (item->m_sendType == SendType_Recv) {
                         m_msgList.remove(item);
                    }
                   
                }
            }
        }
    }

}

// 排序插入聊天记录
bool LSLCUserItem::InsertSortMsgList(LSLCMessageItem* item)
{
	LockMsgList();

   // isSamePhotoId(item);
	// 插入消息
	m_msgList.push_back(item);
    
    // 更新以前没有inviteId的信息
    for(LCMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        LSLCMessageItem* oldItem = *itr;
        if( oldItem->m_inviteId.length() == 0 ) {
            oldItem->m_inviteId = m_inviteId;
        }
    }
    
    // 排序
	m_msgList.sort(LSLCMessageItem::Sort);
	// 改变消息的用户
	item->SetUserItem(this);

	UnlockMsgList();

	return true;
}

// 删除聊天记录
bool LSLCUserItem::RemoveSortMsgList(LSLCMessageItem* item)
{
	bool result = false;
	if (NULL != item) {
		LockMsgList();
		m_msgList.remove(item);
		UnlockMsgList();
	}
	return result;
}

// 清除所有聊天记录
void LSLCUserItem::ClearMsgList(string inviteId)
{
	LockMsgList();
    
    string getInviteId = inviteId;
    if( inviteId.length() == 0 ) {
        getInviteId = m_inviteId;
    }
    
	for (LCMessageList::iterator iter = m_msgList.begin();
			iter != m_msgList.end();
			iter ++)
	{
        LSLCMessageItem* item = *iter;
        bool bFlag = false;

        if( getInviteId == item->m_inviteId ) {
            bFlag = true;
        }
        
        if( bFlag ) {
            (*iter)->Clear();
            delete (*iter);
        }

	}
	m_msgList.clear();
	UnlockMsgList();
}

// 清除所有已完成的聊天记录
void LSLCUserItem::ClearFinishedMsgList(string inviteId)
{
	LockMsgList();

    string getInviteId = inviteId;
    if( inviteId.length() == 0 ) {
        getInviteId = m_inviteId;
    }
    
	// 找到所有已完成的聊天记录
	LCMessageList tempList;
	for (LCMessageList::iterator iter = m_msgList.begin();
			iter != m_msgList.end();
			iter++)
	{
        LSLCMessageItem* item = *iter;
        bool bFlag = false;

        if( getInviteId == item->m_inviteId ) {
            bFlag = true;
        }
        
        if( bFlag ) {
            if ((*iter)->m_statusType == StatusType_Finish
                //&& !(*iter)->IsSubItemProcssign()
                && (*iter)->m_msgType != MT_Custom   // 不删除自定义消息(临时处理)
                ){
                
                if ((*iter)->IsSubItemProcssign()) {
                    if (((*iter)->m_msgType == MT_Photo && (*iter)->m_sendType == SendType_Recv) || (*iter)->m_msgType == MT_Video) {
                        tempList.push_back(*iter);
                    }
                    
                }
                else
                {
                    tempList.push_back(*iter);
                }
                
            }
        }
        
        //        if ((*iter)->m_msgType != LSLCMessageItem::MT_Custom) // 不删除自定义消息(临时处理)
//        {
//			tempList.push_back(*iter);
//		}
	}

	// 移除已完成的聊天记录
	for (LCMessageList::iterator tempIter = tempList.begin();
			tempIter != tempList.end();
			tempIter++)
	{
		m_msgList.remove(*tempIter);
		(*tempIter)->Clear();
		delete (*tempIter);
	}

	UnlockMsgList();
}

// 根据消息ID获取LSLCMessageItem
LSLCMessageItem* LSLCUserItem::GetMsgItemWithId(int msgId)
{
	LSLCMessageItem* item = NULL;

	LockMsgList();

	for (LCMessageList::iterator iter = m_msgList.begin();
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

// 设置聊天状态
void LSLCUserItem::SetChatTypeWithEventType(TALK_EVENT_TYPE eventType)
{
	switch (eventType) {
	case TET_ENDTALK:
		m_chatType = LC_CHATTYPE_OTHER;
		break;
	case TET_STARTCHARGE:
		if (m_chatType != LC_CHATTYPE_IN_CHAT_CHARGE
			&& m_chatType != LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET)
		{
			m_chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
		}
		break;
	case TET_STOPCHARGE:
		m_chatType = LC_CHATTYPE_OTHER;
		break;
	case TET_NOMONEY:
	case TET_VIDEONOMONEY:
		m_chatType = LC_CHATTYPE_OTHER;
		break;
	case TET_TARGETNOTFOUND:
		m_chatType = LC_CHATTYPE_OTHER;
		break;
	default:
		break;
	}
}

// 设置聊天状态
void LSLCUserItem::SetChatTypeWithTalkMsgType(bool charge, TALK_MSG_TYPE msgType)
{
	m_chatType = GetChatTypeWithTalkMsgType(charge, msgType);
}

// 设置在线状态
bool LSLCUserItem::SetUserOnlineStatus(USER_STATUS_TYPE statusType)
{
	bool change = false;
	if (m_statusType != statusType) {
		m_statusType = statusType;
		change = true;
	}
	return change;
}

// 根据 TalkMsgType 获取聊天状态
Chat_Type LSLCUserItem::GetChatTypeWithTalkMsgType(bool charge, TALK_MSG_TYPE msgType)
{
	Chat_Type chatType = LC_CHATTYPE_OTHER;
	switch(msgType) {
	case TMT_FREE:
		if (!charge) {
			// TMT_FREE 及 charge=false，则为邀请
			chatType = LC_CHATTYPE_INVITE;
		}
		else {
			// charge=true，则为InChatCharge
			chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
		}
		break;
	case TMT_CHARGE:
		chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
		break;
	case TMT_CHARGE_FREE:
		chatType = LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET;
		break;
	default:
		chatType = LC_CHATTYPE_OTHER;
		break;
	}
	return chatType;
}

// 获取对方发出的最后一条聊天消息
LSLCMessageItem* LSLCUserItem::GetTheOtherLastMessage()
{
	LSLCMessageItem* item = NULL;

	LockMsgList();
	if (!m_msgList.empty())
	{
		for (LCMessageList::iterator iter = m_msgList.begin();
			iter != m_msgList.end();
			iter++)
		{
			if ((*iter)->m_sendType == SendType_Recv)
			{
				item = (*iter);
			}
		}
	}
	UnlockMsgList();

	return item;
}

// 获取对方发出的最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
bool LSLCUserItem::GetOtherUserLastRecvMessage(LSLCMessageItem& messageItem) {
    bool result = false;
    LockMsgList();
    if (!m_msgList.empty())
    {
        
        // 倒序遍历，找到最后一个接收的消息，也从最后一条消息到最后一个接收的消息的队列加进新的队列里
        for (LCMessageList::const_reverse_iterator iter = m_msgList.rbegin();
             iter != m_msgList.rend();
             iter++)
        {
            
            if ((*iter)->m_sendType == SendType_Recv)
            {
                messageItem.InitWithMessageItem(*iter);
                result = true;
                break;
            }
        }
        
        
    }
    UnlockMsgList();
    
    return result;
}
// 获取对方最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
bool LSLCUserItem::GetOtherUserLastMessage(LSLCMessageItem& messageItem) {
    bool result = false;
    LockMsgList();
    
    string getInviteId = m_inviteId;
    
    for(LCMessageList::const_reverse_iterator iter = m_msgList.rbegin(); iter != m_msgList.rend(); iter++) {
        LSLCMessageItem* item = *iter;
        
        if( getInviteId == item->m_inviteId ) {
            if ((*iter)->IsChatMessage()) {
                messageItem.InitWithMessageItem(*iter);
                result = true;
                break;
            }
        }
    }
    UnlockMsgList();
    return result;
}

// 结束聊天处理
void LSLCUserItem::EndTalk()
{
	m_chatType = LC_CHATTYPE_OTHER;
//	ClearMsgList(m_inviteId);
    m_inviteId = "";
}

// 插入待发消息列表
bool LSLCUserItem::InsertSendMsgList(LSLCMessageItem* item)
{
	bool result = false;

	if (NULL != item)
	{
		LockSendMsgList();
		m_sendMsgList.push_back(item);
		result = true;
		UnlockSendMsgList();
	}

	return result;
}

// pop出最前一条待发消息
LSLCMessageItem* LSLCUserItem::PopSendMsgList()
{
	LSLCMessageItem* msgItem = NULL;

	LockSendMsgList();
	if (!m_sendMsgList.empty())
	{
		msgItem = m_sendMsgList.front();
		m_sendMsgList.pop_front();
	}
	UnlockSendMsgList();

	return msgItem;
}

// 是否处于男士邀请状态
bool LSLCUserItem::IsInManInvite() {
    return m_chatType == LC_CHATTYPE_MANINVITE;
}

// 男士邀请可取消状态判断（1.处于男士邀请状态 2.第一条邀请信息据现在已超过1分钟）
bool LSLCUserItem::IsInManInviteCanCancel() {
    bool result = false;
    if(IsInManInvite()){
        LockMsgList();
        LCMessageList tempList;
        if (!m_msgList.empty())
        {
            // 倒序遍历，找到最后一个接收的消息，也从最后一条消息到最后一个接收的消息的队列加进新的队列里
            for (LCMessageList::const_reverse_iterator iter = m_msgList.rbegin();
                 iter != m_msgList.rend();
                 iter++)
            {
                
                if ((*iter)->m_sendType == SendType_Recv)
                {
                    break;
                } else {
                    tempList.push_back(*iter);
                }
            }
            
            
            LSLCMessageItem* tempItem = NULL;
            // 从新的队列中，找到第一条发送的消息（下面新队列的倒序遍历，相当于旧队列的最后一条接收消息开始遍历）
            for (LCMessageList::const_reverse_iterator iter = tempList.rbegin();
                 iter != tempList.rend();
                 iter++)
            {
                
                if ((*iter)->m_sendType == SendType_Send)
                {
                    tempItem = (*iter);
                    break;
                }
            }
            
            // 判断是否为空，而且是否大于60秒
            if (tempItem != NULL && (tempItem->m_createTime + 2 * 60) < tempItem->GetCreateTime()) {
                result = true;
            }
            
        }
        UnlockMsgList();
    }
    return result;
}

// 比较函数
bool LSLCUserItem::Sort(LSLCUserItem* item1, LSLCUserItem* item2)
{
	// true在前，false在后
	bool result = false;

	item1->LockMsgList();
	item2->LockMsgList();

	if (item1->m_msgList.empty() && item2->m_msgList.empty())
	{
		// 默认按名字排序，a优先，z排最后
		result = item1->m_userName <= item2->m_userName;
	}
	else if (!item1->m_msgList.empty() && !item2->m_msgList.empty())
	{
		// 都有消息
		LCMessageList::iterator iter1 = (--item1->m_msgList.end());
		LCMessageList::iterator iter2 = (--item2->m_msgList.end());
		// 按最后一条待发送消息生成时间排序
		result = (*iter1)->m_createTime >= (*iter2)->m_createTime;
	}
	else {
		// 有消息的排前面，已经排序成功
		result = !item1->m_msgList.empty();
	}

	item2->UnlockMsgList();
	item1->UnlockMsgList();

	return result;
}

LCMessageList LSLCUserItem::GetPrivateAndVideoMessageList() {
    LockMsgList();
    //    LCMessageList tempList = m_msgList;
    LCMessageList tempList;
    
    for(LCMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        LSLCMessageItem* item = *itr;
        bool bFlag = false;
        
        if( MT_Photo == item->m_msgType || MT_Video == item->m_msgType) {
            bFlag = true;
        }
        
        if( bFlag ) {
            tempList.push_back(item);
        }
    }
    UnlockMsgList();
    return tempList;
}

// 根据videoId获取用户item
LSLCMessageItem* LSLCUserItem::GetMsgItemWithVideoId(const string& videoId, const string& inviteId) {
    LSLCMessageItem* msgItem = NULL;
    
    LockMsgList();
    
    for(LCMessageList::const_iterator itr = m_msgList.begin(); itr != m_msgList.end(); itr++) {
        LSLCMessageItem* item = *itr;
        bool bFlag = false;
        
        if( NULL != item->GetVideoItem() && item->GetVideoItem()->m_videoId == videoId && item->m_sendType == SendType_Recv && item->m_inviteId == inviteId) {
            msgItem = item;
            break;
        }

    }
    UnlockMsgList();
    
    return msgItem;
}
