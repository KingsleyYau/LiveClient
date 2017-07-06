/*
 * KThread.cpp
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "KThread.h"
#include <time.h>
#include "KLog.h"

#ifndef _WIN32
KThread::KThread() {
	mpThread = INVALID_PTHREAD;
	mIsRunning = false;
	mpKRunnable = NULL;
}

KThread::KThread(KRunnable *runnable) {
	mpThread = INVALID_PTHREAD;
	mIsRunning = false;
	mpKRunnable = runnable;
}

KThread::~KThread() {
//	Stop();
}

void* KThread::thread_proc_func(void *args){
	KThread *pKThread = (KThread*)args;
	if(pKThread){
		pKThread->onRun();
	}
	return (void*)0;
}

pthread_t KThread::Start(KRunnable *runnable){
	if( runnable != NULL ) {
		this->mpKRunnable = runnable;
	}

	pthread_attr_t attrs;
	pthread_attr_init(&attrs);
	pthread_attr_setdetachstate(&attrs, PTHREAD_CREATE_JOINABLE);

	int ret = pthread_create(&mpThread, &attrs, &thread_proc_func, (void*)this);
	if( 0 != ret ) {
		FileLog("common", "KThread::Start( [Create Thread Fail : %s] )", strerror(ret));
		mpThread = INVALID_PTHREAD;
	}
	else {
		FileLog("common", "KThread::Start( [Create Thread Succees : %lld] )", mpThread);
	}
    
	return mpThread;
}

void KThread::Stop() {
	if( IsRunning() ) {
		FileLog("common", "KThread::Stop( [Wait For Thread Exit : %lld ) ", mpThread);
		if(0 != pthread_join(mpThread, NULL)){
			FileLog("common", "KThread::Stop( [Wait For Thread Exit Fail : %lld] )", mpThread);
		}
		else{
			FileLog("common", "KThread::Stop( [Thread Exit Success : %lld] )", mpThread);
		}
	}
	mpThread = INVALID_PTHREAD;
}

pthread_t KThread::GetThreadId() const {
	return mpThread;
}

bool KThread::IsRunning() const {
	bool bFlag = false;
	if( mpThread != INVALID_PTHREAD ) {
		bFlag = true;
	}
	return bFlag;
}

void KThread::onRun() {
	if( NULL != mpKRunnable ) {
		mpKRunnable->onRun();
	}
}

#else

KThread::KThread() {
	m_pthread_t = NULL;
	m_threadId = 0;
	m_isRunning = false;
	m_pKRunnable = NULL;
}
KThread::KThread(KRunnable *runnable) {
	m_pthread_t = NULL;
	m_threadId = 0;
	m_isRunning = false;
	this->m_pKRunnable = runnable;
}
KThread::~KThread() {
	CloseHandle(m_pthread_t);
	m_pthread_t = NULL;
}
#ifndef _WIN32
void* KThread::thread_proc_func(void *args)
#else
DWORD WINAPI KThread::thread_proc_func(void *args)
#endif
{
	KThread *pKThread = (KThread*)args;
	if(pKThread){
//		DLog("common", "KThread::thread_proc_func ( (%ld)->onRun )", pKThread->getThreadId());
		pKThread->onRun();
	}
	//DLog("KThread", "thread_proc_func ( (%ld) exit ) \n", pKThread->getThreadId());
	return NULL;
}
pthread_t KThread::start(KRunnable *runnable){
	if( runnable != NULL ) {
		this->m_pKRunnable = runnable;
	}

	m_pthread_t = CreateThread(NULL, 0, KThread::thread_proc_func, this, 0, &m_threadId);
	if(NULL == m_pthread_t) {
		FileLog("common", "KThread::start( create thread fail reson : (%x) )", GetLastError());
	}
	else {
		FileLog("common", "KThread::start( create thread : (%lld) succeed )", m_pthread_t);
	}
	return m_threadId;
}
void KThread::stop() {
	if(isRunning()) {
		FileLog("common", "KThread::stop( wait for thread :(%ld) exit )", m_pthread_t);
		if(0 != WaitForSingleObject(m_pthread_t, INFINITE)){
			FileLog("common", "KThread::stop( wait for thread :(%lld) exit error fail )", m_pthread_t);
		}
		else{
			FileLog("common", "KThread::stop( thread : (%lld) exit succeed )", m_pthread_t);
		}
	}

	CloseHandle(m_pthread_t);
	m_pthread_t = NULL;
}
void KThread::sleep(uint32_t msec){
	//usleep(100);
//	struct timespect st;
//	st.tv_sec = msec / 1000;
//	st.tv_nsec = (msec % 1000) * 1000 * 1000;
//	if(-1 == nanosleep(&st, NULL)){
//		showLog("Jni.KThread.sleep", "thread sleep error!");
//	}
}
pthread_t KThread::getThreadId() const {
	//return pthread_self();
	return m_threadId;
}
bool KThread::isRunning() const{
	bool bFlag = false;
	if( NULL != m_pthread_t ) {
		bFlag = true;
	}
	return bFlag;
}
void KThread::onRun() {
	if( NULL != m_pKRunnable ) {
		m_pKRunnable->onRun();
	}
}

#endif
