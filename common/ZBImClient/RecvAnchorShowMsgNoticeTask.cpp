/*
 * author: Alex
 *   date: 2018-05-04
 *   file: RecvAnchorShowMsgNoticeTask.cpp
 *   desc: 11.3.节目取消通知Task实现类
 */

#include "RecvAnchorShowMsgNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBRECVASMN_BACKGROUND_PARAM        "background"
#define ZBRECVASMN_MSG_PARAM               "msg"


RecvAnchorShowMsgNoticeTask::RecvAnchorShowMsgNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorShowMsgNoticeTask::~RecvAnchorShowMsgNoticeTask(void)
{
}

// 初始化
bool RecvAnchorShowMsgNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorShowMsgNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string backgroundUrl = "";
    string msg = "";
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[ZBRECVASMN_BACKGROUND_PARAM].isString()) {
                backgroundUrl = tp.m_data[ZBRECVASMN_BACKGROUND_PARAM].asString();
            }
            if (tp.m_data[ZBRECVASMN_MSG_PARAM].isString()) {
                msg = tp.m_data[ZBRECVASMN_MSG_PARAM].asString();
            }
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorShowMsgNotice(backgroundUrl, msg);
		FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorShowMsgNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvAnchorShowMsgNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorShowMsgNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVANCHORSTATUSCHANGENOTICE;
}

// 设置seq
void RecvAnchorShowMsgNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorShowMsgNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorShowMsgNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorShowMsgNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorShowMsgNoticeTask::OnDisconnect()
{

}
