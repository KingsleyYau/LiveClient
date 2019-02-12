/*
 * LSLiveChatSummitAutoInviteCamFirstTask.cpp
 * author: Hunter Mun
 * date: 2017-03-24
 * desc: 提交小助手Cam优先设置到服务器
 */

#include "LSLiveChatSummitAutoInviteCamFirstTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>


LSLiveChatSummitAutoInviteCamFirstTask::LSLiveChatSummitAutoInviteCamFirstTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_camFirst = false;
}

LSLiveChatSummitAutoInviteCamFirstTask::~LSLiveChatSummitAutoInviteCamFirstTask(void)
{
}

// 初始化
bool LSLiveChatSummitAutoInviteCamFirstTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSummitAutoInviteCamFirstTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_FALSE || root->type == DT_TRUE) {
			m_errType = root->boolValue ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_CHECKVERFAIL;
			m_errMsg = "";
			result = true;
		}

		// 解析失败协议
		if (!result) {
			int errType = 0;
			string errMsg = "";
			if (GetAMFProtocolError(root, errType, errMsg)) {
				m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
				m_errMsg = errMsg;
				result = true;
			}
		}
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSummitAutoInviteCamFirst(m_errType, m_errMsg);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSummitAutoInviteCamFirstTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root;
	root = m_camFirst;
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
TASK_PROTOCOL_TYPE LSLiveChatSummitAutoInviteCamFirstTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatSummitAutoInviteCamFirstTask::GetCmdCode()
{
	return TCMD_SUMMITAUTOINVITECAMFIRST;
}

// 设置seq
void LSLiveChatSummitAutoInviteCamFirstTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSummitAutoInviteCamFirstTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSummitAutoInviteCamFirstTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatSummitAutoInviteCamFirstTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSummitAutoInviteCamFirstTask::InitParam(bool camFirst)
{
	m_camFirst = camFirst;
	return true;
}

// 未完成任务的断线通知
void LSLiveChatSummitAutoInviteCamFirstTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSummitAutoInviteCamFirst(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}
