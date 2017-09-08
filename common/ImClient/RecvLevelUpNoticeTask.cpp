/*
 * author: Alex
 *   date: 2017-08-29
 *   file: RecvLevelUpNoticeTask.cpp
 *   desc: 9.1.观众等级升级通知 Task实现类
 */

#include "RecvLevelUpNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define LEVEL_PARAM                "level"

RecvLevelUpNoticeTask::RecvLevelUpNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvLevelUpNoticeTask::~RecvLevelUpNoticeTask(void)
{
}

// 初始化
bool RecvLevelUpNoticeTask::Init(IImClientListener* listener)
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
bool RecvLevelUpNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvLevelUpNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    int level = 0;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[LEVEL_PARAM].isIntegral()) {
            level = GetTalentStatus(tp.m_data[LEVEL_PARAM].asInt());
        }
    
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvLevelUpNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLevelUpNotice(level);
		FileLog("LiveChatClient", "RecvLevelUpNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvLevelUpNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLevelUpNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvLevelUpNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("LiveChatClient", "RecvLevelUpNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvLevelUpNoticeTask::GetCmdCode() const
{
	return CMD_RECVLEVELUPNOTICE;
}

// 设置seq
void RecvLevelUpNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvLevelUpNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvLevelUpNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvLevelUpNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvLevelUpNoticeTask::OnDisconnect()
{

}
