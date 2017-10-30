/*
 * author: Alex
 *   date: 2017-08-29
 *   file: SendTalentTask.cpp
 *   desc: 8.1.发送直播间才艺点播邀请 Task实现类
 */

#include "SendTalentTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define ROOMID_PARAM                "roomid"
#define TALENTID_PARAM              "talentid"

// 返回
#define TALENTINVITEID_PARAM        "talent_inviteid"

SendTalentTask::SendTalentTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_talentId = "";
}

SendTalentTask::~SendTalentTask(void)
{
}

// 初始化
bool SendTalentTask::Init(IImClientListener* listener)
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
bool SendTalentTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "SendTalentTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    string talentInviteId = "";
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[TALENTINVITEID_PARAM].isString()) {
            talentInviteId = tp.m_data[TALENTINVITEID_PARAM].asString();
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "SendTalentTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendTalent(GetSeq(), success, m_errType, m_errMsg, talentInviteId);
		FileLog("ImClient", "SendTalentTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "SendTalentTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendTalentTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "SendTalentTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[TALENTID_PARAM] = m_talentId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "SendTalentTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendTalentTask::GetCmdCode() const
{
	return CMD_SENDTALENT;
}

// 设置seq
void SendTalentTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendTalentTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendTalentTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendTalentTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendTalentTask::InitParam(const string& roomId, const string& talentId)
{
	bool result = false;
    if (!roomId.empty()
        && !talentId.empty()) {
        m_roomId = roomId;
        m_talentId = talentId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void SendTalentTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendTalent(GetSeq(), false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, "");
    }
}
