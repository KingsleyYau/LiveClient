/*
 * author: Alex
 *   date: 2018-04-13
 *   file: RecvRecommendHangoutNoticeTask.cpp
 *   desc: 10.1.接收主播推荐好友通知 Task实现类
 */

#include "RecvRecommendHangoutNoticeTask.h"
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

RecvRecommendHangoutNoticeTask::RecvRecommendHangoutNoticeTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvRecommendHangoutNoticeTask::~RecvRecommendHangoutNoticeTask(void)
{
}

// 初始化
bool RecvRecommendHangoutNoticeTask::Init(IImClientListener* listener)
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
bool RecvRecommendHangoutNoticeTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvRecommendHangoutNoticeTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    IMRecommendHangoutItem item;
    // 协议解析
    if (!tp.m_isRespond) {
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

	FileLog("ImClient", "RecvRecommendHangoutNoticeTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvRecommendHangoutNotice(item);
		FileLog("ImClient", "RecvRecommendHangoutNoticeTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvRecommendHangoutNoticeTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvRecommendHangoutNoticeTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvRecommendHangoutNoticeTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvRecommendHangoutNoticeTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvRecommendHangoutNoticeTask::GetCmdCode() const
{
	return CMD_RECVRECOMMENDHANGOUTNOTICE;
}

// 设置seq
void RecvRecommendHangoutNoticeTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvRecommendHangoutNoticeTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvRecommendHangoutNoticeTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvRecommendHangoutNoticeTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvRecommendHangoutNoticeTask::OnDisconnect()
{

}
