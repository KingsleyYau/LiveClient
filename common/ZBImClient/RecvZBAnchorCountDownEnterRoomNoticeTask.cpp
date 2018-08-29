/*
 * author: Alex
 *   date: 2018-05-18
 *   file: RecvZBAnchorCountDownEnterRoomNoticeTask.cpp
 *   desc: 10.16.接收进入多人互动直播间倒数通知Task实现类
 */

#include "RecvZBAnchorCountDownEnterRoomNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBRECVACDERN_ROOMID_PARAM        "room_id"
#define ZBRECVACDERN_ANCHORID_PARAM      "anchor_id"
#define ZBRECVACDERN_LEFTSECOND_PARAM    "left_second"


RecvZBAnchorCountDownEnterRoomNoticeTask::RecvZBAnchorCountDownEnterRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvZBAnchorCountDownEnterRoomNoticeTask::~RecvZBAnchorCountDownEnterRoomNoticeTask(void)
{
}

// 初始化
bool RecvZBAnchorCountDownEnterRoomNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvZBAnchorCountDownEnterRoomNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    string anchorId = "";
    int leftSecond = 0;
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[ZBRECVACDERN_ROOMID_PARAM].isString()) {
                roomId = tp.m_data[ZBRECVACDERN_ROOMID_PARAM].asString();
            }
            if (tp.m_data[ZBRECVACDERN_ANCHORID_PARAM].isString()) {
                anchorId = tp.m_data[ZBRECVACDERN_ANCHORID_PARAM].asString();
            }
            if (tp.m_data[ZBRECVACDERN_LEFTSECOND_PARAM].isNumeric()) {
                leftSecond = tp.m_data[ZBRECVACDERN_LEFTSECOND_PARAM].asInt();
            }
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorCountDownEnterRoomNotice(roomId, anchorId, leftSecond);
		FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvZBAnchorCountDownEnterRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvZBAnchorCountDownEnterRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvZBAnchorCountDownEnterRoomNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVANCHORCOUNTDOWNENTERROOMNOTICE;
}

// 设置seq
void RecvZBAnchorCountDownEnterRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvZBAnchorCountDownEnterRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvZBAnchorCountDownEnterRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvZBAnchorCountDownEnterRoomNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvZBAnchorCountDownEnterRoomNoticeTask::OnDisconnect()
{

}
