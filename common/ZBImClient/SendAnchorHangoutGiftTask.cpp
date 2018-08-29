/*
 * author: Alex
 *   date: 2018-04-11
 *   file: SendAnchorHangoutGiftTask.cpp
 *   desc: 10.11.发送多人互动直播间礼物消息
 */

#include "SendAnchorHangoutGiftTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define IMSENDANCHORHANGOUTGIFT_ROOMID_PARAM               "roomid"
#define IMSENDANCHORHANGOUTGIFT_NICKNAME_PARAM             "nickname"
#define IMSENDANCHORHANGOUTGIFT_TOUID_PARAM                "to_uid"
#define IMSENDANCHORHANGOUTGIFT_GIFTID_PARAM               "giftid"
#define IMSENDANCHORHANGOUTGIFT_GIFTNAME_PARAM             "giftname"
#define IMSENDANCHORHANGOUTGIFT_ISBACKPACK_PARAM           "is_backpack"
#define IMSENDANCHORHANGOUTGIFT_ISPRIVATE_PARAM            "is_private"
#define IMSENDANCHORHANGOUTGIFT_GIFTNUM_PARAM              "giftnum"
#define IMSENDANCHORHANGOUTGIFT_MULTICLICK_PARAM           "multi_click"
#define IMSENDANCHORHANGOUTGIFT_MULTICLICKSTART_PARAM      "multi_click_start"
#define IMSENDANCHORHANGOUTGIFT_MULTICLICKEND_PARAM        "multi_click_end"
#define IMSENDANCHORHANGOUTGIFT_MULTICLICKID_PARAM         "multi_click_id"

SendAnchorHangoutGiftTask::SendAnchorHangoutGiftTask(void)
{
    m_listener = NULL;
    
    m_seq = 0;
    m_errType = ZBLCC_ERR_FAIL;
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

SendAnchorHangoutGiftTask::~SendAnchorHangoutGiftTask(void)
{
}

// 初始化
bool SendAnchorHangoutGiftTask::Init(IZBImClientListener* listener)
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
bool SendAnchorHangoutGiftTask::Handle(const ZBTransportProtocol& tp)
{
    bool result = false;
    
    FileLog("ImClient", "SendAnchorHangoutGiftTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
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
    
    FileLog("ImClient", "SendAnchorHangoutGiftTask::Handle() m_errType:%d", m_errType);
    
    // 通知listener
    if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnSendAnchorHangoutGift(GetSeq(), success, m_errType, m_errMsg);
        FileLog("ImClient", "SendAnchorHangoutGiftTask::Handle() callback end, result:%d", success);
    }
    
    FileLog("ImClient", "SendAnchorHangoutGiftTask::Handle() end");
    
    return result;
}

// 获取待发送的Json数据
bool SendAnchorHangoutGiftTask::GetSendData(Json::Value& data)
{
    bool result = false;
    
    FileLog("ImClient", "SendAnchorHangoutGiftTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        Json::Value strArray;
        value[IMSENDANCHORHANGOUTGIFT_ROOMID_PARAM] = m_roomId;
        value[IMSENDANCHORHANGOUTGIFT_NICKNAME_PARAM] = m_nickName;
        value[IMSENDANCHORHANGOUTGIFT_TOUID_PARAM] = m_toUid;
        value[IMSENDANCHORHANGOUTGIFT_GIFTID_PARAM] = m_giftId;
        value[IMSENDANCHORHANGOUTGIFT_GIFTNAME_PARAM] = m_giftName;
        int isBackPack = m_isBackPack ? 1 : 0;
        value[IMSENDANCHORHANGOUTGIFT_ISBACKPACK_PARAM] = isBackPack;
        int isPrivate = m_isPrivate ? 1 : 0;
        value[IMSENDANCHORHANGOUTGIFT_ISPRIVATE_PARAM] = isPrivate;
        value[IMSENDANCHORHANGOUTGIFT_GIFTNUM_PARAM] = m_giftNum;
        int isMultiClick = m_isMultiClick ? 1 : 0;
        value[IMSENDANCHORHANGOUTGIFT_MULTICLICK_PARAM] = isMultiClick;
        value[IMSENDANCHORHANGOUTGIFT_MULTICLICKSTART_PARAM] = m_multiClickStart;
        value[IMSENDANCHORHANGOUTGIFT_MULTICLICKEND_PARAM] = m_multiClickEnd;
        value[IMSENDANCHORHANGOUTGIFT_MULTICLICKID_PARAM] = m_multiClickId;
        data = value;
    }
    
    result = true;
    
    FileLog("ImClient", "SendAnchorHangoutGiftTask::GetSendData() end, result:%d", result);
    
    return result;
}

// 获取命令号
string SendAnchorHangoutGiftTask::GetCmdCode() const
{
    return ZB_CMD_SENDHANGOUTGIFT;
}

// 设置seq
void SendAnchorHangoutGiftTask::SetSeq(SEQ_T seq)
{
    m_seq = seq;
}

// 获取seq
SEQ_T SendAnchorHangoutGiftTask::GetSeq() const
{
    return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendAnchorHangoutGiftTask::IsWaitToRespond() const
{
    return true;
}

// 获取处理结果
void SendAnchorHangoutGiftTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
    errType = m_errType;
    errMsg = m_errMsg;
}

// 初始化参数
bool SendAnchorHangoutGiftTask::InitParam(const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate)
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
void SendAnchorHangoutGiftTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendAnchorHangoutGift(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}

