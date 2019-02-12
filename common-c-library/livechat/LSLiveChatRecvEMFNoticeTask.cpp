/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvEMFNoticeTask.cpp
 *   desc: 接收邮件更新通知Task实现类
 */

#include "LSLiveChatRecvEMFNoticeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define FROMID_PARAM	"from"
#define TYPE_PARAM		"type"

LSLiveChatRecvEMFNoticeTask::LSLiveChatRecvEMFNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_fromId = "";
	m_noticeType = TENT_EMF;
}

LSLiveChatRecvEMFNoticeTask::~LSLiveChatRecvEMFNoticeTask(void)
{
}

// 初始化
bool LSLiveChatRecvEMFNoticeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvEMFNoticeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_OBJECT)
	{
		// fromId
		amf_object_handle fromIdObject = root->get_child(FROMID_PARAM);
		result = !fromIdObject.isnull() && fromIdObject->type == DT_STRING;
		if (result) {
			m_fromId = fromIdObject->strValue;
		}

		// type
		amf_object_handle typeObject = root->get_child(TYPE_PARAM);
		if (!typeObject.isnull() && typeObject->type == DT_INTEGER) {
			m_noticeType = (TENT_BEGIN<=typeObject->intValue && typeObject->intValue<TENT_END 
						? (TALK_EMF_NOTICE_TYPE)typeObject->intValue : TENT_UNKNOW);
		}
		else {
			// default value
			m_noticeType = TENT_EMF;
		}
	}

	FileLog("LiveChatClient", "LSLiveChatRecvEMFNoticeTask::Handle() fromId:%s, noticeType:%d, result:%d, m_listener:%p", m_fromId.c_str(), m_noticeType, result, m_listener);

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvEMFNotice(m_fromId, m_noticeType);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvEMFNoticeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvEMFNoticeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvEMFNoticeTask::GetCmdCode()
{
	return TCMD_RECVEMFNOTICE;
}

// 设置seq
void LSLiveChatRecvEMFNoticeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvEMFNoticeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvEMFNoticeTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvEMFNoticeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvEMFNoticeTask::OnDisconnect()
{
	// 不用回调
}
