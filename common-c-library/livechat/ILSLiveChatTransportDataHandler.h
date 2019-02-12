/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTransportDataHandler.h
 *   desc: 传输数据处理接口类
 */

#pragma once

#include "ILSLiveChatTransportPacketHandler.h"
#include "ILSLiveChatTaskManager.h"		// 加载任务列表（TaskList）
#include <string>
#include <list>

using namespace std;

class ILSLiveChatTask;
class ILSLiveChatTransportDataHandlerListener
{
public:
	ILSLiveChatTransportDataHandlerListener(void) {}
	virtual ~ILSLiveChatTransportDataHandlerListener(void) {}

public:
	// 连接callback
	virtual void OnConnect(bool success) = 0;
	// 断开连接callback（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	virtual void OnDisconnect() = 0;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ILiveChatTransportDataHandler::Stop）
	virtual void OnDisconnect(const TaskList& listUnsentTask) = 0;
	// 发送callback
	virtual void OnSend(bool success, ILSLiveChatTask* task) = 0;
	// 收到数据callback
	virtual void OnRecv(const LSLiveChatTransportProtocol* tp) = 0;

};

class ILSLiveChatTransportDataHandler
{
public:
	static ILSLiveChatTransportDataHandler* Create();
	static void Release(ILSLiveChatTransportDataHandler* handler);

public:
	ILSLiveChatTransportDataHandler(void) {};
	virtual ~ILSLiveChatTransportDataHandler(void) {};

public:
	// 初始化
	virtual bool Init(ILSLiveChatTransportDataHandlerListener* listener) = 0;
	// 开始连接
	virtual bool Start(const list<string>& ips, unsigned int port) = 0;
	// 停止连接
	virtual bool Stop() = 0;
	// 是否开始
	virtual bool IsStart() = 0;
	// 发送task数据（把task放到发送列队）
	virtual bool SendTaskData(ILSLiveChatTask* task) = 0;
    // 获取原始socket
    virtual int GetSocket() = 0;
};
