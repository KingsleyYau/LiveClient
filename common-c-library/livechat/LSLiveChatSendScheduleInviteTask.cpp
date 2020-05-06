/*
 * author: Alex
 *   date: 2020-04-07
 *   file: LSLiveChatSendScheduleInviteTask.cpp
 *   desc: 直播发送预约Schedule邀请（包含发送，接受，拒绝）Task实现类
 */

#include "LSLiveChatSendScheduleInviteTask.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatSendScheduleInviteTask::LSLiveChatSendScheduleInviteTask(void)
{
	m_listener = NULL;
	
	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

}

LSLiveChatSendScheduleInviteTask::~LSLiveChatSendScheduleInviteTask(void)
{
}

// 初始化
bool LSLiveChatSendScheduleInviteTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendScheduleInviteTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
    AmfParser parser;
    amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
    if(!root.isnull()){
        if(root->type == DT_TRUE || root->type == DT_FALSE)
        {
            m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
            m_errMsg  = "";
            //m_scheduleItem.Parse(root);
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
    if(!result){
        m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    //通知listener
    if(NULL != m_listener){
        m_listener->OnSendScheduleInvite(m_errType, m_errMsg, m_scheduleItem);
    }
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendScheduleInviteTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	//Json::Value root(m_userId);
	Json::FastWriter writer;
	string json = writer.write(m_scheduleItem.PackInfo());
	
	// 填入buffer
	if (json.length() < dataSize) {
		memcpy(data, json.c_str(), json.length());
		dataLen = json.length();

		result  = true;
	}
	return result;
}
	
// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatSendScheduleInviteTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendScheduleInviteTask::GetCmdCode()
{
	return TCMD_SCHEDULE_ONE_ON_ONE;
}
	
// 设置seq
void LSLiveChatSendScheduleInviteTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendScheduleInviteTask::GetSeq()
{
	return m_seq;
}
	
// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendScheduleInviteTask::IsWaitToRespond()
{
	return true;
}
	
// 获取处理结果
void LSLiveChatSendScheduleInviteTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendScheduleInviteTask::InitParam(const LSLCScheduleInfoItem& item)
{
	bool result = false;
	if (!item.manId.empty() && !item.womanId.empty()) {
		m_scheduleItem = item;

		result = true;
	}
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendScheduleInviteTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendScheduleInvite( LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", m_scheduleItem);
	}
}

//// 任务已经发送
//void LSLiveChatSendScheduleInviteTask::OnSend() {
//    if (NULL != m_listener) {
//        m_listener->OnSendScheduleInvite(LSLIVECHAT_LCC_ERR_SUCCESS, "", m_scheduleItem);
//    }
//}
