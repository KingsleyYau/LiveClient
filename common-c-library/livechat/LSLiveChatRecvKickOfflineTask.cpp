/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvKickOfflineTask.cpp
 *   desc: 接收服务器踢下线Task实现类
 */

#include "LSLiveChatRecvKickOfflineTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatRecvKickOfflineTask::LSLiveChatRecvKickOfflineTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_kickType = KOT_MAINTAIN;
}

LSLiveChatRecvKickOfflineTask::~LSLiveChatRecvKickOfflineTask(void)
{
}

// 初始化
bool LSLiveChatRecvKickOfflineTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvKickOfflineTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_INTEGER)
	{
		FileLog("LiveChatClient", "LSLiveChatRecvKickOfflineTask::Handle() kickType:%d", root->intValue);
		m_kickType = (KICK_OFFLINE_TYPE)root->intValue;
		result = true;
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvKickOffline(m_kickType);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvKickOfflineTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvKickOfflineTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvKickOfflineTask::GetCmdCode()
{
	return TCMD_RECVKICKOFFLINE;
}

// 设置seq
void LSLiveChatRecvKickOfflineTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvKickOfflineTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvKickOfflineTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvKickOfflineTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvKickOfflineTask::OnDisconnect()
{
	// 不用回调
}
