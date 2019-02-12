/*
 * author: Alex shum
 *   date: 2016-08-24
 *   file: LSLiveChatRecvLadyAutoInviteTask.h
 *   desc: 女士自动邀请消息通知Task实现类（仅女士端）
 */

#include "LSLiveChatRecvLadyAutoInviteTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/CommonFunc.h>

// 请求参数定义
#define WOMANID_PARAM		"womanId"		// 女士Id
#define MANID_PARAM			"manId"			// 男士Id
#define MSGID_PARAM			"msgId"			// 消息内容
#define INVITEID_PARAM		"inviteId"	    // 邀请ID

LSLiveChatRecvLadyAutoInviteTask::LSLiveChatRecvLadyAutoInviteTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_womanId = "";
	m_manId = "";
	m_msg = "";
	m_inviteId = "";

}

LSLiveChatRecvLadyAutoInviteTask::~LSLiveChatRecvLadyAutoInviteTask(void)
{
}

// 初始化
bool LSLiveChatRecvLadyAutoInviteTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvLadyAutoInviteTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_OBJECT)
	{
		// womanId
		amf_object_handle womanIdObject = root->get_child(WOMANID_PARAM);
		result = !womanIdObject.isnull() && womanIdObject->type == DT_STRING;
		if (result) {
			m_womanId = womanIdObject->strValue;
		}

		// manId
		amf_object_handle manIdObject = root->get_child(MANID_PARAM);
		result = !manIdObject.isnull() && manIdObject->type == DT_STRING;
		if (result) {
			m_manId = manIdObject->strValue;
		}

		//m_msg
		amf_object_handle msgObject = root->get_child(MSGID_PARAM);
		result = !msgObject.isnull() && msgObject->type == DT_STRING;
		if (result) {
			m_msg = msgObject->strValue;
		}

		// inviteId
		amf_object_handle inviteIdObject = root->get_child(INVITEID_PARAM);
		result = !inviteIdObject.isnull() && inviteIdObject->type == DT_STRING;
		if (result) {
			m_inviteId = inviteIdObject->strValue;
		}

	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvAutoInviteNotify(m_womanId, m_manId, m_msg,m_inviteId);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvLadyAutoInviteTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvLadyAutoInviteTask::GetSendDataProtocolType()
{
	return AMF_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvLadyAutoInviteTask::GetCmdCode()
{
	return TCMD_RECVLADYAUTOINVITE;
}

// 设置seq
void LSLiveChatRecvLadyAutoInviteTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvLadyAutoInviteTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvLadyAutoInviteTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvLadyAutoInviteTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvLadyAutoInviteTask::OnDisconnect()
{
	// 不用回调
}
