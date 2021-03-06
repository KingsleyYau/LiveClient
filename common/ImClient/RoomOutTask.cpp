/*
 * author: Alex
 *   date: 2017-08-15
 *   file: RoomOutTask.cpp
 *   desc: 3.2.观众退出直播间Task实现类
 */

#include "RoomOutTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
//#define ROOMID_PARAM           "roomid"

RoomOutTask::RoomOutTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
}

RoomOutTask::~RoomOutTask(void)
{
}

// 初始化
bool RoomOutTask::Init(IImClientListener* listener)
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
bool RoomOutTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RoomOutTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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

	FileLog("ImClient", "RoomOutTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnRoomOut(GetSeq(), success, m_errType, m_errMsg);
		FileLog("ImClient", "RoomOutTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RoomOutTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RoomOutTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RoomOutTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "RoomOutTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RoomOutTask::GetCmdCode() const
{
	return CMD_ROOMOUT;
}

// 设置seq
void RoomOutTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RoomOutTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RoomOutTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void RoomOutTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool RoomOutTask::InitParam(const string& roomId)
{
	bool result = false;

    if (!roomId.empty()) {
        m_roomId = roomId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void RoomOutTask::OnDisconnect()
{
	if (NULL != m_listener) {
        m_listener->OnRoomOut(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
	}
}
