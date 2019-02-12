/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCTextManager.h
 *   desc: LiveChat文本管理器
 */

#include "LSLCTextManager.h"
#include "LSLCMessageItem.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

LSLCTextManager::LSLCTextManager()
{
	m_sendingMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Init();
	}
}

LSLCTextManager::~LSLCTextManager()
{
	IAutoLock::ReleaseAutoLock(m_sendingMapLock);
}

// 添加待发送的item
bool LSLCTextManager::AddSendingItem(LSLCMessageItem* item)
{
	bool result = false;

	LockSendingMap();
	SendingMap::iterator iter = m_sendingMap.find(item->m_msgId);
	if (m_sendingMap.end() == iter)
	{
		m_sendingMap.insert(SendingMap::value_type(item->m_msgId, item));
		result = true;
	}
	UnlockSendingMap();

	return result;
}

// 移除待发送的item
LSLCMessageItem* LSLCTextManager::GetAndRemoveSendingItem(int msgId)
{
	LSLCMessageItem* item = NULL;

	LockSendingMap();
	SendingMap::iterator iter = m_sendingMap.find(msgId);
	if (iter != m_sendingMap.end())
	{
		item = (*iter).second;
		m_sendingMap.erase(iter);
	}
	UnlockSendingMap();

	return item;
}

// 清除所有待发送的item
void LSLCTextManager::RemoveAllSendingItems()
{
	LockSendingMap();
	m_sendingMap.clear();
	UnlockSendingMap();
}

// 待发送map表加锁
void LSLCTextManager::LockSendingMap()
{
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Lock();
	}
}

// 待发送map表解锁
void LSLCTextManager::UnlockSendingMap()
{
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Unlock();
	}
}
