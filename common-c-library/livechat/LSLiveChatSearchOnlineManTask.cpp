/*
 * author: Samson.Fan
 *   date: 2015-08-03
 *   file: LSLiveChatSearchOnlineManTask.cpp
 *   desc: 搜索在线男士Task实现类
 */

#include "LSLiveChatSearchOnlineManTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define BEGIN_AGE_PARAM		"beginAge"	// 起始年龄
#define END_AGE_PARAM		"endAge"		// 结束年龄
#define USERID_DELIMITED	","					// 用户ID分隔符

LSLiveChatSearchOnlineManTask::LSLiveChatSearchOnlineManTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_beginAge = 0;
	m_endAge = 100;
}

LSLiveChatSearchOnlineManTask::~LSLiveChatSearchOnlineManTask(void)
{
}

// 初始化
bool LSLiveChatSearchOnlineManTask::Init(ILSLiveChatClientListener* listener)
{
	bool result = false;
	if (NULL != listener)
	{
		m_listener = listener;
		result = true;
	}
	return result;
}

// 初始化变量
bool LSLiveChatSearchOnlineManTask::InitParam(int beginAge, int endAge)
{
    m_beginAge = beginAge;
    m_endAge = endAge;
    return true;
}

// 处理已接收数据
bool LSLiveChatSearchOnlineManTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = true;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";

	list<string> list;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_STRING) {
			string block = root->strValue;
			size_t pos = 0;
			do {
				size_t cur = block.find(USERID_DELIMITED, pos);
				if (cur != string::npos) {
					string temp = block.substr(pos, cur - pos);
					if (!temp.empty()) {
						list.push_back(temp);
					}
					pos = cur + 1;
				}
				else {
					string temp = block.substr(pos);
					if (!temp.empty()) {
						list.push_back(temp);
					}
					break;
				}
			} while(true);
			result = true;
		}
		else {
			result = false;
		}

		// 解析失败协议
		int errType = 0;
		string errMsg = "";
		if (GetAMFProtocolError(root, errType, errMsg)) {
			m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
			m_errMsg = errMsg;
		}
		else {
			result = false;
		}
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatSearchOnlineManTask::Handle() listener:%p, result:%d, errType:%d, errMsg:%s, list.size:%d"
			, m_listener, result, m_errType, m_errMsg.c_str(), list.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSearchOnlineMan(m_errType, m_errMsg, list);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSearchOnlineManTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
    bool result = false;

	// 构造json协议
	Json::Value root;
	root[BEGIN_AGE_PARAM] = m_beginAge;
	root[END_AGE_PARAM] = m_endAge;
	Json::FastWriter writer;
	string json = writer.write(root);

	// 填入buffer
	if (json.length() < dataSize) {
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result  = true;
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatSearchOnlineManTask::GetSendData() result:%d, json:%s", result, json.c_str());

	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatSearchOnlineManTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatSearchOnlineManTask::GetCmdCode()
{
	return TCMD_SEARCHONLINEMAN;
}

// 设置seq
void LSLiveChatSearchOnlineManTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSearchOnlineManTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSearchOnlineManTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatSearchOnlineManTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatSearchOnlineManTask::OnDisconnect()
{
	if (NULL != m_listener) {
		list<string> tmp;
		m_listener->OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", tmp);
	}
}
