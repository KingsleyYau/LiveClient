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
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::~CTransportDataHandler() begin, this:%p", this);
	StopAndWait();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::~CTransportDataHandler() StopAndWait() ok, this:%p", this);
	Uninit();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::~CTransportDataHandler() end, this:%p", this);
}

// 初始化
bool CTransportDataHandler::Init(ITransportDataHandlerListener* listener)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() listener:%p", listener);

	bool result = false;
	m_listener = listener;

	// 创建待发送队列锁
	if (NULL == m_sendTaskListLock) {
		m_sendTaskListLock = IAutoLock::CreateAutoLock();
		if (NULL != m_sendTaskListLock) {
			m_sendTaskListLock->Init();
		}
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_sendTaskListLock:%p", m_sendTaskListLock);

	if (NULL == m_packetHandler) {
		m_packetHandler = ITransportPacketHandler::Create();
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_packetHandler:%p", m_packetHandler);

	if (NULL == m_sendThread) {
		m_sendThread = IThreadHandler::CreateThreadHandler();
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_sendThread:%p", m_sendThread);

	if (NULL == m_loopThread) {
		m_loopThread = IThreadHandler::CreateThreadHandler();
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_loopThread:%p", m_loopThread);

	if (NULL == m_startLock) {
		m_startLock = IAutoLock::CreateAutoLock();
		if (NULL != m_startLock) {
			m_startLock->Init();
		}
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_startLock:%p", m_startLock);

    m_client = ITransportClient::Create();
    if (NULL != m_client) {
        m_client->Init(this);
    }
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() create m_client:%p", m_client);

	result = (NULL != m_sendTaskListLock
				&& NULL != m_packetHandler
				&& NULL != m_sendThread
				&& NULL != m_loopThread
				&& NULL != m_startLock
				&& NULL != m_client);

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Init() result:%d", result);

	if (!result) {
		Uninit();
	}

	return result;
}

// 反初始化
void CTransportDataHandler::Uninit()
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Uninit()");

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
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Start() urls.size:%d, this:%p", urls.size(), this);

	m_startLock->Lock();

	// 若已经启动则停止
	if (IsStart()) {
		StopProc();
	}

	// 赋值
	m_urls = urls;
	// 启动发送及连接线程
    if (NULL != m_loopThread) {
        // 先置为true，防止线程启动后 m_loopThread->Start() 才返回，导致线程处理函数(LoopThread)执行过程中 m_bStart=false 出错
        m_bStart = true;
        
        // 启动线程
		m_bStart = m_loopThread->Start(LoopThread, this);
        FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Start() m_bStart:%d, m_loopThread:%p, this:%p", m_bStart, m_loopThread, this);
	}

	// 启动失败
	if (!m_bStart) {
		StopProc();
	}

	m_startLock->Unlock();

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Start() m_bStart:%d", m_bStart);

	return m_bStart;
}

// 停止连接
bool CTransportDataHandler::Stop()
{
	bool result = false;

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Stop() begin");
//    m_startLock->Lock();
	DisconnectProc();
	result = true;
//    m_startLock->Unlock();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::Stop() end");

	return result;
}

// 停止连接（等待）
bool CTransportDataHandler::StopAndWait()
{
	bool result = false;

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopAndWait() begin");
	m_startLock->Lock();
	result = StopProc();
	m_startLock->Unlock();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopAndWait() end");

	return result;	
}

// 停止连接处理函数
bool CTransportDataHandler::StopProc()
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopProc() begin");
	long long startTime = getCurrentTime();

	// 断开连接
	DisconnectProc();

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopProc() m_loopThread->WaitAndStop() begin");
	// 停接收线程
	if (NULL != m_loopThread) {
		m_loopThread->WaitAndStop();
	}
    
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopProc() m_client->Disconnect() begin");

	m_urls.clear();

    m_client->Disconnect();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopProc() m_client->Disconnect() end");
	
	long long endTime = getCurrentTime();
	long long diffTime = DiffTime(startTime, endTime);

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::StopProc() end, m_bStart:%d, diffTime:%ld", m_bStart, diffTime);

	return true;
}

// 是否开始
bool CTransportDataHandler::IsStart()
{
	FileLog("ImClient", "CTransportDataHandler::IsStart() m_bStart:%d", m_bStart);
	return m_bStart;
}

// 发送task数据（把task放到发送列队）
bool CTransportDataHandler::SendTaskData(ITask* task)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendTaskData() task:%p", task);
	bool result = false;
	if (m_bStart) {
		m_sendTaskListLock->Lock();
		m_sendTaskList.push_back(task);
		m_sendTaskListLock->Unlock();
		result = true;
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendTaskData() end, task:%p", task);
	return result;
}

// 发送线程
TH_RETURN_PARAM CTransportDataHandler::SendThread(void* arg)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendThread() arg:%p", arg);
	CTransportDataHandler* pThis = (CTransportDataHandler*) arg;
	pThis->SendThreadProc();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendThread() end, arg:%p", arg);
	return NULL;
}

void CTransportDataHandler::SendThreadProc(void)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendThreadProc() begin, m_bStart:%d", m_bStart);
	// 连接
	if (m_bStart) {
		FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendThreadProc() SendProc()");
		// 处理task发送队列
		SendProc();
	}
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendThreadProc() end");
}

// 接收线程
TH_RETURN_PARAM CTransportDataHandler::LoopThread(void* arg)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThread() arg:%p", arg);
	CTransportDataHandler* pThis = (CTransportDataHandler*) arg;
	pThis->LoopThreadProc();
    
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThread() end");
	return NULL;
}

void CTransportDataHandler::LoopThreadProc(void)
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThreadProc() start");
    if (ConnectProc()) {
        // 启动发送线程
        if (NULL != m_sendThread) {
            m_sendThread->Start(SendThread, this);
        }
        
        m_client->Loop();
        
        FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThreadProc() loop");
        
        // 停止发送线程
        if (NULL != m_sendThread) {
            m_sendThread->WaitAndStop();
        }
        
        FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThreadProc() m_sendThread->WaitAndStop()");
        
        // 设置接收线程的标志位为false
        m_loopThread->SetStartSign();
    } else {
        FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThreadProc() ConnectProc err");
        // 连接失败处理,返回
        if (NULL != m_listener) {
            m_listener->OnConnect(false);
        }
    }
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::LoopThreadProc() end");
}


bool CTransportDataHandler::ConnectProc()
{
	bool result = false;
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::ConnectProc() start, this:%p", this);
	FileLog("ImClient", "CTransportDataHandler::ConnectProc() m_urls:%d", m_urls.size());
	FileLog("ImClient", "CTransportDataHandler::ConnectProc() m_bStart:%d", m_bStart);

	for (list<string>::iterator iter = m_urls.begin();
		iter != m_urls.end() && m_bStart;
		iter++)
	{
		FileLog("ImClient", "CTransportDataHandler::ConnectProc() url:%s start", (*iter).c_str());
        // 暂时只连接第一个url
        if (m_client->Connect((*iter).c_str())) {
            result = true;
            break;
        }
	}

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::ConnectProc() end, result:%d", result);
	return result;
}

void CTransportDataHandler::SendProc()
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendProc()");

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

            // Add by Max 20171201
            FileLevelLog("ImClient",
                         KLog::LOG_WARNING,
                         "CTaskManager::SendProc( "
                         "len : %d, "
                         "data : %s "
                         ")",
                         dataLen,
                         buffer
                         );
            
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
    
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::SendProc() end");
}

void CTransportDataHandler::DisconnectProc()
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::DisconnectProc()");

    m_bStart = false;
    if (NULL != m_client) {
        m_client->Disconnect();
    }

	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::DisconnectProc() end");
}

void CTransportDataHandler::DisconnectCallback()
{
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::DisconnectCallback()");
	m_listener->OnDisconnect();
    // 当连接中，需要断网（wensoeckt连接超时，或手动logout），停止发送线程标志
    m_bStart = false;
	
	m_sendTaskListLock->Lock();
	if (NULL != m_listener) {
		m_listener->OnDisconnect(m_sendTaskList);
	}
	m_sendTaskList.clear();
	m_sendTaskListLock->Unlock();
	FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::DisconnectCallback() end");
}

// ------ ITransportClientCallback
void CTransportDataHandler::OnConnect(bool success)
{
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::OnConnect(success:%d)", success);
    if (NULL != m_listener) {
        m_listener->OnConnect(success);
    }
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::OnConnect(success:%d) end", success);
}

void CTransportDataHandler::OnRecvData(const unsigned char* data, size_t dataLen)
{
    // Add by Max 20171201
    unsigned char* buffer = new unsigned char[dataLen + 1];
    memcpy(buffer, data, dataLen);
    buffer[dataLen] = '\0';
    FileLevelLog("ImClient",
                KLog::LOG_WARNING,
                "CTaskManager::OnRecvData( "
                "len : %d, "
                "data : %s "
                ")",
                dataLen,
                buffer
                );
    
    // 虽然报警告，但是没有加这些，Unpacket的数据有时被改变，暂时不知道原因
    size_t strLen = dataLen;
    if (NULL != m_listener) {
        if (NULL != m_packetHandler) {
            TransportProtocol tp;
            m_packetHandler->Unpacket(data, dataLen, tp);
            m_listener->OnRecv(tp);
        }
    }
    
    // Add by Max 20171201
    delete[] buffer;
}

void CTransportDataHandler::OnDisconnect()
{
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::OnDisconnect()");
    DisconnectCallback();
    FileLevelLog("ImClient", KLog::LOG_WARNING, "CTransportDataHandler::OnDisconnect() end");
}

