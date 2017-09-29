/*
 * author: Alex
 *   date: 2017-08-29
 *   file: RecvBookingNoticeTask.cpp
 *   desc: 7.7.接收预约开始倒数通知 Task实现类
 */

#include "RecvBookingNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
//#define ROOMID_PARAM                "roomid"
#define USERID_PARAM                "userid"
//#define NICKNAME_PARAM              "nickname"
#define AVATARIMG_PARAM             "avatar_img"
#define LEFTSECONDS_PARAM           "left_seconds"




RecvBookingNoticeTask::RecvBookingNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvBookingNoticeTask::~RecvBookingNoticeTask(void)
{
}

// 初始化
bool RecvBookingNoticeTask::Init(IImClientListener* listener)
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
bool RecvBookingNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvBookingNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    string roomId = "";
    string userId = "";
    string nickName = "";
    string avatarImg = "";
    int leftSeconds = 0;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[USERID_PARAM].isString()) {
            userId = tp.m_data[USERID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            nickName = tp.m_data[NICKNAME_PARAM].asString();
        }
        if (tp.m_data[AVATARIMG_PARAM].isString()) {
            avatarImg = tp.m_data[AVATARIMG_PARAM].asString();
        }
        if (tp.m_data[LEFTSECONDS_PARAM].isIntegral()) {
            leftSeconds = tp.m_data[LEFTSECONDS_PARAM].asInt();
        }

    
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvBookingNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvBookingNotice(roomId, userId, nickName, avatarImg, leftSeconds);
		FileLog("LiveChatClient", "RecvBookingNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvBookingNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvBookingNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvBookingNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("LiveChatClient", "RecvBookingNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvBookingNoticeTask::GetCmdCode() const
{
	return CMD_RECBOOKINGNOTICE;
}

// 设置seq
void RecvBookingNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvBookingNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvBookingNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvBookingNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvBookingNoticeTask::OnDisconnect()
{

}
