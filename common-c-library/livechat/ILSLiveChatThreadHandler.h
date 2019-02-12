/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: ILSLiveChatThreadHandler.h
 *   desc: 跨平台线程处理接口类
 */

#pragma once

#ifdef WIN32
	#include <windows.h>
	#define TH_RETURN_PARAM	DWORD WINAPI	// 返回变量定义
	#define ThreadProFuncDef LPTHREAD_START_ROUTINE
#else
	#include <pthread.h>
	#define TH_RETURN_PARAM	void*	// 返回变量定义
	typedef TH_RETURN_PARAM (*ThreadProFuncDef)(void* param);
#endif

class ILSLiveChatThreadHandler
{
public:
	static ILSLiveChatThreadHandler* CreateThreadHandler();
	static void ReleaseThreadHandler(ILSLiveChatThreadHandler* handler);

public:
	ILSLiveChatThreadHandler(void) {};
	virtual ~ILSLiveChatThreadHandler(void) {};

public:
	// 开始
	virtual bool Start(ThreadProFuncDef func, void* arg) = 0;
	// 等待并停止
	virtual void WaitAndStop() = 0;
};
