/*
 * author: Alex.Shum
 *   date: 2018-03-02
 *   file: ZBLoginTask.cpp
 *   desc: 2.1.登录Task实现类
 */

#include "ZBLoginTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TOKEN_PARAM         "token"     // 直播系统不同服务器的统一验证身份标识（使用《主播端http接口协议文档》的《2.1.登录（http post）》返回参数“token”）
#define PAGENAME_PARAM      "page_name"  // socket所在的页面（1：主播个人首页，2：列表页，3：主播后台，4：预约等待页，5：公开直播间页，6：私密直播间页，7：移动端）

ZBLoginTask::ZBLoginTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";

	m_token = "";
    m_pageName = ZBPAGENAMETYPE_UNKNOW;
}

ZBLoginTask::~ZBLoginTask(void)
{
}

// 初始化
bool ZBLoginTask::Init(IZBImClientListener* listener)
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
bool ZBLoginTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBLoginTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    ZBLoginReturnItem item;
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
        
        Json::FastWriter writer;
        string tmp = writer.write(tp.m_data);
        
    }

	// 协议解析失败
	if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBLoginTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnZBLogin(m_errType, m_errMsg, item);
		FileLog("ImClient", "ZBLoginTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBLoginTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBLoginTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBLoginTask::GetSendData() begin");

    {
        // 构造json协议
        Json::Value value;
        value[TOKEN_PARAM] = m_token;
        value[PAGENAME_PARAM] = m_pageName;
        data = value;
    }
    result = true;

	FileLog("ImClient", "ZBLoginTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBLoginTask::GetCmdCode() const
{
	return ZB_CMD_LOGIN;
}

// 设置seq
void ZBLoginTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBLoginTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBLoginTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBLoginTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBLoginTask::InitParam(const string& token, ZBPageNameType pageName)
{
	bool result = false;
	if (!token.empty()
        && pageName != ZBPAGENAMETYPE_UNKNOW)
	{
        m_token = token;
        m_pageName = pageName;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void ZBLoginTask::OnDisconnect()
{
	if (NULL != m_listener) {
        ZBLoginReturnItem item;
		m_listener->OnZBLogin(ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, item);
	}
}
