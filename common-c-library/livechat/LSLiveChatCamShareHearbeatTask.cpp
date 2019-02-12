/*
 * author: Alex.shum
 *   date: 2016-10-28
 *   file: LSLiveChatCamShareHearbeatTask.cpp
 *   desc: CamShare聊天扣费心跳Task实现类
 */

#include "LSLiveChatCamShareHearbeatTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
#include <json/json/json.h>

// CamShare 对象Id
#define TARGETID_PARAM   "targetId"
// CamShare 会话Id
#define INVITEID_PARAM   "inviteId"
LSLiveChatCamShareHearbeatTask::LSLiveChatCamShareHearbeatTask(void)
{
	m_listener = NULL;
	m_seq = 0;

	m_targetId = "";
	m_inviteId = "";
}

LSLiveChatCamShareHearbeatTask::~LSLiveChatCamShareHearbeatTask(void)
{
}

// 初始化
bool LSLiveChatCamShareHearbeatTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatCamShareHearbeatTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 没有接收数据
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatCamShareHearbeatTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_targetId;
	root[INVITEID_PARAM] = m_inviteId;
	Json::FastWriter writer;
	string json = writer.write(root);
	// 填入buffer
	if(json.length() < dataSize){
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result = true;
	}

	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatCamShareHearbeatTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatCamShareHearbeatTask::GetCmdCode()
{
	return TCMD_CAMSHAREHEARBEAT;
}

// 设置seq
void LSLiveChatCamShareHearbeatTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

	// 初始化参数
bool LSLiveChatCamShareHearbeatTask::InitParam(const string& userId, const string& inviteId)
{
		bool result = false;
	if (!userId.empty() && !inviteId.empty()) {
		m_targetId = userId;
		m_inviteId = inviteId;
		result = true;
	}
	
	return result;
}

// 获取seq
unsigned int LSLiveChatCamShareHearbeatTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatCamShareHearbeatTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatCamShareHearbeatTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	// 不用处理
}

// 未完成任务的断线通知
void LSLiveChatCamShareHearbeatTask::OnDisconnect()
{
	// 不用回调
}
