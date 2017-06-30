/*
 * author: Alex
 *   date: 2017-06-12
 *   file: RecvKickOffRoomNoticeTask.cpp
 *   desc: 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）TaskTask实现类
 */

#include "RecvKickOffRoomNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 接收参数定义
#define ROOMID_PARAM           "roomid"
#define USERID_PARAM           "userid"
#define NICKNAME_PARAM         "nickname"

RecvKickOffRoomNoticeTask::RecvKickOffRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
}

RecvKickOffRoomNoticeTask::~RecvKickOffRoomNoticeTask(void)
{
}

// 初始化
bool RecvKickOffRoomNoticeTask::Init(IImClientListener* listener)
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
bool RecvKickOffRoomNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    RoomTopFanList list;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[USERID_PARAM].isString()) {
            m_userId = tp.m_data[USERID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_PARAM].asString();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvKickOffRoomNotice(m_roomId, m_userId, m_nickName);
		FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvKickOffRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;

        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvKickOffRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvKickOffRoomNoticeTask::GetCmdCode() const
{
	return CMD_RECVKICKOFFROOMNOTICE;
}

// 设置seq
void RecvKickOffRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvKickOffRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvKickOffRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvKickOffRoomNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool RecvKickOffRoomNoticeTask::InitParam(const string& roomId, const string& userId, const string& nickName)
{
	bool result = false;
    if (!roomId.empty()
        && !userId.empty()
        && !nickName.empty()) {
        m_roomId = roomId;
        m_userId = userId;
        m_nickName = nickName;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void RecvKickOffRoomNoticeTask::OnDisconnect()
{
}
