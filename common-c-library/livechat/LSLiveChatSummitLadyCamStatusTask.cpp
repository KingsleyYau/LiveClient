/*
 * author: Hunter Mun
 *   date: 2017-03-02
 *   file: LSLiveChatSummitLadyCamStatusTask.cpp
 *   desc: 女士端更新Camshare服务状态到服务器
 */

#include "LSLiveChatSummitLadyCamStatusTask.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/KLog.h>

LSLiveChatSummitLadyCamStatusTask::LSLiveChatSummitLadyCamStatusTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_camsharestatus = CAMSHARE_STATUS_UNKNOW;
}

LSLiveChatSummitLadyCamStatusTask::~LSLiveChatSummitLadyCamStatusTask(void)
{
}

// 初始化
bool LSLiveChatSummitLadyCamStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSummitLadyCamStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 本命令无返回
	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSummitLadyCamStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root(m_camsharestatus);
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
TASK_PROTOCOL_TYPE LSLiveChatSummitLadyCamStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatSummitLadyCamStatusTask::GetCmdCode()
{
	return TCMD_SUMMITCLADYCAMSTATUS;
}

// 设置seq
void LSLiveChatSummitLadyCamStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSummitLadyCamStatusTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSummitLadyCamStatusTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatSummitLadyCamStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSummitLadyCamStatusTask::InitParam(CAMSHARE_STATUS_TYPE camshareStatus)
{
	m_camsharestatus = camshareStatus;
	FileLog("LiveChatClient", "LSLiveChatSummitLadyCamStatusTask::InitParam() camshareStatus:%d", m_camsharestatus);
	return true;
}

// 未完成任务的断线通知
void LSLiveChatSummitLadyCamStatusTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSummitLadyCamStatus(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}

// 任务已经发送
void LSLiveChatSummitLadyCamStatusTask::OnSend() {

}
