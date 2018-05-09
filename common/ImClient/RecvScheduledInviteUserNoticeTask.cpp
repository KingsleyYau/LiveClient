/*
 * author: Alex
 *   date: 2017-08-28
 *   file: RecvScheduledInviteUserNoticeTask.cpp
 *   desc: 7.5.接收主播预约私密邀请通知 Task实现类
 */

#include "RecvScheduledInviteUserNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define INVITEID_PARAM        "invite_id"
#define ANCHORID_PARAM        "anchor_id"
#define NICKNAMET_PARAM        "nick_name"
#define AVATARIMG_PARAM       "avatar_img"
#define MSG_PARAM             "msg"



RecvScheduledInviteUserNoticeTask::RecvScheduledInviteUserNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_inviteId = "";
    m_anchorId = "";
    m_nickName = "";
    m_avatarImg = "";
    m_msg = "";
}

RecvScheduledInviteUserNoticeTask::~RecvScheduledInviteUserNoticeTask(void)
{
}

// 初始化
bool RecvScheduledInviteUserNoticeTask::Init(IImClientListener* listener)
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
bool RecvScheduledInviteUserNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);

    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[INVITEID_PARAM].isString()) {
            m_inviteId = tp.m_data[INVITEID_PARAM].asString();
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

	FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvScheduledInviteUserNotice(m_inviteId, m_anchorId, m_nickName, m_avatarImg, m_msg);
		FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvScheduledInviteUserNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOT_ERRNO] = (int)m_errType;
        if (m_errType != LCC_ERR_SUCCESS) {
            value[ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvScheduledInviteUserNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvScheduledInviteUserNoticeTask::GetCmdCode() const
{
	return CMD_RECVSCHEDULEDINVITEUSERNOTICE;
}

// 设置seq
void RecvScheduledInviteUserNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvScheduledInviteUserNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvScheduledInviteUserNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvScheduledInviteUserNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvScheduledInviteUserNoticeTask::OnDisconnect()
{

}
