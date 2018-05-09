/*
 * author: Alex
 *   date: 2018-03-05
 *   file: ZBRoomInTask.cpp
 *   desc: 3.2.主播进入指定直播间Task实现类
 */

#include "ZBRoomInTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRI_ROOMID_ROOMIN_PARAM           "room_id"


ZBRoomInTask::ZBRoomInTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    
}

ZBRoomInTask::~ZBRoomInTask(void)
{
}

// 初始化
bool ZBRoomInTask::Init(IZBImClientListener* listener)
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
bool ZBRoomInTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRoomInTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    ZBRoomInfoItem item;
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
        //本地存储roomid
        item.roomId = m_roomId;
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRoomInTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnZBRoomIn(GetSeq(), success, m_errType, m_errMsg, item);
		FileLog("ImClient", "ZBRoomInTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RoomInTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRoomInTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRoomInTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZBRI_ROOMID_ROOMIN_PARAM] = m_roomId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "ZBRoomInTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRoomInTask::GetCmdCode() const
{
	return ZB_CMD_ROOMIN;
}

// 设置seq
void ZBRoomInTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRoomInTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRoomInTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBRoomInTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBRoomInTask::InitParam(const string& roomId)
{
	bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ZBRoomInTask::OnDisconnect()
{
	if (NULL != m_listener) {
        ZBRoomInfoItem item;
        m_listener->OnZBRoomIn(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, item);
	}
}
