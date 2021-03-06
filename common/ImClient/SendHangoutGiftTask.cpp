/*
 * author: Alex
 *   date: 2018-04-13
 *   file: SendHangoutGiftTask.cpp
 *   desc: 10.7.发送多人互动直播间礼物消息
 */

#include "SendHangoutGiftTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define IMSENDHANGOUTGIFT_ROOMID_PARAM               "roomid"
#define IMSENDHANGOUTGIFT_NICKNAME_PARAM             "nickname"
#define IMSENDHANGOUTGIFT_TOUID_PARAM                "to_uid"
#define IMSENDHANGOUTGIFT_GIFTID_PARAM               "giftid"
#define IMSENDHANGOUTGIFT_GIFTNAME_PARAM             "giftname"
#define IMSENDHANGOUTGIFT_ISBACKPACK_PARAM           "is_backpack"
#define IMSENDHANGOUTGIFT_ISPRIVATE_PARAM            "is_private"
#define IMSENDHANGOUTGIFT_GIFTNUM_PARAM              "giftnum"
#define IMSENDHANGOUTGIFT_MULTICLICK_PARAM           "multi_click"
#define IMSENDHANGOUTGIFT_MULTICLICKSTART_PARAM      "multi_click_start"
#define IMSENDHANGOUTGIFT_MULTICLICKEND_PARAM        "multi_click_end"
#define IMSENDHANGOUTGIFT_MULTICLICKID_PARAM         "multi_click_id"

// 返回
#define IMSENDHANGOUTGIFT_CREDIT_PARAM               "credit"

SendHangoutGiftTask::SendHangoutGiftTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = LCC_ERR_FAIL;
    m_errMsg = "";
    
    m_roomId = "";
    m_nickName = "";
    m_toUid = "";
    m_giftId = "";
    m_giftName = "";
    m_isBackPack = false;
    m_isPrivate = false;
    m_giftNum = 0;
    m_isMultiClick = false;
    m_multiClickStart = 0;
    m_multiClickEnd = 0;
    m_multiClickId = 0;
}

SendHangoutGiftTask::~SendHangoutGiftTask(void)
{
}

// 初始化
bool SendHangoutGiftTask::Init(IImClientListener* listener)
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
bool SendHangoutGiftTask::Handle(const TransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "SendHangoutGiftTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
    
    double credit = 0.0;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data.isObject()) {
            if (tp.m_data[IMSENDHANGOUTGIFT_CREDIT_PARAM].isNumeric()) {
                credit = tp.m_data[IMSENDHANGOUTGIFT_CREDIT_PARAM].asDouble();
            }
        }
    }
    
    // 协议解析失败
    if (!result) {
        m_errType = LCC_ERR_PROTOCOLFAIL;
        m_errMsg = "";
    }
    
    FileLog("ImClient", "SendHangoutGiftTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendHangoutGift(GetSeq(), success, m_errType, m_errMsg, credit);
        FileLog("ImClient", "SendHangoutGiftTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "SendHangoutGiftTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool SendHangoutGiftTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "SendHangoutGiftTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[IMSENDHANGOUTGIFT_ROOMID_PARAM] = m_roomId;
        value[IMSENDHANGOUTGIFT_NICKNAME_PARAM] = m_nickName;
        value[IMSENDHANGOUTGIFT_TOUID_PARAM] = m_toUid;
        value[IMSENDHANGOUTGIFT_GIFTID_PARAM] = m_giftId;
        value[IMSENDHANGOUTGIFT_GIFTNAME_PARAM] = m_giftName;
        int isBackPack = m_isBackPack ? 1 : 0;
        value[IMSENDHANGOUTGIFT_ISBACKPACK_PARAM] = isBackPack;
        int isPrivate = m_isPrivate ? 1 : 0;
        value[IMSENDHANGOUTGIFT_ISPRIVATE_PARAM] = isPrivate;
        value[IMSENDHANGOUTGIFT_GIFTNUM_PARAM] = m_giftNum;
        int isMultiClick = m_isMultiClick ? 1 : 0;
        value[IMSENDHANGOUTGIFT_MULTICLICK_PARAM] = isMultiClick;
        value[IMSENDHANGOUTGIFT_MULTICLICKSTART_PARAM] = m_multiClickStart;
        value[IMSENDHANGOUTGIFT_MULTICLICKEND_PARAM] = m_multiClickEnd;
        value[IMSENDHANGOUTGIFT_MULTICLICKID_PARAM] = m_multiClickId;
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "SendHangoutGiftTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string SendHangoutGiftTask::GetCmdCode() const
{
    return CMD_SENDHANGOUTGIFT;
}

// 设置seq
void SendHangoutGiftTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T SendHangoutGiftTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendHangoutGiftTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void SendHangoutGiftTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool SendHangoutGiftTask::InitParam(const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate)
{
    bool result = false;
    if (!roomId.empty()) {
        m_roomId = roomId;
        m_nickName = nickName;
        m_toUid = toUid;
        m_giftId = giftId;
        m_giftName = giftName;
        m_isBackPack = isBackPack;
        m_isPrivate = isPrivate;
        m_giftNum = giftNum;
        m_isMultiClick = isMultiClick;
        m_multiClickStart = multiClickStart;
        m_multiClickEnd = multiClickEnd;
        m_multiClickId = multiClickId;
        result = true;
    }

    return result;
}

// 未完成任务的断线通知
void SendHangoutGiftTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendHangoutGift(m_seq, false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, 0.0);
    }
}

