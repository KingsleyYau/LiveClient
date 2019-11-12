/*
 * author: Alex
 *   date: 2019-07-10
 *   file: LSSendInviteMsgTask.cpp
 *   desc: 2.71.发送邀请语Task实现类
 */

#include "LSSendInviteMsgTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TARGETID_PARAM		"targetId"	// 对方用户Id
#define MESSAGE_PARAM		"msgId"		// 邀请语

LSSendInviteMsgTask::LSSendInviteMsgTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_message = "";
}

LSSendInviteMsgTask::~LSSendInviteMsgTask(void)
{
}

// 初始化
bool LSSendInviteMsgTask::Init(ILSLiveChatClientListener* listener)
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
bool LSSendInviteMsgTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
    string inviteId = "";
		
    AmfParser parser;
    amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
    if (!root.isnull()) {
        if (root->type == DT_STRING) {
            inviteId = root->strValue;
            m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
            m_errMsg = "";
            result = true;
        }

        // 解析失败协议
        if (!result) {
            int errType = LSLIVECHAT_LCC_ERR_FAIL;
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
        m_errType = LSLIVECHAT_LCC_ERR_FAIL;
        m_errMsg = "";
    }
    

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSendInviteMessage(m_userId, m_message, m_errType, m_errMsg, inviteId, m_userName);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSSendInviteMsgTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[MESSAGE_PARAM] = m_message;

	// 打log
    FileLog("LiveChatClient", "LSSendInviteMsgTask::GetSendData() m_userId:%s, m_message:%s", m_userId.c_str(), m_message.c_str());

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
TASK_PROTOCOL_TYPE LSSendInviteMsgTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSSendInviteMsgTask::GetCmdCode()
{
	return TCMD_SENDINVITEMSG;	
}

// 设置seq
void LSSendInviteMsgTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSSendInviteMsgTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSSendInviteMsgTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSSendInviteMsgTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSSendInviteMsgTask::InitParam(const string& userId, const string& message, const string& nickName)
{
	// 打log
    FileLog("LiveChatClient", "LSSendInviteMsgTask::InitParam() userId:%s, message:%s", userId.c_str(), message.c_str());

	bool result = false;
	if (!userId.empty() 
		&& !message.empty()) 
	{
		m_userId = userId;
		m_message = message;
        m_userName = nickName;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSSendInviteMsgTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendInviteMessage(m_userId, m_message, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "", "");
	}
}
