/*
 * author: Alex
 *   date: 2017-06-12
 *   file: FansShutUpTask.cpp
 *   desc: 3.7.主播禁言观众（直播端把制定观众禁言）TaskTask实现类
 */

#include "FansShutUpTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define USERID_PARAM           "userid"
#define TIMEOUT_PARAM          "timeout"

FansShutUpTask::FansShutUpTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_timeOut = 0;
}

FansShutUpTask::~FansShutUpTask(void)
{
}

// 初始化
bool FansShutUpTask::Init(IImClientListener* listener)
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
bool FansShutUpTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "FansShutUpTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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

	FileLog("LiveChatClient", "FansShutUpTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnFansShutUp(GetSeq(), success, m_errType, m_errMsg);
		FileLog("LiveChatClient", "FansShutUpTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "FansShutUpTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool FansShutUpTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "FansShutUpTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[USERID_PARAM] = m_userId;
        value[TIMEOUT_PARAM] = m_timeOut;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "FansShutUpTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string FansShutUpTask::GetCmdCode() const
{
	return CMD_FANSSHUTUP;
}

// 设置seq
void FansShutUpTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T FansShutUpTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool FansShutUpTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void FansShutUpTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool FansShutUpTask::InitParam(const string& roomId, const string userId, int timeOut)
{
	bool result = false;
    if (!roomId.empty()
        && !userId.empty()) {
        m_roomId = roomId;
        m_userId = userId;
        m_timeOut = timeOut;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void FansShutUpTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnFansShutUp(GetSeq(), false, LCC_ERR_CONNECTFAIL, "");
    }
}
