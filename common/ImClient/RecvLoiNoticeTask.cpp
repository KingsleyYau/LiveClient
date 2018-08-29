/*
 * author: Alex
 *   date: 2018-07-09
 *   file: RecvLoiNoticeTask.cpp
 *   desc: 13.1.接收意向信通知 Task实现类
 */

#include "RecvLoiNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 返回
#define RECVLOINOTICE_ANCHORID_PARAM            "anchor_id"
#define RECVLOINOTICE_LOIID_PARAM               "loi_id"

RecvLoiNoticeTask::RecvLoiNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvLoiNoticeTask::~RecvLoiNoticeTask(void)
{
}

// 初始化
bool RecvLoiNoticeTask::Init(IImClientListener* listener)
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
bool RecvLoiNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvLoiNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);


    string anchorId;
    string loiId;
    
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[RECVLOINOTICE_ANCHORID_PARAM].isString()) {
                anchorId = tp.m_data[RECVLOINOTICE_ANCHORID_PARAM].asString();
            }
            if (tp.m_data[RECVLOINOTICE_LOIID_PARAM].isString()) {
                loiId = tp.m_data[RECVLOINOTICE_LOIID_PARAM].asString();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvLoiNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLoiNotice(anchorId, loiId);
		FileLog("ImClient", "RecvLoiNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvLoiNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLoiNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvLoiNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvLoiNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvLoiNoticeTask::GetCmdCode() const
{
	return CMD_SENDLOINOTICE;
}

// 设置seq
void RecvLoiNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvLoiNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvLoiNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvLoiNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvLoiNoticeTask::OnDisconnect()
{

}
