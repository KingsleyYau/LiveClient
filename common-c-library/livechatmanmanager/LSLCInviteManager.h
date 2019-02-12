/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCInviteManager.h
 *   desc: LiveChat高级表情管理类
 */

#pragma once

#include <livechat/ILSLiveChatClientDef.h>
#include "LSLCUserItem.h"
#include <string>
using namespace std;

class ILSLiveChatClient;
class LSLCBlockManager;
class LSLCContactManager;
class LSLCUserManager;
class LSLCUserItem;
class LSLCMessageItem;
class IAutoLock;
class LSLiveChatCounter;

class LSLCInviteManager
{
public:
	// 邀请消息处理结果类型
	typedef enum {
		LOST,	// 丢弃
		PASS,	// 通过
		HANDLE,	// 需要处理
	} HandleInviteMsgType;

public:
	LSLCInviteManager();
	virtual ~LSLCInviteManager();

public:
	// 初始化
	bool Init(LSLCUserManager* userMgr, LSLCBlockManager* blockMgr, LSLCContactManager* contactMgr, ILSLiveChatClient* liveChatClient);
	// 判断是否需要处理的邀请消息
	HandleInviteMsgType IsToHandleInviteMsg(const string& userId, bool charge, TALK_MSG_TYPE type);
	// 更新用户排序分值
	void UpdateUserOrderValue(const string& userId, int orderValue);
	// 处理邀请消息
	LSLCMessageItem* HandleInviteMessage(
			LSLiveChatCounter& msgIdIndex
			, const string& toId
			, const string& fromId
			, const string& fromName
			, const string& inviteId
			, bool charget
			, int ticket
			, TALK_MSG_TYPE msgType
			, const string& message
            , INVITE_TYPE inviteType);

private:
	// 获取用户item（不存在不创建）
	LSLCUserItem* GetUserNotCreate(const string& userId);
	// 获取用户item（不存在则创建）
	LSLCUserItem* GetUser(const string& userId);
	// 获取并移除指定邀请用户
	LSLCUserItem* GetAndRemoveUserWithPos(int pos);
	// 移除超时邀请
	void RemoveOverTimeInvite();
	// 插入邀请用户
	bool InsertInviteUser(LSLCUserItem* item);
	// 对邀请列表排序
	void SortInviteList();
	// 邀请用户列表加锁
	void LockInviteUsersList();
	// 邀请用户列表解锁
	void UnlockInviteUsersList();

	// 比较函数
	static bool Sort(LSLCUserItem* item1, LSLCUserItem* item2);

private:
	bool				m_isInit;			// 是否已初始化
	ILSLiveChatClient*	m_liveChatClient;	// LiveChat客户端
	LSLCUserManager* 		m_userMgr;			// 用户管理器
	LSLCBlockManager*		m_blockMgr;			// 黑名单管理器
	LSLCContactManager*	m_contactMgr;		// LiveChat联系人管理器
	LCUserList			m_inviteUserList;	// 邀请用户列表
	IAutoLock*			m_inviteUserListLock;	// 邀请用户列表锁

	long long			m_preHandleTime;	// 上一次处理邀请的时间
	int 				m_handleCount;		// 当前处理次数
	int 				m_randomHandle;		// 随机处理次数（第几次处理是随机的）
};
