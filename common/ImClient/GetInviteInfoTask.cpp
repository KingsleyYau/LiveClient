/*
 * author: Alex
 *   date: 2017-08-15
 *   file: ControlManPushTask.cpp
 *   desc: 3.15.获取指定立即私密邀请信息Task实现类
 */

#include "GetInviteInfoTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define INVITATIONID_PARAM           "invitation_id"


GetInviteInfoTask::GetInviteInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_invitationId = "";
}

GetInviteInfoTask::~GetInviteInfoTask(void)
{
}

// 初始化
bool GetInviteInfoTask::Init(IImClientListener* listener)
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
bool GetInviteInfoTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "GetInviteInfoTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    PrivateInviteItem item;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "GetInviteInfoTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnGetInviteInfo(GetSeq(), success, m_errType, m_errMsg, item);
		FileLog("ImClient", "GetInviteInfoTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "GetInviteInfoTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool GetInviteInfoTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "GetInviteInfoTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[INVITATIONID_PARAM] = m_invitationId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "GetInviteInfoTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string GetInviteInfoTask::GetCmdCode() const
{
	return CMD_GETINVITEINFO;
}

// 设置seq
void GetInviteInfoTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T GetInviteInfoTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool GetInviteInfoTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void GetInviteInfoTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool GetInviteInfoTask::InitParam(const string& invitationId)
{
	bool result = false;
    if (!invitationId.empty()
        ) {
        m_invitationId = invitationId;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void GetInviteInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
        PrivateInviteItem item;
        m_listener->OnGetInviteInfo(m_seq, false, LCC_ERR_CONNECTFAIL, "", item);
	}
}
