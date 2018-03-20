/*
 * author: alex
 *   file: ZBTaskMap.cpp
 *   desc: Task Map管理（带锁）实现类
 */

#include "ZBTaskMapManager.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

ZBTaskMapManager::ZBTaskMapManager(void)
{
	m_bInit = false;
	m_lock = NULL;
}

ZBTaskMapManager::~ZBTaskMapManager(void)
{
	Uninit();
}

bool ZBTaskMapManager::Init()
{
	if (!m_bInit) {
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_bInit = m_lock->Init();
		}
	}
	return m_bInit;
}

void ZBTaskMapManager::Uninit()
{
	IAutoLock::ReleaseAutoLock(m_lock);
	m_lock = NULL;

	m_bInit = false;
}

bool ZBTaskMapManager::Insert(IZBTask* task)
{
	bool result = false;
	if (m_bInit 
		&& NULL != task) 
	{
		m_lock->Lock();

		pair<ZBTaskMap::iterator, bool> pr;
		pr = m_map.insert(ZBTaskMap::value_type((int)task->GetSeq(), task));
		result = pr.second;

		m_lock->Unlock();
	}
	return result;
}

void ZBTaskMapManager::InsertTaskList(const ZBTaskList& list)
{
	ZBTaskList::const_iterator iter;
	for (iter = list.begin();
		iter != list.end();
		iter++) 
	{
		Insert((*iter));
	}
}
	
IZBTask* ZBTaskMapManager::PopTaskWithSeq(unsigned long seq)
{
	IZBTask* task = NULL;
	if (m_bInit) {
		m_lock->Lock();
	
		ZBTaskMap::iterator iter = m_map.find(seq);
		if (iter != m_map.end()) {
			task = (*iter).second;
			m_map.erase(seq);
		}

		m_lock->Unlock();
	}
	return task;
}
	
void ZBTaskMapManager::Clear(ZBTaskList& list)
{
	if (m_bInit) {
		m_lock->Lock();
	
		ZBTaskMap::iterator iter;
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
