/*
 * author: Alex
 *   date: 2018-03-07
 *   file: ZBRecvLeaveRoomNoticeTask.cpp
 *   desc: 3.7.接收观众退出直播间通知（观众端／主播端接收观众退出直播间通知）Task实现类
 */


#include "ZBRecvLeaveRoomNoticeTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBRLRN_ROOMID_LEAVE_PARAM           "roomid"
#define ZBRLRN_USERID_PARAM                 "userid"
#define ZBRLRN_NICKNAME_LEAVE_PARAM         "nickname"
#define ZBRLRN_PHOTOURL_PARAM               "photourl"
#define ZBRLRN_FANSNUM_PARAM                "fansnum"

ZBRecvLeaveRoomNoticeTask::ZBRecvLeaveRoomNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_userId = "";
    m_nickName = "";
    m_photourl = "";
    m_fansNum = 0;
}

ZBRecvLeaveRoomNoticeTask::~ZBRecvLeaveRoomNoticeTask(void)
{
}

// 初始化
bool ZBRecvLeaveRoomNoticeTask::Init(IZBImClientListener* listener)
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
bool ZBRecvLeaveRoomNoticeTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    // 协议解析
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBRLRN_ROOMID_LEAVE_PARAM].isString()) {
            m_roomId = tp.m_data[ZBRLRN_ROOMID_LEAVE_PARAM].asString();
        }
        if (tp.m_data[ZBRLRN_USERID_PARAM].isString()) {
            m_userId = tp.m_data[ZBRLRN_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBRLRN_NICKNAME_LEAVE_PARAM].isString()) {
            m_nickName = tp.m_data[ZBRLRN_NICKNAME_LEAVE_PARAM].asString();
        }
        if (tp.m_data[ZBRLRN_PHOTOURL_PARAM].isString()) {
            m_photourl = tp.m_data[ZBRLRN_PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[ZBRLRN_FANSNUM_PARAM].isInt()) {
            m_fansNum = tp.m_data[ZBRLRN_FANSNUM_PARAM].asInt();
        }
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnZBRecvLeaveRoomNotice(m_roomId, m_userId, m_nickName, m_photourl, m_fansNum);
		FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBRecvLeaveRoomNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "ZBRecvLeaveRoomNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBRecvLeaveRoomNoticeTask::GetCmdCode() const
{
	return ZB_CMD_RECVLEAVEROOMNOTICE;
}

// 设置seq
void ZBRecvLeaveRoomNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBRecvLeaveRoomNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBRecvLeaveRoomNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void ZBRecvLeaveRoomNoticeTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
//bool RecvLeaveRoomNoticeTask::InitParam(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum)
//{
//	bool result = false;
//    if (!roomId.empty()
//        &&!userId.empty()
//        &&!nickName.empty()
//        &&!photoUrl.empty()) {
//        m_roomId = roomId;
//        m_userId = userId;
//        m_nickName = nickName;
//        m_photourl = photoUrl;
//        m_fansNum = fansNum;
//        
//        result = true;
//    }
//
//
//	return result;
//}

// 未完成任务的断线通知
void ZBRecvLeaveRoomNoticeTask::OnDisconnect()
{

}
