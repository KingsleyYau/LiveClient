/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvTryTalkEndTask.cpp
 *   desc: 接收试聊结束Task实现类
 */

#include "LSLiveChatRecvTryTalkEndTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatRecvTryTalkEndTask::LSLiveChatRecvTryTalkEndTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatRecvTryTalkEndTask::~LSLiveChatRecvTryTalkEndTask(void)
{
}

// 初始化
bool LSLiveChatRecvTryTalkEndTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvTryTalkEndTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_STRING)
	{
		m_userId = root->strValue;
		result = true;
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvTryTalkEnd(m_userId);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvTryTalkEndTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvTryTalkEndTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvTryTalkEndTask::GetCmdCode()
{
	return TCMD_RECVTRYEND;
}

// 设置seq
void LSLiveChatRecvTryTalkEndTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvTryTalkEndTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvTryTalkEndTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvTryTalkEndTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvTryTalkEndTask::OnDisconnect()
{
	// 不用回调
}
