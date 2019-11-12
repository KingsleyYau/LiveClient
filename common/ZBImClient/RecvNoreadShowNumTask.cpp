/*
 * author: Alex
 *   date: 2019-11-08
 *   file: RecvNoreadShowNumTask.cpp
 *   desc: 12.3.多端获取节目未读数同步推送Task实现类
 */

#include "RecvNoreadShowNumTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBRECVNSN_NUM_PARAM               "num"


RecvNoreadShowNumTask::RecvNoreadShowNumTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvNoreadShowNumTask::~RecvNoreadShowNumTask(void)
{
}

// 初始化
bool RecvNoreadShowNumTask::Init(IZBImClientListener* listener)
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
bool RecvNoreadShowNumTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvNoreadShowNumTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    int num = 0;
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRECVNSN_NUM_PARAM].isIntegral()) {
            num = tp.m_data[ZBRECVNSN_NUM_PARAM].asInt();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvNoreadShowNumTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
       m_listener->OnRecvNoreadShowNum(num);
		FileLog("ImClient", "RecvNoreadShowNumTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvNoreadShowNumTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvNoreadShowNumTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvNoreadShowNumTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvNoreadShowNumTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvNoreadShowNumTask::GetCmdCode() const
{
	return ZB_CMD_NOREADSHOWNUM;
}

// 设置seq
void RecvNoreadShowNumTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvNoreadShowNumTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvNoreadShowNumTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvNoreadShowNumTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvNoreadShowNumTask::OnDisconnect()
{

}
