/*
 * author: Alex
 *   date: 2018-03-2
 *   file: IZBTaskManager.h
 *   desc: Task（任务）管理器接口类
 */

#pragma once

#include "IZBTask.h"

#include <string>
#include <list>

using namespace std;

class IZBTaskManagerListener
{
public:
	IZBTaskManagerListener() {}
	virtual ~IZBTaskManagerListener() {}

public:
	// 连接成功回调
	virtual void OnConnect(bool success) = 0;
	// 连接失败回调
	virtual void OnDisconnect() = 0;
	// 连接失败回调(listUnsentTask：未发送/未回复的task列表)
	virtual void OnDisconnect(const ZBTaskList& list) = 0;
	// 已完成交互的task
	virtual void OnTaskDone(IZBTask* task) = 0;
};

class IZBLiveChatClientListener;
class IZBTask;
class IZBTaskManager
{
public:
	IZBTaskManager(void) {};
	virtual ~IZBTaskManager(void) {};

public:
	// 初始化接口
	virtual bool Init(const list<string>& urls, IZBImClientListener* clientListener, IZBTaskManagerListener* mgrListener) = 0;
	// 开始
	virtual bool Start() = 0;
	// 停止（不等待）
	virtual bool Stop() = 0;
	// 停止（等待）
	virtual bool StopAndWait() = 0;
	// 是否已经开始
	virtual bool IsStart() = 0;
	// 处理请求的task
	virtual bool HandleRequestTask(IZBTask* task) = 0;
};
