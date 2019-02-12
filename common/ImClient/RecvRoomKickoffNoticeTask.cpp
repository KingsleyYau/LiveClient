/*
 * author: Alex
 *   date: 2017-08-15
 *   file: RecvRoomKickoffNoticeTask.cpp
 *   desc: 3.8.接收踢出直播间通知 Task实现类
 */

#include "RecvRoomKickoffNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define CREDIT_PARAM           "credit"
#define ERRNO_PARAM				"errno"
#define ERRMSG_PARAM       		"errmsg"
#define RECV_RKONT_PRIV_PATAM   "priv"



RecvRoomKickoffNoticeTask::RecvRoomKickoffNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_credit = 0.0;

}

RecvRoomKickoffNoticeTask::~RecvRoomKickoffNoticeTask(void)
{
}

// 初始化
bool RecvRoomKickoffNoticeTask::Init(IImClientListener* listener)
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
bool RecvRoomKickoffNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvRoomKickoffNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	IMAuthorityItem priv;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[CREDIT_PARAM].isNumeric()) {
            m_credit = tp.m_data[CREDIT_PARAM].asDouble();
        }
        if (tp.m_data[ERRNO_PARAM].isInt()) {
        	m_errType = (LCC_ERR_TYPE)tp.m_data[ERRNO_PARAM].asInt();
        }
        if (tp.m_data[ERRMSG_PARAM].isString()) {
        	m_errMsg = tp.m_data[ERRMSG_PARAM].asString();
        }
        if (tp.m_data[RECV_RKONT_PRIV_PATAM].isObject()) {
            priv.Parse(tp.m_data[RECV_RKONT_PRIV_PATAM]);
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvRoomKickoffNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvRoomKickoffNotice(m_roomId, m_errType, m_errMsg, m_credit, priv);
		FileLog("ImClient", "RecvRoomKickoffNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvRoomKickoffNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvRoomKickoffNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvRoomKickoffNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvRoomKickoffNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvRoomKickoffNoticeTask::GetCmdCode() const
{
	return CMD_RECVROOMKICKOFFNOTICE;
}

// 设置seq
void RecvRoomKickoffNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvRoomKickoffNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvRoomKickoffNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvRoomKickoffNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvRoomKickoffNoticeTask::OnDisconnect()
{

}
