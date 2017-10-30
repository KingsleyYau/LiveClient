/*
 * author: Alex
 *   date: 2017-06-12
 *   file: KickOffTask.cpp
 *   desc: 2.4.用户被挤掉线TaskTask实现类
 */

#include "KickOffTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>



KickOffTask::KickOffTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

KickOffTask::~KickOffTask(void)
{
}

// 初始化
bool KickOffTask::Init(IImClientListener* listener)
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
bool KickOffTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "KickOffTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "KickOffTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnKickOff(m_errType, m_errMsg);
		FileLog("ImClient", "KickOffTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "KickOffTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool KickOffTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "AudienceRoomInTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;

        data = value;
    }

    result = true;

	FileLog("ImClient", "AudienceRoomInTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string KickOffTask::GetCmdCode() const
{
	return CMD_KICKOFF;
}

// 设置seq
void KickOffTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T KickOffTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool KickOffTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void KickOffTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool KickOffTask::InitParam()
{
	bool result = false;

    result = true;
        
	return result;
}

// 未完成任务的断线通知
void KickOffTask::OnDisconnect()
{
}
