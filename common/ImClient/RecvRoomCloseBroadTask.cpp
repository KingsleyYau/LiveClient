/*
 * author: Alex
 *   date: 2017-05-31
 *   file: RecvRoomCloseBroadTask.cpp
 *   desc: 3.4.接收直播间关闭Task实现类（直播端收到服务器的直播间关闭通知）
 */

#include "RecvRoomCloseBroadTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define FANSNUM_PARAM          "fansnum"
#define INCOME_PARAM           "income"
#define NEWFANS_PARAM          "newfans"
#define SHARES_PARAM           "shares"
#define DURATION_PARAM         "duration"

RecvRoomCloseBroadTask::RecvRoomCloseBroadTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_fansNum = 0;
    m_income = 0;
    m_newFans = 0;
    m_shares = 0;
    m_duration = 0;
    
}

RecvRoomCloseBroadTask::~RecvRoomCloseBroadTask(void)
{
}

// 初始化
bool RecvRoomCloseBroadTask::Init(IImClientListener* listener)
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
bool RecvRoomCloseBroadTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvBroadRoomCloseTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[FANSNUM_PARAM].isInt()) {
            m_fansNum = tp.m_data[FANSNUM_PARAM].asInt();
        }
        if (tp.m_data[INCOME_PARAM].isInt()) {
            m_income = tp.m_data[INCOME_PARAM].asInt();
        }
        if (tp.m_data[NEWFANS_PARAM].isInt()) {
            m_newFans = tp.m_data[NEWFANS_PARAM].asInt();
        }
        if (tp.m_data[SHARES_PARAM].isInt()) {
            m_shares = tp.m_data[SHARES_PARAM].asInt();
        }
        if (tp.m_data[DURATION_PARAM].isInt()) {
            m_duration = tp.m_data[DURATION_PARAM].asInt();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvBroadRoomCloseTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvRoomCloseBroad(m_roomId, m_fansNum, m_income, m_newFans, m_shares, m_duration);
		FileLog("LiveChatClient", "RecvBroadRoomCloseTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvBroadRoomCloseTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvRoomCloseBroadTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvBroadRoomCloseTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[FANSNUM_PARAM] = m_fansNum;
        value[INCOME_PARAM] = m_income;
        value[NEWFANS_PARAM] = m_newFans;
        value[SHARES_PARAM] = m_shares;
        value[DURATION_PARAM] = m_duration;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvBroadRoomCloseTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvRoomCloseBroadTask::GetCmdCode() const
{
	return CMD_RECVROOMCLOSEBROAD;
}

// 设置seq
void RecvRoomCloseBroadTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvRoomCloseBroadTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvRoomCloseBroadTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvRoomCloseBroadTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool RecvRoomCloseBroadTask::InitParam(const string& roomId, int fansNum, int income, int newFans, int shares, int duration)
{
	bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        m_fansNum = fansNum;
        m_income = income;
        m_newFans = newFans;
        m_shares = shares;
        m_duration = duration;
        
        result = true;
    }


	return result;
}

// 未完成任务的断线通知
void RecvRoomCloseBroadTask::OnDisconnect()
{
//	if (NULL != m_listener) {
//        m_listener->OnRecvRoomCloseBroad(m_roomId, m_fansNum, m_income, m_newFans, m_shares, m_duration);
//	}
}
