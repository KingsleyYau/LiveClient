/*
 * author: Samson.Fan
 *   date: 2015-08-03
 *   file: LSLiveChatRefreshIdentifyCodeTask.cpp
 *   desc: 刷新验证码Task实现类
 */

#include "LSLiveChatRefreshIdentifyCodeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


LSLiveChatRefreshIdentifyCodeTask::LSLiveChatRefreshIdentifyCodeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatRefreshIdentifyCodeTask::~LSLiveChatRefreshIdentifyCodeTask(void)
{
}

// 初始化
bool LSLiveChatRefreshIdentifyCodeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRefreshIdentifyCodeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 没有返回
	return true;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRefreshIdentifyCodeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	// 没有请求参数
	dataLen = 0;
	return true;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRefreshIdentifyCodeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRefreshIdentifyCodeTask::GetCmdCode()
{
	return TCMD_REFRESHIDENTIFYCODE;
}

// 设置seq
void LSLiveChatRefreshIdentifyCodeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRefreshIdentifyCodeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRefreshIdentifyCodeTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRefreshIdentifyCodeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRefreshIdentifyCodeTask::OnDisconnect()
{
	// 没有回调
}
