/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTaskManager.cpp
 *   desc: Task（任务）管理器实现类
 *			1. 把主动请求的 task 插到传输管理器(ITransportDataHandler)发给服务器
 *			2. 收到服务器数据包时，若为主动请求命令，则找到对应 task(seq) 处理，否则 new 服务器请求 task 处理
 *			3. delete 已经处理完成的 task
 */

#include "LSLiveChatTaskManager.h"
#include "ILSLiveChatTransportDataHandler.h"
#include "LSLiveChatTaskDef.h"
#include <common/KLog.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

#ifndef _WIN32
#include <unistd.h>
#endif

CLSLiveChatTaskManager::CLSLiveChatTaskManager(void)
{
	m_clientListener = NULL;
	m_mgrListener = NULL;
	m_dataHandler = NULL;
	m_bStart = false;
	m_bInit = false;
}

CLSLiveChatTaskManager::~CLSLiveChatTaskManager(void)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::~CLSLiveChatTaskManager() begin");
	Stop();
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::~CLSLiveChatTaskManager() stop ok");
	ILSLiveChatTransportDataHandler::Release(m_dataHandler);
	m_dataHandler = NULL;
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::~CLSLiveChatTaskManager() end");
}

// 初始化接口
bool CLSLiveChatTaskManager::Init(const list<string>& svrIPs, unsigned int svrPort, ILSLiveChatClientListener* clientListener, ILSLiveChatTaskManagerListener* mgrListener)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Init() svrIPs.size:%d, svrPort:%d, clientListener:%p, mgrListener:%p", svrIPs.size(), svrPort, clientListener, mgrListener);

	if (!m_bInit) {
		// 初始化 传输数据处理器
		if (NULL == m_dataHandler) {
			m_dataHandler = ILSLiveChatTransportDataHandler::Create();
			m_bInit = m_dataHandler->Init(this);
		}
		FileLog("LiveChatClient", "CLSLiveChatTaskManager::Init() create m_dataHandler:%p, m_bInit:%d", m_dataHandler, m_bInit);

		// 初始化 task map
		if (m_bInit) {
			m_bInit = m_requestTaskMap.Init();
		}
		FileLog("LiveChatClient", "CLSLiveChatTaskManager::Init() m_requestTaskMap.Init() m_bInit:%d", m_bInit);

		// 赋值
		if (m_bInit) {
			m_clientListener = clientListener;
			m_mgrListener = mgrListener;
			m_svrIPs = svrIPs;
			m_svrPort = svrPort;
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Init() end");

	return m_bInit;
}

// 开始
bool CLSLiveChatTaskManager::Start()
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Start()");
	if (m_bInit && !m_bStart) {
		m_bStart = m_dataHandler->Start(m_svrIPs, m_svrPort);
	}
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Start() m_bStart:%d", m_bStart);
	return m_bStart;
}
	
// 停止
bool CLSLiveChatTaskManager::Stop()
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Stop()");
	bool result = false;
	if (NULL != m_dataHandler) {
		result = m_dataHandler->Stop();
		m_bStart = !result;
	}
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::Stop() result:%d", result);
	return result;
}

// 是否已经开始
bool CLSLiveChatTaskManager::IsStart()
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::IsStart() m_bStart:%d", m_bStart);
	return m_bStart;
}
	
// 处理请求的task
bool CLSLiveChatTaskManager::HandleRequestTask(ILSLiveChatTask* task)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::HandleRequestTask() task:%p", task);

	bool result = false;
	if (m_bInit && NULL != task) {
		result = m_dataHandler->SendTaskData(task);
	}

	FileLog("LiveChatClient", "CLSLiveChatTaskManager::HandleRequestTask() result:%d", result);

	return result;
}

int CLSLiveChatTaskManager::GetSocket() {
    return m_dataHandler->GetSocket();
}
// ------------- ILSLiveChatClientListener接口函数 -------------
// 连接callback
void CLSLiveChatTaskManager::OnConnect(bool success)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnConnect() success:%d", success);
	if (NULL != m_mgrListener) {
		m_mgrListener->OnConnect(success);
	}
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnConnect() end");
}

// 断开连接callback（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
void CLSLiveChatTaskManager::OnDisconnect()
{
	m_mgrListener->OnDisconnect();
}
	
// 断开连接callback（连接不成功不会调用，断开后需要手动调用ILiveChatTransportDataHandler::Stop才能停止）
void CLSLiveChatTaskManager::OnDisconnect(const TaskList& listUnsentTask)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnDisconnect() listUnsentTask.size:%d", listUnsentTask.size());
	if (NULL != m_mgrListener) {
		// 回调 发送不成功 或 发送成功但没有回应 的task
		m_requestTaskMap.InsertTaskList(listUnsentTask);

		TaskList list;
		m_requestTaskMap.Clear(list);
		m_mgrListener->OnDisconnect(list);

		// 释放task
		TaskList::iterator iter;
		for (iter = list.begin();
			iter != list.end();
			iter++)
		{
			ILSLiveChatTask* task = *iter;
			delete task;
		}
	}
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnDisconnect() end");
}
	
// 发送callback
void CLSLiveChatTaskManager::OnSend(bool success, ILSLiveChatTask* task)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnSend() success:%d, task:%p, cmd:%d, seq:%d"
			, success, task, task->GetCmdCode(), task->GetSeq());
	if (success)
	{
        // 回调已经发送出任务，只有当命令没有返回参数，才需要处理这个回调
        task->OnSend();
        
		// 发送成功而且需要回复，则插入map
		if (task->IsWaitToRespond()) {
			m_requestTaskMap.Insert(task);
		}
		else {
			delete task;
		}
        
    } else {
        // 发送失败，放回待处理队列，等待断开处理
        m_requestTaskMap.Insert(task);
    }
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnSend() end");
	// 发送不成功，网络应已断开，程序会调用 OnDisconnect()，不用在此处理
}
	
// 收到数据callback
void CLSLiveChatTaskManager::OnRecv(const LSLiveChatTransportProtocol* tp)
{
	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnRecv() tp:%p", tp);
    FileLevelLog("LiveChatClient", KLog::LOG_WARNING, "CLSLiveChatTaskManager::OnRecv() cmd:%d, seq:%d, lenght:%d, tp.dataLen:%d"
			, tp->header.cmd, tp->header.seq, tp->header.length, tp->GetDataLength());

	ILSLiveChatTask* task = NULL;
	if (IsRequestCmd(tp->header.cmd)) {
		int waitTime = 0;
		do {
			// 客户端请求服务器回复
			task = m_requestTaskMap.PopTaskWithSeq(tp->header.seq);
			if (NULL != task || waitTime > 2) {
				break;
			}
			else {
				// 没有找到该任务，等待任务添加到队列
				waitTime++;
				usleep(100);
			}
		} while (true);
	}
	else {
		// 服务器主动请求
		task = ILSLiveChatTask::CreateTaskWithCmd(tp->header.cmd);
		if (NULL != task) {
			task->SetSeq(tp->header.seq);
			task->Init(m_clientListener);
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnRecv() get task:%p, m_mgrListener:%p", task, m_mgrListener);
	if (NULL != task) {
		task->Handle(tp);

		if (NULL != m_mgrListener) {
			m_mgrListener->OnTaskDone(task);
		}
		// 释放task
		delete task;
	}

	FileLog("LiveChatClient", "CLSLiveChatTaskManager::OnRecv() end, tp:%p, tp.header.cmd:%d, tp.header.lenght:%d, tp.dataLen:%d", tp, tp->header.cmd, tp->header.length, tp->GetDataLength());
}
