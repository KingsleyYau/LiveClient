/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetUsersInfoTask.cpp
 *   desc: 获取多个用户信息Task实现类
 */

#include "LSLiveChatGetUsersInfoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

#define USERID_DELIMITED	","		// 用户ID分隔符

LSLiveChatGetUsersInfoTask::LSLiveChatGetUsersInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetUsersInfoTask::~LSLiveChatGetUsersInfoTask(void)
{
}

// 初始化
bool LSLiveChatGetUsersInfoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetUsersInfoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	UserInfoList userInfoList;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_ARRAY) {
			size_t i = 0;
			for (i = 0; i < root->childrens.size(); i++)
			{
				UserInfoItem item;
				if (ParsingUserInfoItem(root->childrens[i], item)) {
					userInfoList.push_back(item);
				}
			}
			result = true;
		}

		if (!result) {
			// 解析失败协议
			int errType = 0;
			string errMsg = "";
			if (GetAMFProtocolError(root, errType, errMsg)) {
				m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
				m_errMsg = errMsg;
				result = true;
			}
		}
		else {
			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			string errMsg = "";
		}
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatGetUsersInfoTask::Handle() listener:%p, errType:%d, errMsg:%s, userInfoList.size:%d"
			, m_listener, m_errType, m_errMsg.c_str(), userInfoList.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetUsersInfo(m_errType, m_errMsg, m_seq, m_userIdList, userInfoList);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetUsersInfoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造参数
	string param = "";
	int i;
	list<string>::const_iterator iter;
	for (i = 0, iter = m_userIdList.begin();
        iter != m_userIdList.end();
        i++, iter++)
    {
		if (!param.empty()) {
			param += USERID_DELIMITED;
		}
        param += *iter;
    }

	// 构造json协议
	Json::Value root(param);
	Json::FastWriter writer;
	string json = writer.write(root);

	// 填入buffer
	if (json.length() < dataSize) {
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result  = true;
	}

	// 打log
	FileLog("LiveChatClient", "LSLiveChatGetUsersInfoTask::GetSendData() result:%d, json:%s"
			, result, json.c_str());

	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatGetUsersInfoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatGetUsersInfoTask::GetCmdCode()
{
	return TCMD_GETUSERSINFO;
}

// 设置seq
void LSLiveChatGetUsersInfoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetUsersInfoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetUsersInfoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetUsersInfoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetUsersInfoTask::InitParam(const list<string>& userIdList)
{
	bool result = false;
	if (!userIdList.empty()) {
		m_userIdList = userIdList;

		result = true;
	}

	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetUsersInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		UserInfoList userInfoList;
		m_listener->OnGetUsersInfo(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", m_seq, m_userIdList, userInfoList);
	}
}
