/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCTextManager.h
 *   desc: LiveChat文本管理器
 */

#pragma once

#include <string>
#include <map>
using namespace std;

class IAutoLock;
class LSLCMessageItem;
class LSLCTextManager
{
private:
	typedef map<int, LSLCMessageItem*>	SendingMap;	// 待发送map表(msgId, MessageItem)

public:
	LSLCTextManager();
	virtual ~LSLCTextManager();

public:
	// 添加待发送的item
	bool AddSendingItem(LSLCMessageItem* item);
	// 移除待发送的item
	LSLCMessageItem* GetAndRemoveSendingItem(int msgId);
	// 清除所有待发送的item
	void RemoveAllSendingItems();

private:
	// 待发送map表加锁
	void LockSendingMap();
	// 待发送map表解锁
	void UnlockSendingMap();

private:
	SendingMap	m_sendingMap;		// 待发送map表
	IAutoLock*	m_sendingMapLock;	// 待发送map表锁
};
