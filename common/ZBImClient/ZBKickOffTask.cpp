/*
 * author: Alex
 *   date: 2018-03-06
 *   file: ZBKickOffTask.cpp
 *   desc: 2.4.用户被挤掉线TaskTask实现类
 */

#include "ZBKickOffTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>



ZBKickOffTask::ZBKickOffTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
}

ZBKickOffTask::~ZBKickOffTask(void)
{
}

// 初始化
bool ZBKickOffTask::Init(IZBImClientListener* listener)
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
bool ZBKickOffTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBKickOffTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBKickOffTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBKickOff(m_errType, m_errMsg);
		FileLog("ZBImClient", "ZBKickOffTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBKickOffTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBKickOffTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBKickOffTask::GetSendData() begin");
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

	FileLog("ZBImClient", "ZBKickOffTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBKickOffTask::GetCmdCode() const
{
	return ZB_CMD_KICKOFF;
}

// 设置seq
void ZBKickOffTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBKickOffTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBKickOffTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBKickOffTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBKickOffTask::InitParam()
{
	bool result = false;

    result = true;
        
	return result;
}

// 未完成任务的断线通知
void ZBKickOffTask::OnDisconnect()
{
}
