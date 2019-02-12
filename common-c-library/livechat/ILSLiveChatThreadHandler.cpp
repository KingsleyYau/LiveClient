/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatThreadHandler.cpp
 *   desc: 跨平台线程处理类
 */

#include "ILSLiveChatThreadHandler.h"
#include <common/CheckMemoryLeak.h>

#ifdef WIN32

class LSLiveChatWinThreadHandler : public ILSLiveChatThreadHandler
{
public:
	LSLiveChatWinThreadHandler(void) {
		m_hThread = NULL;
	}
	virtual ~LSLiveChatWinThreadHandler(void) {
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

private:
	HANDLE	m_hThread;
};

#else

class LSLiveChatLinuxThreadHandler : public ILSLiveChatThreadHandler
{
public:
	LSLiveChatLinuxThreadHandler(void) {
		m_bStart = false;
	}
	virtual ~LSLiveChatLinuxThreadHandler(void) {
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

private:
	bool		m_bStart;
	pthread_t	m_tId;
};

#endif

ILSLiveChatThreadHandler* ILSLiveChatThreadHandler::CreateThreadHandler()
{
	ILSLiveChatThreadHandler* handler = NULL;
#ifdef WIN32
	handler = new LSLiveChatWinThreadHandler();
#else 
	handler = new LSLiveChatLinuxThreadHandler();
#endif
	return handler;
}

void ILSLiveChatThreadHandler::ReleaseThreadHandler(ILSLiveChatThreadHandler* handler)
{
	delete handler;
}
