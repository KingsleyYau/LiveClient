/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTransportDataHandler.cpp
 *   desc: 传输数据处理实现类
 */

#include "LSLiveChatTransportDataHandler.h"
#include "LSLiveChatTransportPacketHandler.h"
#include "ILSLiveChatTask.h"
#include "ILSLiveChatSocketHandler.h"
#include <common/IAutoLock.h>
#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

const unsigned int bufferSize = 1024 * 100;

CLSLiveChatTransportDataHandler::CLSLiveChatTransportDataHandler(void)
{
	m_listener = NULL;
	m_packetHandler = NULL;

	m_sendThread = NULL;
	m_sendBuffer = NULL;
	m_sendBufferSize = 0;
	m_recvThread = NULL;
	m_recvBuffer = NULL;
	m_recvBufferSize = 0;

	m_startLock = NULL;
	m_bStart = false;
	m_svrPort = 0;
	m_socketHandler = NULL;
	m_socketLock = NULL;

	m_sendTaskListLock = NULL;
}

CLSLiveChatTransportDataHandler::~CLSLiveChatTransportDataHandler(void)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::~CLSLiveChatTransportDataHandler() begin, this:%p", this);
	Stop();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::~CLSLiveChatTransportDataHandler() Stop() ok, this:%p", this);
	Uninit();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::~CLSLiveChatTransportDataHandler() end, this:%p", this);
}

// 初始化
bool CLSLiveChatTransportDataHandler::Init(ILSLiveChatTransportDataHandlerListener* listener)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() listener:%p", listener);

	bool result = false;
	m_listener = listener;
	
	// 创建待发送队列锁
	if (NULL == m_sendTaskListLock) {
		m_sendTaskListLock = IAutoLock::CreateAutoLock();
		if (NULL != m_sendTaskListLock) {
			m_sendTaskListLock->Init();
		}
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_sendTaskListLock:%p", m_sendTaskListLock);

	// 创建发送缓冲
	if (NULL == m_sendBuffer) {
		m_sendBuffer = new unsigned char[bufferSize];
		m_sendBufferSize = bufferSize;
	}

	// 创建接收缓冲
	if (NULL == m_recvBuffer) {
		m_recvBuffer = new unsigned char[bufferSize];
		m_recvBufferSize = bufferSize;
	}

	if (NULL == m_packetHandler) {
		m_packetHandler = ILSLiveChatTransportPacketHandler::Create();
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_packetHandler:%p", m_packetHandler);

	if (NULL == m_sendThread) {
		m_sendThread = ILSLiveChatThreadHandler::CreateThreadHandler();
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_sendThread:%p", m_sendThread);

	if (NULL == m_recvThread) {
		m_recvThread = ILSLiveChatThreadHandler::CreateThreadHandler();
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_recvThread:%p", m_recvThread);

	if (NULL == m_startLock) {
		m_startLock = IAutoLock::CreateAutoLock();
		if (NULL != m_startLock) {
			m_startLock->Init();
		}
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_startLock:%p", m_startLock);

	if (NULL == m_socketLock) {
		m_socketLock = IAutoLock::CreateAutoLock();
		if (NULL != m_socketLock) {
			m_socketLock->Init();
		}
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() create m_socketLock:%p", m_socketLock);

	result = (NULL != m_sendTaskListLock
				&& NULL != m_sendBuffer
				&& NULL != m_recvBuffer
				&& NULL != m_packetHandler
				&& NULL != m_sendThread
				&& NULL != m_recvThread
				&& NULL != m_startLock
				&& NULL != m_socketLock);

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Init() result:%d", result);

	if (!result) {
		Uninit();
	}

	return result;
}

// 反初始化
void CLSLiveChatTransportDataHandler::Uninit()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Uninit()");

	delete m_sendTaskListLock;
	m_sendTaskListLock = NULL;

	delete m_sendThread;
	m_sendThread = NULL;

	delete m_recvThread;
	m_recvThread = NULL;

	ILSLiveChatTransportPacketHandler::Release(m_packetHandler);
	m_packetHandler = NULL;

	IAutoLock::ReleaseAutoLock(m_startLock);
	m_startLock = NULL;

	IAutoLock::ReleaseAutoLock(m_socketLock);
	m_socketLock = NULL;

	delete m_sendBuffer;
	m_sendBuffer = NULL;
	m_sendBufferSize = 0;

	delete m_recvBuffer;
	m_recvBuffer = NULL;
	m_recvBufferSize = 0;

	m_listener = NULL;
}

// 开始连接
bool CLSLiveChatTransportDataHandler::Start(const list<string>& ips, unsigned int port)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Start() ips.size:%d, port:%d, this:%p", ips.size(), port, this);

	m_startLock->Lock();

	// 若已经启动则停止
	if (IsStart()) {
		StopProc();
	}

	// 赋值
	m_svrIPs = ips;
	m_svrPort = port;
	// 启动发送及连接线程
	if (NULL != m_recvThread) {
		// 先置为true, 防止线程启动后 m_loopThread->Start()才返回，导致线程处理函数（RecvThread）执行过程中m_bStart=false 出错
		m_bStart = true;
		m_bStart = m_recvThread->Start(RecvThread, this);
	}

	// 启动失败
	if (!m_bStart) {
		StopProc();
	}

	m_startLock->Unlock();

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Start() m_bStart:%d", m_bStart);

	return m_bStart;
}

// 停止连接
bool CLSLiveChatTransportDataHandler::Stop()
{
	bool result = false;

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Stop() begin");
	m_startLock->Lock();
	result = StopProc();
	m_startLock->Unlock();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::Stop() end");

	return result;
}

// 停止连接处理函数
bool CLSLiveChatTransportDataHandler::StopProc()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::StopProc() begin");
	long long startTime = getCurrentTime();

	// 断开连接
	DisconnectProc();

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::StopProc() m_recvThread->WaitAndStop()");
	// 停接收线程
	if (NULL != m_recvThread) {
		m_recvThread->WaitAndStop();
	}

	m_svrIPs.clear();
	m_svrPort = 0;

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::StopProc() ReleaseSocketHandler(m_socketHandler)");
	// 释放socket
	m_socketLock->Lock();
	if (NULL != m_socketHandler) {
		ILSLiveChatSocketHandler::ReleaseSocketHandler(m_socketHandler);
		m_socketHandler = NULL;
	}
	m_socketLock->Unlock();

	long long endTime = getCurrentTime();
	long long diffTime = DiffTime(startTime, endTime);

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::StopProc() end, m_bStart:%d, diffTime:%ld", m_bStart, diffTime);

	return true;
}

// 是否开始
bool CLSLiveChatTransportDataHandler::IsStart()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::IsStart() m_bStart:%d", m_bStart);
	return m_bStart;
}

// 发送task数据（把task放到发送列队）
bool CLSLiveChatTransportDataHandler::SendTaskData(ILSLiveChatTask* task)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendTaskData() task:%p", task);
	bool result = false;
	if (m_bStart) {
		m_sendTaskListLock->Lock();
		m_sendTaskList.push_back(task);
		m_sendTaskListLock->Unlock();
		result = true;
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendTaskData() end, task:%p", task);
	return result;
}

int CLSLiveChatTransportDataHandler::GetSocket() {
    return m_socketHandler->GetSocket();
}

// 发送线程
TH_RETURN_PARAM CLSLiveChatTransportDataHandler::SendThread(void* arg)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendThread() arg:%p", arg);
	CLSLiveChatTransportDataHandler* pThis = (CLSLiveChatTransportDataHandler*) arg;
	pThis->SendThreadProc();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendThread() end, arg:%p", arg);
	return NULL;
}

void CLSLiveChatTransportDataHandler::SendThreadProc(void)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendThreadProc() begin, m_bStart:%d", m_bStart);
	// 连接
	if (m_bStart) {
		FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendThreadProc() SendProc()");
		// 处理task发送队列
		SendProc();
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendThreadProc() end");
}

// 接收线程
TH_RETURN_PARAM CLSLiveChatTransportDataHandler::RecvThread(void* arg)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvThread() arg:%p", arg);
	CLSLiveChatTransportDataHandler* pThis = (CLSLiveChatTransportDataHandler*) arg;
	pThis->RecvThreadProc();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvThread() end");
	return NULL;
}

void CLSLiveChatTransportDataHandler::RecvThreadProc(void)
{
	// 连接服务器
	bool bConnect = ConnectProc();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvThreadProc() ConnectProc(), m_listener:%p, bConnect:%d", m_listener, bConnect);
	m_listener->OnConnect(bConnect);
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvThreadProc() m_listener->OnConnect(bConnect) ok");

	if (bConnect && m_bStart) {
		// 启动发送线程
		if (NULL != m_sendThread) {
			m_sendThread->Start(SendThread, this);
		}

		// 接收处理
		RecvProc();

		// 断开连接
		DisconnectProc();

		// 等待发送线程停止
		if (NULL != m_sendThread) {
			m_sendThread->WaitAndStop();
		}

		// 断开回调
		DisconnectCallback();
	}
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvThreadProc() end");
}

void CLSLiveChatTransportDataHandler::RecvProc(void)
{
	// 接收处理
	unsigned int bufferLength = 0;
	unsigned int bufferOffset = 0;
	ILSLiveChatSocketHandler::HANDLE_RESULT result = ILSLiveChatSocketHandler::HANDLE_FAIL;
	UNPACKET_RESULT_TYPE unpackResult = UNPACKET_SUCCESS;

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc()");

	memset(m_recvBuffer, 0, m_recvBufferSize);
	while (unpackResult != UNPACKET_ERROR)
	{
		do {
			result = m_socketHandler->Recv(m_recvBuffer + bufferOffset, m_recvBufferSize - bufferOffset, bufferLength);
//			if (ILSLiveChatSocketHandler::HANDLE_TIMEOUT == result) {
//				FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() handle timeout");
//			}
//			else if (ILSLiveChatSocketHandler::HANDLE_FAIL == result) {
//				FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() handle fail");
//			}
		} while (ILSLiveChatSocketHandler::HANDLE_TIMEOUT == result);

		if (ILSLiveChatSocketHandler::HANDLE_SUCCESS == result)
		{
			// 本次收到的数据长度 + 之前未解包的数据长度
			bufferLength += bufferOffset;

			FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() bufferOffset:%d, bufferLength:%d, recvLength:%d", bufferOffset, bufferLength, bufferLength-bufferOffset);

			// 开始解包
			do {
				LSLiveChatTransportProtocol* tp = NULL;
				unsigned int useLen = 0;

				unpackResult = m_packetHandler->Unpacket(m_recvBuffer, bufferLength, m_recvBufferSize, &tp, useLen);
				if (unpackResult == UNPACKET_SUCCESS) {
					m_listener->OnRecv(tp);
				}

				if (unpackResult != UNPACKET_MOREDATA
					&& unpackResult != UNPACKET_ERROR
					&& useLen > 0)
				{
					// 移除已解包的数据
					RemoveData(m_recvBuffer, bufferLength, useLen);
					bufferLength -= useLen;
				}

				// 严重错误，需要重新连接
				if (unpackResult == UNPACKET_ERROR)
				{
					DisconnectProc();
					break;
				}

				FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() unpack:%d, bufferLength:%d", unpackResult, bufferLength);
			} while (unpackResult != UNPACKET_MOREDATA);
			// 记录未解包的数据长度
			bufferOffset = bufferLength;

			FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() Process OK, bufferOffset:%d", bufferOffset);
		}
		else
		{
			break;
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RecvProc() end");
}

bool CLSLiveChatTransportDataHandler::ConnectProc()
{
	bool result = false;
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() start, this:%p", this);
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() m_svrIPs.size:%d", m_svrIPs.size());
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() m_bStart:%d", m_bStart);

	list<string>::const_iterator iter;
	for (iter = m_svrIPs.begin();
		iter != m_svrIPs.end() && m_bStart;
		iter++)
	{
		FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() ip:%s start", (*iter).c_str());
		m_socketLock->Lock();
		m_socketHandler = ILSLiveChatSocketHandler::CreateSocketHandler(ILSLiveChatSocketHandler::TCP_SOCKET);
		m_socketLock->Unlock();
		if (NULL != m_socketHandler){
#ifdef IOS
            result = m_socketHandler->Create(true);
#else
            result = m_socketHandler->Create(false);
#endif
			result = result && m_socketHandler->Connect((*iter), m_svrPort, 0) == SOCKET_RESULT_SUCCESS;
		}
		FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() ip:%s end", (*iter).c_str());

		if (result) {
			m_socketHandler->SetBlock(true);
			break;
		}
		else {
			FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() ReleaseSocketHandler start");
			m_socketLock->Lock();
			ILSLiveChatSocketHandler::ReleaseSocketHandler(m_socketHandler);
			m_socketHandler = NULL;
			m_socketLock->Unlock();
			FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() ReleaseSocketHandler end");
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::ConnectProc() end, result:%d", result);
	return result;
}

void CLSLiveChatTransportDataHandler::SendProc()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendProc()");

	while (m_bStart) {
		ILSLiveChatTask* task = NULL;
		m_sendTaskListLock->Lock();
		if (!m_sendTaskList.empty()) {
			task = m_sendTaskList.front();
			m_sendTaskList.pop_front();
		}
		m_sendTaskListLock->Unlock();

		if (NULL != task) {
			if (NULL != m_packetHandler) {
				// 获取task发送的data
				unsigned int dataLen = 0;
				if (m_packetHandler->Packet(task, m_sendBuffer, m_sendBufferSize, dataLen)) {
					ILSLiveChatSocketHandler::HANDLE_RESULT result = ILSLiveChatSocketHandler::HANDLE_FAIL;
					do {
						result = m_socketHandler->Send(m_sendBuffer, dataLen);
//						if (ILSLiveChatSocketHandler::HANDLE_TIMEOUT == result) {
//							FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendProc() handle timeout");
//						}
//						else if (ILSLiveChatSocketHandler::HANDLE_FAIL == result) {
//							FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendProc() handle fail");
//						}
					} while (ILSLiveChatSocketHandler::HANDLE_TIMEOUT == result);
					m_listener->OnSend(ILSLiveChatSocketHandler::HANDLE_SUCCESS == result, task);

					// 发送不成功，断开连接
					if (result == ILSLiveChatSocketHandler::HANDLE_FAIL) {
						FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendProc() send fail, disconnect now!");
						DisconnectProc();
					}
				}
				else {
					// 组包不成功

				}
			}
		}
		else {
			Sleep(100);
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::SendProc() end");
}

void CLSLiveChatTransportDataHandler::DisconnectProc()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::DisconnectProc()");

	m_bStart = false;

	m_socketLock->Lock();
	if (NULL != m_socketHandler) {
        if (ILSLiveChatSocketHandler::CONNECTION_STATUS_CONNECTING == m_socketHandler->GetConnectionStatus()) {
            m_socketHandler->Close();
        }
        else {
            m_socketHandler->Shutdown();
        }
	}
	m_socketLock->Unlock();

	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::DisconnectProc() end");
}

void CLSLiveChatTransportDataHandler::DisconnectCallback()
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::DisconnectCallback()");
	m_listener->OnDisconnect();

	m_sendTaskListLock->Lock();
	m_listener->OnDisconnect(m_sendTaskList);
	m_sendTaskList.clear();
	m_sendTaskListLock->Unlock();
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::DisconnectCallback() end");
}

// 删除pBuffer头nRemoveLength个字节
void CLSLiveChatTransportDataHandler::RemoveData(unsigned char* pBuffer, int nBufferLength, int nRemoveLength)
{
	FileLog("LiveChatClient", "CLSLiveChatTransportDataHandler::RemoveData() pBuffer:%p nBufferLength:%d, nRemoveLength:%d", pBuffer, nBufferLength, nRemoveLength);
	unsigned char* pSrc = pBuffer + nRemoveLength;
	unsigned char* pDes = pBuffer;
	int i = 0;
	for (i = 0; i < nBufferLength - nRemoveLength; i++) {
		pDes[i] = pSrc[i];
	}
}
