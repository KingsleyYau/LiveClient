/*
 * author: Alex
 *   date: 2017-08-18
 *   file: SendCancelPrivateLiveInviteTask.cpp
 *   desc: 7.2.观众取消立即私密邀请 Task实现类
 */

#include "SendCancelPrivateLiveInviteTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define INVITATIONID_PARAM                "invitation_id"

// 返回
#define ERRDATA_PARAM                 "errdata"
//#define ROOMID_PARAM                  "roomid"


SendCancelPrivateLiveInviteTask::SendCancelPrivateLiveInviteTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_invitationId = "";
    
    m_roomId = "";
}

SendCancelPrivateLiveInviteTask::~SendCancelPrivateLiveInviteTask(void)
{
}

// 初始化
bool SendCancelPrivateLiveInviteTask::Init(IImClientListener* listener)
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
bool SendCancelPrivateLiveInviteTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "SendCancelPrivateLiveInviteTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ERRDATA_PARAM].isObject()) {
            Json::Value value = tp.m_data[ERRDATA_PARAM];
            if (value[ROOMID_PARAM].isString()) {
                m_roomId = value[ROOMID_PARAM].asString();
            }
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "SendCancelPrivateLiveInviteTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendCancelPrivateLiveInvite(GetSeq(), success, m_errType, m_errMsg, m_roomId);
		FileLog("ImClient", "SendCancelPrivateLiveInviteTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "SendCancelPrivateLiveInviteTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendCancelPrivateLiveInviteTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "SendCancelPrivateLiveInviteTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[INVITATIONID_PARAM] = m_invitationId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "SendCancelPrivateLiveInviteTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendCancelPrivateLiveInviteTask::GetCmdCode() const
{
	return CMD_SENDCANCELPRIVATEINVITE;
}

// 设置seq
void SendCancelPrivateLiveInviteTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendCancelPrivateLiveInviteTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendCancelPrivateLiveInviteTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendCancelPrivateLiveInviteTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendCancelPrivateLiveInviteTask::InitParam(const string& invitationId)
{
	bool result = false;
    if (!invitationId.empty()) {
        m_invitationId = invitationId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void SendCancelPrivateLiveInviteTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendCancelPrivateLiveInvite(GetSeq(), false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, "");
    }
}
