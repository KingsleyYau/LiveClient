/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvEmotionTask.cpp
 *   desc: 接收高级表情消息Task实现类
 */

#include "LSLiveChatRecvEmotionTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TOID_PARAM			"toId"			// 接收用户Id
#define FROMID_PARAM		"fromId"	// 发送用户Id
#define FROMNAME_PARAM		"fromUserName"	// 发送用户名称
#define INVITEID_PARAM		"inviteId"		// 邀请Id
#define CHARGE_PARAM		"charge"		// 是否已付费
#define TICKET_PARAM		"ticket"		// 票根
#define MSGTYPE_PARAM		"msgType"		// 消息类型
#define EMOTIONID_PARAM		"eid"			// 高级表情Id

LSLiveChatRecvEmotionTask::LSLiveChatRecvEmotionTask(void)
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
	m_ticket = 0;
	m_msgType = TMT_UNKNOW;
	m_eId = "";
}

LSLiveChatRecvEmotionTask::~LSLiveChatRecvEmotionTask(void)
{
}

// 初始化
bool LSLiveChatRecvEmotionTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvEmotionTask::Handle(const LSLiveChatTransportProtocol* tp)
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

		// ticket
		amf_object_handle ticketObject = root->get_child(TICKET_PARAM);
		result = !ticketObject.isnull() && ticketObject->type == DT_INTEGER;
		if (result) {
			m_ticket = ticketObject->intValue;
		}

		// msgType
		amf_object_handle msgTypeObject = root->get_child(MSGTYPE_PARAM);
		result = !msgTypeObject.isnull() && msgTypeObject->type == DT_INTEGER;
		if (result) {
			m_msgType = GetTalkMsgType(msgTypeObject->intValue);
		}

		// eId
		amf_object_handle eIdObject = root->get_child(EMOTIONID_PARAM);
		result = !eIdObject.isnull() && eIdObject->type == DT_STRING;
		if (result) {
			m_eId = eIdObject->strValue;
		}
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvEmotion(m_toId, m_fromId, m_fromName, m_inviteId, m_charge, m_ticket, m_msgType, m_eId);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvEmotionTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvEmotionTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvEmotionTask::GetCmdCode()
{
	return TCMD_RECVEMOTION;	
}

// 设置seq
void LSLiveChatRecvEmotionTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvEmotionTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvEmotionTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvEmotionTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvEmotionTask::OnDisconnect()
{
	// 不用回调
}
