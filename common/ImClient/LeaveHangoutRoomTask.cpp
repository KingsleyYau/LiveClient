/*
 * author: Alex
 *   date: 2018-04-13
 *   file: LeaveHangoutRoomTask.cpp
 *   desc: 10.4.退出多人互动直播间（观众端/主播端请求退出多人互动直播间）
 */

#include "LeaveHangoutRoomTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define LEAVEHANGOUTROOM_ROOMID_PARAM           "room_id"

LeaveHangoutRoomTask::LeaveHangoutRoomTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
}

LeaveHangoutRoomTask::~LeaveHangoutRoomTask(void)
{
}

// 初始化
bool LeaveHangoutRoomTask::Init(IImClientListener* listener)
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
bool LeaveHangoutRoomTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "LeaveHangoutRoomTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    int expire = 0;
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "LeaveHangoutRoomTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
         bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnLeaveHangoutRoom(GetSeq(), success, m_errType, m_errMsg);
        FileLog("ImClient", "LeaveHangoutRoomTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "LeaveHangoutRoomTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool LeaveHangoutRoomTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "LeaveHangoutRoomTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[LEAVEHANGOUTROOM_ROOMID_PARAM] = m_roomId;

        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "LeaveHangoutRoomTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string LeaveHangoutRoomTask::GetCmdCode() const
{
    return CMD_LEAVEHANGOUTROOM;
}

// 设置seq
void LeaveHangoutRoomTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T LeaveHangoutRoomTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LeaveHangoutRoomTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void LeaveHangoutRoomTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool LeaveHangoutRoomTask::InitParam(const string& roomId)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void LeaveHangoutRoomTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnLeaveHangoutRoom(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}

