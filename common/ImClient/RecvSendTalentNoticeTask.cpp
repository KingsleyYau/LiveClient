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

// 请求参数定义
#define ROOMID_PARAM                "roomid"
#define TALENTINVITEID_PARAM        "talent_inviteid"
#define TALENTID_PARAM              "talentid"
#define NAME_PARAM                  "name"
#define CREDIT_PARAM                "credit"
#define STATUS_PARAM                "status"

RecvSendTalentNoticeTask::RecvSendTalentNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
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

	FileLog("LiveChatClient", "RecvSendTalentNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    string roomId = "";
    string talentInviteId = "";
    string talentId = "";
    string name = "";
    double credit = 0.0;
    TalentStatus status = TALENTSTATUS_UNKNOW;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[TALENTINVITEID_PARAM].isString()) {
            talentInviteId = tp.m_data[TALENTINVITEID_PARAM].asString();
        }
        if (tp.m_data[TALENTID_PARAM].isString()) {
            talentId = tp.m_data[TALENTID_PARAM].asString();
        }
        if (tp.m_data[NAME_PARAM].isString()) {
            name = tp.m_data[NAME_PARAM].asString();
        }
        if (tp.m_data[CREDIT_PARAM].isNumeric()) {
            credit = tp.m_data[CREDIT_PARAM].asDouble();
        }
        if (tp.m_data[STATUS_PARAM].isIntegral()) {
            credit = GetTalentStatus(tp.m_data[STATUS_PARAM].asInt());
        }
    
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvSendTalentNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status);
		FileLog("LiveChatClient", "RecvSendTalentNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvSendTalentNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvSendTalentNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvSendTalentNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("LiveChatClient", "RecvSendTalentNoticeTask::GetSendData() end, result:%d", result);

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
