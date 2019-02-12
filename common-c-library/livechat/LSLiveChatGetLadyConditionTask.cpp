/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatGetLadyConditionTask.cpp
 *   desc: 获取女士择偶条件Task实现类
 */

#include "LSLiveChatGetLadyConditionTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 返回参数定义
#define WOMANID_PARAM		"womanId"			// 女士ID
#define MARRIAGE_PARAM		"marriage"			// 是否判断婚姻状况
#define NEVERMARRIED_PARAM	"nevermarried"		// 是否从未结婚
#define DIVORCED_PARAM		"divorced"				// 是否离婚
#define WIDOWED_PARAM		"widowed"				// 是否丧偶
#define SEPARATED_PARAM		"separated"				// 是否分居
#define MARRIED_PARAM		"married"				// 是否已婚
#define CHILD_PARAM			"child"				// 子女状况
#define COUNTRY_PARAM		"countrylimit"		// 国籍状况
#define UNITEDSTATES_PARAM	"unitedstates"			// 是否美国国籍
#define CANADA_PARAM		"canada"				// 是否加拿大国籍
#define NEWZEALAND_PARAM	"newzealand"			// 是否新西兰国籍
#define AUSTRALIA_PARAM		"australia"				// 是否澳大利亚国籍
#define UNITEDKINGDOM_PARAM	"unitedkingdom"			// 是否英国国籍
#define GERMANY_PARAM		"germany"				// 是否德国国籍
#define OTHERCOUNTRY_PARAM	"othercountries"		// 是否其它国籍
#define STARTAGE_PARAM		"manAge1"			// 起始年龄
#define ENDAGE_PARAM		"manAge2"			// 结束年龄

// 解析LadyCondition协议（为防外部调用需要加载amf协议器，因此不放在头文件定义）
bool ParsingLadyCondition(amf_object_handle handle, LadyConditionItem& item)
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
			item.womanId = womanIdObject->strValue;
		}

		// marriage
		amf_object_handle marriageObject = handle->get_child(MARRIAGE_PARAM);
		if (!marriageObject.isnull()
			&& marriageObject->type == DT_STRING)
		{
			item.marriageCondition = (atoi(marriageObject->strValue.c_str()) != 0);
		}

		// nevermarried
		amf_object_handle neverMarriedObject = handle->get_child(NEVERMARRIED_PARAM);
		if (!neverMarriedObject.isnull()
			&& neverMarriedObject->type == DT_STRING)
		{
			item.neverMarried = (atoi(neverMarriedObject->strValue.c_str()) != 0);
		}

		// divorced
		amf_object_handle divorcedObject = handle->get_child(DIVORCED_PARAM);
		if (!divorcedObject.isnull()
			&& divorcedObject->type == DT_STRING)
		{
			item.divorced = (atoi(divorcedObject->strValue.c_str()) != 0);
		}

		// widowed
		amf_object_handle widowedObject = handle->get_child(WIDOWED_PARAM);
		if (!widowedObject.isnull()
			&& widowedObject->type == DT_STRING)
		{
			item.widowed = (atoi(widowedObject->strValue.c_str()) != 0);
		}

		// separated
		amf_object_handle separatedObject = handle->get_child(SEPARATED_PARAM);
		if (!separatedObject.isnull()
			&& separatedObject->type == DT_STRING)
		{
			item.separated = (atoi(separatedObject->strValue.c_str()) != 0);
		}

		// married
		amf_object_handle marriedObject = handle->get_child(MARRIED_PARAM);
		if (!marriedObject.isnull()
			&& marriedObject->type == DT_STRING)
		{
			item.married = (atoi(marriedObject->strValue.c_str()) != 0);
		}

		// child
		amf_object_handle childObject = handle->get_child(CHILD_PARAM);
		if (!childObject.isnull()
			&& childObject->type == DT_STRING)
		{
			int childValue = atoi(childObject->strValue.c_str());
			item.childCondition = (childValue != 0);
			if (item.childCondition) {
				item.noChild = (childValue == 1);
			}
		}

		// countrylimit
		amf_object_handle countryLimitObject = handle->get_child(COUNTRY_PARAM);
		if (!countryLimitObject.isnull()
			&& countryLimitObject->type == DT_STRING)
		{
			item.countryCondition = (atoi(countryLimitObject->strValue.c_str()) != 0);
		}

		// unitedstates
		amf_object_handle unitedstatesObject = handle->get_child(UNITEDSTATES_PARAM);
		if (!unitedstatesObject.isnull()
			&& unitedstatesObject->type == DT_STRING)
		{
			item.unitedstates = (atoi(unitedstatesObject->strValue.c_str()) != 0);
		}

		// canada
		amf_object_handle canadaObject = handle->get_child(CANADA_PARAM);
		if (!canadaObject.isnull()
			&& canadaObject->type == DT_STRING)
		{
			item.canada = (atoi(canadaObject->strValue.c_str()) != 0);
		}

		// newzealand
		amf_object_handle newzealandObject = handle->get_child(NEWZEALAND_PARAM);
		if (!newzealandObject.isnull()
			&& newzealandObject->type == DT_STRING)
		{
			item.newzealand = (atoi(newzealandObject->strValue.c_str()) != 0);
		}

		// australia
		amf_object_handle australiaObject = handle->get_child(AUSTRALIA_PARAM);
		if (!australiaObject.isnull()
			&& australiaObject->type == DT_STRING)
		{
			item.australia = (atoi(australiaObject->strValue.c_str()) != 0);
		}

		// unitedkingdom
		amf_object_handle unitedkingdomObject = handle->get_child(UNITEDKINGDOM_PARAM);
		if (!unitedkingdomObject.isnull()
			&& unitedkingdomObject->type == DT_STRING)
		{
			item.unitedkingdom = (atoi(unitedkingdomObject->strValue.c_str()) != 0);
		}

		// germany
		amf_object_handle germanyObject = handle->get_child(GERMANY_PARAM);
		if (!germanyObject.isnull()
			&& germanyObject->type == DT_STRING)
		{
			item.germany = (atoi(germanyObject->strValue.c_str()) != 0);
		}

		// othercountries
		amf_object_handle othercountryObject = handle->get_child(OTHERCOUNTRY_PARAM);
		if (!othercountryObject.isnull()
			&& othercountryObject->type == DT_STRING)
		{
			item.othercountries = (atoi(othercountryObject->strValue.c_str()) != 0);
		}

		// manAge1
		amf_object_handle manAge1Object = handle->get_child(STARTAGE_PARAM);
		if (!manAge1Object.isnull()
			&& manAge1Object->type == DT_INTEGER)
		{
			item.startAge = manAge1Object->intValue;
		}

		// manAge2
		amf_object_handle manAge2Object = handle->get_child(ENDAGE_PARAM);
		if (!manAge2Object.isnull()
			&& manAge2Object->type == DT_INTEGER)
		{
			item.endAge = manAge2Object->intValue;
		}

		// 判断是否解析成功
		if (!item.womanId.empty()) {
			result = true;
		}
	}
	return result;
}


LSLiveChatGetLadyConditionTask::LSLiveChatGetLadyConditionTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
}

LSLiveChatGetLadyConditionTask::~LSLiveChatGetLadyConditionTask(void)
{
}

// 初始化
bool LSLiveChatGetLadyConditionTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatGetLadyConditionTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;

	// callback 参数
	LadyConditionItem item;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_OBJECT) {
			result = ParsingLadyCondition(root, item);
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
		m_listener->OnGetLadyCondition(m_userId, m_errType, m_errMsg, item);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetLadyConditionTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
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
TASK_PROTOCOL_TYPE LSLiveChatGetLadyConditionTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatGetLadyConditionTask::GetCmdCode()
{
	return TCMD_GETLADYCONDITION;
}

// 设置seq
void LSLiveChatGetLadyConditionTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetLadyConditionTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetLadyConditionTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetLadyConditionTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatGetLadyConditionTask::InitParam(const string& userId)
{
	bool result = false;
	if (!userId.empty()) {
		m_userId = userId;

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatGetLadyConditionTask::OnDisconnect()
{
	if (NULL != m_listener) {
		LadyConditionItem item;
		m_listener->OnGetLadyCondition(m_userId, LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", item);
	}
}
