/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITaskManager.h
 *   desc: Task（任务）管理器接口类
 */

#pragma once

#include "ITask.h"

#include <string>
#include <list>

using namespace std;

class ITaskManagerListener
{
public:
	ITaskManagerListener() {}
	virtual ~ITaskManagerListener() {}

public:
	// 连接成功回调
	virtual void OnConnect(bool success) = 0;
	// 连接失败回调
	virtual void OnDisconnect() = 0;
	// 连接失败回调(listUnsentTask：未发送/未回复的task列表)
	virtual void OnDisconnect(const TaskList& list) = 0;
	// 已完成交互的task
	virtual void OnTaskDone(ITask* task) = 0;
};

class ILiveChatClientListener;
class ITask;
class ITaskManager
{
public:
	ITaskManager(void) {};
	virtual ~ITaskManager(void) {};

public:
	// 初始化接口
	virtual bool Init(const list<string>& urls, IImClientListener* clientListener, ITaskManagerListener* mgrListener) = 0;
	// 开始
	virtual bool Start() = 0;
	// 停止（不等待）
	virtual bool Stop() = 0;
	// 停止（等待）
	virtual bool StopAndWait() = 0;
	// 是否已经开始
	virtual bool IsStart() = 0;
	// 处理请求的task
	virtual bool HandleRequestTask(ITask* task) = 0;
};
