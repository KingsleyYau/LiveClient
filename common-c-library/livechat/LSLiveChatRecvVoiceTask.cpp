/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvVoiceTask.cpp
 *   desc: 接收语音消息Task实现类
 */

#include "LSLiveChatRecvVoiceTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>

// 请求参数定义
#define TOID_PARAM			"toId"			// 接收用户Id
#define FROMID_PARAM		"fromId"		// 发送用户Id
#define FROMNAME_PARAM		"fromUserName"	// 发送用户名称
#define INVITEID_PARAM		"inviteId"		// 邀请Id
#define CHARGE_PARAM		"charge"		// 是否已付费
#define MSGTYPE_PARAM		"msgType"		// 消息类型
#define VOICEID_PARAM		"voiceId"		// 语音Id
#define VOICEID_DELIMIT		"-"				// 语音ID分隔符

LSLiveChatRecvVoiceTask::LSLiveChatRecvVoiceTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_toId = "";
	m_fromId = "";
	m_fromName = "";
	m_inviteId = "";
	m_charge = false;
	m_msgType = TMT_UNKNOW;
	m_voiceId = "";
	m_fileType = "";
	m_timeLen = 0;
}

LSLiveChatRecvVoiceTask::~LSLiveChatRecvVoiceTask(void)
{
}

// 初始化
bool LSLiveChatRecvVoiceTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvVoiceTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_OBJECT)
	{
		// toId
		amf_object_handle toIdObject = root->get_child(TOID_PARAM);
		result = !toIdObject.isnull() && toIdObject->type == DT_STRING;
		if (result) {
			m_toId = toIdObject->strValue;
		}

		// fromId
		amf_object_handle fromIdObject = root->get_child(FROMID_PARAM);
		result = !fromIdObject.isnull() && fromIdObject->type == DT_STRING;
		if (result) {
			m_fromId = fromIdObject->strValue;
		}

		// fromName
		amf_object_handle fromNameObject = root->get_child(FROMNAME_PARAM);
		result = !fromNameObject.isnull() && fromNameObject->type == DT_STRING;
		if (result) {
			m_fromName = fromNameObject->strValue;
		}

		// inviteId
		amf_object_handle inviteIdObject = root->get_child(INVITEID_PARAM);
		result = !inviteIdObject.isnull() && inviteIdObject->type == DT_STRING;
		if (result) {
			m_inviteId = inviteIdObject->strValue;
		}

		// charge
		amf_object_handle chargeObject = root->get_child(CHARGE_PARAM);
		result = !chargeObject.isnull() && (chargeObject->type == DT_FALSE || chargeObject->type == DT_TRUE);
		if (result) {
			m_charge = chargeObject->type == DT_TRUE;
		}

		// msgType
		amf_object_handle msgTypeObject = root->get_child(MSGTYPE_PARAM);
		result = !msgTypeObject.isnull() && msgTypeObject->type == DT_INTEGER;
		if (result) {
			m_msgType = GetTalkMsgType(msgTypeObject->intValue);
		}

		// voiceId
		amf_object_handle voiceIdObject = root->get_child(VOICEID_PARAM);
		result = !voiceIdObject.isnull() && voiceIdObject->type == DT_STRING;
		if (result) {
			m_voiceId = voiceIdObject->strValue;
		}

		if (!m_voiceId.empty()) {
			char buffer[512] = {0};
			size_t invitePos = m_voiceId.find(m_inviteId);
			if (invitePos != string::npos
				&& m_voiceId.length() > m_inviteId.length() + strlen(VOICEID_DELIMIT)
				&& sizeof(buffer) > m_voiceId.length())
			{
				strcpy(buffer, m_voiceId.c_str() + invitePos + m_inviteId.length() + strlen(VOICEID_DELIMIT));
				char* pIdItem = strtok(buffer, VOICEID_DELIMIT);
				int i = 0;
				while (NULL != pIdItem)
				{
					if (i == 2) {
						m_fileType = pIdItem;
					}
					else if (i == 3) {
						m_timeLen = atoi(pIdItem);
					}
					pIdItem = strtok(NULL, VOICEID_DELIMIT);
					i++;
				}
			}
		}
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvVoice(m_toId, m_fromId, m_fromName, m_inviteId, m_charge, m_msgType, m_voiceId, m_fileType, m_timeLen);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvVoiceTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvVoiceTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvVoiceTask::GetCmdCode()
{
	return TCMD_RECVVOICE;	
}

// 设置seq
void LSLiveChatRecvVoiceTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvVoiceTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvVoiceTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvVoiceTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvVoiceTask::OnDisconnect()
{
	// 不用回调
}
