/*
 * author: alex
 *   date: 2018-03-3
 *   file: ZBHearbeatTask.cpp
 *   desc: 心跳Task实现类
 */

#include "ZBHearbeatTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

ZBHearbeatTask::ZBHearbeatTask(void)
{
	m_listener = NULL;
	m_seq = 0;
}

ZBHearbeatTask::~ZBHearbeatTask(void)
{
}

// 初始化
bool ZBHearbeatTask::Init(IZBImClientListener* listener)
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
bool ZBHearbeatTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;
    
    if (0 == tp.m_errno) {
        result = true;
    }
    
	// 没有接收数据
	return result;
}
	
// 获取待发送的json数据
bool ZBHearbeatTask::GetSendData(Json::Value& data)
{
	return true;
}
	
// 获取命令号
string ZBHearbeatTask::GetCmdCode() const
{
	return ZB_CMD_HEARTBEAT;
}

// 设置seq
void ZBHearbeatTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBHearbeatTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBHearbeatTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBHearbeatTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	// 不用处理
}

// 未完成任务的断线通知
void ZBHearbeatTask::OnDisconnect()
{
	// 不用回调
}

