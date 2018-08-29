/*
 * author: Alex
 *   date: 2018-06-14
 *   file: SendPrivateMessageTask.cpp
 *   desc: 12.1.发送私信文本消息
 */

#include "SendPrivateMessageTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define SENDPRIVATEMESSAGE_TOID_PARAM               "to_id"
#define SENDPRIVATEMESSAGE_CONTENT_PARAM            "content"

// 返回参数定义
#define SENDPRIVATEMESSAGE_ID_PARAM                 "id"
#define SENDPRIVATEMESSAGE_CREDIT_PARAM             "credit"

SendPrivateMessageTask::SendPrivateMessageTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_toId= "";
    m_content = "";
    m_sendMsgId = -1;
  
}

SendPrivateMessageTask::~SendPrivateMessageTask(void)
{
}

// 初始化
bool SendPrivateMessageTask::Init(IImClientListener* listener)
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
bool SendPrivateMessageTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "SendPrivateMessageTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    int messageId = -1;
    double credit = 0.0;
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[SENDPRIVATEMESSAGE_ID_PARAM].isNumeric()) {
                messageId = tp.m_data[SENDPRIVATEMESSAGE_ID_PARAM].asInt();
            }
            if (tp.m_data[SENDPRIVATEMESSAGE_CREDIT_PARAM].isNumeric()) {
                credit = tp.m_data[SENDPRIVATEMESSAGE_CREDIT_PARAM].asDouble();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "SendPrivateMessageTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendPrivateMessage(GetSeq(), success, m_errType, m_errMsg, messageId, credit, m_toId, m_sendMsgId);
        FileLog("ImClient", "SendPrivateMessageTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "SendPrivateMessageTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool SendPrivateMessageTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "SendPrivateMessageTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[SENDPRIVATEMESSAGE_TOID_PARAM] = m_toId;
        value[SENDPRIVATEMESSAGE_CONTENT_PARAM] = m_content;
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "SendPrivateMessageTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string SendPrivateMessageTask::GetCmdCode() const
{
    return CMD_SENDPRIVATEMESSAGE;
}

// 设置seq
void SendPrivateMessageTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T SendPrivateMessageTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendPrivateMessageTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void SendPrivateMessageTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool SendPrivateMessageTask::InitParam(const string& toId, const string& content, int sendMsgId)
{
    bool result = false;
    if (!toId.empty()) {
        m_toId = toId;
        m_content = content;
        m_sendMsgId = sendMsgId;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void SendPrivateMessageTask ::OnDisconnect()
{
    if (NULL != m_listener) {
        list<string> manPushUrl;
        m_listener->OnSendPrivateMessage(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, -1, 0.0, m_toId, m_sendMsgId);
    }
}

