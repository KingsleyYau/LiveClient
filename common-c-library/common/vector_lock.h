/*
 * author: Samson.Fan
 *   date: 2015-12-31
 *   file: vector_lock.h
 *   desc: vector with lock
 */

#pragma once

#include <vector>
#include "IAutoLock.h"

template<class T> class vector_lock	: public std::vector<T>
{
public:
	vector_lock()
	{
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_lock->Init();
		}
	}

	virtual ~vector_lock()
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
