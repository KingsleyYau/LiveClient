/*
 * author: Alex
 *   date: 2018-05-12
 *   file: RecvAnchorHangoutChatNoticeTask.cpp
 *   desc: 10.15.接收直播间文本消息Task实现类
 */

#include "RecvAnchorHangoutChatNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBRECVASMN_BACKGROUND_PARAM        "background"
#define ZBRECVASMN_MSG_PARAM               "msg"


RecvAnchorHangoutChatNoticeTask::RecvAnchorHangoutChatNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorHangoutChatNoticeTask::~RecvAnchorHangoutChatNoticeTask(void)
{
}

// 初始化
bool RecvAnchorHangoutChatNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorHangoutChatNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    IMAnchorRecvHangoutChatItem item;
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            item.Parse(tp.m_data);
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorHangoutChatNotice(item);
		FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorHangoutChatNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZB_ROOT_ERRNO] = (int)m_errType;
        if (m_errType != ZBLCC_ERR_SUCCESS) {
            value[ZB_ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvAnchorHangoutChatNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorHangoutChatNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVHANGOUTSENDCHATNOTICE;
}

// 设置seq
void RecvAnchorHangoutChatNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorHangoutChatNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorHangoutChatNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorHangoutChatNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorHangoutChatNoticeTask::OnDisconnect()
{

}
