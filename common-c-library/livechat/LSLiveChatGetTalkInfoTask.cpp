/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetTalkInfoTask.cpp
 *   desc: 获取会话信息Task实现类
 */

#include "LSLiveChatGetTalkInfoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 发出请求

// 返回参数定义
#define CHARGET_PARAM		"charget"	// 是否已付费
#define TARGETID_PARAM		"targetId"	// 用户Id
#define CHATTIME_PARAM		"chatTime"	// 聊天时长
#define INVITEDID_PARAM		"invitedId"	// 邀请Id

LSLiveChatGetTalkInfoTask::LSLiveChatGetTalkInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetTalkInfoTask::~LSLiveChatGetTalkInfoTask(void)
{
}

// 初始化
bool LSLiveChatGetTalkInfoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetTalkInfoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	bool charget = false;
	string targetId("");
	unsigned int chatTime = 0;
	string invitedId("");
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			// 解析charget
			amf_object_handle objCharGet = root->get_child(CHARGET_PARAM);
			result = !objCharGet.isnull() && (objCharGet->type == DT_TRUE || objCharGet->type == DT_FALSE);
			if (result) {
				charget = objCharGet->type==DT_TRUE;
			}

			// 解析targetId
			amf_object_handle objTargetId = root->get_child(TARGETID_PARAM);
			result = result && !objTargetId.isnull() && objTargetId->type == DT_STRING;
			if (result) {
				targetId = objTargetId->strValue;
			}

			// 解析charTime
			amf_object_handle objChatTime = root->get_child(CHATTIME_PARAM);
			result = result && !objChatTime.isnull() && objChatTime->type == DT_INTEGER;
			if (result) {
				chatTime = objChatTime->intValue;
			}

			// 解析invitedId（可无）
			amf_object_handle objInvitedId = root->get_child(INVITEDID_PARAM);
			if (result && !objInvitedId.isnull() && objInvitedId->type == DT_STRING) {
				invitedId = objInvitedId->strValue;
			}
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

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetTalkInfo(m_userId, m_errType, m_errMsg, targetId, invitedId, charget, chatTime);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetTalkInfoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root(m_userId);
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
TASK_PROTOCOL_TYPE LSLiveChatGetTalkInfoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetTalkInfoTask::GetCmdCode()
{
	return TCMD_GETTALKINFO;	
}

// 设置seq
void LSLiveChatGetTalkInfoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetTalkInfoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetTalkInfoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetTalkInfoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetTalkInfoTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetTalkInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnGetTalkInfo(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "", "", false, 0);
	}
}
