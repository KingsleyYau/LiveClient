/*
 * author: Samson.Fan
 *   date: 2015-04-10
 *   file: LSLiveChatGetTalkListTask.cpp
 *   desc: 获取邀请列表或在聊列表Task实现类
 */

#include "LSLiveChatGetTalkListTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 返回参数定义
// 结构参数
#define INVITE_PARAM			"invite"			// 邀请列表
#define INVITESESSION_PARAM		"inviteSession"		// 邀请session列表
#define INVITED_PARAM			"invited"			// 被邀请列表
#define INVITEDSESSION_PARAM	"invitedSession"	// 被邀请session列表
#define CHATING_PARAM			"chating"			// 在聊列表
#define CHATINGSESSION_PARAM	"chatingSession"	// 在聊session列表
#define PAUSE_PARAM				"pause"				// 在聊已暂停列表
#define PAUSESESSION_PARAM		"pauseSession"		// 在聊已暂停session列表
// TalkSessionList参数
#define TARGETID_PARAM		"targetId"		// 聊天对象ID
#define INVITEDID_PARAM		"invitedId"		// 邀请ID
#define CHARGET_PARAM		"charget"		// 是否已付费
#define CHATTIME_PARAM		"chatTime"		// 聊天时长
#define SERVICE_TYPE        "serviceType"   // 服务类型

// 以下函数若定义为成员，外部使用Task时需要include amf解析器头文件，但外部不应知道协议使用什么解析器，因此没有定义为成员函数
// 解析TalkUserList
inline bool ParsingTalkUserList(amf_object_handle handle, TalkUserList& list);
inline bool ParsingTalkSessionList(amf_object_handle handle, TalkSessionList& list);
inline bool ParsingTalkSessionListItem(amf_object_handle handle, TalkSessionListItem& item);

LSLiveChatGetTalkListTask::LSLiveChatGetTalkListTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetTalkListTask::~LSLiveChatGetTalkListTask(void)
{
}

// 初始化
bool LSLiveChatGetTalkListTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetTalkListTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = true;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";


	TalkListInfo item;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			// invite
			amf_object_handle inviteObject = root->get_child(INVITE_PARAM);
			ParsingTalkUserList(inviteObject, item.invite);

			// inviteSession
			amf_object_handle inviteSessionObject = root->get_child(INVITESESSION_PARAM);
			ParsingTalkSessionList(inviteSessionObject, item.inviteSession);

			// invited
			amf_object_handle invitedObject = root->get_child(INVITED_PARAM);
			ParsingTalkUserList(invitedObject, item.invited);

			// invitedSession
			amf_object_handle invitedSessionObject = root->get_child(INVITEDSESSION_PARAM);
			ParsingTalkSessionList(invitedSessionObject, item.invitedSession);

			// chating
			amf_object_handle chatingObject = root->get_child(CHATING_PARAM);
			ParsingTalkUserList(chatingObject, item.chating);

			// chatingSession
			amf_object_handle chatingSessionObject = root->get_child(CHATINGSESSION_PARAM);
			ParsingTalkSessionList(chatingSessionObject, item.chatingSession);

			// pause
			amf_object_handle pauseObject = root->get_child(PAUSE_PARAM);
			ParsingTalkUserList(pauseObject, item.pause);

			// pauseSession
			amf_object_handle pauseSessionObject = root->get_child(PAUSESESSION_PARAM);
			ParsingTalkSessionList(pauseSessionObject, item.pauseSession);
		}
		else {
			result = false;
		}

		// 解析失败协议
		int errType = 0;
		string errMsg = "";
		if (GetAMFProtocolError(root, errType, errMsg)) {
			m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
			m_errMsg = errMsg;
		}
		else {
			result = false;
		}
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetTalkList(m_listType, m_errType, m_errMsg, item);
	}
	
	FileLog("LiveChatClient", "LSLiveChatGetTalkListTask::Handle() result:%d, errType:%d, errMsg:%s, listener:%p"
			, result, m_errType, m_errMsg.c_str(), m_listener);

	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetTalkListTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root(m_listType);
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
TASK_PROTOCOL_TYPE LSLiveChatGetTalkListTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetTalkListTask::GetCmdCode()
{
	return TCMD_GETTALKLIST;	
}

// 设置seq
void LSLiveChatGetTalkListTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetTalkListTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetTalkListTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetTalkListTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetTalkListTask::InitParam(unsigned int listType)
{
	bool result = false;
	m_listType = listType;
	result = true;
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetTalkListTask::OnDisconnect()
{
	if (NULL != m_listener) {
		TalkListInfo tmp;
		m_listener->OnGetTalkList(m_listType, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", tmp);
	}
}

// 解析TalkUserList
bool ParsingTalkUserList(amf_object_handle handle, TalkUserList& list)
{
	bool result = false;
	if (!handle.isnull() 
		&& handle->type == DT_ARRAY)
	{
		size_t i = 0;
		for (i = 0; i < handle->childrens.size(); i++)
		{
			TalkUserListItem item;
			if (ParsingUserInfoItem(handle->childrens[i], item)) {
				list.push_back(item);
			}
		}
		result = true;
	}
	return result;
}

// 解析TalkSessionList
bool ParsingTalkSessionList(amf_object_handle handle, TalkSessionList& list)
{
	bool result = false;
	if (!handle.isnull() 
		&& handle->type == DT_ARRAY)
	{
		size_t i = 0;
		for (i = 0; i < handle->childrens.size(); i++)
		{
			TalkSessionListItem item;
			if (ParsingTalkSessionListItem(handle->childrens[i], item)) {
				list.push_back(item);
			}
		}
		result = true;
	}
	return result;
}

// 解析TalkSessionListItem
bool ParsingTalkSessionListItem(amf_object_handle handle, TalkSessionListItem& item)
{
	bool result = false;
	if (!handle.isnull()
		&& handle->type == DT_OBJECT)
	{
		// targetId
		amf_object_handle targetIdObject = handle->get_child(TARGETID_PARAM);
		if (!targetIdObject.isnull() 
			&& targetIdObject->type == DT_STRING)
		{
			item.targetId = targetIdObject->strValue;
		}

		// invitedId
		amf_object_handle invitedIdObject = handle->get_child(INVITEDID_PARAM);
		if (!invitedIdObject.isnull() 
			&& invitedIdObject->type == DT_STRING)
		{
			item.invitedId = invitedIdObject->strValue;
		}

		// charget
		amf_object_handle chargetObject = handle->get_child(CHARGET_PARAM);
		if (!chargetObject.isnull() 
			&& (chargetObject->type == DT_FALSE
				|| chargetObject->type == DT_TRUE))
		{
			item.charget = (chargetObject->type == DT_TRUE ? true : false);
		}

		// chatTime
		amf_object_handle chatTimeObject = handle->get_child(CHATTIME_PARAM);
		if (!chatTimeObject.isnull() 
			&& chatTimeObject->type == DT_INTEGER)
		{
			item.chatTime = chatTimeObject->intValue;
		}

		// serviceType
		amf_object_handle serviceTypeObject = handle->get_child(SERVICE_TYPE);
		if (!serviceTypeObject.isnull()
			&& serviceTypeObject->type == DT_INTEGER)
		{
            int serviceType = serviceTypeObject->intValue;
            if( serviceType > TalkSessionServiceType_Unknow && serviceType < TalkSessionServiceType_Count ) {
                item.serviceType = (TalkSessionServiceType)serviceTypeObject->intValue;
            }
		}

		// 判断是否解析成功
		if (!item.targetId.empty()) {
			result = true;
		}
	}
	return result;
}
