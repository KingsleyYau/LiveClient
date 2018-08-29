/*
 * author: Alex
 *   date: 2018-05-12
 *   file: SendAnchorHangoutLiveChatTask.cpp
 *   desc: 10.14.发送多人互动直播间文本消息
 */

#include "SendAnchorHangoutLiveChatTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define IMSENDANCHORHANGOUTLIVECHAT_ROOMID_PARAM                "roomid"
#define IMSENDANCHORHANGOUTLIVECHAT_NICKNAME_PARAM              "nickname"
#define IMSENDANCHORHANGOUTLIVECHAT_MSG_PARAM                   "msg"
#define IMSENDANCHORHANGOUTLIVECHAT_AT_PARAM                    "at"

SendAnchorHangoutLiveChatTask::SendAnchorHangoutLiveChatTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = ZBLCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
    m_nickName = "";
    m_msg = "";
}

SendAnchorHangoutLiveChatTask::~SendAnchorHangoutLiveChatTask(void)
{
}

// 初始化
bool SendAnchorHangoutLiveChatTask::Init(IZBImClientListener* listener)
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
bool SendAnchorHangoutLiveChatTask::Handle(const ZBTransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "SendAnchorHangoutLiveChatTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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
    
    FileLog("ImClient", "SendAnchorHangoutLiveChatTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnSendAnchorHangoutLiveChat(GetSeq(), success, m_errType, m_errMsg);
        FileLog("ImClient", "SendAnchorHangoutLiveChatTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "SendAnchorHangoutLiveChatTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool SendAnchorHangoutLiveChatTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "SendAnchorHangoutLiveChatTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[IMSENDANCHORHANGOUTLIVECHAT_ROOMID_PARAM] = m_roomId;
        value[IMSENDANCHORHANGOUTLIVECHAT_NICKNAME_PARAM] = m_nickName;
        value[IMSENDANCHORHANGOUTLIVECHAT_MSG_PARAM] = m_msg;
        int i = 0;
        for (list<string>::const_iterator iter = m_at.begin(); iter != m_at.end(); iter++) {
            string item = (*iter);
            strArray[i++] = item;
        }
        if (i > 0) {
            value[IMSENDANCHORHANGOUTLIVECHAT_AT_PARAM] = strArray;
        }
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "SendAnchorHangoutLiveChatTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string SendAnchorHangoutLiveChatTask::GetCmdCode() const
{
    return ZB_CMD_HANGOUTSENDLIVECHAT;
}

// 设置seq
void SendAnchorHangoutLiveChatTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T SendAnchorHangoutLiveChatTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendAnchorHangoutLiveChatTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void SendAnchorHangoutLiveChatTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool SendAnchorHangoutLiveChatTask::InitParam(const string& roomId, const string& nickName, const string& msg, const list<string> at)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        m_nickName = nickName;
        m_msg = msg;
        result = true;
    }
    
    if (!at.empty()) {
        m_at = at;
    }

    return result;
}

// 未完成任务的断线通知
void SendAnchorHangoutLiveChatTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendAnchorHangoutLiveChat(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}

