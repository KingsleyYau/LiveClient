/*
 * author: Samson.Fan
 *   date: 2018-06-21
 *   file: LMUserManager.cpp
 *   desc: 直播用户管理器
 */

#include "LMUserManager.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

LMUserManager::LMUserManager()
{
	m_userMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_userMapLock) {
		m_userMapLock->Init();
	}
    ResetParam();
}

LMUserManager::~LMUserManager()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "~LMUserManager() begin");
	RemoveAllUserItem();
	IAutoLock::ReleaseAutoLock(m_userMapLock);
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "~LMUserManager() end");
}

// 用户是否已存在
bool LMUserManager::IsUserExists(const string& userId)
{
	bool result = false;

	LockUserMap();
	LMUserMap::iterator iter = m_userMap.find(userId);
	result = (iter != m_userMap.end());
	UnlockUserMap();

	return result;
}

// 获取
LMUserItem* LMUserManager::GetUserItem(const string& userId)
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::GetUserItem(userId:%s ) begin", userId.c_str());
	LMUserItem* item = NULL;
	if (!userId.empty()) {
		LockUserMap();

		LMUserMap::iterator iter = m_userMap.find(userId);
		if (iter != m_userMap.end()) {
			// 有则返回
			item = (*iter).second;
		}
		else {
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::GetUserItem(new userId:%s )", userId.c_str());
			// 没有则创建, 这里不用加用户item修改锁
			item = new LMUserItem;
			if (NULL != item) {
				item->m_userId = userId;
				//item->m_sexType = USER_SEX_FEMALE;
				m_userMap.insert(LMUserMap::value_type(userId, item));
			}
		}

		UnlockUserMap();
	}
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::GetUserItem(userId:%s ) end", userId.c_str());
	return item;
}

// 添加在聊用户
bool LMUserManager::AddUserItem(LMUserItem* item)
{
	bool result = false;
	if (!item->m_userId.empty())
	{
		LockUserMap();
		LMUserMap::iterator iter = m_userMap.find(item->m_userId);
		if (iter == m_userMap.end())
		{
			m_userMap.insert(LMUserMap::value_type(item->m_userId, item));
		}
		UnlockUserMap();
	}
	return result;
}

// 移除指定用户
bool LMUserManager::RemoveUserItem(const string& userId)
{
	bool result = false;

	LockUserMap();
	LMUserMap::iterator iter = m_userMap.find(userId);
	if (iter != m_userMap.end())
	{
		LMUserItem* userItem = (*iter).second;
		m_userMap.erase(iter);
		delete userItem;

		result = true;
	}
	UnlockUserMap();
	return result;
}

// 移除所有用户
bool LMUserManager::RemoveAllUserItem()
{
	LockUserMap();
	for (LMUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LMUserItem* userItem = (*iter).second;
		delete userItem;
	}
	m_userMap.clear();
	UnlockUserMap();

	return true;
}


// 获取有待发消息的用户列表
LMUserList LMUserManager::GetToSendUsers()
{
	LMUserList userList;

	LockUserMap();
	for (LMUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LMUserItem* userItem = (*iter).second;
		if (userItem->m_sendMsgList.size() > 0)
		{
			userList.push_back(userItem);
		}
	}
	UnlockUserMap();

	return userList;
}

// ---------- 私信列表公开操作 begin----------
// 将http的联系人信息转换为用户信息，而且将没有的用户添加到用户管理器里
LMUserList LMUserManager::RefreshAndAddUsers(const HttpPrivateMsgContactList& list) {
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::RefreshAndAddUsers(list.size():%d ) begin", list.size());
    LMUserList userList;
    // 遍历http的私信列表
    for (HttpPrivateMsgContactList::const_iterator iter = list.begin();
         iter != list.end();
         iter++) {
        // 获取或创建用户item
        LMUserItem* userItem = UpdateAndAddUser((*iter).userId, (*iter).nickName, (*iter).avatarImg, (*iter).lastMsg, (*iter).updateTime, (*iter).onlineStatus, (*iter).anchorType);
        userItem->Lock();
        userItem->SetUnreadNum((*iter).unreadNum);
        userItem->Unlock();
        if (NULL != userItem) {
            userList.push_back(userItem);
        }
    }
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::RefreshAndAddUsers(list.size():%d) end", list.size());
    return userList;
}

// 更新将http的联系人信息转换为用户信息，而且将没有的用户添加到用户管理器里（暂做更新个人联系人）
LMUserItem* LMUserManager::UpdateAndAddUser(const string& userId, const string& nickName, const string& avatarImg, const string& msg, long sysTime, OnLineStatus onLineStatus, bool isAnchor) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::UpdateAndAddUser(userId:%s isAnchor:%d) begin", userId.c_str(), isAnchor);
    // 获取或创建用户item
    LMUserItem* userItem = GetUserItem(userId);
    if (NULL != userItem) {
        userItem->Lock();
        // 修改用户的私信消息
        userItem->UpdateWithUserInfo(userId, nickName, avatarImg, msg, sysTime, onLineStatus, isAnchor, m_diffTime, m_isSynTime);
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::UpdateAndAddUser(userId:%s userItem->m_imageUrl:%s) begin", userId.c_str(),  userItem->m_imageUrl.c_str());
        userItem->Unlock();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::UpdateAndAddUser(userId:%s) end", userId.c_str());
    return userItem;
}
// ---------- 私信列表公开操作 end----------

// 服务器数据库当前时间
void LMUserManager::SetDbTime(long dbTime) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::SetDbTime(dbTime:%ld ) begin", dbTime);
    if (GetSynTimeMark() == false && m_dbTime <= 0) {
        m_dbTime = dbTime;
        long currtentTime = (long)(getCurrentTime() / 1000);
        m_diffTime = currtentTime - dbTime;
        LiveMessageItem::SetDbTime(dbTime);
        m_isSynTime = true;
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::SetDbTime(dbTime:%ld currtentTime:%ld m_diffTime:%ld) begin", dbTime, currtentTime, m_diffTime);
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::SetDbTime(dbTime:%ld) end", dbTime);
}

// 获取同步系统时间标志位
bool LMUserManager::GetSynTimeMark() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::GetSynTimeMark(dbTime:%ld m_isSynTime:%d) begin", m_diffTime, m_isSynTime);
    bool result = false;
    result = m_isSynTime;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::GetSynTimeMark(dbTime:%ld m_isSynTime:%d) end", m_diffTime, m_isSynTime);
    return result;
}

// 设置刷新标志
void LMUserManager::SetRefreshMark(bool isFresh) {
    LockUserMap();
    for (LMUserMap::iterator iter = m_userMap.begin();
         iter != m_userMap.end();
         iter++)
    {
        LMUserItem* userItem = (*iter).second;
        userItem->Lock();
        userItem->m_refreshMark = isFresh;
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LMUserManager::SetRefreshMark(userId: %s m_refreshMark:%d) end", userItem->m_userId.c_str(), userItem->m_refreshMark);
        userItem->Unlock();
    }
    UnlockUserMap();
}

// 重设参数
void LMUserManager::ResetParam() {
    m_dbTime = 0;
    m_diffTime = 0;
    m_isSynTime = false;
}

// 用户map表加锁
void LMUserManager::LockUserMap()
{
	if (NULL != m_userMapLock) {
		m_userMapLock->Lock();
	}
}

// 用户map表解锁
void LMUserManager::UnlockUserMap()
{
	if (NULL != m_userMapLock) {
		m_userMapLock->Unlock();
	}
}
