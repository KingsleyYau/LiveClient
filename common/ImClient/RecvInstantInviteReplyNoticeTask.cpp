/*
 * author: Alex
 *   date: 2017-08-28
 *   file: RecvInstantInviteReplyNoticeTask.cpp
 *   desc: 7.3.接收立即私密邀请回复通知 Task实现类
 */

#include "RecvInstantInviteReplyNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define INVITEID_PARAM          "invite_id"
#define REPLYTYPE_PARAM         "reply_type"
#define IMROOMID_PARAM          "room_id"
#define ROOMTYPE_PARAM          "room_type"
#define ANCHORID_PARAM          "anchor_id"
#define NICKNAMET_PARAM         "nick_name"
#define AVATARIMG_PARAM         "avatar_img"
#define MSG_PARAM               "msg"


RecvInstantInviteReplyNoticeTask::RecvInstantInviteReplyNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_inviteId = "";
    m_roomId = "";
    m_replyType = REPLYTYPE_REJECT;
    m_roomType = ROOMTYPE_UNKNOW;
    m_anchorId = "";
    m_nickName = "";
    m_avatarImg = "";
    m_msg = "";

}

RecvInstantInviteReplyNoticeTask::~RecvInstantInviteReplyNoticeTask(void)
{
}

// 初始化
bool RecvInstantInviteReplyNoticeTask::Init(IImClientListener* listener)
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
bool RecvInstantInviteReplyNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[INVITEID_PARAM].isString()) {
            m_inviteId = tp.m_data[INVITEID_PARAM].asString();
        }
        if (tp.m_data[REPLYTYPE_PARAM].isInt()) {
            m_replyType =  GetReplyType(tp.m_data[REPLYTYPE_PARAM].asInt());
        }
        if (tp.m_data[IMROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[IMROOMID_PARAM].asString();
        }
        if (tp.m_data[ROOMTYPE_PARAM].isInt()) {
            m_roomType = GetRoomType(tp.m_data[ROOMTYPE_PARAM].asInt());
        }
        if (tp.m_data[ANCHORID_PARAM].isString()) {
            m_anchorId = tp.m_data[ANCHORID_PARAM].asString();
        }
        if (tp.m_data[NICKNAMET_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAMET_PARAM].asString();
        }
        if (tp.m_data[AVATARIMG_PARAM].isString()) {
            m_avatarImg = tp.m_data[AVATARIMG_PARAM].asString();
        }
        if (tp.m_data[MSG_PARAM].isString()) {
            m_msg = tp.m_data[MSG_PARAM].asString();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvInstantInviteReplyNotice(m_inviteId, m_replyType, m_roomId, m_roomType, m_anchorId, m_nickName, m_avatarImg, m_msg);
		FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvInstantInviteReplyNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("LiveChatClient", "RecvInstantInviteReplyNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvInstantInviteReplyNoticeTask::GetCmdCode() const
{
	return CMD_RECVINSTANTINVITEREPLYNOTICE;
}

// 设置seq
void RecvInstantInviteReplyNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvInstantInviteReplyNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvInstantInviteReplyNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvInstantInviteReplyNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvInstantInviteReplyNoticeTask::OnDisconnect()
{

}
