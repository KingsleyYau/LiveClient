/*
 * author: Alex
 *   date: 2018-03-07
 *   file: ZBRecvRoomKickoffNoticeTask.cpp
 *   desc: 3.5.接收踢出直播间通知 Task实现类
 */

#include "ZBRecvRoomKickoffNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define ERRNO_PARAM				"errno"
#define ERRMSG_PARAM       		"errmsg"



ZBRecvRoomKickoffNoticeTask::ZBRecvRoomKickoffNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";

}

ZBRecvRoomKickoffNoticeTask::~ZBRecvRoomKickoffNoticeTask(void)
{
}

// 初始化
bool ZBRecvRoomKickoffNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvRoomKickoffNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[ERRNO_PARAM].isInt()) {
        	m_errType = (ZBLCC_ERR_TYPE)tp.m_data[ERRNO_PARAM].asInt();
        }
        if (tp.m_data[ERRMSG_PARAM].isString()) {
        	m_errMsg = tp.m_data[ERRMSG_PARAM].asString();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvRoomKickoffNotice(m_roomId, m_errType, m_errMsg);
		FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvRoomKickoffNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "ZBRecvRoomKickoffNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvRoomKickoffNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVROOMKICKOFFNOTICE;
}

// 设置seq
void ZBRecvRoomKickoffNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvRoomKickoffNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvRoomKickoffNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvRoomKickoffNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvRoomKickoffNoticeTask::OnDisconnect()
{

}
