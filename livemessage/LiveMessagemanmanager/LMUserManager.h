/*
 * author: Samson.Fan
 *   date: 2018-06-21
 *   file: LMUserManager.h
 *   desc: 直播用户管理器
 */

#pragma once

#include "LMUserItem.h"
#include <string>
#include <map>
using namespace std;

class LMUserItem;
class IAutoLock;
class LMUserManager
{
private:
	typedef map<string, LMUserItem*>		LMUserMap;		// 用户map表

public:
	LMUserManager();
	virtual ~LMUserManager();

public:
	// 用户是否已存在
	bool IsUserExists(const string& userId);
	// 获取在聊用户item
	LMUserItem* GetUserItem(const string& userId);
	// 添加在聊用户
	bool AddUserItem(LMUserItem* item);
	// 移除指定用户
	bool RemoveUserItem(const string& userId);
	// 移除所有用户
	bool RemoveAllUserItem();
	// 获取有待发消息的用户列表
	LMUserList GetToSendUsers();
    // 设置刷新标志
    void SetRefreshMark(bool isFresh);
    // 服务器数据库当前时间
    void SetDbTime(long dbTime);
    // 获取同步系统时间标志位
    bool GetSynTimeMark();
    // 重设参数
    void ResetParam();

public:
    // ---------- 私信列表公开操作 begin----------
    // 将http的联系人信息转换为用户信息，而且将没有的用户添加到用户管理器里(暂做刷新联系人列表)
    LMUserList RefreshAndAddUsers(const HttpPrivateMsgContactList& list);
    // 更新将http的联系人信息转换为用户信息，而且将没有的用户添加到用户管理器里（暂做更新个人联系人）
    LMUserItem* UpdateAndAddUser(const string& userId, const string& nickName, const string& avatarImg, const string& msg, long sysTime, OnLineStatus onLineStatus, bool isAnchor);
    // ---------- 私信列表公开操作 end----------
    
public:

private:
	// 用户map表加锁
	void LockUserMap();
	// 用户map表解锁
	void UnlockUserMap();

public:
	LMUserMap		m_userMap;		// 用户map表
	IAutoLock*		m_userMapLock;	// 用户map表锁
    
private:
    long     m_dbTime;        // 服务器数据库当前时间
    long     m_diffTime;      // 本地时间与服务器时间的相差
    long     m_isSynTime;      // 是否同步了服务器时间
};

