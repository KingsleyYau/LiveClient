/*
 * author: Alex
 *   date: 2017-12-07
 *   file: SendInstantInviteUserReportTask.cpp
 *   desc: 7.8.观众端是否显示主播立即私密邀请TaskTask实现类
 */

#include "SendInstantInviteUserReportTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义

#define INVITEID_PARAM                  "invite_id"
#define ISSHOW_PARAM                    "is_show"

SendInstantInviteUserReportTask::SendInstantInviteUserReportTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_inviteId = "";
    m_isShow = false;
}

SendInstantInviteUserReportTask::~SendInstantInviteUserReportTask(void)
{
}

// 初始化
bool SendInstantInviteUserReportTask::Init(IImClientListener* listener)
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
bool SendInstantInviteUserReportTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "SendInstantInviteUserReportTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "SendInstantInviteUserReportTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendInstantInviteUserReport(GetSeq(), success, m_errType, m_errMsg);
		FileLog("ImClient", "SendInstantInviteUserReportTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "SendGiftTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendInstantInviteUserReportTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "SendInstantInviteUserReportTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[INVITEID_PARAM] = m_inviteId;
        value[ISSHOW_PARAM] = m_isShow ? 1 : 0;
        data = value;
    }

    result = true;

	FileLog("ImClient", "SendInstantInviteUserReportTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendInstantInviteUserReportTask::GetCmdCode() const
{
	return CMD_SENDINSTANTINVITEUSERREPORT;
}

// 设置seq
void SendInstantInviteUserReportTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendInstantInviteUserReportTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendInstantInviteUserReportTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendInstantInviteUserReportTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendInstantInviteUserReportTask::InitParam(const string& inviteId, bool isShow)
{
	bool result = false;
    if (!inviteId.empty()) {
        m_inviteId = inviteId;
        m_isShow = isShow;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void SendInstantInviteUserReportTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendInstantInviteUserReport(GetSeq(), false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}
