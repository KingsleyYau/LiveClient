/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTransportDataHandler.h
 *   desc: 传输数据处理实现类
 */

#pragma once

#include "IZBTransportDataHandler.h"
#include "IZBThreadHandler.h"
#include "IZBTaskManager.h"	// 加载任务列表(TaskList)
#include "IZBTransportClient.h"

using namespace std;

class IAutoLock;
class ISocketHandler;
class ITransportPacketHandler;
class ZBCTransportDataHandler : public IZBTransportDataHandler, private IZBTransportClientCallback
{
public:
	ZBCTransportDataHandler(void);
	virtual ~ZBCTransportDataHandler(void);

public:
	// 初始化
	virtual bool Init(IZBTransportDataHandlerListener* listener) override;
	// 开始连接
	virtual bool Start(const list<string>& urls) override;
	// 停止连接（若连接断开会自动停止）
	virtual bool Stop() override;
	// 停止连接（等待）
	virtual bool StopAndWait() override;
	// 是否开始
	virtual bool IsStart() override;
	// 发送task数据（把task放到发送列队）
	virtual bool SendTaskData(IZBTask* task) override;
    
private:
	// 反初始化
	void Uninit();
	// 停止连接处理函数
	bool StopProc();

private:
	// 发送线程
	static TH_RETURN_PARAM SendThread(void* arg);
	void SendThreadProc(void);
	// 接收线程
	static TH_RETURN_PARAM LoopThread(void* arg);
	void LoopThreadProc(void);

private:
	bool ConnectProc();
	void SendProc();
	void DisconnectProc();
	void DisconnectCallback();
    
// IZBTransportClientCallback
private:
    virtual void OnConnect(bool success) override;
    virtual void OnRecvData(const unsigned char* data, size_t dataLen) override;
    virtual void OnDisconnect() override;

private:
	IZBTransportDataHandlerListener*	m_listener;			// 监听器
	IZBTransportPacketHandler*		m_packetHandler;	// 传输包处理器
    
    IZBTransportClient*   m_client;           // 客户端
    list<string>		m_urls;			// 服务器IP

	IAutoLock*			m_startLock;		// 开始锁
	bool				m_bStart;			// 开始标志
	IZBThreadHandler*		m_sendThread;		// 发送线程
	IZBThreadHandler*		m_loopThread;		// 接收线程

	IAutoLock*			m_sendTaskListLock;	// 待发送任务队列锁
	ZBTaskList			m_sendTaskList;		// 待发送任务队列
};
