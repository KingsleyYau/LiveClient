/*
 * author: Alex
 *   date: 2018-04-8
 *   file: AnchorHangoutRoomTask.cpp
 *   desc: 10.1.进入多人互动直播间（主播端进入多人互动直播间）
 */

#include "AnchorHangoutRoomTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ANCHORHANGOUTROOM_ROOMID_PARAM           "room_id"
// 返回参数定义
#define ANCHORHANGOUTROOM_EXPIRE_PARAM           "expire"
AnchorHangoutRoomTask::AnchorHangoutRoomTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = ZBLCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
}

AnchorHangoutRoomTask::~AnchorHangoutRoomTask(void)
{
}

// 初始化
bool AnchorHangoutRoomTask::Init(IZBImClientListener* listener)
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
bool AnchorHangoutRoomTask::Handle(const ZBTransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "AnchorHangoutRoomTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    AnchorHangoutRoomItem item;
    int expire = 0;
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        item.Parse(tp.m_data);
        if (tp.m_errData.isObject()) {
            if (tp.m_errData[ANCHORHANGOUTROOM_EXPIRE_PARAM].isNumeric()) {
                expire = tp.m_errData[ANCHORHANGOUTROOM_EXPIRE_PARAM].asInt();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = ZBLCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "AnchorHangoutRoomTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnAnchorEnterHangoutRoom(GetSeq(), success, m_errType, m_errMsg, item, expire);
        FileLog("ImClient", "AnchorHangoutRoomTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "AnchorHangoutRoomTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool AnchorHangoutRoomTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "AnchorHangoutRoomTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[ANCHORHANGOUTROOM_ROOMID_PARAM] = m_roomId;

        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "AnchorHangoutRoomTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string AnchorHangoutRoomTask::GetCmdCode() const
{
    return ZB_CMD_ENTERHANGOUTROOM;
}

// 设置seq
void AnchorHangoutRoomTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T AnchorHangoutRoomTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool AnchorHangoutRoomTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void AnchorHangoutRoomTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool AnchorHangoutRoomTask::InitParam(const string& roomId)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void AnchorHangoutRoomTask::OnDisconnect()
{
    if (NULL != m_listener) {
        AnchorHangoutRoomItem item;
        m_listener->OnAnchorEnterHangoutRoom(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, item, 0);
    }
}

