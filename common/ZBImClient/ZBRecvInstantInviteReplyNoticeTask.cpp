/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBRecvInstantInviteReplyNoticeTask.cpp
 *   desc: 9.2.接收立即私密邀请回复通知 Task实现类
 */

#include "ZBRecvInstantInviteReplyNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRIIRN_INVITEID_PARAM          "invite_id"
#define ZBRIIRN_REPLYTYPE_PARAM         "reply_type"
#define ZBRIIRN_IMROOMID_PARAM          "room_id"
#define ZBRIIRN_ROOMTYPE_PARAM          "room_type"
#define ZBRIIRN_USERID_PARAM            "user_id"
#define ZBRIIRN_NICKNAMET_PARAM         "nick_name"
#define ZBRIIRN_AVATARIMG_PARAM         "avatar_img"


ZBRecvInstantInviteReplyNoticeTask::ZBRecvInstantInviteReplyNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_inviteId = "";
    m_roomId = "";
    m_replyType = ZBREPLYTYPE_REJECT;
    m_roomType = ZBROOMTYPE_UNKNOW;
    m_userId = "";
    m_nickName = "";
    m_avatarImg = "";

}

ZBRecvInstantInviteReplyNoticeTask::~ZBRecvInstantInviteReplyNoticeTask(void)
{
}

// 初始化
bool ZBRecvInstantInviteReplyNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvInstantInviteReplyNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRIIRN_INVITEID_PARAM].isString()) {
            m_inviteId = tp.m_data[ZBRIIRN_INVITEID_PARAM].asString();
        }
        if (tp.m_data[ZBRIIRN_REPLYTYPE_PARAM].isNumeric()) {
            m_replyType =  ZBGetReplyType(tp.m_data[ZBRIIRN_REPLYTYPE_PARAM].asInt());
        }
        if (tp.m_data[ZBRIIRN_IMROOMID_PARAM].isString()) {
            m_roomId = tp.m_data[ZBRIIRN_IMROOMID_PARAM].asString();
        }
        if (tp.m_data[ZBRIIRN_ROOMTYPE_PARAM].isNumeric()) {
            m_roomType = ZBGetRoomType(tp.m_data[ZBRIIRN_ROOMTYPE_PARAM].asInt());
        }
        if (tp.m_data[ZBRIIRN_USERID_PARAM].isString()) {
            m_userId = tp.m_data[ZBRIIRN_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBRIIRN_NICKNAMET_PARAM].isString()) {
            m_nickName = tp.m_data[ZBRIIRN_NICKNAMET_PARAM].asString();
        }
        if (tp.m_data[ZBRIIRN_AVATARIMG_PARAM].isString()) {
            m_avatarImg = tp.m_data[ZBRIIRN_AVATARIMG_PARAM].asString();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvInstantInviteReplyNotice(m_inviteId, m_replyType, m_roomId, m_roomType, m_userId, m_nickName, m_avatarImg);
		FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvInstantInviteReplyNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "ZBRecvInstantInviteReplyNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvInstantInviteReplyNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVINSTANTINVITEREPLYNOTICE;
}

// 设置seq
void ZBRecvInstantInviteReplyNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvInstantInviteReplyNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvInstantInviteReplyNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvInstantInviteReplyNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvInstantInviteReplyNoticeTask::OnDisconnect()
{

}
