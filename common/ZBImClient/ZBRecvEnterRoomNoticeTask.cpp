/*
 * author: Alex
 *   date: 2018-03-07
 *   file: ZBRecvEnterRoomNoticeTask.cpp
 *   desc: 3.6.接收观众进入直播间通知Task实现类（观众端／主播端接收观众进入直播间通知）
 */

#include "ZBRecvEnterRoomNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRERN_ROOMID_PARAM           "roomid"
#define ZBRERN_USERID_PARAM           "userid"
#define ZBRERN_NICKNAME_PARAM         "nickname"
#define ZBRERN_PHOTOURL_PARAM         "photourl"
#define ZBRERN_RIDERID_PARAM          "riderid"
#define ZBRERN_RIDERNAME_PARAM        "ridername"
#define ZBRERN_RIDERURL_PARAM         "riderurl"
#define ZBRERN_FANSNUM_PARAM          "fansnum"
#define ZBRERN_HASTICKET_PARAM        "has_ticket"

ZBRecvEnterRoomNoticeTask::ZBRecvEnterRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
    m_photourl = "";
    m_fansNum = 0;
    m_riderId = "";
    m_riderName = "";
    m_riderUrl = "";
    m_hasTicket = false;
}

ZBRecvEnterRoomNoticeTask::~ZBRecvEnterRoomNoticeTask(void)
{
}

// 初始化
bool ZBRecvEnterRoomNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvEnterRoomNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRERN_ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ZBRERN_ROOMID_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_USERID_PARAM].isString()) {
            m_userId = tp.m_data[ZBRERN_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[ZBRERN_NICKNAME_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_PHOTOURL_PARAM].isString()) {
            m_photourl = tp.m_data[ZBRERN_PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_RIDERID_PARAM].isString()) {
            m_riderId = tp.m_data[ZBRERN_RIDERID_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_RIDERNAME_PARAM].isString()) {
            m_riderName = tp.m_data[ZBRERN_RIDERNAME_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_RIDERURL_PARAM].isString()) {
            m_riderUrl = tp.m_data[ZBRERN_RIDERURL_PARAM].asString();
        }
        if (tp.m_data[ZBRERN_FANSNUM_PARAM].isNumeric()) {
            m_fansNum = tp.m_data[ZBRERN_FANSNUM_PARAM].asInt();
        }
        
        if (tp.m_data[ZBRERN_HASTICKET_PARAM].isNumeric()) {
            m_hasTicket = tp.m_data[ZBRERN_HASTICKET_PARAM].asInt() == 0 ? false : true;
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvEnterRoomNotice(m_roomId, m_userId, m_nickName, m_photourl, m_riderId, m_riderName, m_riderUrl, m_fansNum, m_hasTicket);
		FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvEnterRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "ZBRecvEnterRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvEnterRoomNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVENTERROOMNOTICE;
}

// 设置seq
void ZBRecvEnterRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvEnterRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvEnterRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvEnterRoomNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvEnterRoomNoticeTask::OnDisconnect()
{

}
