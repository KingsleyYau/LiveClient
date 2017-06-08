/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TaskManager.h
 *   desc: Task（任务）管理器实现类
 */

#pragma once

#include "ITaskManager.h"
#include "ITransportDataHandler.h"
#include "TaskMapManager.h"

class CTaskManager : public ITaskManager
					,public ITransportDataHandlerListener
{
public:
	CTaskManager(void);
	virtual ~CTaskManager(void);

public:
	// 初始化接口
	virtual bool Init(const list<string>& urls, IImClientListener* clientListener, ITaskManagerListener* mgrListener) override;
	// 开始
	virtual bool Start() override;
	// 停止（不等待）
	virtual bool Stop() override;
	// 停止（等待）
	virtual bool StopAndWait() override;
	// 是否已经开始
	virtual bool IsStart() override;
	// 处理请求的task
	virtual bool HandleRequestTask(ITask* task) override;
    
// ITransportDataHandlerListener 接口函数
public:
	// 连接callback
	virtual void OnConnect(bool success) override;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ITransportDataHandler::Stop才能停止）
	virtual void OnDisconnect(const TaskList& listUnsentTask) override;
	// 发送callback
	virtual void OnSend(bool success, ITask* task) override;
	// 收到数据callback
	virtual void OnRecv(const TransportProtocol& tp) override;

private:
	IImClientListener*	m_clientListener;	// LiveChatClient监听器
	ITaskManagerListener*		m_mgrListener;		// TaskManager监听器
	ITransportDataHandler*		m_dataHandler;		// 传输数据处理器

	bool				m_bInit;		// 初始化标志
	bool				m_bStart;		// 开始标志

	list<string>		m_urls;		// url列表

	TaskMapManager		m_requestTaskMap;	// 请求的task map
};
