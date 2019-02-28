/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCInviteManager.h
 *   desc: LiveChat高级表情管理类
 */

#pragma once

#include <livechat/ILSLiveChatClientDef.h>
#include "LSLCUserItem.h"
#include "LSLCAutoInviteInviteManager.h"
#include "LSLCNormalInviteManager.h"
#include <string>
using namespace std;

class ILSLiveChatClient;
//class LSLCBlockManager;
//class LSLCContactManager;
//class LSLCUserManager;
class LSLCUserItem;
class LSLCMessageItem;
class IAutoLock;
class LSLiveChatCounter;
class LSLCAutoInviteItem;

class LSLCInviteManager
{
public:

public:
	LSLCInviteManager();
	virtual ~LSLCInviteManager();

public:
	// 初始化
	bool Init(LSLCUserManager* userMgr, LSLCBlockManager* blockMgr, LSLCContactManager* contactMgr, ILSLiveChatClient* liveChatClient);
	// 判断是否需要处理的邀请消息
    LSLCNormalInviteManager::HandleInviteMsgType IsToHandleInviteMsg(const string& userId, bool charge, TALK_MSG_TYPE type);
	// 更新用户排序分值
	void UpdateUserOrderValue(const string& userId, int orderValue);
	// 处理邀请消息
	void HandleInviteMessage(
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
//    // 选取一条普通邀请消息
//    LSLCMessageItem* GetNormlInviteMessage();
   
    // 收到自动邀请处理
    void HandleAutoInviteMessage(int msgId, LSLCAutoInviteItem* inviteItem, const string& message);
    // 选取一条普通/一条自动邀请消息
    LSLCMessageItem* GetInviteMessage();

private:
    ILSLiveChatClient*        m_liveChatClient;    // LiveChat客户端

	long long			m_preHandleTime;	// 上一次处理邀请的时间
	int 				m_handleCount;		// 当前处理次数
	int 				m_randomHandle;		// 随机处理次数（第几次处理是随机的）
    // 普通邀请管理器
    LSLCNormalInviteManager* m_normalInviteManager;
    // 小助手邀请管理
    LSLCAutoInviteInviteManager* m_autoInviteManager;
};
