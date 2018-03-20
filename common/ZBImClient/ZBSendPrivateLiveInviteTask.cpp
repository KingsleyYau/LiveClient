/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBSendPrivateLiveInviteTask.cpp
 *   desc: 9.1.主播发送立即私密邀请 Task实现类
 */

#include "ZBSendPrivateLiveInviteTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
#define ZBIIU_USERID_PARAM                "userid"

// 返回
#define ZBIIU_INVITATIONID_PARAM               "invite_id"
#define ZBIIU_ROOMID_PARAM                     "roomid"
#define ZBIIU_TIMEOUT_PARAM                    "timeout"



ZBSendPrivateLiveInviteTask::ZBSendPrivateLiveInviteTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_userId = "";
    
    m_inviteId = "";
    m_roomId = "";
    m_timeOut = 0;
}

ZBSendPrivateLiveInviteTask::~ZBSendPrivateLiveInviteTask(void)
{
}

// 初始化
bool ZBSendPrivateLiveInviteTask::Init(IZBImClientListener* listener)
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
bool ZBSendPrivateLiveInviteTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBIIU_INVITATIONID_PARAM].isString()) {
            m_inviteId = tp.m_data[ZBIIU_INVITATIONID_PARAM].asString();
        }
        
//        // alextest
//        if (tp.m_data[ZBIIU_INVITATIONID_PARAM].isNumeric()) {
//            char temp[16];
//            snprintf(temp, sizeof(temp), "%d",  tp.m_data[ZBIIU_INVITATIONID_PARAM].asInt());
//            m_inviteId = temp;
//        }
        
        if (tp.m_data[ZBIIU_ROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ZBIIU_ROOMID_PARAM].asString();
        }
        
        if (tp.m_data[ZBIIU_TIMEOUT_PARAM].isIntegral()) {
            m_timeOut = tp.m_data[ZBIIU_TIMEOUT_PARAM].asInt();
        }

        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnZBSendPrivateLiveInvite(GetSeq(), success, m_errType, m_errMsg, m_inviteId,  m_timeOut, m_roomId);
		FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBSendPrivateLiveInviteTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZBIIU_USERID_PARAM] = m_userId;
        data = value;
    }

    result = true;

	FileLog("ZBImClient", "ZBSendPrivateLiveInviteTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBSendPrivateLiveInviteTask::GetCmdCode() const
{
	return ZB_CMD_SENDPRIVATELIVEINVITE;
}

// 设置seq
void ZBSendPrivateLiveInviteTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBSendPrivateLiveInviteTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBSendPrivateLiveInviteTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBSendPrivateLiveInviteTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBSendPrivateLiveInviteTask::InitParam(const string& userId)
{
	bool result = false;
    if (!userId.empty()) {
        m_userId = userId;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ZBSendPrivateLiveInviteTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnZBSendPrivateLiveInvite(GetSeq(), false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, "", 0, "");
    }
}
