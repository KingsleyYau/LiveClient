/*
 * author: Alex
 *   date: 2018-03-07
 *   file: ZBRecvLeavingPublicRoomNoticeTask.cpp
 *   desc: 3.8.接收关闭直播间倒数通知（观众端接收返点通知）Task实现类
 */

#include "ZBRecvLeavingPublicRoomNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBLCER_LEFTSECONDS_PARAM      "left_seconds"
#define ZBLCER_ROOMID_PARAM           "roomid"
#define ZBLCER_ERRNO_PARAM			  "errno"
#define ZBLCER_ERRMSG_PARAM       	  "errmsg"



ZBRecvLeavingPublicRoomNoticeTask::ZBRecvLeavingPublicRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_leftSeconds = 0;

}

ZBRecvLeavingPublicRoomNoticeTask::~ZBRecvLeavingPublicRoomNoticeTask(void)
{
}

// 初始化
bool ZBRecvLeavingPublicRoomNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvLeavingPublicRoomNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBLCER_ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ZBLCER_ROOMID_PARAM].asString();
        }
        if (tp.m_data[ZBLCER_LEFTSECONDS_PARAM].isIntegral()) {
            m_leftSeconds = tp.m_data[ZBLCER_LEFTSECONDS_PARAM].asInt();
        }
        if (tp.m_data[ZBLCER_ERRNO_PARAM].isInt()) {
        	m_errType = (ZBLCC_ERR_TYPE)tp.m_data[ZBLCER_ERRNO_PARAM].asInt();
        }
        if (tp.m_data[ZBLCER_ERRMSG_PARAM].isString()) {
        	m_errMsg = tp.m_data[ZBLCER_ERRMSG_PARAM].asString();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvLeavingPublicRoomNotice(m_roomId, m_leftSeconds, m_errType, m_errMsg);
		FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvLeavingPublicRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::GetSendData() begin");
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

	FileLog("ZBImClient", "ZBRecvLeavingPublicRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvLeavingPublicRoomNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVLEAVINGPUBLICROOMNOTICE;
}

// 设置seq
void ZBRecvLeavingPublicRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvLeavingPublicRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvLeavingPublicRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvLeavingPublicRoomNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvLeavingPublicRoomNoticeTask::OnDisconnect()
{

}
