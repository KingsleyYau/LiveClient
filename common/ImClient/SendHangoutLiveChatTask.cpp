/*
 * author: Alex
 *   date: 2018-05-12
 *   file: SendHangoutLiveChatTask.cpp
 *   desc: 10.12.发送多人互动直播间文本消息
 */

#include "SendHangoutLiveChatTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define IMSENDHANGOUTLIVECHAT_ROOMID_PARAM               "roomid"
#define IMSENDHANGOUTLIVECHAT_NICKNAME_PARAM             "nickname"
#define IMSENDHANGOUTLIVECHAT_MSG_PARAM                  "msg"
#define IMSENDHANGOUTLIVECHAT_AT_PARAM                   "at"

SendHangoutLiveChatTask::SendHangoutLiveChatTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
    m_nickName = "";
    m_msg = "";
    
}

SendHangoutLiveChatTask::~SendHangoutLiveChatTask(void)
{
}

// 初始化
bool SendHangoutLiveChatTask::Init(IImClientListener* listener)
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
bool SendHangoutLiveChatTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "SendHangoutLiveChatTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    list<string> manPushUrl;
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
    
    FileLog("ImClient", "SendHangoutLiveChatTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendHangoutLiveChat(GetSeq(), success, m_errType, m_errMsg);
        FileLog("ImClient", "SendHangoutLiveChatTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "SendHangoutLiveChatTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool SendHangoutLiveChatTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "SendHangoutLiveChatTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[IMSENDHANGOUTLIVECHAT_ROOMID_PARAM] = m_roomId;
        value[IMSENDHANGOUTLIVECHAT_NICKNAME_PARAM] = m_nickName;
        value[IMSENDHANGOUTLIVECHAT_MSG_PARAM] = m_msg;
        int i = 0;
        for (list<string>::const_iterator iter = m_at.begin(); iter != m_at.end(); iter++) {
            string item = (*iter);
            strArray[i++] = item;
        }
        if (i > 0) {
            value[IMSENDHANGOUTLIVECHAT_AT_PARAM] = strArray;
        }
        
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "SendHangoutLiveChatTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string SendHangoutLiveChatTask::GetCmdCode() const
{
    return CMD_HANGOUTSENDLIVECHAT;
}

// 设置seq
void SendHangoutLiveChatTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T SendHangoutLiveChatTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendHangoutLiveChatTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void SendHangoutLiveChatTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool SendHangoutLiveChatTask::InitParam(const string& roomId, const string& nickName, const string& msg, const list<string>& at)
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
void SendHangoutLiveChatTask ::OnDisconnect()
{
    if (NULL != m_listener) {
        list<string> manPushUrl;
        m_listener->OnSendHangoutLiveChat(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}

