/*
 * author: Alex
 *   date: 2018-05-10
 *   file: RecvAnchorControlManPushHangoutNoticeTask.cpp
 *   desc: 10.13.接收多人互动直播间观众启动/关闭视频互动通知Task实现类
 */

#include "RecvAnchorControlManPushHangoutNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

RecvAnchorControlManPushHangoutNoticeTask::RecvAnchorControlManPushHangoutNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";


}

RecvAnchorControlManPushHangoutNoticeTask::~RecvAnchorControlManPushHangoutNoticeTask(void)
{
}

// 初始化
bool RecvAnchorControlManPushHangoutNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorControlManPushHangoutNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    ZBControlPushItem item;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        item.Parse(tp.m_data);
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorControlManPushHangoutNotice(item);
		FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorControlManPushHangoutNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvAnchorControlManPushHangoutNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorControlManPushHangoutNoticeTask::GetCmdCode() const
{
	return ZB_CMD_CONTROLMANPUSHHANGOUTNOTICE;
}

// 设置seq
void RecvAnchorControlManPushHangoutNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorControlManPushHangoutNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorControlManPushHangoutNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorControlManPushHangoutNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorControlManPushHangoutNoticeTask::OnDisconnect()
{

}
