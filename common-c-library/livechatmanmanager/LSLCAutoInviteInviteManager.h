/*
 * author: Alex
 *   date: 2019-1-28
 *   file: LSLCAutoInviteInviteManager.h
 *   desc: 自动邀请管理类
 */

#pragma once

#include <livechat/ILSLiveChatClientDef.h>
#include "LSLCUserItem.h"
#include <string>
using namespace std;

//class ILSLiveChatClient;
//class LSLCBlockManager;
//class LSLCContactManager;
class LSLCUserManager;
class LSLCUserItem;
class LSLCMessageItem;
//class IAutoLock;
//class LSLiveChatCounter;
class LSLCAutoInviteItem;

class LSLCAutoInviteInviteManager
{
public:
	// 邀请消息处理结果类型
	typedef enum {
		LOST,	// 丢弃
		PASS,	// 通过
		HANDLE,	// 需要处理
	} HandleInviteMsgType;
    
private:
    typedef list<LSLCMessageItem*>        AutoInviteList;        // 用户map表

public:
	LSLCAutoInviteInviteManager(LSLCUserManager* userMgr);
	virtual ~LSLCAutoInviteInviteManager();

public:

    // 收到自动邀请处理
    void HandleAutoInviteMessage(int msgId, LSLCAutoInviteItem* inviteItem, const string& message);
    // 获取自动邀请消息
    LSLCMessageItem* GetAutoInviteMessage();

private:
    void ClearAutoInviteList();
    // 移除超时邀请
    void RemoveOverTimeAutoInvite();
    // 自动邀请消息列表加锁
    void LockAutoInviteList();
    // 自动邀请消息列表解锁
    void UnlockAutoInviteList();
//
//    // 比较函数
//    static bool Sort(LSLCUserItem* item1, LSLCUserItem* item2);

private:
	LSLCUserManager* 		m_userMgr;			// 用户管理器
    AutoInviteList          m_autoInviteList;   // 自动邀请消息列表
    IAutoLock*              m_autoInviteListLock;    // 自动邀请消息列表锁

};
