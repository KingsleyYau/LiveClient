/*
 * author: Alex
 *   date: 2020-04-07
 *   file: LSLiveChatRecvScheduleInviteNoticeTask.cpp
 *   desc: 直播接收预约Schedule邀请（包含接收，接受，拒绝）Task实现类
 */

#include "LSLiveChatRecvScheduleInviteNoticeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatRecvScheduleInviteNoticeTask::LSLiveChatRecvScheduleInviteNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

}

LSLiveChatRecvScheduleInviteNoticeTask::~LSLiveChatRecvScheduleInviteNoticeTask(void)
{
}

// 初始化
bool LSLiveChatRecvScheduleInviteNoticeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvScheduleInviteNoticeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_OBJECT)
	{
        m_scheduleItem.Parse(root);
		result = true;
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvScheduleInviteNotice(m_scheduleItem);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvScheduleInviteNoticeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvScheduleInviteNoticeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvScheduleInviteNoticeTask::GetCmdCode()
{
	return TCMD_SCHEDULE_ONE_ON_ONE_UPDATE;	
}

// 设置seq
void LSLiveChatRecvScheduleInviteNoticeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvScheduleInviteNoticeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvScheduleInviteNoticeTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvScheduleInviteNoticeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvScheduleInviteNoticeTask::OnDisconnect()
{
	// 不需要回调
}
