/*
 * author: Alex.shum
 *   date: 2016-10-27
 *   file: GetLadyCamStatus.cpp
 *   desc: 获取女士cam状态（仅男士端） Task实现类
 */

#include "LSLiveChatGetLadyCamStatusTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/KLog.h>

// 女士ID
#define WOMANID_PARAM "womanId"

LSLiveChatGetLadyCamStatusTask::LSLiveChatGetLadyCamStatusTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatGetLadyCamStatusTask::~LSLiveChatGetLadyCamStatusTask(void)
{
}

// 初始化
bool LSLiveChatGetLadyCamStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetLadyCamStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";

	bool success = false;

	AmfParser parser;
    amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
    
    if (!root.isnull()
        && (root->type == DT_FALSE || root->type == DT_TRUE))
    {
        success = (root->type == DT_TRUE);
        m_errMsg = "";
        
        result = true;
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }

	FileLog("LiveChatClient", "LSLiveChatGetLadyCamStatusTask::Handle() result:%d, success:%d", result, success);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetLadyCamStatus(GetSeq(), m_userId, m_errType, m_errMsg, success);
	}

	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetLadyCamStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	//root[WOMANID_PARAM] = m_userId;
	root = m_userId;
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
TASK_PROTOCOL_TYPE LSLiveChatGetLadyCamStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetLadyCamStatusTask::GetCmdCode()
{
	return TCMD_GETLADYCAMSTATUS;
}
	
// 设置seq
void LSLiveChatGetLadyCamStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetLadyCamStatusTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetLadyCamStatusTask::IsWaitToRespond()
{
	return true;
}
	
// 获取处理结果
void LSLiveChatGetLadyCamStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetLadyCamStatusTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetLadyCamStatusTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnGetLadyCamStatus(GetSeq(), m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", false);
	}
}
