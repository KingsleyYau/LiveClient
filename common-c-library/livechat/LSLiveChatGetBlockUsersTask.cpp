/*
 * author: Samson.Fan
 *   date: 2015-06-16
 *   file: LSLiveChatGetBlockUsersTask.cpp
 *   desc: 获取被屏蔽女士列表Task实现类
 */

#include "LSLiveChatGetBlockUsersTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

#define USERID_DELIMITED		","			// 用户ID分隔符

LSLiveChatGetBlockUsersTask::LSLiveChatGetBlockUsersTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetBlockUsersTask::~LSLiveChatGetBlockUsersTask(void)
{
}

// 初始化
bool LSLiveChatGetBlockUsersTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetBlockUsersTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = true;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";


	list<string> list;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_STRING) {
			string block = root->strValue;
			size_t pos = 0;
			do {
				size_t cur = block.find(USERID_DELIMITED, pos);
				if (cur != string::npos) {
					string temp = block.substr(pos, cur - pos);
					if (!temp.empty()) {
						list.push_back(temp);
					}
					pos = cur + 1;
				}
				else {
					string temp = block.substr(pos);
					if (!temp.empty()) {
						list.push_back(temp);
					}
					break;
				}
			} while(true);
			result = true;
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

	FileLog("LiveChatClient", "LSLiveChatGetBlockUsersTask::Handle() result:%d, list.size:%d", result, list.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetBlockUsers(m_errType, m_errMsg, list);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetBlockUsersTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	// 没有参数
	dataLen = 0;
	return true;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatGetBlockUsersTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetBlockUsersTask::GetCmdCode()
{
	return TCMD_GETBLOCKUSERS;
}

// 设置seq
void LSLiveChatGetBlockUsersTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetBlockUsersTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetBlockUsersTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetBlockUsersTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatGetBlockUsersTask::OnDisconnect()
{
	if (NULL != m_listener) {
		list<string> tmp;
		m_listener->OnGetBlockUsers(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", tmp);
	}
}
