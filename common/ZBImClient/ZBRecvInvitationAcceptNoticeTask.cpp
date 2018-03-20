/*
 * author: Alex
 *   date: 2018-03-09
 *   file: ZBRecvInvitationAcceptNoticeTask.cpp
 *   desc: 9.6.接收观众接受预约通知Task实现类
 */

#include "ZBRecvInvitationAcceptNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRIAN_USERID_PARAM                 "userid"
#define ZBRIAN_NICKNAME_PARAM               "nickname"
#define ZBRIAN_PHOTOURL_PARAM               "photourl"
#define ZBRIAN_INVITATIONID_PARAM           "invitation_id"
#define ZBRIAN_BOOKTIME_PARAM               "book_time"

ZBRecvInvitationAcceptNoticeTask::ZBRecvInvitationAcceptNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";

    m_userId = "";
    m_nickName = "";
    m_photoUrl = "";
    m_invitationId = "";
    m_bookTime = 0;

}

ZBRecvInvitationAcceptNoticeTask::~ZBRecvInvitationAcceptNoticeTask(void)
{
}

// 初始化
bool ZBRecvInvitationAcceptNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvInvitationAcceptNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRIAN_USERID_PARAM].isString()) {
            m_userId = tp.m_data[ZBRIAN_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBRIAN_NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[ZBRIAN_NICKNAME_PARAM].asString();
        }
        if (tp.m_data[ZBRIAN_PHOTOURL_PARAM].isString()) {
            m_photoUrl = tp.m_data[ZBRIAN_PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[ZBRIAN_INVITATIONID_PARAM].isString()) {
            m_invitationId = tp.m_data[ZBRIAN_INVITATIONID_PARAM].asString();
        }
        if (tp.m_data[ZBRIAN_BOOKTIME_PARAM].isIntegral()) {
            m_bookTime = tp.m_data[ZBRIAN_BOOKTIME_PARAM].asInt();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvInvitationAcceptNotice(m_userId, m_nickName, m_photoUrl, m_invitationId, m_bookTime);
		FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvInvitationAcceptNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::GetSendData() begin");
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

	FileLog("ZBImClient", "ZBRecvInvitationAcceptNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvInvitationAcceptNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVLEAVINGPUBLICROOMNOTICE;
}

// 设置seq
void ZBRecvInvitationAcceptNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvInvitationAcceptNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvInvitationAcceptNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvInvitationAcceptNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvInvitationAcceptNoticeTask::OnDisconnect()
{

}
