/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: LSLiveChatTaskMap.cpp
 *   desc: Task Map管理（带锁）实现类
 */

#include "LSLiveChatTaskMapManager.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatTaskMapManager::LSLiveChatTaskMapManager(void)
{
	m_bInit = false;
	m_lock = NULL;
}

LSLiveChatTaskMapManager::~LSLiveChatTaskMapManager(void)
{
	Uninit();
}

bool LSLiveChatTaskMapManager::Init()
{
	if (!m_bInit) {
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_bInit = m_lock->Init();
		}
	}
	return m_bInit;
}

void LSLiveChatTaskMapManager::Uninit()
{
	IAutoLock::ReleaseAutoLock(m_lock);
	m_lock = NULL;

	m_bInit = false;
}

bool LSLiveChatTaskMapManager::Insert(ILSLiveChatTask* task)
{
	bool result = false;
	if (m_bInit 
		&& NULL != task) 
	{
		m_lock->Lock();

		pair<TaskMap::iterator, bool> pr;
		pr = m_map.insert(TaskMap::value_type((int)task->GetSeq(), task));
		result = pr.second;

		m_lock->Unlock();
	}
	return result;
}

void LSLiveChatTaskMapManager::InsertTaskList(const TaskList& list)
{
	TaskList::const_iterator iter;
	for (iter = list.begin();
		iter != list.end();
		iter++) 
	{
		Insert((*iter));
	}
}
	
ILSLiveChatTask* LSLiveChatTaskMapManager::PopTaskWithSeq(int seq)
{
	ILSLiveChatTask* task = NULL;
	if (m_bInit) {
		m_lock->Lock();
	
		TaskMap::iterator iter = m_map.find(seq);
		if (iter != m_map.end()) {
			task = (*iter).second;
			m_map.erase(seq);
		}

		m_lock->Unlock();
	}
	return task;
}
	
void LSLiveChatTaskMapManager::Clear(TaskList& list)
{
	if (m_bInit) {
		m_lock->Lock();
	
		TaskMap::iterator iter;
		for (iter = m_map.begin();
			iter != m_map.end();
			iter++)
		{
			list.push_back((*iter).second);
		}
		m_map.clear();

		m_lock->Unlock();
	}
}
