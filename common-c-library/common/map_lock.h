/*
 * author: Samson.Fan
 *   date: 2015-12-31
 *   file: map_lock.h
 *   desc: map with lock
 */

#pragma once

#include <map>
#include "IAutoLock.h"

template<class T, class A> class map_lock : public std::map<T, A>
{
public:
	map_lock()
	{
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_lock->Init();
		}
	}

	virtual ~map_lock()
	{
		IAutoLock::ReleaseAutoLock(m_lock);
		m_lock = NULL;
	}

public:
	void lock()
	{
		if (NULL != m_lock)
		{
			m_lock->Lock();
		}
	}

	void unlock()
	{
		if (NULL != m_lock)
		{
			m_lock->Unlock();
		}
	}

private:
	IAutoLock* m_lock;
};
