/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTaskMap.h
 *   desc: Task Map管理（带锁）实现类
 */

#pragma once

#include "IZBTask.h"
#include <map>

using namespace std;

typedef map<unsigned long, IZBTask*> ZBTaskMap;

class IAutoLock;
class ZBTaskMapManager
{
public:
	ZBTaskMapManager(void);
	virtual ~ZBTaskMapManager(void);

public:
	bool Init();
	bool Insert(IZBTask* task);
	void InsertTaskList(const ZBTaskList& list);
	IZBTask* PopTaskWithSeq(unsigned long seq);
	void Clear(ZBTaskList& list);

private:
	void Uninit();

private:
	ZBTaskMap		m_map;
	IAutoLock*	m_lock;
	bool		m_bInit;
};
