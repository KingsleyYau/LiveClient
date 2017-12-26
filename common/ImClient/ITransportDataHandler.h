/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITransportDataHandler.h
 *   desc: 传输数据处理接口类
 */

#pragma once

#include "ITransportPacketHandler.h"
#include "ITaskManager.h"		// 加载任务列表（TaskList）
#include <string>
#include <list>

using namespace std;

class ITask;
class ITransportDataHandlerListener
{
public:
	ITransportDataHandlerListener(void) {}
	virtual ~ITransportDataHandlerListener(void) {}

public:
	// 连接callback
	virtual void OnConnect(bool success) = 0;
	// 断开连接callback
	virtual void OnDisconnect() = 0;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ITransportDataHandler::Stop）
	virtual void OnDisconnect(const TaskList& listUnsentTask) = 0;
	// 发送callback
	virtual void OnSend(bool success, ITask* task) = 0;
	// 收到数据callback
	virtual void OnRecv(const TransportProtocol& tp) = 0;

};

class ITransportDataHandler
{
public:
	static ITransportDataHandler* Create();
	static void Release(ITransportDataHandler* handler);

public:
	ITransportDataHandler(void) {};
	virtual ~ITransportDataHandler(void) {};

public:
	// 初始化
	virtual bool Init(ITransportDataHandlerListener* listener) = 0;
	// 开始连接
	virtual bool Start(const list<string>& urls) = 0;
	// 停止连接（不等待）
	virtual bool Stop() = 0;
	// 停止连接（等待）
	virtual bool StopAndWait() = 0;
	// 是否开始
	virtual bool IsStart() = 0;
	// 发送task数据（把task放到发送列队）
	virtual bool SendTaskData(ITask* task) = 0;
};
