/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvLadyVoiceCodeTask.cpp
 *   desc: 接收女士语音验证码Task实现类
 */

#include "LSLiveChatRecvLadyVoiceCodeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatRecvLadyVoiceCodeTask::LSLiveChatRecvLadyVoiceCodeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_voiceCode = "";
}

LSLiveChatRecvLadyVoiceCodeTask::~LSLiveChatRecvLadyVoiceCodeTask(void)
{
}

// 初始化
bool LSLiveChatRecvLadyVoiceCodeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvLadyVoiceCodeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_STRING)
	{
		m_voiceCode = root->strValue;
		result = true;
	}

	// 通知listener
	if (NULL != m_listener
		&& result)
	{
		m_listener->OnRecvLadyVoiceCode(m_voiceCode);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvLadyVoiceCodeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvLadyVoiceCodeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatRecvLadyVoiceCodeTask::GetCmdCode()
{
	return TCMD_RECVLADYVOICECODE;
}

// 设置seq
void LSLiveChatRecvLadyVoiceCodeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvLadyVoiceCodeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvLadyVoiceCodeTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvLadyVoiceCodeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvLadyVoiceCodeTask::OnDisconnect()
{
	// 不需要回调
}
