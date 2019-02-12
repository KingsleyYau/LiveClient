/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: LSLiveChatAmfPublicParse.h
 *   desc: AMF协议的公共解析函数
 */

#pragma once

#include <amf/AmfParser.h>
#include <string>

using namespace std;

// 公共协议定义
#define AMF_ERROR_MSG	"_errorMsg"		// 错误描述
#define AMF_ERROR_OK	"_ok"			// 错误code

inline bool GetAMFProtocolError(const amf_object_handle& root, int& errCode, string& errMsg)
{
	bool result = false;
	if (!root.isnull() 
		&& DT_OBJECT == root->type) 
	{
		amf_object_handle objErrCode = root->get_child(AMF_ERROR_OK);
		if (!objErrCode.isnull() 
			&& DT_INTEGER == objErrCode->type) 
		{
			errCode = objErrCode->intValue;
			result = true;
		}

		amf_object_handle objErrMsg = root->get_child(AMF_ERROR_MSG);
		if (!objErrMsg.isnull()
			&& DT_STRING == objErrMsg->type) 
		{
			errMsg = objErrMsg->strValue;
		}
	}
	return result;
}
