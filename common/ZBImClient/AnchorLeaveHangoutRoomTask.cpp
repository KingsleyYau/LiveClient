/*
 * author: Alex
 *   date: 2018-04-9
 *   file: AnchorLeaveHangoutRoomTask.cpp
 *   desc: 10.2.退出多人互动直播间（主播端请求退出多人互动直播间）
 */

#include "AnchorLeaveHangoutRoomTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ANCHORLEAVEHANGOUTROOM_ROOMID_PARAM           "room_id"

AnchorLeaveHangoutRoomTask::AnchorLeaveHangoutRoomTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = ZBLCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
}

AnchorLeaveHangoutRoomTask::~AnchorLeaveHangoutRoomTask(void)
{
}

// 初始化
bool AnchorLeaveHangoutRoomTask::Init(IZBImClientListener* listener)
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
bool AnchorLeaveHangoutRoomTask::Handle(const ZBTransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "AnchorLeaveHangoutRoomTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    int expire = 0;
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = ZBLCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "AnchorLeaveHangoutRoomTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnAnchorLeaveHangoutRoom(GetSeq(), success, m_errType, m_errMsg);
        FileLog("ImClient", "AnchorLeaveHangoutRoomTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "AnchorLeaveHangoutRoomTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool AnchorLeaveHangoutRoomTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "AnchorLeaveHangoutRoomTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[ANCHORLEAVEHANGOUTROOM_ROOMID_PARAM] = m_roomId;

        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "AnchorLeaveHangoutRoomTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string AnchorLeaveHangoutRoomTask::GetCmdCode() const
{
    return ZB_CMD_LEAVEHANGOUTROOM;
}

// 设置seq
void AnchorLeaveHangoutRoomTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T AnchorLeaveHangoutRoomTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool AnchorLeaveHangoutRoomTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void AnchorLeaveHangoutRoomTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool AnchorLeaveHangoutRoomTask::InitParam(const string& roomId)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void AnchorLeaveHangoutRoomTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnAnchorLeaveHangoutRoom(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}

