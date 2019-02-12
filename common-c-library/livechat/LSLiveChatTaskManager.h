/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTaskManager.h
 *   desc: Task（任务）管理器实现类
 */

#pragma once

#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatTransportDataHandler.h"
#include "LSLiveChatTaskMapManager.h"

class CLSLiveChatTaskManager : public ILSLiveChatTaskManager
					,public ILSLiveChatTransportDataHandlerListener
{
public:
	CLSLiveChatTaskManager(void);
	virtual ~CLSLiveChatTaskManager(void);

public:
	// 初始化接口
	virtual bool Init(const list<string>& svrIPs, unsigned int svrPort, ILSLiveChatClientListener* clientListener, ILSLiveChatTaskManagerListener* mgrListener) override;
	// 开始
	virtual bool Start() override;
	// 停止
	virtual bool Stop() override;
	// 是否已经开始
	virtual bool IsStart() override;
	// 处理请求的task
	virtual bool HandleRequestTask(ILSLiveChatTask* task) override;
    // 获取原始socket
    int GetSocket() override;
// ILiveChatTransportDataHandlerListener 接口函数
public:
	// 连接callback
	virtual void OnConnect(bool success) override;
	// 断开连接callback（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
	virtual void OnDisconnect() override;
	// 断开连接callback（连接不成功不会调用，断开后需要手动调用ILiveChatTransportDataHandler::Stop才能停止）
	virtual void OnDisconnect(const TaskList& listUnsentTask) override;
	// 发送callback
	virtual void OnSend(bool success, ILSLiveChatTask* task) override;
	// 收到数据callback
	virtual void OnRecv(const LSLiveChatTransportProtocol* tp) override;

private:
	ILSLiveChatClientListener*	m_clientListener;	// LiveChatClient监听器
	ILSLiveChatTaskManagerListener*		m_mgrListener;		// TaskManager监听器
	ILSLiveChatTransportDataHandler*		m_dataHandler;		// 传输数据处理器

	bool				m_bInit;		// 初始化标志
	bool				m_bStart;		// 开始标志

	list<string>		m_svrIPs;		// 服务器IP列表
	unsigned int		m_svrPort;		// 端口

	LSLiveChatTaskMapManager		m_requestTaskMap;	// 请求的task map
};
