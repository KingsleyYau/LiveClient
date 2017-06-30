/*
 * author: Alex
 *   date: 2017-06-12
 *   file: RecvPushRoomFavTask.cpp
 *   desc: 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）TaskTask实现类
 */

#include "RecvPushRoomFavTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 接收参数定义
#define ROOMID_PARAM           "roomid"
#define FROMID_PARAM           "fromid"
#define NICKNAME_PARAM         "nickname"
#define FIRST_PARAM            "first"

RecvPushRoomFavTask::RecvPushRoomFavTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_fromId = "";
    m_nickName = "";
    m_first = false;
}

RecvPushRoomFavTask::~RecvPushRoomFavTask(void)
{
}

// 初始化
bool RecvPushRoomFavTask::Init(IImClientListener* listener)
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
bool RecvPushRoomFavTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvPushRoomFavTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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
        if (tp.m_data[FROMID_PARAM].isString()) {
            m_fromId = tp.m_data[FROMID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_PARAM].asString();
        }
        if (tp.m_data[FIRST_PARAM].isInt()) {
            m_first = tp.m_data[FIRST_PARAM].asInt() == 0 ? false : true;
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvPushRoomFavTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvPushRoomFav(m_roomId, m_fromId, m_nickName, m_first);
		FileLog("LiveChatClient", "RecvPushRoomFavTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvPushRoomFavTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvPushRoomFavTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvPushRoomFavTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;

        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvPushRoomFavTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvPushRoomFavTask::GetCmdCode() const
{
	return CMD_RECVPUSHROOMFAV;
}

// 设置seq
void RecvPushRoomFavTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvPushRoomFavTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvPushRoomFavTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvPushRoomFavTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool RecvPushRoomFavTask::InitParam(const string& roomId, const string& fromId)
{
	bool result = false;
    if (!roomId.empty()
        && !fromId.empty()) {
        m_roomId = roomId;
        m_fromId = fromId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void RecvPushRoomFavTask::OnDisconnect()
{
}
