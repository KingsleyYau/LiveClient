/*
 * author: Samson.Fan
 *   date: 2015-03-31
 *   file: LSLiveChatSetStatusTask.h
 *   desc: 设置在线状态task实现类
 */

#include "LSLiveChatSetStatusTask.h"
#include <amf/AmfParser.h>
#include <common/CommonFunc.h>
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatSetStatusTask::LSLiveChatSetStatusTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_status = USTATUS_ONLINE;
}

LSLiveChatSetStatusTask::~LSLiveChatSetStatusTask(void)
{
}

// 初始化
bool LSLiveChatSetStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSetStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& (root->type == DT_FALSE || root->type == DT_TRUE))
	{
		m_errType = root->boolValue ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL;
		m_errMsg = "";

		result = true;
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSetStatus(m_errType, m_errMsg);
	}
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSetStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root(m_status);
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
TASK_PROTOCOL_TYPE LSLiveChatSetStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSetStatusTask::GetCmdCode()
{
	return TCMD_SETSTATUS;
}
	
// 设置seq
void LSLiveChatSetStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}
	
// 获取seq
unsigned int LSLiveChatSetStatusTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSetStatusTask::IsWaitToRespond()
{
	return true;
}
	
// 获取处理结果
void LSLiveChatSetStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSetStatusTask::InitParam(USER_STATUS_TYPE status)
{
	m_status = status;
	return true;
}

// 未完成任务的断线通知
void LSLiveChatSetStatusTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSetStatus(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}
