/*
 * author: Alex
 *   date: 2018-04-11
 *   file: RecvAnchorLeaveRoomNoticeTask.cpp
 *   desc: 3.9.接收主播退出直播间通知Task实现类
 */

#include "RecvAnchorLeaveRoomNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

#define ANCHORLEAVEROOM_ROOMID_PARAM               "roomid"
#define ANCHORLEAVEROOM_ANCHORID_PARAM             "anchorid"
RecvAnchorLeaveRoomNoticeTask::RecvAnchorLeaveRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorLeaveRoomNoticeTask::~RecvAnchorLeaveRoomNoticeTask(void)
{
}

// 初始化
bool RecvAnchorLeaveRoomNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorLeaveRoomNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    string anchorId = "";
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ANCHORLEAVEROOM_ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ANCHORLEAVEROOM_ROOMID_PARAM].asString();
        }
        if (tp.m_data[ANCHORLEAVEROOM_ANCHORID_PARAM].isString()) {
            anchorId = tp.m_data[ANCHORLEAVEROOM_ANCHORID_PARAM].asString();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorLeaveRoomNotice(roomId, anchorId);
		FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorLeaveRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvAnchorLeaveRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorLeaveRoomNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVANCHORLEAVEROOMNOTICE;
}

// 设置seq
void RecvAnchorLeaveRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorLeaveRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorLeaveRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorLeaveRoomNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorLeaveRoomNoticeTask::OnDisconnect()
{

}
