/*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBTransportDataHandler.h
 *   desc: 传输数据处理接口类
 */

#pragma once

#include "IZBTransportPacketHandler.h"
#include "IZBTaskManager.h"		// 加载任务列表（TaskList）
#include <string>
#include <list>

using namespace std;

class IZBTask;
class IZBTransportDataHandlerListener
{
public:
	IZBTransportDataHandlerListener(void) {}
	virtual ~IZBTransportDataHandlerListener(void) {}

public:
	// 连接callback
	virtual void OnConnect(bool success) = 0;
	// 断开连接callback
	virtual void OnDisconnect() = 0;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ITransportDataHandler::Stop）
	virtual void OnDisconnect(const ZBTaskList& listUnsentTask) = 0;
	// 发送callback
	virtual void OnSend(bool success, IZBTask* task) = 0;
	// 收到数据callback
	virtual void OnRecv(const ZBTransportProtocol& tp) = 0;

};

class IZBTransportDataHandler
{
public:
	static IZBTransportDataHandler* Create();
	static void Release(IZBTransportDataHandler* handler);

public:
	IZBTransportDataHandler(void) {};
	virtual ~IZBTransportDataHandler(void) {};

public:
	// 初始化
	virtual bool Init(IZBTransportDataHandlerListener* listener) = 0;
	// 开始连接
	virtual bool Start(const list<string>& urls) = 0;
	// 停止连接（不等待）
	virtual bool Stop() = 0;
	// 停止连接（等待）
	virtual bool StopAndWait() = 0;
	// 是否开始
	virtual bool IsStart() = 0;
	// 发送task数据（把task放到发送列队）
	virtual bool SendTaskData(IZBTask* task) = 0;
};
