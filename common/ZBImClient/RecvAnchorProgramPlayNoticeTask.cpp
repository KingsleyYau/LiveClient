/*
 * author: Alex
 *   date: 2018-04-18
 *   file: RecvAnchorProgramPlayNoticeTask.cpp
 *   desc: 11.1.节目开播通知Task实现类
 */

#include "RecvAnchorProgramPlayNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBRECVAPPN_SHOWINFO_PARAM               "show_info"
#define ZBRECVAPPN_MSG_PARAM                    "msg"


RecvAnchorProgramPlayNoticeTask::RecvAnchorProgramPlayNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorProgramPlayNoticeTask::~RecvAnchorProgramPlayNoticeTask(void)
{
}

// 初始化
bool RecvAnchorProgramPlayNoticeTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorProgramPlayNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    IMAnchorProgramInfoItem item;
    string msg = "";
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[ZBRECVAPPN_SHOWINFO_PARAM].isObject()) {
                item.Parse(tp.m_data[ZBRECVAPPN_SHOWINFO_PARAM]);
            }
            
            if (tp.m_data[ZBRECVAPPN_MSG_PARAM].isString()) {
                msg = tp.m_data[ZBRECVAPPN_MSG_PARAM].asString();
            }
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorProgramPlayNotice(item, msg);
		FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorProgramPlayNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvAnchorProgramPlayNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorProgramPlayNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVANCHORPROGRAMPLAYNOTICE;
}

// 设置seq
void RecvAnchorProgramPlayNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorProgramPlayNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorProgramPlayNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorProgramPlayNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorProgramPlayNoticeTask::OnDisconnect()
{

}
