/*
 * author: Alex
 *   date: 2018-06-14
 *   file: RecvPrivateMessageNoticeTask.cpp
 *   desc: 12.2.接收私信文本消息通知 Task实现类
 */

#include "RecvPrivateMessageNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>



RecvPrivateMessageNoticeTask::RecvPrivateMessageNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvPrivateMessageNoticeTask::~RecvPrivateMessageNoticeTask(void)
{
}

// 初始化
bool RecvPrivateMessageNoticeTask::Init(IImClientListener* listener)
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
bool RecvPrivateMessageNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvPrivateMessageNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);

    IMPrivateMessageItem item;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            item.Parse(tp.m_data);
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvPrivateMessageNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvPrivateMessageNotice(item);
		FileLog("ImClient", "RecvPrivateMessageNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvPrivateMessageNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvPrivateMessageNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvPrivateMessageNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvPrivateMessageNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvPrivateMessageNoticeTask::GetCmdCode() const
{
	return CMD_RECVSENDPRIVATEMESSAGENOTICE;
}

// 设置seq
void RecvPrivateMessageNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvPrivateMessageNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvPrivateMessageNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvPrivateMessageNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvPrivateMessageNoticeTask::OnDisconnect()
{

}
