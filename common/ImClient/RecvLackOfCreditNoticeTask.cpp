/*
 * author: Alex
 *   date: 2017-08-15
 *   file: RecvLackOfCreditNoticeTask.cpp
 *   desc: 3.9.接收充值通知 Task实现类
 */

#include "RecvLackOfCreditNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define ERRMSG_PARAM           "errmsg"
#define LEFTCREDIT_PARAM       "left_credit"
#define ERRNO_PARAM            "errno"


RecvLackOfCreditNoticeTask::RecvLackOfCreditNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_msg = "";
    m_credit = 0.0;
    m_errReason = LCC_ERR_FAIL;

}

RecvLackOfCreditNoticeTask::~RecvLackOfCreditNoticeTask(void)
{
}

// 初始化
bool RecvLackOfCreditNoticeTask::Init(IImClientListener* listener)
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
bool RecvLackOfCreditNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvLackOfCreditNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[ERRMSG_PARAM].isString()) {
            m_msg = tp.m_data[ERRMSG_PARAM].asString();
        }
        if (tp.m_data[LEFTCREDIT_PARAM].isNumeric()) {
            m_credit = tp.m_data[LEFTCREDIT_PARAM].asDouble();
        }
        if (tp.m_data[ERRNO_PARAM].isNumeric()) {
            m_errReason = (LCC_ERR_TYPE)tp.m_data[ERRNO_PARAM].asInt();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvLackOfCreditNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLackOfCreditNotice(m_roomId, m_msg, m_credit, m_errReason);
		FileLog("ImClient", "RecvLackOfCreditNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvLackOfCreditNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLackOfCreditNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvLackOfCreditNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvLackOfCreditNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvLackOfCreditNoticeTask::GetCmdCode() const
{
	return CMD_RECVLACKOFCREDITNOTICE;
}

// 设置seq
void RecvLackOfCreditNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvLackOfCreditNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvLackOfCreditNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvLackOfCreditNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvLackOfCreditNoticeTask::OnDisconnect()
{

}
