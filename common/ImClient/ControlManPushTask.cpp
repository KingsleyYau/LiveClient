/*
 * author: Alex
 *   date: 2017-08-15
 *   file: ControlManPushTask.cpp
 *   desc: 3.14.观众开始／结束视频互动Task实现类
 */

#include "ControlManPushTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define CONTROL_PARAM          "control"

// 返回
#define MANPUSHURL_PARAM       "man_push_url"

ControlManPushTask::ControlManPushTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_control = IMCONTROLTYPE_UNKNOW;
}

ControlManPushTask::~ControlManPushTask(void)
{
}

// 初始化
bool ControlManPushTask::Init(IImClientListener* listener)
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
bool ControlManPushTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "ControlManPushTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    list<string> manPushUrl;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[MANPUSHURL_PARAM].isArray()) {
            for (int i = 0; i < tp.m_data[MANPUSHURL_PARAM].size(); i++) {
                Json::Value element = tp.m_data[MANPUSHURL_PARAM].get(i, Json::Value::null);
                if (element.isString()) {
                    manPushUrl.push_back(element.asString());
                }
            }
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "ControlManPushTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnControlManPush(GetSeq(), success, m_errType, m_errMsg, manPushUrl);
		FileLog("LiveChatClient", "ControlManPushTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "ControlManPushTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ControlManPushTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "ControlManPushTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[CONTROL_PARAM] = m_control;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "ControlManPushTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ControlManPushTask::GetCmdCode() const
{
	return CMD_CONTROLMANPUSH;
}

// 设置seq
void ControlManPushTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ControlManPushTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ControlManPushTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ControlManPushTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ControlManPushTask::InitParam(const string& roomId, IMControlType control)
{
	bool result = false;
    if (!roomId.empty()
        ) {
        m_roomId = roomId;
        m_control = control;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ControlManPushTask::OnDisconnect()
{
	if (NULL != m_listener) {
        list<string> manPushUrl;
        m_listener->OnControlManPush(m_seq, false, LCC_ERR_CONNECTFAIL, "", manPushUrl);
	}
}
