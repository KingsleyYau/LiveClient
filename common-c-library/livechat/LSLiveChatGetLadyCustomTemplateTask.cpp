/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetLadyCustomTemplateTask.cpp
 *   desc: 获取女士自定义邀请模板Task实现类
 */

#include "LSLiveChatGetLadyCustomTemplateTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 返回参数定义
#define WOMANID_PARAM		"womanId"			// 女士ID
#define CONTENTS_PARAM		"contents"			// 自定义邀请模板内容
#define FLAGS_PARAM			"flags"				// 模板是否可用标记

// 解析LadyCondition协议（为防外部调用需要加载amf协议器，因此不放在头文件定义）
bool ParsingLadyCustomTemplate(amf_object_handle handle, string& womanId, vector<string>& contents, vector<bool>& flags)
{
	bool result = false;
	if (!handle.isnull()
		&& handle->type == DT_OBJECT)
	{
		// womanId
		amf_object_handle womanIdObject = handle->get_child(WOMANID_PARAM);
		if (!womanIdObject.isnull()
			&& womanIdObject->type == DT_STRING)
		{
			womanId = womanIdObject->strValue;
		}

		// contents
		amf_object_handle contentsObject = handle->get_child(CONTENTS_PARAM);
		if (!contentsObject.isnull()
			&& contentsObject->type == DT_ARRAY)
		{
			for (int i = 0; i < contentsObject->childrens.size(); i++)
			{
				if (!contentsObject->childrens[i].isnull()
					&& contentsObject->childrens[i]->type == DT_STRING)
				{
					contents.push_back(contentsObject->childrens[i]->strValue);
				}
			}
		}

		// flags
		amf_object_handle flagsObject = handle->get_child(FLAGS_PARAM);
		if (!flagsObject.isnull()
			&& flagsObject->type == DT_ARRAY)
		{
			for (int i = 0; i < flagsObject->childrens.size(); i++)
			{
				if (!flagsObject->childrens[i].isnull()
					&& flagsObject->childrens[i]->type == DT_STRING)
				{
					bool flag = (atoi(flagsObject->childrens[i]->strValue.c_str()) == 1);
					flags.push_back(flag);
				}
			}
		}

		// 判断是否解析成功
		if (!womanId.empty()
			&& contents.size() == flags.size())
		{
			result = true;
		}
	}
	return result;
}


LSLiveChatGetLadyCustomTemplateTask::LSLiveChatGetLadyCustomTemplateTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatGetLadyCustomTemplateTask::~LSLiveChatGetLadyCustomTemplateTask(void)
{
}

// 初始化
bool LSLiveChatGetLadyCustomTemplateTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetLadyCustomTemplateTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	string womanId;
	vector<string> contents;
	vector<bool> flags;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			result = ParsingLadyCustomTemplate(root, womanId, contents, flags);
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
		m_listener->OnGetLadyCustomTemplate(m_userId, m_errType, m_errMsg, contents, flags);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetLadyCustomTemplateTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
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
TASK_PROTOCOL_TYPE LSLiveChatGetLadyCustomTemplateTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetLadyCustomTemplateTask::GetCmdCode()
{
	return TCMD_GETLADYCUSTOMTEMPLATE;
}

// 设置seq
void LSLiveChatGetLadyCustomTemplateTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetLadyCustomTemplateTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetLadyCustomTemplateTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetLadyCustomTemplateTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetLadyCustomTemplateTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetLadyCustomTemplateTask::OnDisconnect()
{
	if (NULL != m_listener) {
		vector<string> contents;
		vector<bool> flags;
		m_listener->OnGetLadyCustomTemplate(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", contents, flags);
	}
}
