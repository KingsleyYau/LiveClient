/*
 * author: Samson.Fan
 *   date: 2015-08-13
 *   file: LSLiveChatPlayVideoTask.cpp
 *   desc: 播放视频Task实现类
 */

#include "LSLiveChatPlayVideoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/Arithmetic.h>
#include <common/KLog.h>
#include "LSLiveChatRecvVideoTask.h"
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TARGETID_PARAM		"targetId"	// 对方用户Id
#define INVITEID_PARAM		"inviteId"	// 邀请Id
#define VIDEO_PARAM			"video"		// 视频信息
#define TICKET_PARAM		"ticket"	// 票根

LSLiveChatPlayVideoTask::LSLiveChatPlayVideoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_inviteId = "";
	m_videoId = "";
	m_sendId = "";
	m_charget = false;
	m_videoDesc = "";
	m_ticket = 0;
}

LSLiveChatPlayVideoTask::~LSLiveChatPlayVideoTask(void)
{
}

// 初始化
bool LSLiveChatPlayVideoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatPlayVideoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_TRUE) {
			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			m_errMsg = "";
			result = true;
		}
		else if (root->type == DT_FALSE) {
			m_errType = LSLIVECHAT_LCC_ERR_FAIL;
			m_errMsg = "";
			result = true;
			FileLog("LiveChatClient", "LSLiveChatPlayVideoTask::Handle() root->type:%d, m_errType:%d", root->type, m_errType);
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
		m_listener->OnPlayVideo(m_errType, m_errMsg, m_ticket);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatPlayVideoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[INVITEID_PARAM] = m_inviteId;
	root[VIDEO_PARAM] = LSLiveChatRecvVideoTask::GetVideoValue(m_videoId, m_sendId, m_charget, m_videoDesc);
	root[TICKET_PARAM] = m_ticket;
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
TASK_PROTOCOL_TYPE LSLiveChatPlayVideoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatPlayVideoTask::GetCmdCode()
{
	return TCMD_PLAYVIDEO;
}

// 设置seq
void LSLiveChatPlayVideoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatPlayVideoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatPlayVideoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatPlayVideoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatPlayVideoTask::InitParam(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charget, const string& videoDesc, int ticket)
{
	bool result = false;
	if (!userId.empty()
		&& !inviteId.empty()
		&& !videoId.empty()
		&& !sendId.empty())
	{
		m_userId = userId;
		m_inviteId = inviteId;
		m_videoId = videoId;
		m_sendId = sendId;
		m_charget = charget;
		m_ticket = ticket;
		m_videoDesc = videoDesc;

		result = true;
	}
	else
	{
		FileLog("LiveChatClient", "LSLiveChatPlayVideoTask::InitParam() userId:%s, inviteId:%s, videoId:%s, sendId:%s, charget:%d, ticket:%d"
				, userId.c_str(), inviteId.c_str(), videoId.c_str(), sendId.c_str(), charget, ticket);
	}

	return result;
}

// 未完成任务的断线通知
void LSLiveChatPlayVideoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnPlayVideo(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", m_ticket);
	}
}

