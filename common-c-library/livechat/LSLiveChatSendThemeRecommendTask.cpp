/*
 * author: Alex shum
 *   date: 2016-08-24
 *   file: LSLiveChatSendThemeRecommendTask.cpp
 *   desc: 女士推荐男士购买主题包Task实现类（仅女士）
 */

#include "LSLiveChatSendThemeRecommendTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define MANID_PARAM			"targetId"
#define	THEMEID_PARAM		"subjectId"

LSLiveChatSendThemeRecommendTask::LSLiveChatSendThemeRecommendTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_manId = "";
	m_themeId = "";
}

LSLiveChatSendThemeRecommendTask::~LSLiveChatSendThemeRecommendTask(void)
{
}

// 初始化
bool LSLiveChatSendThemeRecommendTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendThemeRecommendTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	// 本协议没有返回
	// 通知listener
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendThemeRecommendTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[MANID_PARAM] = m_manId;
	root[THEMEID_PARAM] = m_themeId;
;
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
TASK_PROTOCOL_TYPE LSLiveChatSendThemeRecommendTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendThemeRecommendTask::GetCmdCode()
{
	return TCMD_SENDTHEMERECOMMEND;	
}

// 设置seq
void LSLiveChatSendThemeRecommendTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendThemeRecommendTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendThemeRecommendTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatSendThemeRecommendTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendThemeRecommendTask::InitParam(const string& userId, const string& themeId)
{
	bool result = false;
	if (!userId.empty() 
		&& !themeId.empty()) 
	{
		m_manId = userId;
		m_themeId = themeId;
		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendThemeRecommendTask::OnDisconnect()
{

	if (NULL != m_listener) {
		m_listener->OnRecommendThemeToMan(m_manId, m_themeId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
}
