/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvEditMsgTask.cpp
 *   desc: 接收用户编辑聊天消息Task实现类
 */

#include "LSLiveChatRecvEditMsgTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatRecvEditMsgTask::LSLiveChatRecvEditMsgTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_fromId = "";
}

LSLiveChatRecvEditMsgTask::~LSLiveChatRecvEditMsgTask(void)
{
}

// 初始化
bool LSLiveChatRecvEditMsgTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvEditMsgTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_STRING)
	{
		m_fromId = root->strValue;
		result = true;
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvEditMsg(m_fromId);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvEditMsgTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvEditMsgTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvEditMsgTask::GetCmdCode()
{
	return TCMD_RECVEDITMSG;	
}

// 设置seq
void LSLiveChatRecvEditMsgTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvEditMsgTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvEditMsgTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvEditMsgTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvEditMsgTask::OnDisconnect()
{
	// 不需要回调
}
