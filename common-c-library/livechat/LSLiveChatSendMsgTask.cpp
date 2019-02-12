/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatSendMsgTask.cpp
 *   desc: 发送聊天消息Task实现类
 */

#include "LSLiveChatSendMsgTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TARGETID_PARAM		"targetId"	// 对方用户Id
#define MESSAGE_PARAM		"msg"		// 聊天消息
#define ILLEGAL_PARAM		"illegal"	// 是否合法
#define TICKET_PARAM		"ticket"	// 票根
#define INVITETYPE_PARAM    "type" // 消息类型 0：livechar 1:camshare

LSLiveChatSendMsgTask::LSLiveChatSendMsgTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_illegal = false;
	m_message = "";
	m_ticket = 0;
}

LSLiveChatSendMsgTask::~LSLiveChatSendMsgTask(void)
{
}

// 初始化
bool LSLiveChatSendMsgTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendMsgTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		if (root->type == DT_TRUE || root->type == DT_FALSE) {
			m_errType = (root->type==DT_TRUE ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL);
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
		m_listener->OnSendTextMessage(m_userId, m_message, m_ticket, m_errType, m_errMsg);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendMsgTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[MESSAGE_PARAM] = m_message;
	root[ILLEGAL_PARAM] = m_illegal;
	root[TICKET_PARAM] = m_ticket;

	// 打log
	FileLog("LiveChatClient", "LSLiveChatSendMsgTask::GetSendData() m_inviteType:%d", m_inviteType);

    root[INVITETYPE_PARAM] = m_inviteType;
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
TASK_PROTOCOL_TYPE LSLiveChatSendMsgTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendMsgTask::GetCmdCode()
{
	return TCMD_SENDMSG;	
}

// 设置seq
void LSLiveChatSendMsgTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendMsgTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendMsgTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatSendMsgTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendMsgTask::InitParam(const string& userId, const string& message, bool illegal, int ticket, INVITE_TYPE inviteType)
{
	// 打log
	FileLog("LiveChatClient", "LSLiveChatSendMsgTask::InitParam() inviteType:%d", inviteType);

	bool result = false;
	if (!userId.empty() 
		&& !message.empty()) 
	{
		m_userId = userId;
		m_message = message;
		m_illegal = illegal;
		m_ticket = ticket;
		if(inviteType != INVITE_TYPE_UNKNOW){
			m_inviteType = inviteType;
		}else{
			m_inviteType = INVITE_TYPE_CHAT;
		}
		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendMsgTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendTextMessage(m_userId, m_message, m_ticket, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}
