/*
 * author: Alex
 *   date: 2017-08-14
 *   file: RecvLeaveRoomNoticeTask.cpp
 *   desc: 3.5.接收观众退出直播间通知（观众端／主播端接收观众退出直播间通知）Task实现类
 */


#include "RecvLeaveRoomNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_LEAVE_PARAM           "roomid"
#define USERID_PARAM                 "userid"
#define NICKNAME_LEAVE_PARAM         "nickname"
#define PHOTOURL_PARAM               "photourl"
#define FANSNUM_PARAM                "fansnum"

RecvLeaveRoomNoticeTask::RecvLeaveRoomNoticeTask(void)
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
}

RecvLeaveRoomNoticeTask::~RecvLeaveRoomNoticeTask(void)
{
}

// 初始化
bool RecvLeaveRoomNoticeTask::Init(IImClientListener* listener)
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
bool RecvLeaveRoomNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_LEAVE_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_LEAVE_PARAM].asString();
        }
        if (tp.m_data[USERID_PARAM].isString()) {
            m_userId = tp.m_data[USERID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_LEAVE_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_LEAVE_PARAM].asString();
        }
        if (tp.m_data[PHOTOURL_PARAM].isString()) {
            m_photourl = tp.m_data[PHOTOURL_PARAM].asString();
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

	FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLeaveRoomNotice(m_roomId, m_userId, m_nickName, m_photourl, m_fansNum);
		FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLeaveRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::GetSendData() begin");
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

	FileLog("LiveChatClient", "RecvLeaveRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvLeaveRoomNoticeTask::GetCmdCode() const
{
	return CMD_RECVLEAVEROOMNOTICE;
}

// 设置seq
void RecvLeaveRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvLeaveRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvLeaveRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvLeaveRoomNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
//bool RecvLeaveRoomNoticeTask::InitParam(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum)
//{
//	bool result = false;
//    if (!roomId.empty()
//        &&!userId.empty()
//        &&!nickName.empty()
//        &&!photoUrl.empty()) {
//        m_roomId = roomId;
//        m_userId = userId;
//        m_nickName = nickName;
//        m_photourl = photoUrl;
//        m_fansNum = fansNum;
//        
//        result = true;
//    }
//
//
//	return result;
//}

// 未完成任务的断线通知
void RecvLeaveRoomNoticeTask::OnDisconnect()
{

}
