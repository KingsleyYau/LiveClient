/*
 * author: Alex
 *   date: 2019-09-11
 *   file: RecvPublicRoomFreeMsgNoticeTask.cpp
 *   desc: 3.16.接收公开直播间前3秒免费提示通知Task实现类
 */

#include "RecvPublicRoomFreeMsgNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

#define RECVPUBLICROOMFREEMSGNOTICE_ROOMID_PARAM            "room_id"
#define RECVPUBLICROOMFREEMSGNOTICE_MESSAGE_PARAM           "message"

RecvPublicRoomFreeMsgNoticeTask::RecvPublicRoomFreeMsgNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
}

RecvPublicRoomFreeMsgNoticeTask::~RecvPublicRoomFreeMsgNoticeTask(void)
{
}

// 初始化
bool RecvPublicRoomFreeMsgNoticeTask::Init(IImClientListener* listener)
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
bool RecvPublicRoomFreeMsgNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    string message = "";
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[RECVPUBLICROOMFREEMSGNOTICE_ROOMID_PARAM].isString()) {
                roomId = tp.m_data[RECVPUBLICROOMFREEMSGNOTICE_ROOMID_PARAM].asString();
            }
            if (tp.m_data[RECVPUBLICROOMFREEMSGNOTICE_MESSAGE_PARAM].isString()) {
                message = tp.m_data[RECVPUBLICROOMFREEMSGNOTICE_MESSAGE_PARAM].asString();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvPublicRoomFreeMsgNotice(roomId, message);
		FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvPublicRoomFreeMsgNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvPublicRoomFreeMsgNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvPublicRoomFreeMsgNoticeTask::GetCmdCode() const
{
	return CMD_RECVPUBLICROOMFREEMSGNOTICE;
}

// 设置seq
void RecvPublicRoomFreeMsgNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvPublicRoomFreeMsgNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvPublicRoomFreeMsgNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvPublicRoomFreeMsgNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvPublicRoomFreeMsgNoticeTask::OnDisconnect()
{

}
