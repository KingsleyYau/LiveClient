/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: LSLiveChatCheckVerTask.h
 *   desc: 检测版本Task实现类
 */


#include "LSLiveChatCheckVerTask.h"
#include "ILSLiveChatClient.h"
#include <amf/AmfParser.h>
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatCheckVerTask::LSLiveChatCheckVerTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_version = "";
}

LSLiveChatCheckVerTask::~LSLiveChatCheckVerTask(void)
{
    
}

// 初始化
bool LSLiveChatCheckVerTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatCheckVerTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& (root->type == DT_FALSE || root->type == DT_TRUE))
	{
		m_errType = root->boolValue ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_CHECKVERFAIL;
		m_errMsg = "";

		result = true;
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatCheckVerTask::Handle() errType:%d, errMsg:%s"
			, m_errType, m_errMsg.c_str());

	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatCheckVerTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root(m_version);
	Json::FastWriter writer;
	string json = writer.write(root);

	// 填入buffer
	if (json.length() < dataSize) {
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result  = true;
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatCheckVerTask::GetSendData() result:%d, json:%s", result, json.c_str());

	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatCheckVerTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatCheckVerTask::GetCmdCode()
{
	return TCMD_CHECKVER;	
}

// 设置seq
void LSLiveChatCheckVerTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatCheckVerTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatCheckVerTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatCheckVerTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errmsg)
{
	errType = m_errType;
	errmsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatCheckVerTask::InitParam(const string& version)
{
	if (!version.empty()) {
		m_version = version;
	}
	return !m_version.empty();
}

// 未完成任务的断线通知
void LSLiveChatCheckVerTask::OnDisconnect()
{
	// 不需要通知上层
}
