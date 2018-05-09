/*
 * author: Alex
 *   date: 2017-08-29
 *   file: RecvSendTalentNoticeTask.cpp
 *   desc: 8.2.接收直播间才艺点播回复通知 Task实现类
 */

#include "RecvSendTalentNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 返回
#define RECVTALENTINVITEID_PARAM          "talent_inviteid"


RecvSendTalentNoticeTask::RecvSendTalentNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    m_talentInviteId = "";
    
}

RecvSendTalentNoticeTask::~RecvSendTalentNoticeTask(void)
{
}

// 初始化
bool RecvSendTalentNoticeTask::Init(IImClientListener* listener)
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
bool RecvSendTalentNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvSendTalentNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
//    string roomId = "";
//    string talentInviteId = "";
//    string talentId = "";
//    string name = "";
//    double credit = 0.0;
//    TalentStatus status = TALENTSTATUS_UNKNOW;
    TalentReplyItem item;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        item.Parse(tp.m_data);
        m_talentInviteId = item.talentInviteId;
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvSendTalentNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvSendTalentNotice(item);
		FileLog("ImClient", "RecvSendTalentNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvSendTalentNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvSendTalentNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvSendTalentNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOT_ERRNO] = (int)m_errType;
        if (m_errType != LCC_ERR_SUCCESS) {
            value[ROOT_ERRMSG] = m_errMsg;
        }
        Json::Value valueDate;
        valueDate[RECVTALENTINVITEID_PARAM] = m_talentInviteId;
        value[ROOT_DATA] = valueDate;
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvSendTalentNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvSendTalentNoticeTask::GetCmdCode() const
{
	return CMD_RECVSENDTALENTNOTICE;
}

// 设置seq
void RecvSendTalentNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvSendTalentNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvSendTalentNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvSendTalentNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvSendTalentNoticeTask::OnDisconnect()
{

}
