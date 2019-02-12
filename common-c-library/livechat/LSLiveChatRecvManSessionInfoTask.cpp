/*
 * author: Hunter Mun
 *   date: 2017-03-02
 *   file: LSLiveChatRecvManSessionInfoTask.cpp
 *   desc: 男士加入或退出Camshare会议室更新通知
 */

#include "LSLiveChatRecvManSessionInfoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/KLog.h>

LSLiveChatRecvManSessionInfoTask::LSLiveChatRecvManSessionInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatRecvManSessionInfoTask::~LSLiveChatRecvManSessionInfoTask(void)
{
}

// 初始化
bool LSLiveChatRecvManSessionInfoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvManSessionInfoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	SessionInfoItem item;
	FileLog("LiveChatClient", "LSLiveChatRecvManSessionInfoTask::Handle() enter");
	AmfParser parser;
	amf_object_handle amfRoot = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!amfRoot.isnull()
		&& amfRoot->type == DT_OBJECT)
	{
		result = ParsingSessionInfoItem(amfRoot, item);
	}
	FileLog("LiveChatClient", "LSLiveChatRecvManSessionInfoTask::Handle() parse result: %d, listener: %p", result?1:0, m_listener);
	// 通知listener
	if (NULL != m_listener
		&& result)
	{
		m_listener->OnRecvManSessionInfo(item);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvManSessionInfoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvManSessionInfoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatRecvManSessionInfoTask::GetCmdCode()
{
	return TCMD_RECVMANSESSIONINFO;
}

// 设置seq
void LSLiveChatRecvManSessionInfoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvManSessionInfoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvManSessionInfoTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvManSessionInfoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvManSessionInfoTask::OnDisconnect()
{
	// 不用回调
}
