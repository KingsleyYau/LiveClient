/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LoginTask.cpp
 *   desc: 2.1.登录Task实现类
 */

#include "LoginTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TOKEN_PARAM         "token"     // 统一身份验证标识
#define PAGENAME_PARAM      "page_name"  // socket所在的页面

LoginTask::LoginTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";

	m_token = "";
    m_pageName = PAGENAMETYPE_UNKNOW;
}

LoginTask::~LoginTask(void)
{
}

// 初始化
bool LoginTask::Init(IImClientListener* listener)
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
bool LoginTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "LoginTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    LoginReturnItem item;
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
        
        Json::FastWriter writer;
        string tmp = writer.write(tp.m_data);
        
    }

	// 协议解析失败
	if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "LoginTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnLogin(m_errType, m_errMsg, item);
		FileLog("ImClient", "LoginTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "LoginTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool LoginTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "LoginTask::GetSendData() begin");

    {
        // 构造json协议
        Json::Value value;
        value[TOKEN_PARAM] = m_token;
        value[PAGENAME_PARAM] = m_pageName;
        data = value;
    }
    result = true;

	FileLog("ImClient", "LoginTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string LoginTask::GetCmdCode() const
{
	return CMD_LOGIN;	
}

// 设置seq
void LoginTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T LoginTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LoginTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void LoginTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LoginTask::InitParam(const string& token, PageNameType pageName)
{
	bool result = false;
	if (!token.empty()
        && pageName != PAGENAMETYPE_UNKNOW)
	{
        m_token = token;
        m_pageName = pageName;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LoginTask::OnDisconnect()
{
	if (NULL != m_listener) {
        LoginReturnItem item;
		m_listener->OnLogin(LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, item);
	}
}
