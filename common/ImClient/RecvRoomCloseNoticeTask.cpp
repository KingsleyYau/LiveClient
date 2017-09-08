/*
 * author: Alex
 *   date: 2017-05-31
 *   file: RecvRoomCloseNoticeTask.cpp
 *   desc: 3.3.接收直播间关闭Task实现类
 */

#include "RecvRoomCloseNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define USERID_PARAM           "userid"
#define NICKNAME_PARAM         "nickname"

RecvRoomCloseNoticeTask::RecvRoomCloseNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
}

RecvRoomCloseNoticeTask::~RecvRoomCloseNoticeTask(void)
{
}

// 初始化
bool RecvRoomCloseNoticeTask::Init(IImClientListener* listener)
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
bool RecvRoomCloseNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvRoomCloseNotice(m_roomId, m_userId, m_nickName, m_errType, m_errMsg);
		FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvRoomCloseNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::GetSendData() begin");
    {
//        // 构造json协议
//        Json::Value value;
//        value[ROOMID_PARAM] = m_roomId;
//        value[USERID_PARAM] = m_userId;
//        value[NICKNAME_PARAM] = m_nickName;
//        value[REASON_PARAM] = m_reason;
//        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvRoomCloseNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvRoomCloseNoticeTask::GetCmdCode() const
{
	return CMD_RECVROOMCLOSENOTICE;
}

// 设置seq
void RecvRoomCloseNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvRoomCloseNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvRoomCloseNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvRoomCloseNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void RecvRoomCloseNoticeTask::OnDisconnect()
{
//	if (NULL != m_listener) {
//        m_listener->OnRecvRoomCloseFans(m_roomId, m_userId, m_nickName, m_fansNum);
//	}
}
