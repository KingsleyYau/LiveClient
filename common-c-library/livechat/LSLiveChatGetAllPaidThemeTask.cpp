/*
 * author: Samson.Fan
 *   date: 2016-04-25
 *   file: LSLiveChatGetAllPaidThemeTask.cpp
 *   desc: 获取男/女士所有已购主题包Task实现类
 */

#include "LSLiveChatGetAllPaidThemeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLiveChatGetAllPaidThemeTask::LSLiveChatGetAllPaidThemeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetAllPaidThemeTask::~LSLiveChatGetAllPaidThemeTask(void)
{
}

// 初始化
bool LSLiveChatGetAllPaidThemeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetAllPaidThemeTask::Handle(const LSLiveChatTransportProtocol* tp)
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

	FileLog("LiveChatClient", "LSLiveChatGetAllPaidThemeTask::Handle() result:%d, list.size:%d", result, themeList.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetAllPaidTheme(m_errType, m_errMsg, themeList);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetAllPaidThemeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	// 没有参数
	dataLen = 0;
	return true;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatGetAllPaidThemeTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetAllPaidThemeTask::GetCmdCode()
{
	return TCMD_GETALLPAIDTHEME;
}

// 设置seq
void LSLiveChatGetAllPaidThemeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetAllPaidThemeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetAllPaidThemeTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetAllPaidThemeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatGetAllPaidThemeTask::OnDisconnect()
{
	if (NULL != m_listener) {
		ThemeInfoList themeList;
		m_listener->OnGetAllPaidTheme(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", themeList);
	}
}
