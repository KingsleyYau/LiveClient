/*
 * author: Alex
 *   date: 2019-1-28
 *   file: LSLCAutoInviteInviteManager.h
 *   desc: 自动邀请管理类
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
#include "LSLCAutoInviteInviteManager.h"
#include "LSLCAutoInviteItem.h"

using namespace std;

static long long g_handleTimeInterval = 3* 60 * 1000;	// 处理邀请时间间隔(25s)

LSLCAutoInviteInviteManager::LSLCAutoInviteInviteManager(LSLCUserManager* userMgr)
{

	m_userMgr = userMgr;
    m_autoInviteListLock = IAutoLock::CreateAutoLock();
    if (NULL != m_autoInviteListLock) {
        m_autoInviteListLock->Init();
    }
}

LSLCAutoInviteInviteManager::~LSLCAutoInviteInviteManager()
{
    ClearAutoInviteList();
    IAutoLock::ReleaseAutoLock(m_autoInviteListLock);
    
}

void LSLCAutoInviteInviteManager::HandleAutoInviteMessage(int msgId, LSLCAutoInviteItem* inviteItem, const string& message) {
    if (NULL != inviteItem) {
        LSLCMessageItem* item = new LSLCMessageItem();
        item->Init(msgId, SendType_Recv, inviteItem->womanId, inviteItem->manId, "", StatusType_Finish);
        // 生成TextItem
        LSLCTextItem* textItem = new LSLCTextItem();
        textItem->Init(message, false);
        // 把TextItem添加到MessageItem
        item->SetTextItem(textItem);
        //设置自动邀请消息关键信息
        item->SetAutoInviteItem(inviteItem);
        LockAutoInviteList();
        m_autoInviteList.push_back(item);
        UnlockAutoInviteList();
    }

}

LSLCMessageItem* LSLCAutoInviteInviteManager::GetAutoInviteMessage() {
    LSLCMessageItem* item = NULL;
    RemoveOverTimeAutoInvite();
    LockAutoInviteList();
    if(m_autoInviteList.size() > 0){

        for (AutoInviteList::const_reverse_iterator iter = m_autoInviteList.rbegin(); iter != m_autoInviteList.rend(); ) {
            item = (*iter);
            if (item != NULL && m_userMgr != NULL) {
                LSLCUserItem* userItem = m_userMgr->GetUserItem(item->m_fromId);
                iter = AutoInviteList::const_reverse_iterator(m_autoInviteList.erase((++iter).base()));
                if (userItem != NULL) {
                    if (userItem->m_chatType == LC_CHATTYPE_OTHER) {
                        userItem->SetChatTypeWithTalkMsgType(false, TMT_FREE);
                        userItem->SetUserOnlineStatus(USTATUS_ONLINE);
                        item->SetUserItem(userItem);
                        // 添加到用户聊天记录中
                        userItem->InsertSortMsgList(item);
                        break;
                    } else {
                        delete item;
                        item = NULL;
                    }
                }
            } else {
                ++iter;
            }
        }
        
    }
     UnlockAutoInviteList();
    return item;
}

void LSLCAutoInviteInviteManager::ClearAutoInviteList() {
    m_autoInviteList.clear();
    for (AutoInviteList::const_iterator iter = m_autoInviteList.begin(); iter != m_autoInviteList.end(); iter++) {
        LSLCMessageItem* item = (*iter);
        if (item != NULL) {
            delete item;
            item = NULL;
        }
    }
    m_autoInviteList.clear();
    UnlockAutoInviteList();
}

// 移除超时邀请
void LSLCAutoInviteInviteManager::RemoveOverTimeAutoInvite() {
    LockAutoInviteList();
    AutoInviteList tempList = m_autoInviteList;
    m_autoInviteList.clear();
    for (AutoInviteList::const_iterator iter = tempList.begin(); iter != tempList.end(); iter++) {
        LSLCMessageItem* item = (*iter);
        if (item != NULL) {
            if (item->m_createTime + g_handleTimeInterval >= getCurrentTime()) {
                delete item;
                item = NULL;
            } else {
                m_autoInviteList.push_back(item);
            }
        }
    }
    UnlockAutoInviteList();
}

// 邀请用户列表加锁
void LSLCAutoInviteInviteManager::LockAutoInviteList()
{
    if (NULL != m_autoInviteListLock) {
        m_autoInviteListLock->Lock();
    }
}

// 邀请用户列表解锁
void LSLCAutoInviteInviteManager::UnlockAutoInviteList()
{
    if (NULL != m_autoInviteListLock) {
        m_autoInviteListLock->Unlock();
    }
}
