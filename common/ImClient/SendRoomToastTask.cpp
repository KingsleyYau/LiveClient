/*
 * author: Alex
 *   date: 2017-06-12
 *   file: SendRoomToastTask.cpp
 *   desc: 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）TaskTask实现类
 */

#include "SendRoomToastTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define ROOMID_PARAM                "roomid"
#define TOKEN_PARAM                 "token"
#define NICKNAME_PARAM              "nickname"
#define MSG_PARAM                   "msg"


// 返回
#define COINS_PARAM                 "coins"

SendRoomToastTask::SendRoomToastTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_token = "";
    m_nickName = "";
    m_msg = "";

    
    m_coins = 0.0;
}

SendRoomToastTask::~SendRoomToastTask(void)
{
}

// 初始化
bool SendRoomToastTask::Init(IImClientListener* listener)
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
bool SendRoomToastTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "SendRoomGiftTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    RoomTopFanList list;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[COINS_PARAM].isNumeric()) {
            m_coins = tp.m_data[COINS_PARAM].asDouble();
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "SendRoomGiftTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendRoomToast(GetSeq(), success, m_errType, m_errMsg, m_coins);
		FileLog("LiveChatClient", "SendRoomGiftTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "SendRoomGiftTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendRoomToastTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "SendRoomGiftTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[TOKEN_PARAM] = m_token;
        value[NICKNAME_PARAM] = m_nickName;
        value[MSG_PARAM] = m_msg;

        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "SendRoomGiftTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendRoomToastTask::GetCmdCode() const
{
	return CMD_SENDROOMTOAST;
}

// 设置seq
void SendRoomToastTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendRoomToastTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendRoomToastTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendRoomToastTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendRoomToastTask::InitParam(const string& roomId, const string token, const string nickName, const string msg)
{
	bool result = false;
    if (!roomId.empty()
        && !token.empty()
        && !nickName.empty()
        && !msg.empty()) {
        m_roomId = roomId;
        m_token = token;
        m_nickName = nickName;
        m_msg = msg;

        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void SendRoomToastTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendRoomToast(GetSeq(), false, LCC_ERR_CONNECTFAIL, "", 0.0);
    }
}
