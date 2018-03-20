/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBRecvInstantInviteUserNoticeTask.cpp
 *   desc: 9.3.接收主播立即私密邀请通知 Task实现类
 */

#include "ZBRecvInstantInviteUserNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRIIN_INVITEID_PARAM        "invitation_id"
#define ZBRIIN_ANCHORID_PARAM        "userid"
#define ZBRIIN_NICKNAMET_PARAM       "nickname"
#define ZBRIIN_PHOTOURL_PARAM        "photourl"

ZBRecvInstantInviteUserNoticeTask::ZBRecvInstantInviteUserNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_userId = "";
    m_nickName = "";
    m_photoUrl = "";
    m_invitationId = "";

}

ZBRecvInstantInviteUserNoticeTask::~ZBRecvInstantInviteUserNoticeTask(void)
{
}

// 初始化
bool ZBRecvInstantInviteUserNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvInstantInviteUserNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRIIN_ANCHORID_PARAM].isString()) {
            m_userId = tp.m_data[ZBRIIN_ANCHORID_PARAM].asString();
        }
        if (tp.m_data[ZBRIIN_NICKNAMET_PARAM].isString()) {
            m_nickName = tp.m_data[ZBRIIN_NICKNAMET_PARAM].asString();
        }
        if (tp.m_data[ZBRIIN_PHOTOURL_PARAM].isString()) {
            m_photoUrl = tp.m_data[ZBRIIN_PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[ZBRIIN_INVITEID_PARAM].isString()) {
            m_invitationId = tp.m_data[ZBRIIN_INVITEID_PARAM].asString();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvInstantInviteUserNotice(m_userId, m_nickName, m_photoUrl, m_invitationId);
		FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvInstantInviteUserNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZB_ROOT_ERRNO] = (int)m_errType;
        if (m_errType != ZBLCC_ERR_SUCCESS) {
            value[ZB_ROOT_ERRMSG] = m_errMsg;
        }
        Json::Value valueDate;
        value[ZB_ROOT_DATA] = valueDate;
        data = value;
    }

    result = true;

	FileLog("ZBImClient", "ZBRecvInstantInviteUserNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvInstantInviteUserNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVINSTANTINVITEUSERNOTICE;
}

// 设置seq
void ZBRecvInstantInviteUserNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvInstantInviteUserNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvInstantInviteUserNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvInstantInviteUserNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvInstantInviteUserNoticeTask::OnDisconnect()
{

}
