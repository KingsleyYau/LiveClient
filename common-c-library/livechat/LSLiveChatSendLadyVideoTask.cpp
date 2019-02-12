/*
 * author: Samson.Fan
 *   date: 2016-01-06
 *   file: LSLiveChatSendLadyVideoTask.cpp
 *   desc: 女士发送微视频Task实现类
 */

#include "LSLiveChatSendLadyVideoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/Arithmetic.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TARGETID_PARAM		"targetId"	// 对方用户Id
#define INVITEID_PARAM		"inviteId"	// 邀请Id
#define VIDEO_PARAM			"video"		// 微视频信息
#define TICKET_PARAM		"ticket"	// 票根

// video参数的分隔符
#define VIDEO_PARAM_DELIMIT	"|||"
// 是否已扣费值定义
#define CHARGET_YES			"1"			// 是
#define CHARGET_NO			"0"			// 否

LSLiveChatSendLadyVideoTask::LSLiveChatSendLadyVideoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";

	m_userId = "";
	m_inviteId = "";
	m_videoId = "";
	m_sendId = "";
	m_charget = false;
	m_videoDesc = "";
	m_ticket = 0;
}

LSLiveChatSendLadyVideoTask::~LSLiveChatSendLadyVideoTask(void)
{
}

// 初始化
bool LSLiveChatSendLadyVideoTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatSendLadyVideoTask::Handle(const LSLiveChatTransportProtocol* tp)
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
		m_listener->OnSendLadyVideo(m_errType, m_errMsg, m_ticket);
	}
	
	return result;
}
	
// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatSendLadyVideoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	
	// 构造json协议
	Json::Value root;
	root[TARGETID_PARAM] = m_userId;
	root[INVITEID_PARAM] = m_inviteId;
	root[VIDEO_PARAM] = GetVideoValue(m_videoId, m_sendId, m_charget, m_videoDesc);
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
TASK_PROTOCOL_TYPE LSLiveChatSendLadyVideoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}
	
// 获取命令号
int LSLiveChatSendLadyVideoTask::GetCmdCode()
{
	return TCMD_SENDLADYVIDEO;
}

// 设置seq
void LSLiveChatSendLadyVideoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatSendLadyVideoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatSendLadyVideoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatSendLadyVideoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool LSLiveChatSendLadyVideoTask::InitParam(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charget, const string& videoDesc, int ticket)
{
	bool result = false;
	if (!userId.empty() 
		&& !inviteId.empty()
		&& !videoId.empty()
		&& !sendId.empty()) 
	{
		m_userId = userId;
		m_inviteId = inviteId;
		m_videoId = videoId;
		m_sendId = sendId;
		m_charget = charget;
		m_ticket = ticket;

		// 微视频描述需要BASE64
		if (!videoDesc.empty()) {
			m_videoDesc = videoDesc;
		}

		result = true;
	}
	
	return result;
}

// 未完成任务的断线通知
void LSLiveChatSendLadyVideoTask::OnDisconnect()
{
	if (NULL != m_listener) {
		m_listener->OnSendLadyVideo(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", m_ticket);
	}
}

// 构建video参数值
string LSLiveChatSendLadyVideoTask::GetVideoValue(const string& videoId, const string& sendId, bool charget, const string& videoDesc)
{
	string video("");

	// [videoid]|||[0/1是否查看(是否已扣费)]|||[base64(描述)]|||[sendId]
	video += videoId;
	video += VIDEO_PARAM_DELIMIT;
	video += charget ? CHARGET_YES : CHARGET_NO;
	video += VIDEO_PARAM_DELIMIT;
	video += Arithmetic::Base64Encode(videoDesc.c_str(), videoDesc.length());
	video += VIDEO_PARAM_DELIMIT;
	video += sendId;

	return video;
}

// 解析video参数
bool LSLiveChatSendLadyVideoTask::ParsingVideoValue(const string& video, string& videoId, string& sendId, bool& charget, string& videoDesc)
{
	bool result = false;
	size_t begin = 0;
	size_t end = 0;
	int i = 0;
	
	while (string::npos != (end = video.find_first_of(VIDEO_PARAM_DELIMIT, begin)))
	{
		if (i == 0) {
			// videoId
			videoId = video.substr(begin, end - begin);
			begin = end + strlen(VIDEO_PARAM_DELIMIT);
		}
		else if (i == 1) {
			// charget
			string strCharget = video.substr(begin, end - begin);
			charget = (strCharget==CHARGET_YES ? true : false);
			begin = end + strlen(VIDEO_PARAM_DELIMIT);
		}
		else if (i == 2) {
			// videoDesc
			videoDesc = video.substr(begin, end - begin);
			const int bufferSize = 1024;
			char buffer[bufferSize] = {0};
			if (!videoDesc.empty() && videoDesc.length() < bufferSize) {
				Arithmetic::Base64Decode(videoDesc.c_str(), videoDesc.length(), buffer);
				videoDesc = buffer;
			}
			begin = end + strlen(VIDEO_PARAM_DELIMIT);

			// sendId
			sendId = video.substr(begin);
			break;
		}
		i++;
	}
	
	if (!videoId.empty() && !sendId.empty()) {
		result = true;
	}

	return result;
}
