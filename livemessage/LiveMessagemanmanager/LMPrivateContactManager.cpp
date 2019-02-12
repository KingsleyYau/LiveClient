/*
 * author: Samson.Fan
 *   date: 2018-06-21
 *   file: LMPrivateContactManager.h
 *   desc: 私信联系人管理类
 */

#include "LMPrivateContactManager.h"
#include "LMUserManager.h"
//#include <livechat/ILiveChatClient.h>
#include <common/IAutoLock.h>
//#include <livechat/Counter.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


using namespace std;

//static long long g_handleTimeInterval = 25 * 1000;    // 处理邀请时间间隔(25s)
//static int g_maxNoRandomCount = 10;                    // 最大非随机处理数（最多多少次就要有一次随机）

LMPrivateContactManager::LMPrivateContactManager()
{
    m_isInit = false;
    m_userMgr = NULL;
    m_privateContactListLock = IAutoLock::CreateAutoLock();
    if (NULL != m_privateContactListLock) {
        m_privateContactListLock->Init();
    }
    
    m_followContactListLock = IAutoLock::CreateAutoLock();
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Init();
    }
}

LMPrivateContactManager::~LMPrivateContactManager()
{
    IAutoLock::ReleaseAutoLock(m_privateContactListLock);
    IAutoLock::ReleaseAutoLock(m_followContactListLock);
}

// 初始化
bool LMPrivateContactManager::Init(
        LMUserManager* userMgr)
{
    bool result = false;

    if (NULL != userMgr)
    {
        m_userMgr = userMgr;

        result = true;
    }

    m_isInit = result;

    return result;
}


// ----------- 私信联系人公开操作 begin---------------------
// 刷新私信联系人列表（将本地的私信联系人列表删除，在增加进去，需要时间排列，）
bool LMPrivateContactManager::UpdatePrivateContactList(const IMPrivateMessageItem& item) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::UpdatePrivateContactList(userId:%s, m_privateContactList.size():%d) begin", item.fromId.c_str(), m_privateContactList.size());
    bool isUpdate = false;
    // 加锁
    LockContactList();
    if (NULL != m_userMgr) {
        // 将http的私信联系人列表转化为LM的用户私信联系人，没有就增加
        LMUserItem* userItem = m_userMgr->UpdateAndAddUser(item.fromId, item.nickName, item.avatarImg, item.msg, item.sendTime, ONLINE_STATUS_LIVE, true);
        if (NULL != userItem) {
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::UpdatePrivateContactList(userId:%s, m_privateContactList.size():%d) begin1", item.fromId.c_str(), m_privateContactList.size());
            // 将http中获取的私信联系人列表代替本地的
            bool isHas = false;
            for (LMUserList::const_iterator miter = m_privateContactList.begin();
                 miter != m_privateContactList.end();
                 miter++) {
                if (userItem == (*miter)) {
                    isHas = true;
                    break;
                }
            }
            if (!isHas) {
                m_privateContactList.push_back(userItem);
            }

            
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::UpdatePrivateContactList(userId:%s, m_privateContactList.size():%d) begin2", item.fromId.c_str(), m_privateContactList.size());
            // 按最后更新时间排序
            SortContactList();
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::UpdatePrivateContactList(userId:%s, m_privateContactList.size():%d) begin3", item.fromId.c_str(), m_privateContactList.size());
            isUpdate = true;
        }
    }
    // 解锁
    UnlockContactList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::UpdatePrivateContactList(item.userId:%s, m_privateContactList.size():%d isUpdate:%d) end", item.fromId.c_str(), m_privateContactList.size(), isUpdate);
    return isUpdate;
}

// 刷新私信联系人列表（将本地的私信联系人列表删除，在增加进去，需要时间排列，）
void LMPrivateContactManager::RefreshPrivateContactList(const HttpPrivateMsgContactList& list, long dbtime) {
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::RefreshPrivateContactList(list.size():%d, m_privateContactList.size():%d) begin", list.size(), m_privateContactList.size());
    // 加锁
    LockContactList();
    if (NULL != m_userMgr) {
        // 设置同步服务器时间
        m_userMgr->SetDbTime(dbtime);
        // 将http的私信联系人列表转化为LM的用户私信联系人，没有就增加
        LMUserList tempList = m_userMgr->RefreshAndAddUsers(list);
        // 清空本地私信联系人列表
        m_privateContactList.clear();
        // 将http中获取的私信联系人列表代替本地的
        for (LMUserList::const_iterator iter = tempList.begin();
             iter != tempList.end();
             iter++) {
            m_privateContactList.push_back((*iter));
        }
        // 按最后更新时间排序
        SortContactList();
        
    }
    // 解锁
    UnlockContactList();
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::RefreshPrivateContactList(list.size():%d, m_privateContactList.size():%d) begin", list.size(), m_privateContactList.size());
}

// 获取系统时间标志
bool LMPrivateContactManager::GetSynTimeMark() {
    bool result = false;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::GetSynTimeMark(m_privateContactList.size():%d) begin", m_privateContactList.size());
    if (NULL != m_userMgr) {
       result = m_userMgr->GetSynTimeMark();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMPrivateContactManager::GetSynTimeMark(m_privateContactList.size():%d) begin",  m_privateContactList.size());
    return result;
}
// ----------- 私信联系人公开操作 end---------------------


// 增加或修改关注私信联系人列表的数据
bool LMPrivateContactManager::UpdateFollowPrivateContactList(const LMUserList& privateList)
{
    bool result = false;
    // 加锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Lock();
    }
    if (!privateList.empty()) {
        for (LMUserList::const_iterator iter = privateList.begin();
             iter != privateList.end();
             iter++) {
            bool isHas = false;
            for (LMUserList::const_iterator miter = m_followContactList.begin();
                 miter != m_followContactList.end();
                 miter++) {
                if ((*iter) == (*miter)) {
                    isHas = true;
                    break;
                }
            }
            if (!isHas) {
                m_followContactList.push_back((*iter));
            }
        }
    }
    // 解锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Unlock();
    }
    
    return result;
}

// 获取私信联系人列表
LMUserList LMPrivateContactManager::GetContactList() {
    LMUserList tempList;
    // 加锁
    LockContactList();
    for (LMUserList::iterator iter = m_privateContactList.begin(); iter != m_privateContactList.end(); iter++) {
        tempList.push_back(*iter);
    }
    // 解锁
    UnlockContactList();
    
    return tempList;
}
// 获取关注私信联系人列表
LMUserList LMPrivateContactManager::GetFollowContactList() {
    LMUserList tempList;
    // 加锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Lock();
    }
    for (LMUserList::iterator iter = m_followContactList.begin(); iter != m_followContactList.end(); iter++) {
        tempList.push_back(*iter);
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetLocalFollowPrivateMsgFriendList((*iter)->m_imageUrl:%s) end", (*iter)->m_imageUrl.c_str());
    }
    // 解锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Unlock();
    }
    return tempList;
}

// 获取用户item（不存在不创建）
LMUserItem* LMPrivateContactManager::GetUserNotCreate(const string& userId)
{
    LMUserItem* userItem = NULL;
    // 加锁
    LockContactList();
    for (LMUserList::iterator iter = m_privateContactList.begin();
            iter != m_privateContactList.end();
            iter++)
    {
        if (userId == (*iter)->m_userId)
        {
            userItem = (*iter);
        }
    }
    // 解锁
    UnlockContactList();
    return userItem;
}

// 获取用户item（不存在则创建）
LMUserItem* LMPrivateContactManager::GetUser(const string& userId)
{
    LMUserItem* userItem = NULL;
    if (!userId.empty())
    {
        userItem = GetUserNotCreate(userId);
        
        if (NULL == userItem)
        {
            userItem = m_userMgr->GetUserItem(userId);
//            userItem = new LMUserItem;
//            userItem->m_userId = userId;
            // 加锁
            LockContactList();
             m_privateContactList.push_back(userItem);
            // 解锁
            UnlockContactList();
        }
    }
    return userItem;
}

// 移除所有私信联系人列表 和 关注的私信联系人列表
void LMPrivateContactManager::RemoveAllUserItem() {
    LMUserItem* userItem = NULL;
    // 加锁
    LockContactList();
    m_privateContactList.clear();
    // 解锁
    UnlockContactList();
    
    // 加锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Lock();
    }
    m_followContactList.clear();
    // 解锁
    if (NULL != m_followContactListLock) {
        m_followContactListLock->Unlock();
    }
    
}

// 联系人用户列表加锁
void LMPrivateContactManager::LockContactList() {
    if (NULL != m_privateContactListLock) {
        m_privateContactListLock->Lock();
    }
}
// 联系人用户列表解锁
void LMPrivateContactManager::UnlockContactList() {
    if (NULL != m_privateContactListLock) {
        m_privateContactListLock->Unlock();
    }
}

void LMPrivateContactManager::SortContactList() {
    m_privateContactList.sort(LMPrivateContactManager::Sort);
}

// 比较函数
bool LMPrivateContactManager::Sort(LMUserItem* item1, LMUserItem* item2)
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

