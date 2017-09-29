/*
 * author: Alex
 *   date: 2017-08-15
 *   file: RecvSendGiftNoticeTask.cpp
 *   desc: 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）TaskTask实现类
 */

#include "RecvSendGiftNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 接收参数定义
#define ROOMID_GIFT_PARAM           "roomid"
#define FROMID_PARAM                "fromid"
#define NICKNAME_GIFT_PARAM         "nickname"
#define GIFTID_PARAM                "giftid"
#define GIFTNAME_PARAM              "giftname"
#define GIFTNUM_PARAM               "giftnum"
#define MULTI_CLICK_PARAM           "multi_click"
#define MULTI_CLICK_START_PARAM     "multi_click_start"
#define MULTI_CLICK_END_PARAM       "multi_click_end"
#define MULTI_CLICK_ID_PARAM        "multi_click_id"


RecvSendGiftNoticeTask::RecvSendGiftNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_fromId = "";
    m_nickName = "";
    m_giftId = "";
    m_giftName = "";
    m_giftNum = 0;
    m_multi_click = false;
    m_multi_click_start = 0;
    m_multi_click_end = 0;
    m_multi_click_id = 0;
}

RecvSendGiftNoticeTask::~RecvSendGiftNoticeTask(void)
{
}

// 初始化
bool RecvSendGiftNoticeTask::Init(IImClientListener* listener)
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
bool RecvSendGiftNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "RecvSendGiftNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[ROOMID_GIFT_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_GIFT_PARAM].asString();
        }
        if (tp.m_data[FROMID_PARAM].isString()) {
            m_fromId = tp.m_data[FROMID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_PARAM].asString();
        }
        if (tp.m_data[GIFTID_PARAM].isString()) {
            m_giftId = tp.m_data[GIFTID_PARAM].asString();
        }
        if (tp.m_data[GIFTNAME_PARAM].isString()) {
        	m_giftName = tp.m_data[GIFTNAME_PARAM].asString();
        }
        if (tp.m_data[GIFTNUM_PARAM].isInt()) {
            m_giftNum = tp.m_data[GIFTNUM_PARAM].asInt();
        }
        if (tp.m_data[MULTI_CLICK_PARAM].isInt()) {
            m_multi_click = tp.m_data[MULTI_CLICK_PARAM].asInt() == 0 ? false : true;
        }
        if (tp.m_data[MULTI_CLICK_START_PARAM].isInt()) {
            m_multi_click_start = tp.m_data[MULTI_CLICK_START_PARAM].asInt();
        }
        if (tp.m_data[MULTI_CLICK_END_PARAM].isInt()) {
            m_multi_click_end = tp.m_data[MULTI_CLICK_END_PARAM].asInt();
        }
        if (tp.m_data[MULTI_CLICK_ID_PARAM].isInt()) {
            m_multi_click_id = tp.m_data[MULTI_CLICK_ID_PARAM].asInt();
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "RecvSendGiftNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvSendGiftNotice(m_roomId, m_fromId, m_nickName, m_giftId, m_giftName, m_giftNum, m_multi_click, m_multi_click_start, m_multi_click_end, m_multi_click_id);
		FileLog("LiveChatClient", "RecvSendGiftNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "RecvSendGiftNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvSendGiftNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "RecvSendGiftNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;

        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "RecvSendGiftNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvSendGiftNoticeTask::GetCmdCode() const
{
	return CMD_RECVSENDGIFTNOTICE;
}

// 设置seq
void RecvSendGiftNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvSendGiftNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvSendGiftNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvSendGiftNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

//// 初始化参数
//bool RecvSendGiftNoticeTask::InitParam(const string& roomId, const string fromId, const string nickName, const string giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end)
//{
//	bool result = false;
//    if (!roomId.empty()
//        && !fromId.empty()
//        && !nickName.empty()
//        && !giftId.empty()) {
//        m_roomId = roomId;
//        m_fromId = fromId;
//        m_nickName = nickName;
//        m_giftId = giftId;
//        m_giftNum = giftNum;
//        m_multi_click = multi_click;
//        m_multi_click_start = multi_click_start;
//        m_multi_click_end = multi_click_end;
//        
//        result = true;
//        
//    }
//
//	return result;
//}

// 未完成任务的断线通知
void RecvSendGiftNoticeTask::OnDisconnect()
{
}
