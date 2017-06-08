/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: TaskMap.h
 *   desc: Task Map管理（带锁）实现类
 */

#pragma once

#include "ITask.h"
#include <map>

using namespace std;

typedef map<unsigned long, ITask*> TaskMap;

class IAutoLock;
class TaskMapManager
{
public:
	TaskMapManager(void);
	virtual ~TaskMapManager(void);

public:
	bool Init();
	bool Insert(ITask* task);
	void InsertTaskList(const TaskList& list);
	ITask* PopTaskWithSeq(unsigned long seq);
	void Clear(TaskList& list);

private:
	void Uninit();

private:
	TaskMap		m_map;
	IAutoLock*	m_lock;
	bool		m_bInit;
};
