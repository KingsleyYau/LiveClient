/*
 * author: Alex
 *   date: 2018-04-11
 *   file: RecvAnchorChangeVideoUrlTask.cpp
 *   desc: 10.10.接收观众/主播多人互动直播间视频切换通知Task实现类
 */

#include "RecvAnchorChangeVideoUrlTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
// 返回参数定义
#define ZBCHANGEVIDEOURL_ROOMID_PARAM               "roomid"
#define ZBCHANGEVIDEOURL_ISANCHOR_PARAM             "is_anchor"
#define ZBCHANGEVIDEOURL_USERID_PARAM               "userid"
#define ZBCHANGEVIDEOURL_PLAYURL_PARAM              "play_url"


RecvAnchorChangeVideoUrlTask::RecvAnchorChangeVideoUrlTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
}

RecvAnchorChangeVideoUrlTask::~RecvAnchorChangeVideoUrlTask(void)
{
}

// 初始化
bool RecvAnchorChangeVideoUrlTask::Init(IZBImClientListener* listener)
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
bool RecvAnchorChangeVideoUrlTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    // 协议解析
    string roomId = "";
    bool isAnchor = false;
    string userId = "";
    list<string> playUrl;
    if (!tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ZBCHANGEVIDEOURL_ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ZBCHANGEVIDEOURL_ROOMID_PARAM].asString();
        }
        if (tp.m_data[ZBCHANGEVIDEOURL_ISANCHOR_PARAM].isNumeric()) {
            isAnchor = tp.m_data[ZBCHANGEVIDEOURL_ISANCHOR_PARAM].asInt() == 0 ? false : true;
        }
        if (tp.m_data[ZBCHANGEVIDEOURL_USERID_PARAM].isString()) {
            userId = tp.m_data[ZBCHANGEVIDEOURL_USERID_PARAM].asString();
        }
        if (tp.m_data[ZBCHANGEVIDEOURL_PLAYURL_PARAM].isArray()) {
            int i = 0;
            for (i = 0; i < tp.m_data[ZBCHANGEVIDEOURL_PLAYURL_PARAM].size(); i++) {
                Json::Value element = tp.m_data[ZBCHANGEVIDEOURL_PLAYURL_PARAM].get(i, Json::Value::null);
                if (element.isString()) {
                    playUrl.push_back(element.asString());
                }
            }
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvAnchorChangeVideoUrl(roomId, isAnchor, userId, playUrl);
		FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvAnchorChangeVideoUrlTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZB_ROOT_ERRNO] = (int)m_errType;
        if (m_errType != ZBLCC_ERR_SUCCESS) {
            value[ZB_ROOT_ERRMSG] = m_errMsg;
        }
        data = value;
    }

    result = true;

	FileLog("ImClient", "RecvAnchorChangeVideoUrlTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvAnchorChangeVideoUrlTask::GetCmdCode() const
{
	return ZB_CMD_CHANGEVIDEOURL;
}

// 设置seq
void RecvAnchorChangeVideoUrlTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvAnchorChangeVideoUrlTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvAnchorChangeVideoUrlTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvAnchorChangeVideoUrlTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvAnchorChangeVideoUrlTask::OnDisconnect()
{

}
