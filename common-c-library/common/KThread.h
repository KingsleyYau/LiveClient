/*
 * KThread.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _INC_KTHREAD_
#define _INC_KTHREAD_

#include <stdio.h>
#include <stdlib.h>

#ifndef _WIN32
#include <pthread.h>
#include <string.h>
#endif

#include <common/KMutex.h>
#include <common/KRunnable.h>

#ifndef _WIN32

#ifdef IOS
#define INVALID_PTHREAD NULL
#else
#define INVALID_PTHREAD -1
#endif

class KThread {
public:
	KThread();
	KThread(KRunnable *runnable);
	virtual ~KThread();
    
	pthread_t Start(KRunnable *runnable = NULL);
	void Stop();
    
	bool IsRunning() const;
	pthread_t GetThreadId() const;
    
protected:
	virtual void onRun();
    
private:
	KRunnable *mpKRunnable;
	bool mIsRunning;
	pthread_t mpThread;
    
	static void *thread_proc_func(void *args);
};

#else

#include <windows.h>
#define pthread_t DWORD
#define uint32_t DWORD

class KThread
{
public:
	KThread();
	KThread(KRunnable *runnable);
	virtual ~KThread();
	pthread_t start(KRunnable *runnable = NULL);
	void stop();
	void sleep(uint32_t msec);
	bool isRunning() const;
	pthread_t getThreadId() const;
protected:
	virtual void onRun();
private:
	KRunnable *m_pKRunnable;
	bool m_isRunning;
	HANDLE m_pthread_t;
	DWORD m_threadId;
#ifndef _WIN32
	static void *thread_proc_func(void *args);
#else
	static DWORD WINAPI thread_proc_func(void *args);
#endif
};
#endif

#endif
