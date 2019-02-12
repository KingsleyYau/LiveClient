/*
 * author: Alex.shum
 *   date: 2016-10-27
 *   file: LSLiveChatSendCamShareInviteTask.cpp
 *   desc: 发送CamShare邀请 Task实现类
 */

#include "LSLiveChatSendCamShareInviteTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/KLog.h>

// CamShare对象Id
#define TARGETID_PARAM      "targetId"
// CamShare邀请信息
#define MSG_PARAM            "msg"
LSLiveChatSendCamShareInviteTask::LSLiveChatSendCamShareInviteTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_camShareMsg = "";
}

LSLiveChatSendCamShareInviteTask::~LSLiveChatSendCamShareInviteTask(void)
{
}

// 初始化
bool LSLiveChatSendCamShareInviteTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendCamShareInviteTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";

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
    
    FileLog("LiveChatClient", "LSLiveChatSendCamShareInviteTask::Handle() result:%d", result);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSendCamShareInvite(m_userId, m_errType, m_errMsg);
	}
    
	// 本命令无返回
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendCamShareInviteTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[MSG_PARAM]      = m_camShareMsg;
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
TASK_PROTOCOL_TYPE LSLiveChatSendCamShareInviteTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendCamShareInviteTask::GetCmdCode()
{
	return TCMD_SENDCAMSHAREINVITE;
}
	
// 设置seq
void LSLiveChatSendCamShareInviteTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendCamShareInviteTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendCamShareInviteTask::IsWaitToRespond()
{
	return true;
}
	
// 获取处理结果
void LSLiveChatSendCamShareInviteTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendCamShareInviteTask::InitParam(const string& userId, CamshareInviteType inviteType, int sessionId, const string& fromName)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;
        
        Json::Value root;
        root[CamshareInviteTypeKey] = inviteType;
        root[CamshareInviteTypeSessionIdKey] = sessionId;
        root[CamshareInviteTypeFromNameKey] = fromName;
        
        Json::FastWriter writer;
        string camShareMsg = writer.write(root);
        
        m_camShareMsg = camShareMsg;
        
		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendCamShareInviteTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendCamShareInvite(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}
