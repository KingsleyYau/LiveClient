/*
 * author: Alex
 *   date: 2017-08-15
 *   file: RecvSendChatNoticeTask.cpp
 *   desc: 4.2.接收直播间文本消息Task实现类（观众端／主播端向直播间发送文本消息）
 */

#include "RecvSendChatNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_SEND_PARAM      "roomid"
#define LEVEL_PARAM            "level"
#define FROMID_PARAM           "fromid"
#define NICKNAME_SEND_PARAM    "nickname"
#define MSG_PARAM              "msg"
#define HONORURL_PARAM         "honor_url"

RecvSendChatNoticeTask::RecvSendChatNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_level = 0;
    m_fromId = "";
    m_nickName = "";
    m_Msg = "";
    m_HonorUrl = "";
}

RecvSendChatNoticeTask::~RecvSendChatNoticeTask(void)
{
}

// 初始化
bool RecvSendChatNoticeTask::Init(IImClientListener* listener)
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
bool RecvSendChatNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvSendChatNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_SEND_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_SEND_PARAM].asString();
        }
        if (tp.m_data[LEVEL_PARAM].isInt()) {
            m_level = tp.m_data[LEVEL_PARAM].isInt();
        }
        if (tp.m_data[FROMID_PARAM].isString()) {
            m_fromId = tp.m_data[FROMID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_SEND_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_SEND_PARAM].asString();
        }
        if (tp.m_data[MSG_PARAM].isString()) {
            m_Msg = tp.m_data[MSG_PARAM].asString();
        }
        if (tp.m_data[HONORURL_PARAM].isString()) {
            m_HonorUrl = tp.m_data[HONORURL_PARAM].asString();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvSendChatNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvSendChatNotice(m_roomId, m_level, m_fromId, m_nickName, m_Msg, m_HonorUrl);
		FileLog("ImClient", "RecvSendChatNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvSendChatNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvSendChatNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvSendChatNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[FROMID_PARAM] = m_fromId;
        value[NICKNAME_PARAM] = m_nickName;
        value[MSG_PARAM] = m_Msg;
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvSendChatNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvSendChatNoticeTask::GetCmdCode() const
{
	return CMD_RECVSENDCHATNOTICE;
}

// 设置seq
void RecvSendChatNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvSendChatNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvSendChatNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvSendChatNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

//// 初始化参数
//bool RecvRoomMsgTask::InitParam(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg)
//{
//	bool result = false;
//    if (!roomId.empty()
//        &&!fromId.empty()
//        &&!nickName.empty()
//        &&!msg.empty()) {
//        m_roomId = roomId;
//        m_level = level;
//        m_fromId = fromId;
//        m_nickName = nickName;
//        m_Msg = msg;
//    }
//    result = true;
//
//	return result;
//}

// 未完成任务的断线通知
void RecvSendChatNoticeTask::OnDisconnect()
{

}
