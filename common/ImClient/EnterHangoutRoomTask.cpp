/*
 * author: Alex
 *   date: 2018-04-13
 *   file: EnterHangoutRoomTask.cpp
 *   desc: 10.3.观众新建/进入多人互动直播间（观众端新建/进入多人互动直播间）
 */

#include "EnterHangoutRoomTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ENTERHANGOUTROOM_ROOMID_PARAM           "room_id"
#define ENTERHANGOUTROOM_CREATE_ONLY_PARAM      "create_only"
EnterHangoutRoomTask::EnterHangoutRoomTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
}

EnterHangoutRoomTask::~EnterHangoutRoomTask(void)
{
}

// 初始化
bool EnterHangoutRoomTask::Init(IImClientListener* listener)
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
bool EnterHangoutRoomTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "EnterHangoutRoomTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    IMHangoutRoomItem item;
    int expire = 0;
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        item.Parse(tp.m_data);
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "EnterHangoutRoomTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
         bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnEnterHangoutRoom(GetSeq(), success, m_errType, m_errMsg, item);
        FileLog("ImClient", "EnterHangoutRoomTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "EnterHangoutRoomTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool EnterHangoutRoomTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "EnterHangoutRoomTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[ENTERHANGOUTROOM_ROOMID_PARAM] = m_roomId;
        value[ENTERHANGOUTROOM_CREATE_ONLY_PARAM] = (m_isCreateOnly == true ? 1 : 0);
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "EnterHangoutRoomTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string EnterHangoutRoomTask::GetCmdCode() const
{
    return CMD_ENTERHANGOUTROOM;
}

// 设置seq
void EnterHangoutRoomTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T EnterHangoutRoomTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool EnterHangoutRoomTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void EnterHangoutRoomTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool EnterHangoutRoomTask::InitParam(const string& roomId, bool isCreateOnly)
{
    bool result = true;
    if (!roomId.empty()) {
        m_roomId = roomId;
    }
    
    m_isCreateOnly = isCreateOnly;

    return result;
}

// 未完成任务的断线通知
void EnterHangoutRoomTask::OnDisconnect()
{
    if (NULL != m_listener) {
        IMHangoutRoomItem item;
        m_listener->OnEnterHangoutRoom(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, item);
    }
}

