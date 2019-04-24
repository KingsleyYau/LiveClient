/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCUserItem.h
 *   desc: LiveChat用户item
 */

#pragma once

#include "LSLCMessageItem.h"
#include <livechat/ILSLiveChatClientDef.h>
#include "ILSLiveChatManManagerEnumDef.h"
#include <string>
#include <list>
using namespace std;

class IAutoLock;
class LSLCUserItem
{

public:
	LSLCUserItem();
	virtual ~LSLCUserItem();

public:
    // 根据UserInfo更新信息
    void UpdateWithUserInfo(const UserInfoItem& item);
    
	// 获取聊天记录列表（已按时间排序）
	LCMessageList GetMsgList(string inviteId = "");
	// 排序插入聊天记录
	bool InsertSortMsgList(LSLCMessageItem* item);
	// 删除聊天记录
	bool RemoveSortMsgList(LSLCMessageItem* item);
	// 清除所有聊天记录
	void ClearMsgList(string inviteId = "");
	// 清除所有已完成的聊天记录
	void ClearFinishedMsgList(string inviteId = "");
	// 根据消息ID获取LSLCMessageItem
	LSLCMessageItem* GetMsgItemWithId(int msgId);
	// 设置聊天状态
	void SetChatTypeWithEventType(TALK_EVENT_TYPE eventType);
	// 设置聊天状态
	void SetChatTypeWithTalkMsgType(bool charge, TALK_MSG_TYPE msgType);
	// 根据 TalkMsgType 获取聊天状态
	static Chat_Type GetChatTypeWithTalkMsgType(bool charge, TALK_MSG_TYPE msgType);
	// 获取对方发出的最后一条聊天消息
	LSLCMessageItem* GetTheOtherLastMessage();
    // 获取对方发出的最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    bool GetOtherUserLastRecvMessage(LSLCMessageItem& messageItem);
    // 获取对方最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    bool GetOtherUserLastMessage(LSLCMessageItem& messageItem);
	// 结束聊天处理
	void EndTalk();
	// 设置在线状态
	bool SetUserOnlineStatus(USER_STATUS_TYPE statusType);
	// 插入待发消息列表
	bool InsertSendMsgList(LSLCMessageItem* item);
	// pop出最前一条待发消息
	LSLCMessageItem* PopSendMsgList();
    // 是否处于男士邀请状态
    bool IsInManInvite();
    // 男士邀请可取消状态判断（1.处于男士邀请状态 2.第一条邀请信息据现在已超过1分钟）
    bool IsInManInviteCanCancel();

	// 比较函数
	static bool Sort(LSLCUserItem* item1, LSLCUserItem* item2);
    
    void isSamePhotoId(LSLCMessageItem* messageItem);
    // 获取用户的私密照和视频的消息
    LCMessageList GetPrivateAndVideoMessageList();
    // 根据videoId获取用户item
    LSLCMessageItem* GetMsgItemWithVideoId(const string& videoId, const string& inviteId);

public:
	// 聊天消息列表加锁
	void LockMsgList();
	// 聊天消息列表解徜
	void UnlockMsgList();
	// 待发送消息列表加锁
	void LockSendMsgList();
	// 待发送消息列表解锁
	void UnlockSendMsgList();
    // 状态加锁
    void Lock();
    // 状态解锁
    void Unlock();
    
public:
	string			m_userId;			// 用户ID
	string			m_userName;			// 用户名
    string          m_imageUrl;         // 头像URL
	USER_SEX_TYPE	m_sexType;			// 用户性别
	CLIENT_TYPE		m_clientType;		// 客户端类型
	USER_STATUS_TYPE	m_statusType;	// 在线状态
	Chat_Type		m_chatType;			// 聊天状态
	string			m_inviteId;			// 邀请ID
	bool			m_tryingSend;		// 是否正在尝试发送（可能正在检测是否可聊天，包括检测是否有试聊券，是否可使用，是否有足够点数等)
	int				m_order;			// 排序分值（用于邀请排序）
    bool            m_isOpenCam;        // 是否打开Camshare服务
    
	LCMessageList	m_msgList;			// 聊天消息列表
	IAutoLock*		m_msgListLock;		// 聊天消息列表锁
	LCMessageList	m_sendMsgList;		// 待发消息列表
	IAutoLock*		m_sendMsgListLock;	// 待发消息列表锁
    
    IAutoLock*		m_statusLock;       // 状态锁
};
typedef list<LSLCUserItem*>		LCUserList;
