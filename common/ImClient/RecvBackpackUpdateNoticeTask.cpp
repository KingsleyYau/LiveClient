/*
 * author: Alex
 *   date: 2017-08-29
 *   file: RecvBackpackUpdateNoticeTask.cpp
 *   desc: 9.3.背包更新通知 Task实现类
 */

#include "RecvBackpackUpdateNoticeTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define GIFT_PARAM                  "gift"
#define GIFT_GIFTID_PARAM                   "giftid"
#define GIFT_NAME_PARAM                     "name"
#define GIFT_NUM_PARAM                      "num"
#define VOUCHER_PARAM               "voucher"
#define VOUCHER_ID_PARAM                    "id"
#define VOUCHER_PHOTOURL_PARAM              "photourl"
#define VOUCHER_DESC_PARAM                  "desc"
#define RIDE_PARAM                  "ride"
#define RIDE_ID_PARAM                       "id"
#define RIDE_PHOTOURL_PARAM                 "photourl"
#define RIDE_NAME_PARAM                     "name"

RecvBackpackUpdateNoticeTask::RecvBackpackUpdateNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvBackpackUpdateNoticeTask::~RecvBackpackUpdateNoticeTask(void)
{
}

// 初始化
bool RecvBackpackUpdateNoticeTask::Init(IImClientListener* listener)
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
bool RecvBackpackUpdateNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvBackpackUpdateNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    BackpackInfo item;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[GIFT_PARAM].isObject()) {
            Json::Value giftSon = tp.m_data[GIFT_PARAM];
            if (giftSon[GIFT_GIFTID_PARAM].isString()) {
                item.gift.giftId = giftSon[GIFT_GIFTID_PARAM].asString();
            }
            if (giftSon[GIFT_NAME_PARAM].isString()) {
                item.gift.name = giftSon[GIFT_NAME_PARAM].asString();
            }
            if (giftSon[GIFT_NUM_PARAM].isIntegral()) {
                item.gift.num = giftSon[GIFT_NUM_PARAM].asInt();
            }
        }
        if (tp.m_data[VOUCHER_PARAM].isObject()) {
            Json::Value voucherSon = tp.m_data[VOUCHER_PARAM];
            if (voucherSon[VOUCHER_ID_PARAM].isString()) {
                item.voucher.voucherId = voucherSon[VOUCHER_ID_PARAM].asString();
            }
            if (voucherSon[VOUCHER_PHOTOURL_PARAM].isString()) {
                item.voucher.photoUrl = voucherSon[VOUCHER_PHOTOURL_PARAM].asString();
            }
            if (voucherSon[VOUCHER_DESC_PARAM].isString()) {
                item.voucher.desc = voucherSon[VOUCHER_DESC_PARAM].asString();
            }
        }
        if (tp.m_data[RIDE_PARAM].isObject()) {
            Json::Value rideSon = tp.m_data[RIDE_PARAM];
            if (rideSon[RIDE_ID_PARAM].isString()) {
                item.ride.rideId = rideSon[RIDE_ID_PARAM].asString();
            }
            if (rideSon[RIDE_PHOTOURL_PARAM].isString()) {
                item.ride.photoUrl = rideSon[RIDE_PHOTOURL_PARAM].asString();
            }
            if (rideSon[RIDE_NAME_PARAM].isString()) {
                item.ride.name = rideSon[RIDE_NAME_PARAM].asString();
            }
        }
    
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvBackpackUpdateNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvBackpackUpdateNotice(item);
		FileLog("ImClient", "RecvBackpackUpdateNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvBackpackUpdateNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvBackpackUpdateNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvBackpackUpdateNoticeTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ROOT_ERRNO] = (int)m_errType;
        if (m_errType != LCC_ERR_SUCCESS) {
            value[ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvBackpackUpdateNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvBackpackUpdateNoticeTask::GetCmdCode() const
{
	return CMD_RECVBACKPACKUPDATENOTICE;
}

// 设置seq
void RecvBackpackUpdateNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvBackpackUpdateNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvBackpackUpdateNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvBackpackUpdateNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvBackpackUpdateNoticeTask::OnDisconnect()
{

}
