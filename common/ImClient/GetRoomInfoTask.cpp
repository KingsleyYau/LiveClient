/*
 * author: Alex
 *   date: 2017-05-31
 *   file: GetRoomInfoTask.cpp
 *   desc: 3.6.获取直播间信息（观众端／主播端获取直播间信息）
 */

#include "GetRoomInfoTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TOKEN_PARAM            "token"
#define ROOMID_PARAM           "roomid"

// 返回
#define FANSNUM_PARAM          "fansnum"
#define CONTRIBUTE_PARAM       "contribute"

GetRoomInfoTask::GetRoomInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_token = "";
    m_roomId = "";
    
    m_fansNum = 0;
    m_contribute = 0;

}

GetRoomInfoTask::~GetRoomInfoTask(void)
{
}

// 初始化
bool GetRoomInfoTask::Init(IImClientListener* listener)
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
bool GetRoomInfoTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "GetRoomInfoTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (m_errType == LCC_ERR_SUCCESS) {
            if (tp.m_data[FANSNUM_PARAM].isInt()) {
                m_fansNum = tp.m_data[FANSNUM_PARAM].asInt();
            }
            if (tp.m_data[CONTRIBUTE_PARAM].isInt()) {
                m_contribute = tp.m_data[CONTRIBUTE_PARAM].asInt();
            }
        }

    }
    
        // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "GetRoomInfoTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnGetRoomInfo(GetSeq(), success, m_errType, m_errMsg, m_fansNum, m_contribute);
		FileLog("LiveChatClient", "GetRoomInfoTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "GetRoomInfoTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool GetRoomInfoTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "GetRoomInfoTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[TOKEN_PARAM] = m_token;
        value[ROOMID_PARAM] = m_roomId;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "GetRoomInfoTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string GetRoomInfoTask::GetCmdCode() const
{
	return CMD_GETROOMINFO;
}

// 设置seq
void GetRoomInfoTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T GetRoomInfoTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool GetRoomInfoTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void GetRoomInfoTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool GetRoomInfoTask::InitParam(const string& token, const string& roomId)
{
	bool result = false;
    if (!token.empty()
        &&!roomId.empty()) {
        m_token = token;
        m_roomId = roomId;

        result = true;
    }


	return result;
}

// 未完成任务的断线通知
void GetRoomInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
        m_listener->OnGetRoomInfo(GetSeq(), false, LCC_ERR_CONNECTFAIL, "", 0, 0);
	}
}
