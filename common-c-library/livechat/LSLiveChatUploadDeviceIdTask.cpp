/*
 * author: Samson.Fan
 *   date: 2015-03-31
 *   file: LSLiveChatUploadDeviceIdTask.cpp
 *   desc: 上传设备ID Task实现类
 */

#include "LSLiveChatUploadDeviceIdTask.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatUploadDeviceIdTask::LSLiveChatUploadDeviceIdTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_deviceId = "";
}

LSLiveChatUploadDeviceIdTask::~LSLiveChatUploadDeviceIdTask(void)
{
}

// 初始化
bool LSLiveChatUploadDeviceIdTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatUploadDeviceIdTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 本命令无返回	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatUploadDeviceIdTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root(m_deviceId);
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
TASK_PROTOCOL_TYPE LSLiveChatUploadDeviceIdTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatUploadDeviceIdTask::GetCmdCode()
{
	return TCMD_UPLOADDEVID;
}
	
// 设置seq
void LSLiveChatUploadDeviceIdTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatUploadDeviceIdTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatUploadDeviceIdTask::IsWaitToRespond()
{
	return false;
}
	
// 获取处理结果
void LSLiveChatUploadDeviceIdTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatUploadDeviceIdTask::InitParam(const string& deviceId)
{
	bool result = false;
	if (!deviceId.empty()) {
		m_deviceId = deviceId;

		result = true;
	}
	return result;
}

// 未完成任务的断线通知
void LSLiveChatUploadDeviceIdTask::OnDisconnect() 
{
	// 不用回调
}
