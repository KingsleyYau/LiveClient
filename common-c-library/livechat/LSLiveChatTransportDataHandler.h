/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTransportDataHandler.h
 *   desc: 传输数据处理实现类
 */

#pragma once

#include "ILSLiveChatTransportDataHandler.h"
#include "ILSLiveChatThreadHandler.h"
#include "ILSLiveChatTaskManager.h"	// 加载任务列表(TaskList)

using namespace std;

class IAutoLock;
class ILSLiveChatSocketHandler;
class ILSLiveChatTransportPacketHandler;
class CLSLiveChatTransportDataHandler : public ILSLiveChatTransportDataHandler
{
public:
	CLSLiveChatTransportDataHandler(void);
	virtual ~CLSLiveChatTransportDataHandler(void);

public:
	// 初始化
	virtual bool Init(ILSLiveChatTransportDataHandlerListener* listener) override;
	// 开始连接
	virtual bool Start(const list<string>& ips, unsigned int port) override;
	// 停止连接（若连接断开会自动停止）
	virtual bool Stop() override;
	// 是否开始
	virtual bool IsStart() override;
	// 发送task数据（把task放到发送列队）
	virtual bool SendTaskData(ILSLiveChatTask* task) override;
    // 获取原始socket
    int GetSocket() override;
    
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
	static TH_RETURN_PARAM RecvThread(void* arg);
	void RecvThreadProc(void);
	void RecvProc(void);

private:
	bool ConnectProc();
	void SendProc();
	void DisconnectProc();
	void DisconnectCallback();
	// 删除pBuffer头nRemoveLength个字节
	void RemoveData(unsigned char* pBuffer, int nBufferLength, int nRemoveLength);

private:
	ILSLiveChatTransportDataHandlerListener*	m_listener;			// 监听器
	ILSLiveChatTransportPacketHandler*		m_packetHandler;	// 传输包处理器

	list<string>		m_svrIPs;			// 服务器IP
	unsigned int		m_svrPort;			// 服务器端口
	ILSLiveChatSocketHandler*		m_socketHandler;	// socket
	IAutoLock*			m_socketLock;		// socket锁

	IAutoLock*			m_startLock;		// 开始锁
	bool				m_bStart;			// 开始标志
	ILSLiveChatThreadHandler*		m_sendThread;		// 发送线程
	unsigned char*		m_sendBuffer;		// 发送缓冲
	size_t				m_sendBufferSize;	// 发送缓冲大小
	ILSLiveChatThreadHandler*		m_recvThread;		// 接收线程
	unsigned char*		m_recvBuffer;		// 接收缓冲
	size_t				m_recvBufferSize;	// 接收缓冲大小

	IAutoLock*			m_sendTaskListLock;	// 待发送任务队列锁
	TaskList			m_sendTaskList;		// 待发送任务队列
};
