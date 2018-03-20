/*
 * author: Alex
 *   date: 2017-09-06
 *   file: ZBRecvSendSystemNoticeTask.cpp
 *   desc: 4.3.接收直播间公告消息Task实现类
 */

#include "ZBRecvSendSystemNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define MSG_PARAM              "msg"
#define LINK_PARAM             "link"
#define TYPE_PARAM             "type"

ZBRecvSendSystemNoticeTask::ZBRecvSendSystemNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_msg = "";
    m_link = "";
    m_type = ZBIMSYSTEMTYPE_COMMON;
}

ZBRecvSendSystemNoticeTask::~ZBRecvSendSystemNoticeTask(void)
{
}

// 初始化
bool ZBRecvSendSystemNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvSendSystemNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[MSG_PARAM].isString()) {
            m_msg = tp.m_data[MSG_PARAM].asString();
        }
        if (tp.m_data[LINK_PARAM].isString()) {
            m_link = tp.m_data[LINK_PARAM].asString();
        }
        if (tp.m_data[TYPE_PARAM].isNumeric()) {
            m_type = ZBGetIMSystemType(tp.m_data[TYPE_PARAM].asInt());
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvSendSystemNotice(m_roomId, m_msg, m_link, m_type);
		FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvSendSystemNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZB_ROOT_ERRNO] = (int)m_errType;
        if (m_errType != ZBLCC_ERR_SUCCESS) {
            value[ZB_ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ZBImClient", "ZBRecvSendSystemNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvSendSystemNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVSENDSYSTEMNOTICE;
}

// 设置seq
void ZBRecvSendSystemNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvSendSystemNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvSendSystemNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvSendSystemNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
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
void ZBRecvSendSystemNoticeTask::OnDisconnect()
{

}
