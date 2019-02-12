/*
 * author: Samson.Fan
 *   date: 2015-11-20
 *   file: LSLiveChatSendLadyPhotoTask.cpp
 *   desc: 女士发送图片Task实现类
 */

#include "LSLiveChatSendLadyPhotoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/Arithmetic.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TARGETID_PARAM		"targetId"	// 对方用户Id
#define INVITEID_PARAM		"inviteId"	// 邀请Id
#define IMG_PARAM			"img"		// 图片信息
#define TICKET_PARAM		"ticket"	// 票根

// img参数的分隔符
#define IMG_PARAM_DELIMIT	"|||"		
// 是否已扣费值定义
#define CHARGET_YES			"1"			// 是
#define CHARGET_NO			"0"			// 否

LSLiveChatSendLadyPhotoTask::LSLiveChatSendLadyPhotoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_inviteId = "";
	m_photoId = "";
	m_sendId = "";
	m_charget = false;
	m_photoDesc = "";
	m_ticket = 0;
}

LSLiveChatSendLadyPhotoTask::~LSLiveChatSendLadyPhotoTask(void)
{
}

// 初始化
bool LSLiveChatSendLadyPhotoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendLadyPhotoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
		
	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
		// 解析成功协议
		if (root->type == DT_TRUE) {
			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			m_errMsg = "";
			result = true;
		}

		// 解析失败协议
		if (!result) {
			int errType = 0;
			string errMsg = "";
			if (GetAMFProtocolError(root, errType, errMsg)) {
				m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
				m_errMsg = errMsg;
				result = true;
			}
		}
	}

	// 协议解析失败
	if (!result) {
		m_errType = LSLIVECHAT_LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnSendLadyPhoto(m_errType, m_errMsg, m_ticket);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendLadyPhotoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[INVITEID_PARAM] = m_inviteId;
	root[IMG_PARAM] = GetImgValue(m_photoId, m_sendId, m_charget, m_photoDesc);
	root[TICKET_PARAM] = m_ticket;
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
TASK_PROTOCOL_TYPE LSLiveChatSendLadyPhotoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendLadyPhotoTask::GetCmdCode()
{
	return TCMD_SENDLADYPHOTO;
}

// 设置seq
void LSLiveChatSendLadyPhotoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendLadyPhotoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendLadyPhotoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatSendLadyPhotoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendLadyPhotoTask::InitParam(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket)
{
	bool result = false;
	if (!userId.empty() 
		&& !inviteId.empty()
		&& !photoId.empty()
		&& !sendId.empty()) 
	{
		m_userId = userId;
		m_inviteId = inviteId;
		m_photoId = photoId;
		m_sendId = sendId;
		m_charget = charget;
		m_ticket = ticket;

		// 图片描述需要BASE64
		if (!photoDesc.empty()) {
			m_photoDesc = photoDesc;
		}

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendLadyPhotoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendLadyPhoto(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", m_ticket);
	}
}

// 构建img参数值
string LSLiveChatSendLadyPhotoTask::GetImgValue(const string& photoId, const string& sendId, bool charget, const string& photoDesc)
{
	string img("");

	// [photoid]|||[0/1是否查看(是否已扣费)]|||[base64(描述)]|||[sendId]
	img += photoId;
	img += IMG_PARAM_DELIMIT;
	img += charget ? CHARGET_YES : CHARGET_NO;
	img += IMG_PARAM_DELIMIT;
	img += Arithmetic::Base64Encode(photoDesc.c_str(), photoDesc.length());
	img += IMG_PARAM_DELIMIT;
	img += sendId;

	return img;
}

// 解析img参数
bool LSLiveChatSendLadyPhotoTask::ParsingImgValue(const string& img, string& photoId, string& sendId, bool& charget, string& photoDesc)
{
	bool result = false;
	size_t begin = 0;
	size_t end = 0;
	int i = 0;
	
	while (string::npos != (end = img.find_first_of(IMG_PARAM_DELIMIT, begin)))
	{
		if (i == 0) {
			// photoId
			photoId = img.substr(begin, end - begin);
			begin = end + strlen(IMG_PARAM_DELIMIT);
		}
		else if (i == 1) {
			// charget
			string strCharget = img.substr(begin, end - begin);
			charget = (strCharget==CHARGET_YES ? true : false);
			begin = end + strlen(IMG_PARAM_DELIMIT);
		}
		else if (i == 2) {
			// photoDesc
			photoDesc = img.substr(begin, end - begin);
			const int bufferSize = 1024;
			char buffer[bufferSize] = {0};
			if (!photoDesc.empty() && photoDesc.length() < bufferSize) {
				Arithmetic::Base64Decode(photoDesc.c_str(), photoDesc.length(), buffer);
				photoDesc = buffer;
			}
			begin = end + strlen(IMG_PARAM_DELIMIT);

			// sendId
			sendId = img.substr(begin);
			break;
		}
		i++;
	}
	
	if (!photoId.empty() && !sendId.empty()) {
		result = true;
	}

	return result;
}
