/*
 * author: Alex
 *   date: 2018-03-05
 *   file: ZBSendGiftTask.cpp
 *   desc: 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）TaskTask实现类
 */

#include "ZBSendGiftTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
//#define ROOMID_PARAM                "roomid"
#define NICKNAME_PARAM              "nickname"
#define GIFTID_PARAM                "giftid"
#define GIFTNAME_PARAM              "giftname"
#define ISBACKPACK_PARAM            "is_backpack"
#define GIFTNUM_PARAM               "giftnum"
#define MULTI_CLICK_PARAM           "multi_click"
#define MULTI_CLICK_START_PARAM     "multi_click_start"
#define MULTI_CLICK_END_PARAM       "multi_click_end"
#define MULTI_CLICK_ID_PARAM        "multi_click_id"

ZBSendGiftTask::ZBSendGiftTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_nickName = "";
    m_giftId = "";
    m_giftName = "";
    m_isBackPack = false;
    m_giftNum = 0;
    m_multi_click = false;
    m_multi_click_start = 0;
    m_multi_click_end = 0;
    m_multi_click_id = 0;
    
}

ZBSendGiftTask::~ZBSendGiftTask(void)
{
}

// 初始化
bool ZBSendGiftTask::Init(IZBImClientListener* listener)
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
bool ZBSendGiftTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBSendGiftTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    // 协议解析
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

	FileLog("ImClient", "ZBSendGiftTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnZBSendGift(GetSeq(), success, m_errType, m_errMsg);
		FileLog("ImClient", "ZBSendGiftTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBSendGiftTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBSendGiftTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBSendGiftTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOMID_PARAM] = m_roomId;
        value[NICKNAME_PARAM] = m_nickName;
        value[GIFTID_PARAM] = m_giftId;
        value[GIFTNAME_PARAM] = m_giftName;
        value[ISBACKPACK_PARAM] = m_isBackPack ? 1 : 0;
        value[GIFTNUM_PARAM] = m_giftNum;
        int isClick = m_multi_click ? 1 : 0;
        value[MULTI_CLICK_PARAM] = isClick;
//        if (isClick) {
        value[MULTI_CLICK_START_PARAM] = m_multi_click_start;
        value[MULTI_CLICK_END_PARAM] = m_multi_click_end;
        value[MULTI_CLICK_ID_PARAM] = m_multi_click_id;
//        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "ZBSendGiftTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBSendGiftTask::GetCmdCode() const
{
	return ZB_CMD_SENDGIFT;
}

// 设置seq
void ZBSendGiftTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBSendGiftTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBSendGiftTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBSendGiftTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBSendGiftTask::InitParam(const string& roomId, const string nickName, const string giftId, const string giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id)
{
	bool result = false;
    if (!roomId.empty()
        && !nickName.empty()
        && !giftId.empty()
        && !giftName.empty()) {
        m_roomId = roomId;
        m_nickName = nickName;
        m_giftId = giftId;
        m_giftName = giftName;
        m_isBackPack = isBackPack;
        m_giftNum = giftNum;
        m_multi_click = multi_click;
        m_multi_click_start = multi_click_start;
        m_multi_click_end = multi_click_end;
        m_multi_click_id = multi_click_id;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void ZBSendGiftTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnZBSendGift(GetSeq(), false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC);
    }
}
