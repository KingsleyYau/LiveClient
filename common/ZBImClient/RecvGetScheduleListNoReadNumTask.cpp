/*
 * author: Alex
 *   date: 2018-04-24
 *   file: RecvGetScheduleListNoReadNumTask.cpp
 *   desc: 12.1.多端获取预约邀请未读或代处理数量同步推送Task实现类
 */

#include "RecvGetScheduleListNoReadNumTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


RecvGetScheduleListNoReadNumTask::RecvGetScheduleListNoReadNumTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvGetScheduleListNoReadNumTask::~RecvGetScheduleListNoReadNumTask(void)
{
}

// 初始化
bool RecvGetScheduleListNoReadNumTask::Init(IZBImClientListener* listener)
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
bool RecvGetScheduleListNoReadNumTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    ZBIMBookingUnreadUnhandleNumItem item;
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            item.Parse(tp.m_data);
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
       m_listener->OnRecvGetScheduleListNReadNum(item);
		FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvGetScheduleListNoReadNumTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZB_ROOT_ERRNO] = (int)m_errType;
        if (m_errType != ZBLCC_ERR_SUCCESS) {
            value[ZB_ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvGetScheduleListNoReadNumTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvGetScheduleListNoReadNumTask::GetCmdCode() const
{
	return ZB_CMD_GETSCHEDULELISTNOREADNUM;
}

// 设置seq
void RecvGetScheduleListNoReadNumTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvGetScheduleListNoReadNumTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvGetScheduleListNoReadNumTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvGetScheduleListNoReadNumTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvGetScheduleListNoReadNumTask::OnDisconnect()
{

}
