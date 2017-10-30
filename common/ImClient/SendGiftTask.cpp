/*
 * author: Alex
 *   date: 2017-08-15
 *   file: SendGiftTask.cpp
 *   desc: 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）TaskTask实现类
 */

#include "SendGiftTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>


// 请求参数定义
//#define ROOMID_PARAM                "roomid"
//#define NICKNAME_PARAM              "nickname"
#define GIFTID_PARAM                "giftid"
#define GIFTNAME_PARAM              "giftname"
#define ISBACKPACK_PARAM            "is_backpack"
#define GIFTNUM_PARAM               "giftnum"
#define MULTI_CLICK_PARAM           "multi_click"
#define MULTI_CLICK_START_PARAM     "multi_click_start"
#define MULTI_CLICK_END_PARAM       "multi_click_end"
#define MULTI_CLICK_ID_PARAM        "multi_click_id"


// 返回
#define CREDIT_PARAM                 "credit"
#define REBATECREDIT_PARAM           "rebate_credit"

SendGiftTask::SendGiftTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
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
    
    m_credit = 0.0;
    m_rebateCredit = 0.0;
}

SendGiftTask::~SendGiftTask(void)
{
}

// 初始化
bool SendGiftTask::Init(IImClientListener* listener)
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
bool SendGiftTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "SendGiftTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		

    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[CREDIT_PARAM].isNumeric()) {
            m_credit = tp.m_data[CREDIT_PARAM].asDouble();
        }
        if (tp.m_data[REBATECREDIT_PARAM].isNumeric()) {
            m_rebateCredit = tp.m_data[REBATECREDIT_PARAM].asDouble();
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "SendGiftTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnSendGift(GetSeq(), success, m_errType, m_errMsg, m_credit, m_rebateCredit);
		FileLog("ImClient", "SendGiftTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "SendGiftTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool SendGiftTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "SendGiftTask::GetSendData() begin");
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

	FileLog("ImClient", "SendGiftTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string SendGiftTask::GetCmdCode() const
{
	return CMD_SENDGIFT;
}

// 设置seq
void SendGiftTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T SendGiftTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool SendGiftTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void SendGiftTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool SendGiftTask::InitParam(const string& roomId, const string nickName, const string giftId, const string giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id)
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
void SendGiftTask::OnDisconnect()
{
    if (NULL != m_listener) {
        m_listener->OnSendGift(GetSeq(), false, LCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, 0.0, 0.0);
    }
}
