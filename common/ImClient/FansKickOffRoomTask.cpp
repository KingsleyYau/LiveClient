/*
 * author: Alex
 *   date: 2017-06-12
 *   file: FansKickOffRoomTask.cpp
 *   desc: 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）TaskTask实现类
 */

#include "FansKickOffRoomTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define USERID_PARAM           "userid"

FansKickOffRoomTask::FansKickOffRoomTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
}

FansKickOffRoomTask::~FansKickOffRoomTask(void)
{
}

// 初始化
bool FansKickOffRoomTask::Init(IImClientListener* listener)
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
bool FansKickOffRoomTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "FansKickOffRoomTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    RoomTopFanList list;
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

	FileLog("LiveChatClient", "FansKickOffRoomTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnFansKickOffRoom(GetSeq(), success, m_errType, m_errMsg);
		FileLog("LiveChatClient", "FansKickOffRoomTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "FansKickOffRoomTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool FansKickOffRoomTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "FansShutUpTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[USERID_PARAM] = m_userId;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "FansKickOffRoomTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string FansKickOffRoomTask::GetCmdCode() const
{
	return CMD_FANSKICKOFFROOM;
}

// 设置seq
void FansKickOffRoomTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T FansKickOffRoomTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool FansKickOffRoomTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void FansKickOffRoomTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool FansKickOffRoomTask::InitParam(const string& roomId, const string userId)
{
	bool result = false;
    if (!roomId.empty()
        && !userId.empty()) {
        m_roomId = roomId;
        m_userId = userId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void FansKickOffRoomTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnFansKickOffRoom(GetSeq(), false, LCC_ERR_CONNECTFAIL, "");
    }
}
