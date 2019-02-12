/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTaskManager.h
 *   desc: Task（任务）管理器接口类
 */

#pragma once

#include "ILSLiveChatTask.h"

#include <string>
#include <list>

using namespace std;

class ILSLiveChatTaskManagerListener
{
public:
	ILSLiveChatTaskManagerListener() {}
	virtual ~ILSLiveChatTaskManagerListener() {}

public:
	// 连接成功回调
	virtual void OnConnect(bool success) = 0;
	// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	virtual void OnDisconnect() = 0;
	// 断开连接或连接失败回调(listUnsentTask：未发送/未回复的task列表)
	virtual void OnDisconnect(const TaskList& list) = 0;
	// 已完成交互的task
	virtual void OnTaskDone(ILSLiveChatTask* task) = 0;
};

class ILSLiveChatClientListener;
class ILSLiveChatTask;
class ILSLiveChatTaskManager
{
public:
	ILSLiveChatTaskManager(void) {};
	virtual ~ILSLiveChatTaskManager(void) {};

public:
	// 初始化接口
	virtual bool Init(const list<string>& svrIPs, unsigned int svrPort, ILSLiveChatClientListener* clientListener, ILSLiveChatTaskManagerListener* mgrListener) = 0;
	// 开始
	virtual bool Start() = 0;
	// 停止
	virtual bool Stop() = 0;
	// 是否已经开始
	virtual bool IsStart() = 0;
	// 处理请求的task
	virtual bool HandleRequestTask(ILSLiveChatTask* task) = 0;
    // 获取原始socket
    virtual int GetSocket() = 0;
};
