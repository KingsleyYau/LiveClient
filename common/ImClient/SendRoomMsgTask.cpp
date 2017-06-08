/*
 * author: Alex
 *   date: 2017-05-31
 *   file: SendRoomMsgTask.cpp
 *   desc: 4.1.发送直播间文本消息Task实现类（观众端／主播端向直播间发送文本消息）
 */

#include "SendRoomMsgTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define TOKEN_PARAM            "token"
#define NICKNAME_PARAM         "nickname"
#define MSG_PARAM              "msg"

SendRoomMsgTask::SendRoomMsgTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_token = "";
    m_nickName = "";
    m_Msg = "";
}

SendRoomMsgTask::~SendRoomMsgTask(void)
{
}

// 初始化
bool SendRoomMsgTask::Init(IImClientListener* listener)
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
bool SendRoomMsgTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "SendRoomMsgTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "SendRoomMsgTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnSendRoomMsg(GetSeq(), m_errType, m_errMsg);
		FileLog("LiveChatClient", "SendRoomMsgTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "SendRoomMsgTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendRoomMsgTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "SendRoomMsgTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[TOKEN_PARAM] = m_token;
        value[NICKNAME_PARAM] = m_nickName;
        value[MSG_PARAM] = m_Msg;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "SendRoomMsgTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendRoomMsgTask::GetCmdCode() const
{
	return CMD_SENDROOMMSG;
}

// 设置seq
void SendRoomMsgTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendRoomMsgTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendRoomMsgTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendRoomMsgTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendRoomMsgTask::InitParam(const string& roomId, const string& token, const string& nickName, const string& msg)
{
	bool result = false;
    if (!roomId.empty()
        &&!token.empty()
        &&!nickName.empty()
        &&!msg.empty()) {
        m_roomId = roomId;
        m_token = token;
        m_nickName = nickName;
        m_Msg = msg;
    }
    result = true;

	return result;
}

// 未完成任务的断线通知
void SendRoomMsgTask::OnDisconnect()
{
	if (NULL != m_listener) {
        m_listener->OnSendRoomMsg(0, LCC_ERR_CONNECTFAIL, "");
	}
}
