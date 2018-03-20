/*
 * author: alex
 *   date: 2018-03-03
 *   file: ThreadHandler.cpp
 *   desc: 跨平台线程处理类
 */

#include "IZBThreadHandler.h"
#include <common/CheckMemoryLeak.h>

#ifdef WIN32

class ZBWinThreadHandler : public IZBThreadHandler
{
public:
	ZBWinThreadHandler(void) {
		m_hThread = NULL;
	}
	virtual ~ZBWinThreadHandler(void) {
		WaitAndStop();
	}

public:
	// 开始
	virtual bool Start(ThreadProFuncDef func, void* arg) {
		bool result = false;
		if (NULL == m_hThread) {
			m_hThread = CreateThread(NULL, 0, func, arg, 0, NULL);
			result = NULL != m_hThread;
		}
		return result;
	}
	
	// 等待并停止
	virtual void WaitAndStop() {
		if (NULL != m_hThread) {
			WaitForSingleObject(m_hThread, INFINITE);
			CloseHandle(m_hThread);
			m_hThread = NULL;
		}
	}
    virtual void SetStartSign() {
    
    }

private:
	HANDLE	m_hThread;
};

#else

class ZBLinuxThreadHandler : public IZBThreadHandler
{
public:
	ZBLinuxThreadHandler(void) {
		m_bStart = false;
	}
	virtual ~ZBLinuxThreadHandler(void) {
		WaitAndStop();
	}

public:
	// 开始
	virtual bool Start(ThreadProFuncDef func, void* arg) {
		bool result = false;
		if (!m_bStart) {
			int err = pthread_create(&m_tId, NULL, func, arg);
			m_bStart = err == 0;
			result = m_bStart;
		}
		return result;
	}
	
	// 等待并停止
	virtual void WaitAndStop() {
		if (m_bStart) {
			pthread_join(m_tId, NULL);
			m_bStart = false;
		}
	}
    
    virtual void SetStartSign() {
        m_bStart = false;
    }

private:
	bool		m_bStart;
	pthread_t	m_tId;
};

#endif

IZBThreadHandler* IZBThreadHandler::CreateThreadHandler()
{
	IZBThreadHandler* handler = NULL;
#ifdef WIN32
	handler = new ZBWinThreadHandler();
#else 
	handler = new ZBLinuxThreadHandler();
#endif
	return handler;
}

void IZBThreadHandler::ReleaseThreadHandler(IZBThreadHandler* handler)
{
	delete handler;
}
