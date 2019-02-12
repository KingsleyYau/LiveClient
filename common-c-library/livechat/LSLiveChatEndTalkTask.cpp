/*
 * author: Samson.Fan
 *   date: 2015-03-31
 *   file: LSLiveChatEndTalkTask.cpp
 *   desc: 上传设备ID Task实现类
 */

#include "LSLiveChatEndTalkTask.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatEndTalkTask::LSLiveChatEndTalkTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatEndTalkTask::~LSLiveChatEndTalkTask(void)
{
}

// 初始化
bool LSLiveChatEndTalkTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatEndTalkTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 本命令无返回	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatEndTalkTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root(m_userId);
	Json::FastWriter writer;
	string json = writer.write(root);
	
	// 填入buffer
	if (json.length() < dataSize) {
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result  = true;
	}
	return result;
}
	
// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatEndTalkTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatEndTalkTask::GetCmdCode()
{
	return TCMD_ENDTALK;
}
	
// 设置seq
void LSLiveChatEndTalkTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatEndTalkTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatEndTalkTask::IsWaitToRespond()
{
	return false;
}
	
// 获取处理结果
void LSLiveChatEndTalkTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatEndTalkTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}
	return result;
}

// 未完成任务的断线通知
void LSLiveChatEndTalkTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnEndTalk(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}

// 任务已经发送
void LSLiveChatEndTalkTask::OnSend() {
    if (NULL != m_listener) {
        m_listener->OnEndTalk(m_userId, LSLIVECHAT_LCC_ERR_SUCCESS, "");
    }
}
