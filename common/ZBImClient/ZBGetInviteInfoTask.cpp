/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBGetInviteInfoTask.cpp
 *   desc: 9.5.获取指定立即私密邀请信息Task实现类
 */

#include "ZBGetInviteInfoTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBGII_INVITATIONID_PARAM           "invitation_id"


ZBGetInviteInfoTask::ZBGetInviteInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_invitationId = "";
}

ZBGetInviteInfoTask::~ZBGetInviteInfoTask(void)
{
}

// 初始化
bool ZBGetInviteInfoTask::Init(IZBImClientListener* listener)
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
bool ZBGetInviteInfoTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBGetInviteInfoTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    ZBPrivateInviteItem item;
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        item.Parse(tp.m_data);
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBGetInviteInfoTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnZBGetInviteInfo(GetSeq(), success, m_errType, m_errMsg, item);
		FileLog("ImClient", "ZBGetInviteInfoTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBGetInviteInfoTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBGetInviteInfoTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBGetInviteInfoTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZBGII_INVITATIONID_PARAM] = m_invitationId;
        data = value;
    }

    result = true;

	FileLog("ImClient", "ZBGetInviteInfoTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBGetInviteInfoTask::GetCmdCode() const
{
	return ZB_CMD_GETINVITEINFO;
}

// 设置seq
void ZBGetInviteInfoTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBGetInviteInfoTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBGetInviteInfoTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBGetInviteInfoTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBGetInviteInfoTask::InitParam(const string& invitationId)
{
	bool result = false;
    if (!invitationId.empty()
        ) {
        m_invitationId = invitationId;
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ZBGetInviteInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
        ZBPrivateInviteItem item;
        m_listener->OnZBGetInviteInfo(m_seq, false, ZBLCC_ERR_CONNECTFAIL, "", item);
	}
}
