/*
 * author: Alex
 *   date: 2018-05-10
 *   file: ControlManPushHangoutTask.cpp
 *   desc: 10.11.多人互动观众开始/结束视频互动
 */

#include "ControlManPushHangoutTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define IMCOMTROMANPUSHHANGOUT_ROOMID_PARAM               "room_id"
#define IMCOMTROMANPUSHHANGOUT_CONTROL_PARAM              "control"

// 返回参数
#define IMCOMTROMANPUSHHANGOUT_MANPUSHURL_PARAM           "man_push_url"

ControlManPushHangoutTask::ControlManPushHangoutTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
    m_control = IMCONTROLTYPE_UNKNOW;
}

ControlManPushHangoutTask::~ControlManPushHangoutTask(void)
{
}

// 初始化
bool ControlManPushHangoutTask::Init(IImClientListener* listener)
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
bool ControlManPushHangoutTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "ControlManPushHangoutTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    // 协议解析
    list<string> manPushUrl;
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if ( tp.m_data[IMCOMTROMANPUSHHANGOUT_MANPUSHURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < tp.m_data[IMCOMTROMANPUSHHANGOUT_MANPUSHURL_PARAM].size(); i++) {
                    Json::Value element = tp.m_data[IMCOMTROMANPUSHHANGOUT_MANPUSHURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        string strUrl = element.asString();
                        manPushUrl.push_back(strUrl);
                    }
                }
            }
            
        }
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "ControlManPushHangoutTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnControlManPushHangout(GetSeq(), success, m_errType, m_errMsg, manPushUrl);
        FileLog("ImClient", "ControlManPushHangoutTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "ControlManPushHangoutTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool ControlManPushHangoutTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "ControlManPushHangoutTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[IMCOMTROMANPUSHHANGOUT_ROOMID_PARAM] = m_roomId;
        if (m_control > IMCONTROLTYPE_UNKNOW && m_control <= IMCONTROLTYPE_CLOSE) {
            value[IMCOMTROMANPUSHHANGOUT_CONTROL_PARAM] = m_control;
        }
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "ControlManPushHangoutTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string ControlManPushHangoutTask::GetCmdCode() const
{
    return CMD_CONTROLMANPUSHHANGOUT;
}

// 设置seq
void ControlManPushHangoutTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T ControlManPushHangoutTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ControlManPushHangoutTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void ControlManPushHangoutTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool ControlManPushHangoutTask::InitParam(const string& roomId, IMControlType control)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        m_control = control;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void ControlManPushHangoutTask::OnDisconnect()
{
    if (NULL != m_listener) {
        list<string> manPushUrl;
        m_listener->OnControlManPushHangout(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, manPushUrl);
    }
}

