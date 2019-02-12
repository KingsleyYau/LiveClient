/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: LSLiveChatTaskMap.h
 *   desc: Task Map管理（带锁）实现类
 */

#pragma once

#include "ILSLiveChatTask.h"
#include <map>

using namespace std;

typedef map<int, ILSLiveChatTask*> TaskMap;

class IAutoLock;
class LSLiveChatTaskMapManager
{
public:
	LSLiveChatTaskMapManager(void);
	virtual ~LSLiveChatTaskMapManager(void);

public:
	bool Init();
	bool Insert(ILSLiveChatTask* task);
	void InsertTaskList(const TaskList& list);
	ILSLiveChatTask* PopTaskWithSeq(int seq);
	void Clear(TaskList& list);

private:
	void Uninit();

private:
	TaskMap		m_map;
	IAutoLock*	m_lock;
	bool		m_bInit;
};
