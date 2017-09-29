/*
 * author: Alex
 *   date: 2017-08-15
 *   file: PublicRoomInTask.cpp
 *   desc: 3.13.观众进入公开直播间Task实现类
 */

#include "PublicRoomInTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define USERID_PARAM           "userid"

PublicRoomInTask::PublicRoomInTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_userId = "";
    
}

PublicRoomInTask::~PublicRoomInTask(void)
{
}

// 初始化
bool PublicRoomInTask::Init(IImClientListener* listener)
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
bool PublicRoomInTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "PublicRoomInTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    RoomInfoItem item;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "PublicRoomInTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnPublicRoomIn(GetSeq(), success, m_errType, m_errMsg, item);
		FileLog("LiveChatClient", "PublicRoomInTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "PublicRoomInTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool PublicRoomInTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "PublicRoomInTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[USERID_PARAM] = m_userId;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RoomInTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string PublicRoomInTask::GetCmdCode() const
{
	return CMD_PUBLICROOMIN;
}

// 设置seq
void PublicRoomInTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T PublicRoomInTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool PublicRoomInTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void PublicRoomInTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool PublicRoomInTask::InitParam(const string& userId)
{
	bool result = false;
    if (!userId.empty()) {
        m_userId = userId;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void PublicRoomInTask::OnDisconnect()
{
	if (NULL != m_listener) {
        RoomInfoItem item;
        m_listener->OnPublicRoomIn(m_seq, false, LCC_ERR_CONNECTFAIL, "", item);
	}
}
