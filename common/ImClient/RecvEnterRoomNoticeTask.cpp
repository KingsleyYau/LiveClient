/*
 * author: Alex
 *   date: 2017-05-31
 *   file: RecvEnterRoomNoticeTask.cpp
 *   desc: 3.4.接收观众进入直播间通知Task实现类（观众端／主播端接收观众进入直播间通知）
 */

#include "RecvEnterRoomNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
//#define ROOMID_PARAM           "roomid"
#define USERID_PARAM           "userid"
//#define NICKNAME_PARAM         "nickname"
#define PHOTOURL_PARAM         "photourl"
#define RIDERID_PARAM          "riderid"
#define RIDERNAME_PARAM        "ridername"
#define RIDERURL_PARAM         "riderurl"
#define FANSNUM_PARAM          "fansnum"

RecvEnterRoomNoticeTask::RecvEnterRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
    m_photourl = "";
    m_fansNum = 0;
    m_riderId = "";
    m_riderName = "";
    m_riderUrl = "";
}

RecvEnterRoomNoticeTask::~RecvEnterRoomNoticeTask(void)
{
}

// 初始化
bool RecvEnterRoomNoticeTask::Init(IImClientListener* listener)
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
bool RecvEnterRoomNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvEnterRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[USERID_PARAM].isString()) {
            m_userId = tp.m_data[USERID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_PARAM].asString();
        }
        if (tp.m_data[PHOTOURL_PARAM].isString()) {
            m_photourl = tp.m_data[PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[RIDERID_PARAM].isString()) {
            m_riderId = tp.m_data[RIDERID_PARAM].asString();
        }
        if (tp.m_data[RIDERNAME_PARAM].isString()) {
            m_riderName = tp.m_data[RIDERNAME_PARAM].asString();
        }
        if (tp.m_data[RIDERURL_PARAM].isString()) {
            m_riderUrl = tp.m_data[RIDERURL_PARAM].asString();
        }
        if (tp.m_data[FANSNUM_PARAM].isInt()) {
            m_fansNum = tp.m_data[FANSNUM_PARAM].asInt();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvEnterRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvEnterRoomNotice(m_roomId, m_userId, m_nickName, m_photourl, m_riderId, m_riderName, m_riderUrl, m_fansNum);
		FileLog("ImClient", "RecvEnterRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvEnterRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvEnterRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvEnterRoomNoticeTask::GetSendData() begin");
    {
//        // 构造json协议
//        Json::Value value;
//        value[ROOMID_PARAM] = m_roomId;
//        value[USERID_PARAM] = m_userId;
//        value[NICKNAME_PARAM] = m_nickName;
//        value[PHOTOURL_PARAM] = m_photourl;
//        value[FANSNUM_PARAM] = m_fansNum;
//        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvEnterRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvEnterRoomNoticeTask::GetCmdCode() const
{
	return CMD_RECVENTERROOMNOTICE;
}

// 设置seq
void RecvEnterRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvEnterRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvEnterRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvEnterRoomNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvEnterRoomNoticeTask::OnDisconnect()
{

}
