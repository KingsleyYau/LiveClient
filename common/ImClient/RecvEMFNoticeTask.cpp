/*
 * author: Alex
 *   date: 2018-07-09
 *   file: RecvEMFNoticeTask.cpp
 *   desc: 13.2.接收EMF通知 Task实现类
 */

#include "RecvEMFNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 返回
#define RECVEMFNOTICE_ANCHORID_PARAM            "anchor_id"
#define RECVEMFNOTICE_EMFID_PARAM               "emf_id"

RecvEMFNoticeTask::RecvEMFNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvEMFNoticeTask::~RecvEMFNoticeTask(void)
{
}

// 初始化
bool RecvEMFNoticeTask::Init(IImClientListener* listener)
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
bool RecvEMFNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvEMFNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);

    string anchorId;
    string emfId;
    
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[RECVEMFNOTICE_ANCHORID_PARAM].isString()) {
                anchorId = tp.m_data[RECVEMFNOTICE_ANCHORID_PARAM].asString();
            }
            if (tp.m_data[RECVEMFNOTICE_EMFID_PARAM].isString()) {
                emfId = tp.m_data[RECVEMFNOTICE_EMFID_PARAM].asString();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "v::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvEMFNotice(anchorId, emfId);
		FileLog("ImClient", "RecvEMFNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvEMFNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvEMFNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvEMFNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOT_ERRNO] = (int)m_errType;
        if (m_errType != LCC_ERR_SUCCESS) {
            value[ROOT_ERRMSG] = m_errMsg;
        }
        Json::Value valueDate;
        value[ROOT_DATA] = valueDate;
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvEMFNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvEMFNoticeTask::GetCmdCode() const
{
	return CMD_SENDEMFNOTICE;
}

// 设置seq
void RecvEMFNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvEMFNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvEMFNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvEMFNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvEMFNoticeTask::OnDisconnect()
{

}
