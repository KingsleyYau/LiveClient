/*
 * author: Samson.Fan
 *   date: 2015-05-30
 *   file: HearbeatTask.cpp
 *   desc: 心跳Task实现类
 */

#include "HearbeatTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

HearbeatTask::HearbeatTask(void)
{
	m_listener = NULL;
	m_seq = 0;
}

HearbeatTask::~HearbeatTask(void)
{
}

// 初始化
bool HearbeatTask::Init(IImClientListener* listener)
{
	bool result = false;
	if (NULL != listener)
	{
		m_listener = listener;
		result = true;
	}
	return result;
}
	
// 处理已接收数据
bool HearbeatTask::Handle(const TransportProtocol& tp)
{
	bool result = false;
    
    if (0 == tp.m_errno) {
        result = true;
    }
    
	// 没有接收数据
	return result;
}
	
// 获取待发送的json数据
bool HearbeatTask::GetSendData(Json::Value& data)
{
	return true;
}
	
// 获取命令号
string HearbeatTask::GetCmdCode() const
{
	return CMD_HEARTBEAT;
}

// 设置seq
void HearbeatTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T HearbeatTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool HearbeatTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void HearbeatTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	// 不用处理
}

// 未完成任务的断线通知
void HearbeatTask::OnDisconnect()
{
	// 不用回调
}

