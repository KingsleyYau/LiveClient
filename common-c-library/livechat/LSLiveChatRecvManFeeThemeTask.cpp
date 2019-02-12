/*
 * author: Alex shum
 *   date: 2016-08-24
 *   file: LSLiveChatRecvManFeeThemeTask.cpp
 *   desc: 男士购买主题包Task实现类（仅女士）
 */

#include "LSLiveChatRecvManFeeThemeTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


LSLiveChatRecvManFeeThemeTask::LSLiveChatRecvManFeeThemeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatRecvManFeeThemeTask::~LSLiveChatRecvManFeeThemeTask(void)
{
}



// 初始化
bool LSLiveChatRecvManFeeThemeTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvManFeeThemeTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = false;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";


	ThemeInfoItem item;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			result = ParsingThemeInfoItem(root, item);
		}
		else {
			result = false;
		}

	}

	FileLog("LiveChatClient", "ManFeeThemeTask::Handle() result:%d", result);

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnManBuyThemeNotify(item);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvManFeeThemeTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvManFeeThemeTask::GetSendDataProtocolType()
{
	return AMF_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvManFeeThemeTask::GetCmdCode()
{
	return TCMD_RECVMANFEETHEME;
}

// 设置seq
void LSLiveChatRecvManFeeThemeTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvManFeeThemeTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvManFeeThemeTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvManFeeThemeTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvManFeeThemeTask::OnDisconnect()
{
	if (NULL != m_listener) {
		ThemeInfoItem item;
		//m_listener->OnManFeeTheme(m_userId, m_themeId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", item);
	}
}
