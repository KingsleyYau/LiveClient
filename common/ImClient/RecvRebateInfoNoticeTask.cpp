/*
 * author: Alex
 *   date: 2017-08-14
 *   file: RecvRebateInfoNoticeTask.cpp
 *   desc: 3.6.接收返点通知（观众端接收返点通知) Task实现类
 */

#include "RecvRebateInfoNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ROOMID_PARAM           "roomid"
#define REBATEINFO_PARAM       "rebate_info"
#define REBATEINFO_CURCREDIT_PARAM  "cur_credit"
#define REBATEINFO_CURTIME_PARAM    "cur_time"
#define REBATEINFO_PRECREDIT_PARAM  "pre_credit"
#define REBATEINFO_PRETIME_PARAM    "pre_time"


RecvRebateInfoNoticeTask::RecvRebateInfoNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";

}

RecvRebateInfoNoticeTask::~RecvRebateInfoNoticeTask(void)
{
}

// 初始化
bool RecvRebateInfoNoticeTask::Init(IImClientListener* listener)
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
bool RecvRebateInfoNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvRebateInfoNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    RebateInfoItem item;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[REBATEINFO_PARAM].isObject()) {
            Json::Value permission = tp.m_data[REBATEINFO_PARAM];
            if (permission[REBATEINFO_CURCREDIT_PARAM].isNumeric()) {
                item.curCredit = permission[REBATEINFO_CURCREDIT_PARAM].asDouble();
            }
            if (permission[REBATEINFO_CURTIME_PARAM].isInt()) {
                item.curTime = permission[REBATEINFO_CURTIME_PARAM].asInt();
            }
            if (permission[REBATEINFO_PRECREDIT_PARAM].isNumeric()) {
                item.preCredit = permission[REBATEINFO_PRECREDIT_PARAM].asDouble();
            }
            if (permission[REBATEINFO_PRETIME_PARAM].isInt()) {
                item.preTime = permission[REBATEINFO_PRETIME_PARAM].asInt();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvRebateInfoNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvRebateInfoNotice(m_roomId, item);
		FileLog("ImClient", "RecvRebateInfoNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvRebateInfoNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvRebateInfoNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvLeaveRoomNoticeTask::GetSendData() begin");
    {

    }

    result = true;

	FileLog("ImClient", "RecvLeaveRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvRebateInfoNoticeTask::GetCmdCode() const
{
	return CMD_RECVREBATEINFONOTICE;
}

// 设置seq
void RecvRebateInfoNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvRebateInfoNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvRebateInfoNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvRebateInfoNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvRebateInfoNoticeTask::OnDisconnect()
{

}
