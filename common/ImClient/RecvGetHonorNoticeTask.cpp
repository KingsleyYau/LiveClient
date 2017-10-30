/*
 * author: Alex
 *   date: 2017-10-23
 *   file: RecvGetHonorNoticeTask.cpp
 *   desc: 9.4.观众勋章升级通知 Task实现类
 */

#include "RecvGetHonorNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define HONORID_PARAM                  "honor_id"
#define HONORURL_PARAM                 "honor_url"

RecvGetHonorNoticeTask::RecvGetHonorNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvGetHonorNoticeTask::~RecvGetHonorNoticeTask(void)
{
}

// 初始化
bool RecvGetHonorNoticeTask::Init(IImClientListener* listener)
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
bool RecvGetHonorNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvGetHonorNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    string honorId = "";
    string honorUrl = "";
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[HONORID_PARAM].isString()) {
            honorId = tp.m_data[HONORID_PARAM].asString();
        }
        if (tp.m_data[HONORURL_PARAM].isString()) {
            honorUrl = tp.m_data[HONORURL_PARAM].asString();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvGetHonorNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvGetHonorNotice(honorId, honorUrl);
		FileLog("ImClient", "RecvGetHonorNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvGetHonorNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvGetHonorNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvGetHonorNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("ImClient", "RecvGetHonorNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvGetHonorNoticeTask::GetCmdCode() const
{
	return CMD_RECVGETHONORNOTICE;
}

// 设置seq
void RecvGetHonorNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvGetHonorNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvGetHonorNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvGetHonorNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvGetHonorNoticeTask::OnDisconnect()
{

}
