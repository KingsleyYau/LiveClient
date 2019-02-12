/*
 * author: Samson.Fan
 *   date: 2016-04-25
 *   file: LSLiveChatPlayThemeMotionTask.cpp
 *   desc: 男/女士播放主题包动画Task实现类
 */

#include "LSLiveChatPlayThemeMotionTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define USERID_PARAM	"targetId"
#define THEMEID_PARAM	"subjectId"


LSLiveChatPlayThemeMotionTask::LSLiveChatPlayThemeMotionTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_themeId = "";
}

LSLiveChatPlayThemeMotionTask::~LSLiveChatPlayThemeMotionTask(void)
{
}

bool LSLiveChatPlayThemeMotionTask::InitParam(const string& userId, const string& themeId)
{
	bool result = false;
	if (!userId.empty()
		&& !themeId.empty()) 
	{
		m_userId = userId;
		m_themeId = themeId;
		result = true;
	}
	return result;
}

// 初始化
bool LSLiveChatPlayThemeMotionTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatPlayThemeMotionTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = false;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";

	bool success = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_TRUE
			|| root->type == DT_FALSE) 
		{
			success = (root->type == DT_TRUE);
			result = true;
		}
		else {
			// 解析失败协议
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

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "LSLiveChatPlayThemeMotionTask::Handle() result:%d, success:%d", result, success);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnPlayThemeMotion(m_userId, m_themeId, m_errType, m_errMsg, success);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatPlayThemeMotionTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[USERID_PARAM] = m_userId;
	root[THEMEID_PARAM] = m_themeId;
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
TASK_PROTOCOL_TYPE LSLiveChatPlayThemeMotionTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatPlayThemeMotionTask::GetCmdCode()
{
	return TCMD_PLAYTHEMEMOTION;
}

// 设置seq
void LSLiveChatPlayThemeMotionTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatPlayThemeMotionTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatPlayThemeMotionTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatPlayThemeMotionTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatPlayThemeMotionTask::OnDisconnect()
{
	if (NULL != m_listener) {
		ThemeInfoItem item;
		m_listener->OnPlayThemeMotion(m_userId, m_themeId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", false);
	}
}
