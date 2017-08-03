/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TaskManager.cpp
 *   desc: Task（任务）管理器实现类
 *			1. 把主动请求的 task 插到传输管理器(ITransportDataHandler)发给服务器
 *			2. 收到服务器数据包时，若为主动请求命令，则找到对应 task(seq) 处理，否则 new 服务器请求 task 处理
 *			3. delete 已经处理完成的 task
 */

#include "TaskManager.h"
#include "ITransportDataHandler.h"
#include "TaskDef.h"
#include <common/KLog.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

#ifndef _WIN32
#include <unistd.h>
#endif

CTaskManager::CTaskManager(void)
{
	m_clientListener = NULL;
	m_mgrListener = NULL;
	m_dataHandler = NULL;
	m_bStart = false;
	m_bInit = false;
}

CTaskManager::~CTaskManager(void)
{
	FileLog("LiveChatClient", "CTaskManager::~CTaskManager() begin");
	Stop();
	FileLog("LiveChatClient", "CTaskManager::~CTaskManager() stop ok");
	ITransportDataHandler::Release(m_dataHandler);
	m_dataHandler = NULL;
	FileLog("LiveChatClient", "CTaskManager::~CTaskManager() end");
}

// 初始化接口
bool CTaskManager::Init(const list<string>& urls, IImClientListener* clientListener, ITaskManagerListener* mgrListener)
{
	FileLog("LiveChatClient", "CTaskManager::Init() urls.size:%d, clientListener:%p, mgrListener:%p"
            , urls.size(), clientListener, mgrListener);

	if (!m_bInit) {
		// 初始化 传输数据处理器
		if (NULL == m_dataHandler) {
			m_dataHandler = ITransportDataHandler::Create();
			m_bInit = m_dataHandler->Init(this);
		}
		FileLog("LiveChatClient", "CTaskManager::Init() create m_dataHandler:%p, m_bInit:%d", m_dataHandler, m_bInit);

		// 初始化 task map
		if (m_bInit) {
			m_bInit = m_requestTaskMap.Init();
		}
		FileLog("LiveChatClient", "CTaskManager::Init() m_requestTaskMap.Init() m_bInit:%d", m_bInit);

		// 赋值
		if (m_bInit) {
			m_clientListener = clientListener;
			m_mgrListener = mgrListener;
            m_urls = urls;
		}
	}

	FileLog("LiveChatClient", "CTaskManager::Init() end");

	return m_bInit;
}

// 开始
bool CTaskManager::Start()
{
	FileLog("LiveChatClient", "CTaskManager::Start()");
	if (m_bInit && !m_bStart) {
		m_bStart = m_dataHandler->Start(m_urls);
	}
	FileLog("LiveChatClient", "CTaskManager::Start() m_bStart:%d", m_bStart);
	return m_bStart;
}
	
// 停止（不等待）
bool CTaskManager::Stop()
{
	FileLog("LiveChatClient", "CTaskManager::Stop()");
	bool result = false;
	if (NULL != m_dataHandler) {
		result = m_dataHandler->Stop();
		m_bStart = !result;
	}
	FileLog("LiveChatClient", "CTaskManager::Stop() result:%d", result);
	return result;
}

// 停止（等待）
bool CTaskManager::StopAndWait()
{
	FileLog("LiveChatClient", "CTaskManager::StopAndWait()");
	bool result = false;
	if (NULL != m_dataHandler) {
		result = m_dataHandler->StopAndWait();
		m_bStart = !result;
	}
	FileLog("LiveChatClient", "CTaskManager::StopAndWait() result:%d", result);

	return result;	
}

// 是否已经开始
bool CTaskManager::IsStart()
{
	FileLog("LiveChatClient", "CTaskManager::IsStart() m_bStart:%d", m_bStart);
	return m_bStart;
}
	
// 处理请求的task
bool CTaskManager::HandleRequestTask(ITask* task)
{
	FileLog("LiveChatClient", "CTaskManager::HandleRequestTask() task:%p", task);

	bool result = false;
	if (m_bInit && NULL != task) {
		result = m_dataHandler->SendTaskData(task);
	}

	FileLog("LiveChatClient", "CTaskManager::HandleRequestTask() result:%d", result);

	return result;
}

// ------------- ILiveChatClientListener接口函数 -------------
// 连接callback
void CTaskManager::OnConnect(bool success)
{
	FileLog("LiveChatClient", "CTaskManager::OnConnect() success:%d", success);
	if (NULL != m_mgrListener) {
		m_mgrListener->OnConnect(success);
	}
	FileLog("LiveChatClient", "CTaskManager::OnConnect() end");
}
	
// 断开连接callback（连接不成功不会调用，断开后需要手动调用ITransportDataHandler::Stop才能停止）
void CTaskManager::OnDisconnect(const TaskList& listUnsentTask)
{
	FileLog("LiveChatClient", "CTaskManager::OnDisconnect() listUnsentTask.size:%d", listUnsentTask.size());
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
			ITask* task = *iter;
			delete task;
		}
	}
	FileLog("LiveChatClient", "CTaskManager::OnDisconnect() end");
}
	
// 发送callback
void CTaskManager::OnSend(bool success, ITask* task)
{
	FileLog("LiveChatClient", "CTaskManager::OnSend() success:%d, task:%p, cmd:%s, seq:%d"
			, success, task, task->GetCmdCode().c_str(), task->GetSeq());
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
	FileLog("LiveChatClient", "CTaskManager::OnSend() end");
	// 发送不成功，网络应已断开，程序会调用 OnDisconnect()，不用在此处理
}
	
// 收到数据callback
void CTaskManager::OnRecv(const TransportProtocol& tp)
{
	FileLevelLog(
                 "LiveChatClient",
                 KLog::LOG_WARNING,
                 "CTaskManager::OnRecv() cmd:%s, seq:%d, data.empty:%d",
                 tp.m_cmd.c_str(),
                 tp.m_reqId,
                 tp.m_data.empty()
                 );

	ITask* task = NULL;
	if (IsRequestCmd(tp.m_cmd)) {
        if (tp.m_isRespond) {
            int waitTime = 0;
            do {
                // 客户端请求服务器回复
                task = m_requestTaskMap.PopTaskWithSeq(tp.m_reqId);
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
            // 命令是客户端主动请求，但协议解析不是返回命令（没有res_data）
            Json::FastWriter writer;
            string data = writer.write(tp.m_data);
            FileLevelLog("LiveChatClient",
                         KLog::LOG_ERR_USER,
                         "CTaskManager::OnRecv() tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d, tp.errno:%d, tp.errmsg:%s, data:%s"
                         , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId, tp.m_errno, tp.m_errmsg.c_str(), data.c_str());
        }
	}
	else {
		// 服务器主动请求
		task = ITask::CreateTaskWithCmd(tp.m_cmd);
		if (NULL != task) {
			task->SetSeq(tp.m_reqId);
			task->Init(m_clientListener);
		}
	}

	FileLog("LiveChatClient", "CTaskManager::OnRecv() get task:%p, m_mgrListener:%p", task, m_mgrListener);
	if (NULL != task) {
		task->Handle(tp);

		if (NULL != m_mgrListener) {
			m_mgrListener->OnTaskDone(task);
		}
		// 释放task
		delete task;
	}

	FileLog("LiveChatClient", "CTaskManager::OnRecv() end, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d, tp.errno:%d, tp.errmsg:%s"
		, tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId, tp.m_errno, tp.m_errmsg.c_str());
}
