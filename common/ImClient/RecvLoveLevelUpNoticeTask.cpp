/*
 * author: Alex
 *   date: 2017-08-29
 *   file: RecvLoveLevelUpNoticeTask.cpp
 *   desc: 9.2.观众亲密度升级通知 Task实现类
 */

#include "RecvLoveLevelUpNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define LOVELEVEL_PARAM                "love_level"

RecvLoveLevelUpNoticeTask::RecvLoveLevelUpNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvLoveLevelUpNoticeTask::~RecvLoveLevelUpNoticeTask(void)
{
}

// 初始化
bool RecvLoveLevelUpNoticeTask::Init(IImClientListener* listener)
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
bool RecvLoveLevelUpNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvLoveLevelUpNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    int loveLevel = 0;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[LOVELEVEL_PARAM].isIntegral()) {
            loveLevel = tp.m_data[LOVELEVEL_PARAM].asInt();
        }
    
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvLoveLevelUpNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvLoveLevelUpNotice(loveLevel);
		FileLog("ImClient", "RecvLoveLevelUpNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvLoveLevelUpNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvLoveLevelUpNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvLoveLevelUpNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvLoveLevelUpNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvLoveLevelUpNoticeTask::GetCmdCode() const
{
	return CMD_RECVLOVELEVELUPNOTICE;
}

// 设置seq
void RecvLoveLevelUpNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvLoveLevelUpNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvLoveLevelUpNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvLoveLevelUpNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvLoveLevelUpNoticeTask::OnDisconnect()
{

}
