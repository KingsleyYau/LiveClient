/*
 * author: Samson.Fan
 *   date: 2015-01-13
 *   file: map_lock.h
 *   desc: dual map with lock
 */

#pragma once

#include <map>
#include <iostream>
#include <list>
#include "IAutoLock.h"


template<class T, class A> class dualmap_lock
{
private:
	typedef std::map<T, A> PositiveMap;
	typedef std::map<A, T> ReverseMap;

public:
	typedef std::list<T> KeyList;
	typedef std::list<A> ValueList;

public:
	dualmap_lock()
	{
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_lock->Init();
		}
	}

	virtual ~dualmap_lock()
	{
		IAutoLock::ReleaseAutoLock(m_lock);
		m_lock = NULL;
	}

	// lock
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

	// operation
public:
	bool insertItem(const T& key, const A& value)
	{
		bool result = false;

		typename PositiveMap::const_iterator positiveIter = m_positiveMap.find(key);
		typename ReverseMap::const_iterator reverseIter = m_reverseMap.find(value);
		if (positiveIter == m_positiveMap.end() && reverseIter == m_reverseMap.end())
		{
			std::pair<typename PositiveMap::iterator, bool> positiveResult;
			std::pair<typename ReverseMap::iterator, bool> reverseResult;

			positiveResult = m_positiveMap.insert(typename PositiveMap::value_type(key, value));
			if (positiveResult.second) {
				reverseResult = m_reverseMap.insert(typename ReverseMap::value_type(value, key));
				if (reverseResult.second) {
					result = true;
				}
				else {
					// insert fail, remove
					m_positiveMap.erase(key);
				}
			}
		}

		return result;
	}

	bool findWithValue(const A& value, T& key) const
	{
		bool result = false;

		typename ReverseMap::const_iterator iter = m_reverseMap.find(value);
		if (iter != m_reverseMap.end()) {
			key = (*iter).second;
			result = true;
		}

		return result;
	}

	bool findWithKey(const T& key, A& value) const
	{
		bool result = false;

		typename PositiveMap::const_iterator iter = m_positiveMap.find(key);
		if (iter != m_positiveMap.end()) {
			value = (*iter).second;
			result = true;
		}

		return result;
	}

	bool eraseWithKey(const T& key)
	{
		bool result = false;

		typename PositiveMap::iterator positiveIter = m_positiveMap.find(key);
		if (positiveIter != m_positiveMap.end()) {
			typename ReverseMap::iterator reverseIter = m_reverseMap.find((*positiveIter).second);
			if (reverseIter != m_reverseMap.end()) {
				m_reverseMap.erase(reverseIter);
			}
			m_positiveMap.erase(positiveIter);

			result = true;
		}

		return result;
	}

	bool eraseWithValue(const A& value)
	{
		bool result = false;

		typename ReverseMap::iterator reverseIter = m_reverseMap.find(value);
		if (reverseIter != m_reverseMap.end()) {
			typename PositiveMap::iterator positiveIter = m_positiveMap.find((*reverseIter).second);
			if (positiveIter != m_positiveMap.end()) {
				m_positiveMap.erase(positiveIter);
			}
			m_reverseMap.erase(reverseIter);

			result = true;
		}

		return result;
	}

	KeyList getKeyList() const
	{
		KeyList result;
		for (typename PositiveMap::const_iterator iter = m_positiveMap.begin();
			iter != m_positiveMap.end();
			iter++)
		{
			result.push_back((*iter).first);
		}
		return result;
	}

	ValueList getValueList() const
	{
		ValueList result;
		for (typename PositiveMap::const_iterator iter = m_positiveMap.begin();
			iter != m_positiveMap.end();
			iter++)
		{
			result.push_back((*iter).second);
		}
		return result;
	}

	void clear()
	{
		m_positiveMap.clear();
		m_reverseMap.clear();
	}

private:
	IAutoLock*	m_lock;
	PositiveMap	m_positiveMap;
	ReverseMap	m_reverseMap;
};
