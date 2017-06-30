/*
 * author: Alex
 *   date: 2017-06-12
 *   file: RecvShutUpNoticeTask.cpp
 *   desc: 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）TaskTask实现类
 */

#include "RecvShutUpNoticeTask.h"
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
#define TIMEOUT_PARAM          "timeout"

RecvShutUpNoticeTask::RecvShutUpNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
    m_timeOut = 0;
}

RecvShutUpNoticeTask::~RecvShutUpNoticeTask(void)
{
}

// 初始化
bool RecvShutUpNoticeTask::Init(IImClientListener* listener)
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
bool RecvShutUpNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvShutUpNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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
        if (tp.m_data[TIMEOUT_PARAM].isInt()) {
            m_timeOut = tp.m_data[TIMEOUT_PARAM].asInt();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvShutUpNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvShutUpNotice(m_roomId, m_userId, m_nickName, m_timeOut);
		FileLog("LiveChatClient", "RecvShutUpNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvShutUpNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvShutUpNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvShutUpNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;

        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvShutUpNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvShutUpNoticeTask::GetCmdCode() const
{
	return CMD_RECVSHUTUPNOTICE;
}

// 设置seq
void RecvShutUpNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvShutUpNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvShutUpNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvShutUpNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool RecvShutUpNoticeTask::InitParam(const string& roomId, const string& userId, const string& nickName, int timeOut)
{
	bool result = false;
    if (!roomId.empty()
        && !userId.empty()
        && !nickName.empty()) {
        m_roomId = roomId;
        m_userId = userId;
        m_nickName = nickName;
        m_timeOut = timeOut;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void RecvShutUpNoticeTask::OnDisconnect()
{
}
