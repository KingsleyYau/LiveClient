/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TransportDataHandler.cpp
 *   desc: 传输数据处理实现类
 */

#include "TransportDataHandler.h"
#include "TransportPacketHandler.h"
#include "ITask.h"
#include <common/IAutoLock.h>
#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

CTransportDataHandler::CTransportDataHandler(void)
{
	m_listener = NULL;
	m_packetHandler = NULL;

	m_sendThread = NULL;
	m_loopThread = NULL;

	m_startLock = NULL;
	m_bStart = false;
    
    m_client = NULL;

	m_sendTaskListLock = NULL;
}

CTransportDataHandler::~CTransportDataHandler(void)
{
	FileLog("LiveChatClient", "CTransportDataHandler::~CTransportDataHandler() begin, this:%p", this);
	StopAndWait();
	FileLog("LiveChatClient", "CTransportDataHandler::~CTransportDataHandler() StopAndWait() ok, this:%p", this);
	Uninit();
	FileLog("LiveChatClient", "CTransportDataHandler::~CTransportDataHandler() end, this:%p", this);
}

// 初始化
bool CTransportDataHandler::Init(ITransportDataHandlerListener* listener)
{
	FileLog("LiveChatClient", "CTransportDataHandler::Init() listener:%p", listener);

	bool result = false;
	m_listener = listener;

	// 创建待发送队列锁
	if (NULL == m_sendTaskListLock) {
		m_sendTaskListLock = IAutoLock::CreateAutoLock();
		if (NULL != m_sendTaskListLock) {
			m_sendTaskListLock->Init();
		}
	}
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_sendTaskListLock:%p", m_sendTaskListLock);

	if (NULL == m_packetHandler) {
		m_packetHandler = ITransportPacketHandler::Create();
	}
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_packetHandler:%p", m_packetHandler);

	if (NULL == m_sendThread) {
		m_sendThread = IThreadHandler::CreateThreadHandler();
	}
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_sendThread:%p", m_sendThread);

	if (NULL == m_loopThread) {
		m_loopThread = IThreadHandler::CreateThreadHandler();
	}
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_loopThread:%p", m_loopThread);

	if (NULL == m_startLock) {
		m_startLock = IAutoLock::CreateAutoLock();
		if (NULL != m_startLock) {
			m_startLock->Init();
		}
	}
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_startLock:%p", m_startLock);

    m_client = ITransportClient::Create();
    if (NULL != m_client) {
        m_client->Init(this);
    }
	FileLog("LiveChatClient", "CTransportDataHandler::Init() create m_client:%p", m_client);

	result = (NULL != m_sendTaskListLock
				&& NULL != m_packetHandler
				&& NULL != m_sendThread
				&& NULL != m_loopThread
				&& NULL != m_startLock
				&& NULL != m_client);

	FileLog("LiveChatClient", "CTransportDataHandler::Init() result:%d", result);

	if (!result) {
		Uninit();
	}

	return result;
}

// 反初始化
void CTransportDataHandler::Uninit()
{
	FileLog("LiveChatClient", "CTransportDataHandler::Uninit()");

	delete m_sendTaskListLock;
	m_sendTaskListLock = NULL;

	delete m_sendThread;
	m_sendThread = NULL;

	delete m_loopThread;
	m_loopThread = NULL;

	ITransportPacketHandler::Release(m_packetHandler);
	m_packetHandler = NULL;

	IAutoLock::ReleaseAutoLock(m_startLock);
	m_startLock = NULL;

    ITransportClient::Release(m_client);
    m_client = NULL;

	m_listener = NULL;
}

// 开始连接
bool CTransportDataHandler::Start(const list<string>& urls)
{
	FileLog("LiveChatClient", "CTransportDataHandler::Start() urls.size:%d, this:%p", urls.size(), this);

	m_startLock->Lock();

	// 若已经启动则停止
	if (IsStart()) {
		StopProc();
	}

	// 赋值
	m_urls = urls;
	// 启动发送及连接线程
	if (NULL != m_loopThread) {
		m_bStart = m_loopThread->Start(LoopThread, this);
	}

	// 启动失败
	if (!m_bStart) {
		StopProc();
	}

	m_startLock->Unlock();

	FileLog("LiveChatClient", "CTransportDataHandler::Start() m_bStart:%d", m_bStart);

	return m_bStart;
}

// 停止连接
bool CTransportDataHandler::Stop()
{
	bool result = false;

	FileLog("LiveChatClient", "CTransportDataHandler::Stop() begin");
	m_startLock->Lock();
	DisconnectProc();
	result = true;
	m_startLock->Unlock();
	FileLog("LiveChatClient", "CTransportDataHandler::Stop() end");

	return result;
}

// 停止连接（等待）
bool CTransportDataHandler::StopAndWait()
{
	bool result = false;

	FileLog("LiveChatClient", "CTransportDataHandler::StopAndWait() begin");
	m_startLock->Lock();
	result = StopProc();
	m_startLock->Unlock();
	FileLog("LiveChatClient", "CTransportDataHandler::StopAndWait() end");

	return result;	
}

// 停止连接处理函数
bool CTransportDataHandler::StopProc()
{
	FileLog("LiveChatClient", "CTransportDataHandler::StopProc() begin");
	long long startTime = getCurrentTime();

	// 断开连接
	DisconnectProc();

	FileLog("LiveChatClient", "CTransportDataHandler::StopProc() m_loopThread->WaitAndStop()");
	// 停接收线程
	if (NULL != m_loopThread) {
		m_loopThread->WaitAndStop();
	}

	m_urls.clear();

    m_client->Disconnect();
	FileLog("LiveChatClient", "CTransportDataHandler::StopProc() m_client->Disconnect()");
	
	long long endTime = getCurrentTime();
	long long diffTime = DiffTime(startTime, endTime);

	FileLog("LiveChatClient", "CTransportDataHandler::StopProc() end, m_bStart:%d, diffTime:%ld", m_bStart, diffTime);

	return true;
}

// 是否开始
bool CTransportDataHandler::IsStart()
{
	FileLog("LiveChatClient", "CTransportDataHandler::IsStart() m_bStart:%d", m_bStart);
	return m_bStart;
}

// 发送task数据（把task放到发送列队）
bool CTransportDataHandler::SendTaskData(ITask* task)
{
	FileLog("LiveChatClient", "CTransportDataHandler::SendTaskData() task:%p", task);
	bool result = false;
	if (m_bStart) {
		m_sendTaskListLock->Lock();
		m_sendTaskList.push_back(task);
		m_sendTaskListLock->Unlock();
		result = true;
	}
	FileLog("LiveChatClient", "CTransportDataHandler::SendTaskData() end, task:%p", task);
	return result;
}

// 发送线程
TH_RETURN_PARAM CTransportDataHandler::SendThread(void* arg)
{
	FileLog("LiveChatClient", "CTransportDataHandler::SendThread() arg:%p", arg);
	CTransportDataHandler* pThis = (CTransportDataHandler*) arg;
	pThis->SendThreadProc();
	FileLog("LiveChatClient", "CTransportDataHandler::SendThread() end, arg:%p", arg);
	return NULL;
}

void CTransportDataHandler::SendThreadProc(void)
{
	FileLog("LiveChatClient", "CTransportDataHandler::SendThreadProc() begin, m_bStart:%d", m_bStart);
	// 连接
	if (m_bStart) {
		FileLog("LiveChatClient", "CTransportDataHandler::SendThreadProc() SendProc()");
		// 处理task发送队列
		SendProc();
	}
	FileLog("LiveChatClient", "CTransportDataHandler::SendThreadProc() end");
}

// 接收线程
TH_RETURN_PARAM CTransportDataHandler::LoopThread(void* arg)
{
	FileLog("LiveChatClient", "CTransportDataHandler::LoopThread() arg:%p", arg);
	CTransportDataHandler* pThis = (CTransportDataHandler*) arg;
	pThis->LoopThreadProc();
    
	FileLog("LiveChatClient", "CTransportDataHandler::LoopThread() end");
	return NULL;
}

void CTransportDataHandler::LoopThreadProc(void)
{
	FileLog("LiveChatClient", "CTransportDataHandler::LoopThreadProc() start");
    if (ConnectProc()) {
        // 启动发送线程
        if (NULL != m_sendThread) {
            m_sendThread->Start(SendThread, this);
        }
        
        m_client->Loop();
        
        // 停止发送线程
        if (NULL != m_sendThread) {
            m_sendThread->WaitAndStop();
        }
        // 设置接收线程的标志位为false
        m_loopThread->SetStartSign();
    }
	FileLog("LiveChatClient", "CTransportDataHandler::LoopThreadProc() end");
}


bool CTransportDataHandler::ConnectProc()
{
	bool result = false;
	FileLog("LiveChatClient", "CTransportDataHandler::ConnectProc() start, this:%p", this);
	FileLog("LiveChatClient", "CTransportDataHandler::ConnectProc() m_urls:%d", m_urls.size());
	FileLog("LiveChatClient", "CTransportDataHandler::ConnectProc() m_bStart:%d", m_bStart);

	for (list<string>::iterator iter = m_urls.begin();
		iter != m_urls.end() && m_bStart;
		iter++)
	{
		FileLog("LiveChatClient", "CTransportDataHandler::ConnectProc() url:%s start", (*iter).c_str());
        // 暂时只连接第一个url
        if (m_client->Connect((*iter).c_str())) {
            result = true;
            break;
        }
	}

	FileLog("LiveChatClient", "CTransportDataHandler::ConnectProc() end, result:%d", result);
	return result;
}

void CTransportDataHandler::SendProc()
{
	FileLog("LiveChatClient", "CTransportDataHandler::SendProc()");

    // 新建发送buffer
	size_t bufferSize = 1024 * 100;
	unsigned char* buffer = new unsigned char[bufferSize];
    memset(buffer, 0, bufferSize);
    
    // 发送循环
	while (m_bStart) {
		ITask* task = NULL;
		m_sendTaskListLock->Lock();
		if (!m_sendTaskList.empty()) {
			task = m_sendTaskList.front();
			m_sendTaskList.pop_front();
		}
		m_sendTaskListLock->Unlock();

        size_t dataLen = 0;
		if (NULL != task && NULL != m_packetHandler
            && m_packetHandler->Packet(task, buffer, bufferSize, dataLen))
        {
			bool success = false;
            if (NULL != m_client) {
				success = m_client->SendData(buffer, dataLen);
            }

			if (NULL != m_listener) {
				m_listener->OnSend(success, task);
			}
		}
		else {
			Sleep(100);
		}
	}

    // 释放发送buffer
	delete []buffer;
    
    FileLog("LiveChatClient", "CTransportDataHandler::SendProc() end");
}

void CTransportDataHandler::DisconnectProc()
{
	FileLog("LiveChatClient", "CTransportDataHandler::DisconnectProc()");

	m_bStart = false;

    if (NULL != m_client) {
        m_client->Disconnect();
    }

	FileLog("LiveChatClient", "CTransportDataHandler::DisconnectProc() end");
}

void CTransportDataHandler::DisconnectCallback()
{
	FileLog("LiveChatClient", "CTransportDataHandler::DisconnectCallback()");
	m_sendTaskListLock->Lock();
	if (NULL != m_listener) {
		m_listener->OnDisconnect(m_sendTaskList);
	}
	m_sendTaskList.clear();
	m_sendTaskListLock->Unlock();
	FileLog("LiveChatClient", "CTransportDataHandler::DisconnectCallback() end");
}

// ------ ITransportClientCallback
void CTransportDataHandler::OnConnect(bool success)
{
    if (NULL != m_listener) {
        m_listener->OnConnect(success);
    }
}

void CTransportDataHandler::OnRecvData(const unsigned char* data, size_t dataLen)
{
    size_t strLen = dataLen;
    if (NULL != m_listener) {
        if (NULL != m_packetHandler) {
            TransportProtocol tp;
            m_packetHandler->Unpacket(data, dataLen, tp);
            m_listener->OnRecv(tp);
        }
    }
}

void CTransportDataHandler::OnDisconnect()
{
    DisconnectCallback();
}

