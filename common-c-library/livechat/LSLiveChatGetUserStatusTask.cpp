/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetUserStatusTask.cpp
 *   desc: 获取用户在线状态Task实现类
 */

#include "LSLiveChatGetUserStatusTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define SEX_PARAM			"sex"		// 性别
#define SEX_PARAM_FEMALE		0			// 女士
#define SEX_PARAM_MALE			1			// 男士
#define USERIDS_PARAM		"userIds"	// 用户ID（可多个）
#define USERID_DELIMITED		","			// 用户ID分隔符
// 返回参数定义
#define STATUS_PARAM		"status"	// 在线状态
#define STATUS_PARAM_OFFLINE	0			// 不在线
#define STATUS_PARAM_ONLINE		1			// 在线
#define USERID_PARAM		"userId"	// 用户Id

LSLiveChatGetUserStatusTask::LSLiveChatGetUserStatusTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetUserStatusTask::~LSLiveChatGetUserStatusTask(void)
{
}

// 初始化
bool LSLiveChatGetUserStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetUserStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	UserStatusList list;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_STRING) {
			Json::Value jsonRoot;
			Json::Reader jsonReader;
			if (jsonReader.parse(root->strValue, jsonRoot)
				&& jsonRoot.isArray()) 
			{
				FileLog("LiveChatClient", "LSLiveChatGetUserStatusTask::Handle() root->strValue:%s", root->strValue.c_str());

				UserStatusItem item;
				int arraySize = jsonRoot.size();
				int i = 0;
				for (i = 0; i < arraySize; i++) {
					item.Reset();
					Json::Value jsonItem = jsonRoot[i];
					
					if (jsonItem[STATUS_PARAM].isIntegral()) {
						item.statusType = jsonItem[STATUS_PARAM].asInt()==STATUS_PARAM_ONLINE ? USTATUS_ONLINE : USTATUS_OFFLINE_OR_HIDDEN;
					}

					if (jsonItem[USERID_PARAM].isString()) {
						item.userId = jsonItem[USERID_PARAM].asString();
					}

					if (!item.userId.empty()) {
						list.push_back(item);
					}
				}
				
				
				m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
				m_errMsg = "";
				result = true;
			}
			else {
				FileLog("LiveChatClient", "LSLiveChatGetUserStatusTask::Handle() parsing fail:%s", root->strValue.c_str());
			}
		}
		else {
			FileLog("LiveChatClient", "LSLiveChatGetUserStatusTask::Handle() root->type:%d", root->type);
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
	else {
		FileLog("LiveChatClient", "LSLiveChatGetUserStatusTask::Handle() root.isnull");
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetUserStatus(m_userIdList, m_errType, m_errMsg, list);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetUserStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造user ids
	string userIds("");
	UserIdList::iterator iter;
	for (iter = m_userIdList.begin();
		iter != m_userIdList.end();
		iter++)
	{
		if (!userIds.empty()) {
			userIds += USERID_DELIMITED;
		}
		userIds += (*iter);
	}
	
	// 构造json协议
	Json::Value root;
	root[SEX_PARAM] = m_sexType;
	root[USERIDS_PARAM] = userIds;
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
TASK_PROTOCOL_TYPE LSLiveChatGetUserStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetUserStatusTask::GetCmdCode()
{
	return TCMD_GETUSERSTATUS;	
}

// 设置seq
void LSLiveChatGetUserStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetUserStatusTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetUserStatusTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetUserStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetUserStatusTask::InitParam(USER_SEX_TYPE sexType, const UserIdList& list)
{
	bool result = false;
	if (!list.empty()) {
		m_sexType = sexType;
		m_userIdList = list;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetUserStatusTask::OnDisconnect()
{
	if (NULL != m_listener) {
		UserStatusList list;
		m_listener->OnGetUserStatus(m_userIdList, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", list);
	}
}
