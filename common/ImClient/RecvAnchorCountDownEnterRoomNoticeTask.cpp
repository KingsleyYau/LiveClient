/*
 * author: Alex
 *   date: 2018-05-19
 *   file: RecvAnchorCountDownEnterRoomNoticeTask.cpp
 *   desc: 10.14.接收进入多人互动直播间倒数通知Task实现类
 */

#include "RecvAnchorCountDownEnterRoomNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define RECVANCHORCDERN_ROOMID_PARAM               "room_id"
#define RECVANCHORCDERN_ANCHORID_PARAM             "anchor_id"
#define RECVANCHORCDERN_LEFTSECOND_PARAM           "left_second"
RecvAnchorCountDownEnterRoomNoticeTask::RecvAnchorCountDownEnterRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorCountDownEnterRoomNoticeTask::~RecvAnchorCountDownEnterRoomNoticeTask(void)
{
}

// 初始化
bool RecvAnchorCountDownEnterRoomNoticeTask::Init(IImClientListener* listener)
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
bool RecvAnchorCountDownEnterRoomNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    string anchorId = "";
    int leftSecond = 0;
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[RECVANCHORCDERN_ROOMID_PARAM].isString()) {
                roomId = tp.m_data[RECVANCHORCDERN_ROOMID_PARAM].asString();
            }
            if (tp.m_data[RECVANCHORCDERN_ANCHORID_PARAM].isString()) {
                anchorId = tp.m_data[RECVANCHORCDERN_ANCHORID_PARAM].asString();
            }
            if (tp.m_data[RECVANCHORCDERN_LEFTSECOND_PARAM].isNumeric()) {
                leftSecond = tp.m_data[RECVANCHORCDERN_LEFTSECOND_PARAM].asInt();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorCountDownEnterHangoutRoomNotice(roomId, anchorId, leftSecond);
		FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorCountDownEnterRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvAnchorCountDownEnterRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorCountDownEnterRoomNoticeTask::GetCmdCode() const
{
	return CMD_RECVANCHORCOUNTDOWNENTERROOMNOTICE;
}

// 设置seq
void RecvAnchorCountDownEnterRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorCountDownEnterRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorCountDownEnterRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorCountDownEnterRoomNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorCountDownEnterRoomNoticeTask::OnDisconnect()
{

}
