/*
 * author: Samson.Fan
 *   date: 2015-12-31
 *   file: list_lock.h
 *   desc: list with lock
 */

#pragma once

#include <list>
#include "IAutoLock.h"

template<class T> class list_lock : public std::list<T>
{
public:
	list_lock()
	{
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_lock->Init(IAutoLock::IAutoLockType_Recursive);
		}
	}

	virtual ~list_lock()
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

	bool has(const T& value) const
	{
		bool result = false;
		typename std::list<T>::const_iterator iter;
		for (iter = std::list<T>::begin();
			iter != std::list<T>::end();
			iter++)
		{
			if (value == (*iter))
			{
				result = true;
				break;
			}
		}
		return result;
	}

	bool erase(const T& value)
	{
		bool result = false;
		typename std::list<T>::iterator iter = std::list<T>::begin();
		while (iter != std::list<T>::end())
		{
			if (value == (*iter))
			{
				iter = std::list<T>::erase(iter);
				result = true;
				continue;
			}
			iter++;
		}
		return result;
	}

	typename std::list<T>::iterator erase(typename std::list<T>::iterator _Where)
	{
		return std::list<T>::erase(_Where);
	}

private:
	IAutoLock* m_lock;
};
