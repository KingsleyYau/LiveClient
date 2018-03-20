/*
 * author: Alex
 *   date: 2018-03-5
 *   file: ZBRoomOutTask.cpp
 *   desc: 3.3.主播退出直播间Task实现类
 */

#include "ZBRoomOutTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRO_ROOMID_ROOMOUT_PARAM           "room_id"

ZBRoomOutTask::ZBRoomOutTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
}

ZBRoomOutTask::~ZBRoomOutTask(void)
{
}

// 初始化
bool ZBRoomOutTask::Init(IZBImClientListener* listener)
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
bool ZBRoomOutTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRoomOutTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRoomOutTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnZBRoomOut(GetSeq(), success, m_errType, m_errMsg);
		FileLog("ZBImClient", "ZBRoomOutTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRoomOutTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRoomOutTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRoomOutTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZBRO_ROOMID_ROOMOUT_PARAM] = m_roomId;
        data = value;
    }

    result = true;

	FileLog("ZBImClient", "ZBRoomOutTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRoomOutTask::GetCmdCode() const
{
	return ZB_CMD_ROOMOUT;
}

// 设置seq
void ZBRoomOutTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRoomOutTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRoomOutTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBRoomOutTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBRoomOutTask::InitParam(const string& roomId)
{
	bool result = false;

    if (!roomId.empty()) {
        m_roomId = roomId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ZBRoomOutTask::OnDisconnect()
{
	if (NULL != m_listener) {
        m_listener->OnZBRoomOut(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
	}
}
