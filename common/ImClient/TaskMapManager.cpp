/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: TaskMap.cpp
 *   desc: Task Map管理（带锁）实现类
 */

#include "TaskMapManager.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

TaskMapManager::TaskMapManager(void)
{
	m_bInit = false;
	m_lock = NULL;
}

TaskMapManager::~TaskMapManager(void)
{
	Uninit();
}

bool TaskMapManager::Init()
{
	if (!m_bInit) {
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_bInit = m_lock->Init();
		}
	}
	return m_bInit;
}

void TaskMapManager::Uninit()
{
	IAutoLock::ReleaseAutoLock(m_lock);
	m_lock = NULL;

	m_bInit = false;
}

bool TaskMapManager::Insert(ITask* task)
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

void TaskMapManager::InsertTaskList(const TaskList& list)
{
	TaskList::const_iterator iter;
	for (iter = list.begin();
		iter != list.end();
		iter++) 
	{
		Insert((*iter));
	}
}
	
ITask* TaskMapManager::PopTaskWithSeq(unsigned long seq)
{
	ITask* task = NULL;
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
	
void TaskMapManager::Clear(TaskList& list)
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
