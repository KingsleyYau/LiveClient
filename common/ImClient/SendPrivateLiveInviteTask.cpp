/*
 * author: Alex
 *   date: 2017-08-18
 *   file: SendPrivateLiveInviteTask.cpp
 *   desc: 7.1.观众立即私密邀请 Task实现类
 */

#include "SendPrivateLiveInviteTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define USERID_PARAM                "userid"
#define LOGID_PARAM                 "log_id"
#define FORCE_PARAM                 "force"

// 返回
#define INVITATIONID_PARAM               "invitation_id"
#define TIMEOUT_PARAM                    "timeout"
//#define ROOMID_PARAM                     "roomid"


SendPrivateLiveInviteTask::SendPrivateLiveInviteTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_userId = "";
    m_logId = "";
    m_force = false;

}

SendPrivateLiveInviteTask::~SendPrivateLiveInviteTask(void)
{
}

// 初始化
bool SendPrivateLiveInviteTask::Init(IImClientListener* listener)
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
bool SendPrivateLiveInviteTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "SendPrivateLiveInviteTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    string invitationId = "";
    int    timeOut = 0;
    string roomId = "";
    IMInviteErrItem item;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[INVITATIONID_PARAM].isString()) {
            invitationId = tp.m_data[INVITATIONID_PARAM].asString();
        }
        if (tp.m_data[TIMEOUT_PARAM].isIntegral()) {
            timeOut = tp.m_data[TIMEOUT_PARAM].asInt();
        }
        if (tp.m_data[ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (m_errType != LCC_ERR_SUCCESS) {
            if (tp.m_errData.isObject()) {
                item.Parse(tp.m_errData);
            }
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "SendPrivateLiveInviteTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendPrivateLiveInvite(GetSeq(), success, m_errType, m_errMsg, invitationId, timeOut, roomId, item);
		FileLog("ImClient", "SendPrivateLiveInviteTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "SendPrivateLiveInviteTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendPrivateLiveInviteTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "SendPrivateLiveInviteTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[USERID_PARAM] = m_userId;
        value[LOGID_PARAM] = m_logId;
        int isForce = m_force ? 1 : 0;
        value[FORCE_PARAM] = isForce;
        data = value;
    }

    result = true;

	FileLog("ImClient", "SendPrivateLiveInviteTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendPrivateLiveInviteTask::GetCmdCode() const
{
	return CMD_SENDPRIVATELIVEINVITE;
}

// 设置seq
void SendPrivateLiveInviteTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendPrivateLiveInviteTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendPrivateLiveInviteTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendPrivateLiveInviteTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendPrivateLiveInviteTask::InitParam(const string& userId, const string& logId, bool force)
{
	bool result = false;
    if (!userId.empty()) {
        m_userId = userId;
        m_logId = logId;
        m_force = force;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void SendPrivateLiveInviteTask::OnDisconnect()
{
    if (NULL != m_listener) {
        IMInviteErrItem item;
        m_listener->OnSendPrivateLiveInvite(GetSeq(), false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, "", 0, "", item);
    }
}
