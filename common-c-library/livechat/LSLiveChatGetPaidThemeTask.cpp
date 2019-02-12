/*
 * author: Samson.Fan
 *   date: 2016-04-25
 *   file: LSLiveChatGetPaidThemeTask.cpp
 *   desc: 获取指定男/女士已购主题包Task实现类
 */

#include "LSLiveChatGetPaidThemeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatGetPaidThemeTask::LSLiveChatGetPaidThemeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatGetPaidThemeTask::~LSLiveChatGetPaidThemeTask(void)
{
}

bool LSLiveChatGetPaidThemeTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) 
	{
		m_userId = userId;
		result = true;
	}
	return result;
}

// 初始化
bool LSLiveChatGetPaidThemeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetPaidThemeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = true;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";


	ThemeInfoList themeList;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_ARRAY) {
			for (size_t i = 0; i < root->childrens.size(); i++)
			{
				ThemeInfoItem item;
				if (ParsingThemeInfoItem(root->childrens[i], item)) {
					themeList.push_back(item);
				}
			}
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

			// 解析成功
			result = true;
		}
	}

	FileLog("LiveChatClient", "LSLiveChatGetPaidThemeTask::Handle() result:%d, list.size:%d", result, themeList.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetPaidTheme(m_userId, m_errType, m_errMsg, themeList);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetPaidThemeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
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
TASK_PROTOCOL_TYPE LSLiveChatGetPaidThemeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetPaidThemeTask::GetCmdCode()
{
	return TCMD_GETPAIDTHEME;
}

// 设置seq
void LSLiveChatGetPaidThemeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetPaidThemeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetPaidThemeTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetPaidThemeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatGetPaidThemeTask::OnDisconnect()
{
	if (NULL != m_listener) {
		ThemeInfoList themeList;
		m_listener->OnGetPaidTheme(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", themeList);
	}
}
