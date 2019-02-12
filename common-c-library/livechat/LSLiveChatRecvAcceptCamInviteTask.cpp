/*
 * author: Alex shum
 *   date: 2016-10-28
 *   file: LSLiveChatRecvAcceptCamInviteTask.cpp
 *   desc: 女士应邀通知（仅男士端） Task实现类
 */

#include "LSLiveChatRecvAcceptCamInviteTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>
#include <common/CommonFunc.h>

// 返回参数定义
// 消息发送者
#define FROM_PARAM	  "from"
// 消息接收者
#define TO_PARAM	  "to"
// 消息详情
#define MSG_PARAM      "msg"
// Cam是否打开（布尔）
#define CAM_PARAM	   "cam"


LSLiveChatRecvAcceptCamInviteTask::LSLiveChatRecvAcceptCamInviteTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_from = "";
	m_to = "";
    m_inviteType = CamshareLadyInviteType_UnKnow;
    m_sessionId = -1;
    m_fromName = "";
	m_cam = false;
}

LSLiveChatRecvAcceptCamInviteTask::~LSLiveChatRecvAcceptCamInviteTask(void)
{
}

// 初始化
bool LSLiveChatRecvAcceptCamInviteTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvAcceptCamInviteTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull())
	{
		if(root->type == DT_OBJECT)
		{

			// from
			amf_object_handle fromObject = root->get_child(FROM_PARAM);
			result = !fromObject.isnull() && fromObject->type == DT_STRING;
			if (result) {
				m_from = fromObject->strValue;
			}

			// to
			amf_object_handle toObject = root->get_child(TO_PARAM);
			result = !toObject.isnull() && toObject->type == DT_STRING;
			if (result) {
				m_to = toObject->strValue;
			}

			// msg
			amf_object_handle msgObject = root->get_child(MSG_PARAM);
			result = !msgObject.isnull() && msgObject->type == DT_STRING;
			if (result) {
               
                Json::Value root;
                Json::Reader reader;
                if( reader.parse(msgObject->strValue, root) ) {
                    if( root[CamshareInviteTypeKey].isInt() ) {
                        int type = root[CamshareInviteTypeKey].asInt();
                        if( type < CamshareLadyInviteType_Count && type > CamshareLadyInviteType_UnKnow ) {
                            m_inviteType = (CamshareLadyInviteType)type;
                        }
                    }
                    
                    if( root[CamshareInviteTypeSessionIdKey].isInt() ) {
                        m_sessionId = root[CamshareInviteTypeSessionIdKey].asInt();
                    }
                    
                    if( root[CamshareInviteTypeFromNameKey].isString() ) {
                        m_fromName = root[CamshareInviteTypeFromNameKey].asString();
                    }
                }

			}

			// cam
			amf_object_handle camObject = root->get_child(CAM_PARAM);
			result = !camObject.isnull() && (camObject->type == DT_TRUE || camObject->type == DT_FALSE);
			if (result) {
				m_cam = camObject->boolValue;
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
		m_listener->OnRecvAcceptCamInvite(m_from, m_to, m_inviteType, m_sessionId, m_fromName, m_cam);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvAcceptCamInviteTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvAcceptCamInviteTask::GetSendDataProtocolType()
{
	return AMF_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvAcceptCamInviteTask::GetCmdCode()
{
	return TCMD_RECVACCEPTCAMINVITE;
}

// 设置seq
void LSLiveChatRecvAcceptCamInviteTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvAcceptCamInviteTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvAcceptCamInviteTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvAcceptCamInviteTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvAcceptCamInviteTask::OnDisconnect()
{
	// 不用回调
}
