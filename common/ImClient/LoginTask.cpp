/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LoginTask.cpp
 *   desc: 登录Task实现类
 */

#include "LoginTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define USERID_PARAM		"userid"	// 帐号ID
#define VERSION_PARAM		"ver"       // 客户端内部版本号
#define TOKEN_PARAM         "token"     // 统一身份验证标识

LoginTask::LoginTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";

    m_ver = 0;
	m_user = "";
	m_token = "";
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

	FileLog("LiveChatClient", "LoginTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }

	// 协议解析失败
	if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "LoginTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnLogin(m_errType, m_errMsg);
		FileLog("LiveChatClient", "LoginTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "LoginTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool LoginTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "LoginTask::GetSendData() begin");

    {
        // 构造json协议
        Json::Value value;
        value[VERSION_PARAM] = m_ver;
        value[USERID_PARAM] = m_user;
        value[TOKEN_PARAM] = m_token;
        data = value;
    }
    result = true;

	FileLog("LiveChatClient", "LoginTask::GetSendData() end, result:%d", result);

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
bool LoginTask::InitParam(int version, const string& user, const string& token)
{
	bool result = false;
	if (!user.empty() 
		&& !token.empty())
	{
        m_ver = version;
		m_user = user;
        m_token = token;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LoginTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnLogin(LCC_ERR_CONNECTFAIL, "");
	}
}
