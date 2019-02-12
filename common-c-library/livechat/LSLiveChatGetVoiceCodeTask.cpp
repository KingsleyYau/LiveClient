/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetVoiceCodeTask.cpp
 *   desc: 获取语音发送验证码Task实现类
 */

#include "LSLiveChatGetVoiceCodeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatGetVoiceCodeTask::LSLiveChatGetVoiceCodeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatGetVoiceCodeTask::~LSLiveChatGetVoiceCodeTask(void)
{
}

// 初始化
bool LSLiveChatGetVoiceCodeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetVoiceCodeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	string voiceCode("");
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_STRING) {
			voiceCode = root->strValue;

			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			m_errMsg = "";
			result = true;
		}

		// 解析失败协议
		if (!result) {
			int errType = 0;
			string errMsg = "";
			if (GetAMFProtocolError(root, errType, errMsg)) {
				m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
				m_errMsg = errMsg;
				result = true;
			}
		}
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetVoiceCode(m_userId, m_ticket, m_errType, m_errMsg, voiceCode);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetVoiceCodeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
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
TASK_PROTOCOL_TYPE LSLiveChatGetVoiceCodeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetVoiceCodeTask::GetCmdCode()
{
	return TCMD_GETVOICECODE;
}

// 设置seq
void LSLiveChatGetVoiceCodeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetVoiceCodeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetVoiceCodeTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetVoiceCodeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetVoiceCodeTask::InitParam(const string& userId, int ticket)
{
	bool result = false;
	if (!userId.empty()) 
	{
		m_userId = userId;
		m_ticket = ticket;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetVoiceCodeTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnGetVoiceCode(m_userId, m_ticket, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "");
	}
}
