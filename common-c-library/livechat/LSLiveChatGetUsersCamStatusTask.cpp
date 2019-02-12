/*
 * author: Alex.shum
 *   date: 2016-10-28
 *   file: LSLiveChatGetUsersCamStatusTask.cpp
 *   desc: 批量获取女士Cam状态(仅男士端) Task实现类
 */

#include "LSLiveChatGetUsersCamStatusTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define USERIDS_PARAM		"ids"	// 用户ID（可多个）
#define USERID_DELIMITED		","			// 用户ID分隔符
// 返回参数定义
#define STATUS_PARAM		"status"	// 在线状态
#define STATUS_PARAM_OFF	0			// 不在线
#define STATUS_PARAM_ON		1			// 在线
#define USERID_PARAM		"userId"	// 用户Id

LSLiveChatGetUsersCamStatusTask::LSLiveChatGetUsersCamStatusTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetUsersCamStatusTask::~LSLiveChatGetUsersCamStatusTask(void)
{
}

// 初始化
bool LSLiveChatGetUsersCamStatusTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetUsersCamStatusTask::Handle(const LSLiveChatTransportProtocol* tp)
{
    // 服务器有可能返回空，因此默认为成功
    bool result = true;
    m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
    m_errMsg = "";

	UserCamStatusList list;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
        result = false;
        
		if (root->type == DT_STRING) {
			Json::Value jsonRoot;
			Json::Reader jsonReader;
			if (jsonReader.parse(root->strValue, jsonRoot)
				&& jsonRoot.isArray()) 
			{
				FileLog("LiveChatClient", "LSLiveChatGetUsersCamStatusTask::Handle() root->strValue:%s", root->strValue.c_str());

				UserCamStatusItem item;
				int arraySize = jsonRoot.size();
				int i = 0;
				for (i = 0; i < arraySize; i++) {
					item.Reset();
					Json::Value jsonItem = jsonRoot[i];
					
					if (jsonItem[STATUS_PARAM].isIntegral()) {
						item.statusType = jsonItem[STATUS_PARAM].asInt()== STATUS_PARAM_ON ? USTATUS_CAM_ON : USTATUS_CAM_OFF;
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
				FileLog("LiveChatClient", "LSLiveChatGetUsersCamStatusTask::Handle() parsing fail:%s", root->strValue.c_str());
			}
		}
		else {
			FileLog("LiveChatClient", "LSLiveChatGetUsersCamStatusTask::Handle() root->type:%d", root->type);
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
		FileLog("LiveChatClient", "GetUserStatusTask::Handle() root.isnull");
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetUsersCamStatus(m_userIdList, m_errType, m_errMsg, list);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetUsersCamStatusTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
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
	root = userIds;
	//root[USERIDS_PARAM] = userIds;
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
TASK_PROTOCOL_TYPE LSLiveChatGetUsersCamStatusTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetUsersCamStatusTask::GetCmdCode()
{
	return TCMD_GETUSERSCAMSTATUS;	
}

// 设置seq
void LSLiveChatGetUsersCamStatusTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetUsersCamStatusTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetUsersCamStatusTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetUsersCamStatusTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetUsersCamStatusTask::InitParam(const UserIdList& list)
{
	bool result = false;
	if (!list.empty()) {
		m_userIdList = list;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetUsersCamStatusTask::OnDisconnect()
{
	if (NULL != m_listener) {
		UserCamStatusList list;
		m_listener->OnGetUsersCamStatus(m_userIdList, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", list);
	}
}
