/*
 * author: Samson.Fan
 *   date: 2015-04-01
 *   file: LSLiveChatRecvAutoChargeResultTask.cpp
 *   desc: 接收自动充值状态Task实现类
 */

#include "LSLiveChatRecvAutoChargeResultTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define MANID_PARAM			"manId"			// 男士Id
#define MONEY_PARAM			"money"			// 当前余额
#define TYPE_PARAM			"type"			// 当前充值状态
#define DESC_PARAM			"desc"			// 充值完成结果描述
#define RESULT_PARAM		"result"		// 充值结果
#define CODE_PARAM			"code"			// 充值结果状态码
#define MSG_PARAM			"msg"			// 充值结果状态码描述

LSLiveChatRecvAutoChargeResultTask::LSLiveChatRecvAutoChargeResultTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_manId = "";
	m_money = 0;
	m_type = AUTO_CHARGE_START;
	m_result = false;
	m_code = "";
	m_msg = "";
}

LSLiveChatRecvAutoChargeResultTask::~LSLiveChatRecvAutoChargeResultTask(void)
{
}

// 初始化
bool LSLiveChatRecvAutoChargeResultTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvAutoChargeResultTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()
		&& root->type == DT_OBJECT)
	{
		// manId
		amf_object_handle manIdObject = root->get_child(MANID_PARAM);
		result = !manIdObject.isnull() && manIdObject->type == DT_STRING;
		if (result) {
			m_manId = manIdObject->strValue;
		}

		// money
		amf_object_handle moneyObject = root->get_child(MONEY_PARAM);
		result = !moneyObject.isnull() && moneyObject->type == DT_DOUBLE;
		if (result) {
			m_money = moneyObject->doubleValue;
		}

		// type
		amf_object_handle typeObject = root->get_child(TYPE_PARAM);
		result = !typeObject.isnull() && typeObject->type == DT_INTEGER;
		if (result) {
//			int type = atoi(typeObject->strValue.c_str());
			int type = typeObject->intValue;
			m_type = GetAutoChargeType(type);
		}

		// desc
		amf_object_handle descObject = root->get_child(DESC_PARAM);
		if (!descObject.isnull() && descObject->type == DT_STRING) {
			string desc = descObject->strValue;
			if (!desc.empty()) {
				// 解析json
				Json::Value root;
				Json::Reader reader;
				if (reader.parse(desc, root, false) && root.isObject())
				{
					// result
					Json::Value resultJson = root[RESULT_PARAM];
					if (resultJson.isInt()) {
						m_result = (resultJson.asInt() == 1);
					}

					// code
					Json::Value codeJson = root[CODE_PARAM];
					if (codeJson.isInt()) {
						m_code = codeJson.asString();
					}

					// msg
					Json::Value msgJson = root[MSG_PARAM];
					if (msgJson.isInt()) {
						m_msg = msgJson.asString();
					}
				}
			}
		}
	}

	// 通知listener
	if (NULL != m_listener 
		&& result) 
	{
		m_listener->OnRecvAutoChargeResult(m_manId, m_money, m_type, m_result, m_code, m_msg);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvAutoChargeResultTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvAutoChargeResultTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatRecvAutoChargeResultTask::GetCmdCode()
{
	return TCMD_RECVAUTOCHARGE;
}

// 设置seq
void LSLiveChatRecvAutoChargeResultTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvAutoChargeResultTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvAutoChargeResultTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvAutoChargeResultTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvAutoChargeResultTask::OnDisconnect()
{
	// 不用回调
}
