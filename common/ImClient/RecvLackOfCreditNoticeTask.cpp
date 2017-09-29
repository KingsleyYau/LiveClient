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
#define MSG_PARAM              "msg"
#define CREDIT_PARAM           "credit"



RecvLackOfCreditNoticeTask::RecvLackOfCreditNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_msg = "";
    m_credit = 0.0;

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

	FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[MSG_PARAM].isString()) {
            m_msg = tp.m_data[MSG_PARAM].asString();
        }
        if (tp.m_data[CREDIT_PARAM].isNumeric()) {
            m_credit = tp.m_data[CREDIT_PARAM].asDouble();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLackOfCreditNotice(m_roomId, m_msg, m_credit);
		FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLackOfCreditNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("LiveChatClient", "RecvLackOfCreditNoticeTask::GetSendData() end, result:%d", result);

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
