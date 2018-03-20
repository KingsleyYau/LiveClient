/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTaskManager.h
 *   desc: Task（任务）管理器实现类
 */

#pragma once

#include "IZBTaskManager.h"
#include "IZBTransportDataHandler.h"
#include "ZBTaskMapManager.h"

class ZBCTaskManager : public IZBTaskManager
					,public IZBTransportDataHandlerListener
{
public:
	ZBCTaskManager(void);
	virtual ~ZBCTaskManager(void);

public:
	// 初始化接口
	virtual bool Init(const list<string>& urls, IZBImClientListener* clientListener, IZBTaskManagerListener* mgrListener) override;
	// 开始
	virtual bool Start() override;
	// 停止（不等待）
	virtual bool Stop() override;
	// 停止（等待）
	virtual bool StopAndWait() override;
	// 是否已经开始
	virtual bool IsStart() override;
	// 处理请求的task
	virtual bool HandleRequestTask(IZBTask* task) override;
    
// IZBTransportDataHandlerListener 接口函数
public:
	// 连接callback
	virtual void OnConnect(bool success) override;
	// 断开连接callback（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	virtual void OnDisconnect() override;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ITransportDataHandler::Stop才能停止）
	virtual void OnDisconnect(const ZBTaskList& listUnsentTask) override;
	// 发送callback
	virtual void OnSend(bool success, IZBTask* task) override;
	// 收到数据callback
	virtual void OnRecv(const ZBTransportProtocol& tp) override;

private:
	IZBImClientListener*	m_clientListener;	// ImClient监听器
	IZBTaskManagerListener*		m_mgrListener;		// TaskManager监听器
	IZBTransportDataHandler*		m_dataHandler;		// 传输数据处理器

	bool				m_bInit;		// 初始化标志
	bool				m_bStart;		// 开始标志

	list<string>		m_urls;		// url列表

	ZBTaskMapManager		m_requestTaskMap;	// 请求的task map
};
