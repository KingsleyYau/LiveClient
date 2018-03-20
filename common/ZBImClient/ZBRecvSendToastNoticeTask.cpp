/*
 * author: Alex
 *   date: 2018-03-05
 *   file: ZBRecvSendToastNoticeTask.cpp
 *   desc: 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）TaskTask实现类
 */

#include "ZBRecvSendToastNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 接收参数定义
#define ROOMID_TOAST_PARAM          "roomid"
#define FROMID_PARAM                "fromid"
#define NICKNAME_TOAST_PARAM        "nickname"
#define MSG_PARAM                   "msg"
#define HONORURL_PARAM              "honor_url"

ZBRecvSendToastNoticeTask::ZBRecvSendToastNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_fromId = "";
    m_nickName = "";
    m_msg = "";
    m_honorUrl = "";
}

ZBRecvSendToastNoticeTask::~ZBRecvSendToastNoticeTask(void)
{
}

// 初始化
bool ZBRecvSendToastNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvSendToastNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[ROOMID_TOAST_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_TOAST_PARAM].asString();
        }
        if (tp.m_data[FROMID_PARAM].isString()) {
            m_fromId = tp.m_data[FROMID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_TOAST_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_TOAST_PARAM].asString();
        }
        if (tp.m_data[MSG_PARAM].isString()) {
            m_msg = tp.m_data[MSG_PARAM].asString();
        }
        if (tp.m_data[HONORURL_PARAM].isString()) {
            m_honorUrl = tp.m_data[HONORURL_PARAM].asString();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvSendToastNotice(m_roomId, m_fromId, m_nickName, m_msg, m_honorUrl);
		FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvSendToastNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::GetSendData() begin");
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

	FileLog("ZBImClient", "ZBRecvSendToastNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvSendToastNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVSENDTOASTNOTICE;
}

// 设置seq
void ZBRecvSendToastNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvSendToastNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvSendToastNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvSendToastNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

//// 初始化参数
//bool RecvSendToastNoticeTask::InitParam(const string& roomId, const string fromId, const string nickName, const string msg)
//{
//	bool result = false;
//    if (!roomId.empty()
//        && !fromId.empty()
//        && !nickName.empty()
//        && !msg.empty()) {
//        m_roomId = roomId;
//        m_fromId = fromId;
//        m_nickName = nickName;
//        m_msg = msg;
//
//        result = true;
//        
//    }
//
//	return result;
//}

// 未完成任务的断线通知
void ZBRecvSendToastNoticeTask::OnDisconnect()
{
}
