/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCUserManager.h
 *   desc: LiveChat用户管理器
 */

#pragma once

#include "LSLCUserItem.h"
#include <string>
#include <map>
using namespace std;

class LSLCUserItem;
class IAutoLock;
class LSLCUserManager
{
private:
	typedef map<string, LSLCUserItem*>		LCUserMap;		// 用户map表

public:
	LSLCUserManager();
	virtual ~LSLCUserManager();

public:
	// 用户是否已存在
	bool IsUserExists(const string& userId);
	// 获取在聊用户item
	LSLCUserItem* GetUserItem(const string& userId);
	// 添加在聊用户
	bool AddUserItem(LSLCUserItem* item);
	// 移除指定用户
	bool RemoveUserItem(const string& userId);
	// 移除所有用户
	bool RemoveAllUserItem();
	// 查找指定邀请ID的userItem
	LSLCUserItem* GetUserItemWithInviteId(const string& inviteId);
	// 获取邀请的用户item
	LCUserList GetInviteUsers();
	// 获取在聊的用户item（包括付费和试聊券）
	LCUserList GetChatingUsers();
    // 获取男士主动邀请的用户item
    LCUserList GetManInviteUsers();
	// 获取有待发消息的用户列表
	LCUserList GetToSendUsers();

private:
	// 用户map表加锁
	void LockUserMap();
	// 用户map表解锁
	void UnlockUserMap();

public:
	LCUserMap		m_userMap;		// 用户map表
	IAutoLock*		m_userMapLock;	// 用户map表锁
};

