/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: IAutoLock.cpp
 *   desc: 跨平台锁
 */


#include "IAutoLock.h"
#include <assert.h>

#ifdef WIN32

#include <windows.h>

class WinAutoLock : public IAutoLock
{
public:
	WinAutoLock() {
		m_bInit = false;
	}
	virtual ~WinAutoLock() {
		if (m_bInit) {
			DeleteCriticalSection(&m_section);
			m_bInit = false;
		}
	}

public:
	bool Init(IAutoLockType type) {
		if (!m_bInit) {
			m_bInit = InitializeCriticalSectionAndSpinCount(&m_section, 1) ? true : false;
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif
		}
		return m_bInit;
	}

	bool TryLock() {
		bool result = false;
		if (m_bInit) {
			TryEnterCriticalSection(&m_section);
			result = true;
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif
		}
		return result;
	}

	bool Lock() {
		bool result = false;
		if (m_bInit) {
			EnterCriticalSection(&m_section);
			result = true;
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return result;
	}

	bool Unlock() {
		bool result = false;
		if (m_bInit) {
			LeaveCriticalSection(&m_section);
			result = true;
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return result;
	}

private:
	CRITICAL_SECTION	m_section;
	bool				m_bInit;
};

#else

#include <pthread.h>

class LinuxAutoLock : public IAutoLock
{
public:
    LinuxAutoLock() {
        m_bInit = false;
    };

    virtual ~LinuxAutoLock() {
		if (m_bInit) {
			pthread_mutex_destroy(&m_lock);
			m_bInit = false;
		}
    };

public:
	bool Init(IAutoLockType type) {
		if (!m_bInit) {
            int mtType = PTHREAD_MUTEX_NORMAL;
            switch (type) {
                case IAutoLockType_Normal:{
                    mtType = PTHREAD_MUTEX_NORMAL;
                } break;
                case IAutoLockType_ErrorCheck:{
                    mtType = PTHREAD_MUTEX_ERRORCHECK;
                }break;
                case IAutoLockType_Recursive:{
                    mtType = PTHREAD_MUTEX_RECURSIVE;
                }break;
                case IAutoLockType_Default:{
                    mtType = PTHREAD_MUTEX_DEFAULT;
                }break;
                default:
                    break;
            }
            
            pthread_mutexattr_t mattr;
            pthread_mutexattr_init(&mattr);
            pthread_mutexattr_settype(&mattr, (int)mtType);
            
			m_bInit = pthread_mutex_init(&m_lock, &mattr) == 0;
            
            pthread_mutexattr_destroy(&mattr);
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return m_bInit;
	}

	bool TryLock() {
		bool result = false;
		if (m_bInit) {
			result = (0 == pthread_mutex_trylock(&m_lock));
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return result;
	}

	bool Lock() {
		bool result = false;
		if (m_bInit) {
			result = (0 == pthread_mutex_lock(&m_lock));
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return result;
	}

	bool Unlock() {
		bool result = false;
		if (m_bInit) {
			result = (0 == pthread_mutex_unlock(&m_lock));
		}
		else {
#if (defined DEBUG) || (defined _DEBUG)
			assert(false);
#endif		
		}
		return result;
	}

private:
	pthread_mutex_t	m_lock;
	bool			m_bInit;
};

#endif

IAutoLock* IAutoLock::CreateAutoLock()
{
	IAutoLock* lock = NULL;

#ifdef WIN32
	lock = new WinAutoLock();
#else
	lock = new LinuxAutoLock();
#endif

	return lock;
}

void IAutoLock::ReleaseAutoLock(IAutoLock* lock)
{
	delete lock;
}
