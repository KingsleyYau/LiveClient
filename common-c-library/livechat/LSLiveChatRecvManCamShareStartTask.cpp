/*
 * author: Alex shum
 *   date: 2016-10-28
 *   file: LSLiveChatRecvManCamShareStartTask.cpp
 *   desc: Cam聊天开始通知（仅女士端） Task实现类
 */

#include "LSLiveChatRecvManCamShareStartTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/CommonFunc.h>

// 返回参数定义
// Cam聊天参与男士Id
#define MANID_PARAM	  "manId"
// Cam聊天参与女士Id
#define WOMANID_PARAM	  "womanId"
// Cam邀请Id
#define INVITEID_PARAM      "inviteId"

LSLiveChatRecvManCamShareStartTask::LSLiveChatRecvManCamShareStartTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_manId = "";
	m_womanId = "";
	m_inviteId = "";
}

LSLiveChatRecvManCamShareStartTask::~LSLiveChatRecvManCamShareStartTask(void)
{
}

// 初始化
bool LSLiveChatRecvManCamShareStartTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvManCamShareStartTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull())
	{
		if(root->type == DT_OBJECT)
		{
			// manId
			amf_object_handle manIdObject = root->get_child(MANID_PARAM);
			result = !manIdObject.isnull() && manIdObject->type == DT_STRING;
			if (result) {
				m_manId = manIdObject->strValue;
			}

			// womanId
			amf_object_handle womanIdObject = root->get_child(WOMANID_PARAM);
			result = !womanIdObject.isnull() && womanIdObject->type == DT_STRING;
			if (result) {
				m_womanId = womanIdObject->strValue;
			}

			// inviteId
			amf_object_handle inviteIdObject = root->get_child(INVITEID_PARAM);
			result = !inviteIdObject.isnull() && inviteIdObject->type == DT_STRING;
			if (result) {
				m_inviteId = inviteIdObject->strValue;
			}
		}
			if (!result){
				int errType = 0;
				string errMsg = "";
				if (GetAMFProtocolError(root, errType, errMsg)) {
					m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
					m_errMsg = errMsg;
					// 解析成功
					result = true;
				}
			}
	}
	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvManCamShareStart(m_manId, m_womanId, m_inviteId);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvManCamShareStartTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvManCamShareStartTask::GetSendDataProtocolType()
{
	return AMF_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvManCamShareStartTask::GetCmdCode()
{
	return TCMD_RECVMANCAMSHARESTART;
}

// 设置seq
void LSLiveChatRecvManCamShareStartTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvManCamShareStartTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvManCamShareStartTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvManCamShareStartTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvManCamShareStartTask::OnDisconnect()
{
	// 不用回调
}
