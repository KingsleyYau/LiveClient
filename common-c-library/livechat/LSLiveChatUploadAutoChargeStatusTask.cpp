/*
 * author: Samson.Fan
 *   date: 2015-03-31
 *   file: LSLiveChatUploadAutoChargeStatusTask.cpp
 *   desc: 上传弹出女士自动邀请消息Task实现类
 */

#include "LSLiveChatUploadAutoChargeStatusTask.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatUploadAutoChargeStatusTask::LSLiveChatUploadAutoChargeStatusTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_isCharge = false;
}

LSLiveChatUploadAutoChargeStatusTask::~LSLiveChatUploadAutoChargeStatusTask(void)
{
}

// 初始化
bool LSLiveChatUploadAutoChargeStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatUploadAutoChargeStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 本命令无返回
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatUploadAutoChargeStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root = m_isCharge;
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
TASK_PROTOCOL_TYPE LSLiveChatUploadAutoChargeStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatUploadAutoChargeStatusTask::GetCmdCode()
{
	return TCMD_UPLOADAUTOCHARGE;
}
	
// 设置seq
void LSLiveChatUploadAutoChargeStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatUploadAutoChargeStatusTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatUploadAutoChargeStatusTask::IsWaitToRespond()
{
	return false;
}
	
// 获取处理结果
void LSLiveChatUploadAutoChargeStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatUploadAutoChargeStatusTask::InitParam(bool isCharge)
{
	m_isCharge = isCharge;
	return true;
}

// 未完成任务的断线通知
void LSLiveChatUploadAutoChargeStatusTask::OnDisconnect()
{
	// 不用回调
}
