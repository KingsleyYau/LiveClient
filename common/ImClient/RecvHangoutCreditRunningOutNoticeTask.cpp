/*
 * author: Alex
 *   date: 2019-03-06
 *   file: RecvHangoutCreditRunningOutNoticeTask.cpp
 *   desc: 10.16.接收Hangout直播间男士信用点不足两个周期通知Task实现类
 */

#include "RecvHangoutCreditRunningOutNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

#define HANGOUTCREDITRUNNINGOUT_ROOMID_PARAM            "roomid"
#define HANGOUTCREDITRUNNINGOUT_ERRNO_PARAM             "errno"
#define HANGOUTCREDITRUNNINGOUT_ERRMSG_PARAM            "errmsg"

RecvHangoutCreditRunningOutNoticeTask::RecvHangoutCreditRunningOutNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
}

RecvHangoutCreditRunningOutNoticeTask::~RecvHangoutCreditRunningOutNoticeTask(void)
{
}

// 初始化
bool RecvHangoutCreditRunningOutNoticeTask::Init(IImClientListener* listener)
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
bool RecvHangoutCreditRunningOutNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    LCC_ERR_TYPE errNo = LCC_ERR_FAIL;
    string errMsg = "";
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[HANGOUTCREDITRUNNINGOUT_ROOMID_PARAM].isString()) {
                roomId = tp.m_data[HANGOUTCREDITRUNNINGOUT_ROOMID_PARAM].asString();
            }
            if (tp.m_data[HANGOUTCREDITRUNNINGOUT_ERRNO_PARAM].isInt()) {
                errNo = (LCC_ERR_TYPE)tp.m_data[HANGOUTCREDITRUNNINGOUT_ERRNO_PARAM].asInt();
            }
            if (tp.m_data[HANGOUTCREDITRUNNINGOUT_ERRMSG_PARAM].isString()) {
                errMsg = tp.m_data[HANGOUTCREDITRUNNINGOUT_ERRMSG_PARAM].asString();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvHangoutCreditRunningOutNotice(roomId, errNo, errMsg);
		FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvHangoutCreditRunningOutNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvHangoutCreditRunningOutNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvHangoutCreditRunningOutNoticeTask::GetCmdCode() const
{
	return CMD_RECVHANGOUTCREDITRUNNINGOUTNOTICE;
}

// 设置seq
void RecvHangoutCreditRunningOutNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvHangoutCreditRunningOutNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvHangoutCreditRunningOutNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvHangoutCreditRunningOutNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvHangoutCreditRunningOutNoticeTask::OnDisconnect()
{

}
