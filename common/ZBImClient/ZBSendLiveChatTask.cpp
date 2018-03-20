/*
 * author: Alex
 *   date: 2018-03-5
 *   file: ZBSendLiveChatTask.cpp
 *   desc: 4.1.发送直播间文本消息Task实现类（观众端／主播端向直播间发送文本消息）
 */

#include "ZBSendLiveChatTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
//#define ROOMID_PARAM           "roomid"
#define SNEDLIVECHAT_NICKNAME_PARAM         "nickname"
#define MSG_PARAM              "msg"
#define AT_PARAM               "at"

ZBSendLiveChatTask::ZBSendLiveChatTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_nickName = "";
    m_Msg = "";
}

ZBSendLiveChatTask::~ZBSendLiveChatTask(void)
{
}

// 初始化
bool ZBSendLiveChatTask::Init(IZBImClientListener* listener)
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
bool ZBSendLiveChatTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBSendLiveChatTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBSendLiveChatTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBSendLiveChat(GetSeq(), result, m_errType, m_errMsg);
		FileLog("ZBImClient", "ZBSendLiveChatTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBSendLiveChatTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBSendLiveChatTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBSendLiveChatTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[ROOMID_PARAM] = m_roomId;
        value[SNEDLIVECHAT_NICKNAME_PARAM] = m_nickName;
        value[MSG_PARAM] = m_Msg;
       // value["join"] = "1";
        int i = 0;
        for (list<string>::const_iterator iter = m_at.begin(); iter != m_at.end(); iter++) {
            string item = (*iter);
            strArray[i++] = item;
        }
        if (i > 0) {
            value[AT_PARAM] = strArray;
        }
        data = value;
    }

    result = true;

	FileLog("ZBImClient", "ZBSendLiveChatTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBSendLiveChatTask::GetCmdCode() const
{
	return ZB_CMD_SENDLIVECHAT;
}

// 设置seq
void ZBSendLiveChatTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBSendLiveChatTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBSendLiveChatTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBSendLiveChatTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBSendLiveChatTask::InitParam(const string& roomId, const string& nickName, const string& msg, const list<string> at)
{
	bool result = false;
    if (!roomId.empty()
        &&!nickName.empty()
        &&!msg.empty()) {
        m_roomId = roomId;
        m_nickName = nickName;
        m_Msg = msg;
        result = true;
    }
    if (!at.empty()) {
        m_at = at;
    }
    
	return result;
}

// 未完成任务的断线通知
void ZBSendLiveChatTask::OnDisconnect()
{
	if (NULL != m_listener) {
        m_listener->OnZBSendLiveChat(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
	}
}
