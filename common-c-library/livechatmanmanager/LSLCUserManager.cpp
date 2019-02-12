/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCUserManager.cpp
 *   desc: LiveChat用户管理器
 */

#include "LSLCUserManager.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

LSLCUserManager::LSLCUserManager()
{
	m_userMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_userMapLock) {
		m_userMapLock->Init();
	}
}

LSLCUserManager::~LSLCUserManager()
{
	RemoveAllUserItem();
	IAutoLock::ReleaseAutoLock(m_userMapLock);
}

// 用户是否已存在
bool LSLCUserManager::IsUserExists(const string& userId)
{
	bool result = false;

	LockUserMap();
	LCUserMap::iterator iter = m_userMap.find(userId);
	result = (iter != m_userMap.end());
	UnlockUserMap();

	return result;
}

// 获取在聊用户item
LSLCUserItem* LSLCUserManager::GetUserItem(const string& userId)
{
	LSLCUserItem* item = NULL;
	if (!userId.empty()) {
		LockUserMap();

		LCUserMap::iterator iter = m_userMap.find(userId);
		if (iter != m_userMap.end()) {
			// 有则返回
			item = (*iter).second;
		}
		else {
			// 没有则创建
			item = new LSLCUserItem;
			if (NULL != item) {
				item->m_userId = userId;
				item->m_sexType = USER_SEX_FEMALE;

				m_userMap.insert(LCUserMap::value_type(userId, item));
			}
		}

		UnlockUserMap();
	}
	return item;
}

// 添加在聊用户
bool LSLCUserManager::AddUserItem(LSLCUserItem* item)
{
	bool result = false;
	if (!item->m_userId.empty())
	{
		LockUserMap();
		LCUserMap::iterator iter = m_userMap.find(item->m_userId);
		if (iter == m_userMap.end())
		{
			m_userMap.insert(LCUserMap::value_type(item->m_userId, item));
		}
		UnlockUserMap();
	}
	return result;
}

// 移除指定用户
bool LSLCUserManager::RemoveUserItem(const string& userId)
{
	bool result = false;

	LockUserMap();
	LCUserMap::iterator iter = m_userMap.find(userId);
	if (iter != m_userMap.end())
	{
		LSLCUserItem* userItem = (*iter).second;
		m_userMap.erase(iter);
		delete userItem;

		result = true;
	}
	UnlockUserMap();
	return result;
}

// 移除所有用户
bool LSLCUserManager::RemoveAllUserItem()
{
	LockUserMap();
	for (LCUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LSLCUserItem* userItem = (*iter).second;
		delete userItem;
	}
	m_userMap.clear();
	UnlockUserMap();

	return true;
}

// 查找指定邀请ID的userItem
LSLCUserItem* LSLCUserManager::GetUserItemWithInviteId(const string& inviteId)
{
	LSLCUserItem* userItem = NULL;

	LockUserMap();
	for (LCUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LSLCUserItem* item = (*iter).second;
		if (item->m_inviteId == inviteId) {
			userItem = item;
			break;
		}
	}
	UnlockUserMap();

	return userItem;
}

// 获取邀请的用户item
LCUserList LSLCUserManager::GetInviteUsers()
{
	LCUserList userList;

	LockUserMap();
	// 找出所有邀请用户
	for (LCUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LSLCUserItem* userItem = (*iter).second;
		if (userItem->m_chatType == LC_CHATTYPE_INVITE)
		{
			userList.push_back(userItem);
		}
	}
	// 排序
	userList.sort(LSLCUserItem::Sort);
	UnlockUserMap();

	return userList;
}

// 获取在聊的用户item（包括付费和试聊券）
LCUserList LSLCUserManager::GetChatingUsers()
{
	LCUserList userList;

	LockUserMap();
	for (LCUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LSLCUserItem* userItem = (*iter).second;
		if (userItem->m_chatType == LC_CHATTYPE_IN_CHAT_CHARGE
			|| userItem->m_chatType == LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET)
		{
			userList.push_back(userItem);
		}
	}
	UnlockUserMap();

	return userList;
}

// 获取男士主动邀请的用户item
LCUserList LSLCUserManager::GetManInviteUsers()
{
    LCUserList userList;
    
    LockUserMap();
    for (LCUserMap::iterator iter = m_userMap.begin();
         iter != m_userMap.end();
         iter++)
    {
        LSLCUserItem* userItem = (*iter).second;
        if (userItem->m_chatType == LC_CHATTYPE_MANINVITE)
        {
            userList.push_back(userItem);
        }
    }
    UnlockUserMap();
    
    return userList;
}

// 获取有待发消息的用户列表
LCUserList LSLCUserManager::GetToSendUsers()
{
	LCUserList userList;

	LockUserMap();
	for (LCUserMap::iterator iter = m_userMap.begin();
			iter != m_userMap.end();
			iter++)
	{
		LSLCUserItem* userItem = (*iter).second;
		if (userItem->m_sendMsgList.size() > 0)
		{
			userList.push_back(userItem);
		}
	}
	UnlockUserMap();

	return userList;
}

// 用户map表加锁
void LSLCUserManager::LockUserMap()
{
	if (NULL != m_userMapLock) {
		m_userMapLock->Lock();
	}
}

// 用户map表解锁
void LSLCUserManager::UnlockUserMap()
{
	if (NULL != m_userMapLock) {
		m_userMapLock->Unlock();
	}
}
