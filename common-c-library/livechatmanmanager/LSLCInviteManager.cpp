/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCInviteManager.h
 *   desc: LiveChat高级表情管理类
 */

#include "LSLCInviteManager.h"
#include "LSLCBlockManager.h"
#include "LSLCContactManager.h"
#include "LSLCUserManager.h"
#include "LSLCUserItem.h"
#include "LSLCMessageItem.h"
#include <livechat/ILSLiveChatClient.h>
#include <common/IAutoLock.h>
#include <livechat/LSLiveChatCounter.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>
#include "LSLCAutoInviteItem.h"
#include <common/KLog.h>

using namespace std;

static long long g_handleTimeInterval = 25 * 1000;	// 处理邀请时间间隔(25s)
static int g_maxNoRandomCount = 10;					// 最大非随机处理数（最多多少次就要有一次随机）

LSLCInviteManager::LSLCInviteManager()
{
	m_preHandleTime = 0;
	m_handleCount = 0;
	m_randomHandle = 0;
    m_normalInviteManager = NULL;
    m_autoInviteManager = NULL;
}

LSLCInviteManager::~LSLCInviteManager()
{
    if (m_normalInviteManager != NULL) {
        delete m_normalInviteManager;
        m_normalInviteManager = NULL;
    }
    if (m_autoInviteManager != NULL) {
        delete m_autoInviteManager;
        m_autoInviteManager = NULL;
    }
}

// 初始化
bool LSLCInviteManager::Init(
		LSLCUserManager* userMgr
		, LSLCBlockManager* blockMgr
		, LSLCContactManager* contactMgr
		, ILSLiveChatClient* liveChatClient)
{
	bool result = false;

	if (NULL != userMgr
		&& NULL != liveChatClient
		&& NULL != blockMgr
		&& NULL != contactMgr)
	{
        m_liveChatClient = liveChatClient;
        
        m_normalInviteManager = new LSLCNormalInviteManager;
        result = m_normalInviteManager->Init(userMgr, blockMgr, contactMgr, liveChatClient);
        m_autoInviteManager = new LSLCAutoInviteInviteManager(userMgr);

		//result = true;
	}
//
//    m_isInit = result;

	return result;
}

// 判断是否需要处理的邀请消息
LSLCNormalInviteManager::HandleInviteMsgType LSLCInviteManager::IsToHandleInviteMsg(
															const string& userId
															, bool charge
															, TALK_MSG_TYPE type)
{
    LSLCNormalInviteManager::HandleInviteMsgType result = LSLCNormalInviteManager::PASS;
    if (m_normalInviteManager != NULL) {
        result = m_normalInviteManager->IsToHandleInviteMsg(userId, charge, type);
    }
	return result;
}


// 处理邀请消息
void LSLCInviteManager::HandleInviteMessage(
									LSLiveChatCounter& msgIdIndex
									, const string& toId
									, const string& fromId
									, const string& fromName
									, const string& inviteId
									, bool charge
									, int ticket
									, TALK_MSG_TYPE msgType
									, const string& message
                                    ,INVITE_TYPE inviteType)
{
	LSLCMessageItem* item = NULL;
    if (m_normalInviteManager != NULL) {
        m_normalInviteManager->HandleInviteMessage(msgIdIndex, toId, fromId, fromName, inviteId, charge, ticket, msgType, message, inviteType);
    }

}

void LSLCInviteManager::HandleAutoInviteMessage(int msgId, LSLCAutoInviteItem* inviteItem, const string& message) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCInviteManager::HandleAutoInviteMessage(m_autoInviteManager : %p) begin", m_autoInviteManager);
    if (m_autoInviteManager != NULL) {
        m_autoInviteManager->HandleAutoInviteMessage(msgId, inviteItem, message);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnAutoInviteFilterCallback() end");
}



LSLCMessageItem* LSLCInviteManager::GetInviteMessage() {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCInviteManager::HandleAutoInviteMessage(m_autoInviteManager : %p) begin", m_autoInviteManager);
    LSLCMessageItem* item = NULL;
    if (m_autoInviteManager != NULL && (m_preHandleTime == 0 || m_preHandleTime + g_handleTimeInterval <= getCurrentTime())) {
        // 获取自动邀请的item
        item = m_autoInviteManager->GetAutoInviteMessage();
        if (item == NULL) {
            item = m_normalInviteManager->GetNormlInviteMessage();
        }
        if (item != NULL) {
            LSLCAutoInviteItem* autoInvite = item->GetAutoInviteItem();
            if (autoInvite != NULL && m_liveChatClient) {
                // 向服务器发送UploadPopLadyAutoInvite上传弹出女士自动邀请消息
                m_liveChatClient->UploadPopLadyAutoInvite(autoInvite->womanId, item->GetTextItem()->m_message, autoInvite->identifyKey);
            }
            m_preHandleTime = getCurrentTime();
        }
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::GetAutoInviteMessage(item : %p) end", item);
    return item;
}

// 更新用户排序分值
void LSLCInviteManager::UpdateUserOrderValue(const string& userId, int orderValue)
{
//    LockInviteUsersList();
//    LSLCUserItem* item = GetUserNotCreate(userId);
//    if (NULL != item) {
//        item->m_order = orderValue;
//        SortInviteList();
//    }
//    UnlockInviteUsersList();
    if (m_normalInviteManager != NULL) {
        m_normalInviteManager->UpdateUserOrderValue(userId, orderValue);
    }
}

//// 比较函数
//bool LSLCInviteManager::Sort(LSLCUserItem* item1, LSLCUserItem* item2)
//{
//    // true在前面，false在后面
//    bool result = false;
//
//    if (item1->m_order == item2->m_order)
//    {
//        item1->LockMsgList();
//        item2->LockMsgList();
//        if (!item1->m_msgList.empty() && !item2->m_msgList.empty())
//        {
//            // 消息早收到的优先
//            LCMessageList::iterator iter1 = item1->m_msgList.begin();
//            LCMessageList::iterator iter2 = item2->m_msgList.begin();
//            result = ((*iter1)->m_createTime >= (*iter2)->m_createTime);
//        }
//        else if (item1->m_msgList.empty() && item2->m_msgList.empty())
//        {
//            // 按原来顺序（不应该出现的情况）
//            result = true;
//        }
//        else {
//            // 有消息的优先（不应该出现的情况）
//            result = !item1->m_msgList.empty();
//        }
//        item2->UnlockMsgList();
//        item1->UnlockMsgList();
//    }
//    else
//    {
//        // 按分数排序
//        result = (item1->m_order > item2->m_order);
//    }
//
//    return result;
//}
//
//// 邀请用户列表加锁
//void LSLCInviteManager::LockInviteUsersList()
//{
//    if (NULL != m_inviteUserListLock) {
//        m_inviteUserListLock->Lock();
//    }
//}
//
//// 邀请用户列表解锁
//void LSLCInviteManager::UnlockInviteUsersList()
//{
//    if (NULL != m_inviteUserListLock) {
//        m_inviteUserListLock->Unlock();
//    }
//}

