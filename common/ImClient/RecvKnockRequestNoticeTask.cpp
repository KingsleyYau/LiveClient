/*
 * author: Alex
 *   date: 2018-04-14
 *   file: RecvKnockRequestNoticeTask.cpp
 *   desc: 10.9.接收主播敲门通知Task实现类
 */

#include "RecvKnockRequestNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


RecvKnockRequestNoticeTask::RecvKnockRequestNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";


}

RecvKnockRequestNoticeTask::~RecvKnockRequestNoticeTask(void)
{
}

// 初始化
bool RecvKnockRequestNoticeTask::Init(IImClientListener* listener)
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
bool RecvKnockRequestNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvKnockRequestNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    IMKnockRequestItem item;
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        item.Parse(tp.m_data);
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvKnockRequestNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvKnockRequestNotice(item);
		FileLog("ImClient", "RecvKnockRequestNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvKnockRequestNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvKnockRequestNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvKnockRequestNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOT_ERRNO] = (int)m_errType;
        if (m_errType != LCC_ERR_SUCCESS) {
            value[ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvKnockRequestNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvKnockRequestNoticeTask::GetCmdCode() const
{
	return CMD_RECVKNOCKREQUESTNOTICE;
}

// 设置seq
void RecvKnockRequestNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvKnockRequestNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvKnockRequestNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvKnockRequestNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvKnockRequestNoticeTask::OnDisconnect()
{

}
