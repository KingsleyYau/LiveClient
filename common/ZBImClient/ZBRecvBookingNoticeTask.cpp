/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBRecvBookingNoticeTask.cpp
 *   desc: 9.4.接收预约开始倒数通知 Task实现类
 */

#include "ZBRecvBookingNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBBN_ROOMID_PARAM                "roomid"
#define ZBBN_USERID_PARAM                "userid"
#define ZBBN_NICKNAME_PARAM              "nickname"
#define ZBBN_AVATARIMG_PARAM             "avatar_img"
#define ZBBN_LEFTSECONDS_PARAM           "left_seconds"

ZBRecvBookingNoticeTask::ZBRecvBookingNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
}

ZBRecvBookingNoticeTask::~ZBRecvBookingNoticeTask(void)
{
}

// 初始化
bool ZBRecvBookingNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvBookingNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRecvBookingNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    string roomId = "";
    string userId = "";
    string nickName = "";
    string avatarImg = "";
    int leftSeconds = 0;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBBN_ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ZBBN_ROOMID_PARAM].asString();
        }
        if (tp.m_data[ZBBN_USERID_PARAM].isString()) {
            userId = tp.m_data[ZBBN_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBBN_NICKNAME_PARAM].isString()) {
            nickName = tp.m_data[ZBBN_NICKNAME_PARAM].asString();
        }
        if (tp.m_data[ZBBN_AVATARIMG_PARAM].isString()) {
            avatarImg = tp.m_data[ZBBN_AVATARIMG_PARAM].asString();
        }
        if (tp.m_data[ZBBN_LEFTSECONDS_PARAM].isIntegral()) {
            leftSeconds = tp.m_data[ZBBN_LEFTSECONDS_PARAM].asInt();
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRecvBookingNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvBookingNotice(roomId, userId, nickName, avatarImg, leftSeconds);
		FileLog("ImClient", "ZBRecvBookingNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBRecvBookingNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvBookingNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRecvBookingNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "ZBRecvBookingNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvBookingNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECBOOKINGNOTICE;
}

// 设置seq
void ZBRecvBookingNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvBookingNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvBookingNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvBookingNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void ZBRecvBookingNoticeTask::OnDisconnect()
{

}
