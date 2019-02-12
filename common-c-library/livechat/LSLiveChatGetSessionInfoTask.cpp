/*
 * author: Hunter.Mun
 *   date: 2016-12-6
 *   file: LSLiveChatGetSessionInfoTask.cpp
 *   desc: 获取会话信息Task实现类
 */

#include "LSLiveChatGetSessionInfoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 发出请求

// 返回参数定义
#define CHARGET_PARAM		"charget"	// 是否已付费
#define TARGETID_PARAM		"targetId"	// 用户Id
#define CHATTIME_PARAM		"chatTime"	// 聊天时长
#define INVITEDID_PARAM		"invitedId"	// 邀请Id
#define FREECHAT_PARAM      "freeChat"  //是否正在使用试聊券
#define VIDEO_PARAM         "video"     //是否存在视频
#define VIDEOTYPE_PARAM     "videoType" //视频类型
#define VIDEOTIME_PARAM     "videoTime" //视频有效期
#define FREETARGET_PARAM    "freeTarget" //是否试聊券已经绑定目标
#define FORBIT_PARAM        "forbit"   //是否禁止
#define INVITETIME_PARAM    "inviteDtime" //最后发送时间
#define CAMINVITED_PARAM    "camInvited" //是否CamShare会话

LSLiveChatGetSessionInfoTask::LSLiveChatGetSessionInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetSessionInfoTask::~LSLiveChatGetSessionInfoTask(void)
{
}

// 初始化
bool LSLiveChatGetSessionInfoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetSessionInfoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	SessionInfoItem item;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			// 解析charget
			result = ParsingSessionInfoItem(root, item);
		}

		if (!result) {
			// 解析失败协议
			int errType = 0;
			string errMsg = "";
			if (GetAMFProtocolError(root, errType, errMsg)) {
				m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
				m_errMsg = errMsg;
				result = true;
			}
		}
		else {
			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			string errMsg = "";
		}
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetSessionInfo(m_userId, m_errType, m_errMsg, item);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetSessionInfoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;

	// 构造json协议
	Json::Value root(m_userId);
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
TASK_PROTOCOL_TYPE LSLiveChatGetSessionInfoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatGetSessionInfoTask::GetCmdCode()
{
	return TCMD_GETSESSIONINFO;
}

// 设置seq
void LSLiveChatGetSessionInfoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetSessionInfoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetSessionInfoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetSessionInfoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetSessionInfoTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}

	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetSessionInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		SessionInfoItem item;
		m_listener->OnGetSessionInfo(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", item);
	}
}
