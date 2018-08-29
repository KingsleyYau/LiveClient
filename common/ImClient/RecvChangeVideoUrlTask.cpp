/*
 * author: Alex
 *   date: 2017-08-30
 *   file: RecvChangeVideoUrlTask.cpp
 *   desc: 3.12.接收观众／主播切换视频流通知接口 Task实现类
 */

#include "RecvChangeVideoUrlTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
//#define ROOMID_PARAM            "roomid"
#define ISANCHOR_PARAM          "is_anchor"
#define PLAYURL_PARAM           "play_url"
#define RCVU_USERID_PARAM       "userid"


RecvChangeVideoUrlTask::RecvChangeVideoUrlTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
}

RecvChangeVideoUrlTask::~RecvChangeVideoUrlTask(void)
{
}

// 初始化
bool RecvChangeVideoUrlTask::Init(IImClientListener* listener)
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
bool RecvChangeVideoUrlTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "RecvChangeVideoUrlTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
	
    string roomId = "";
    string userId = "";
    bool isAnchor = false;
    list<string> playUrl;
    // 协议解析
    if (!tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
		m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        if (tp.m_data[ROOMID_PARAM].isString()) {
            roomId = tp.m_data[ROOMID_PARAM].asString();
        }
        if (tp.m_data[RCVU_USERID_PARAM].isString()) {
            userId = tp.m_data[RCVU_USERID_PARAM].asString();
        }
        if (tp.m_data[ISANCHOR_PARAM].isIntegral()) {
            isAnchor = tp.m_data[ISANCHOR_PARAM].asInt() == 1 ? true : false;
        }
        if (tp.m_data[PLAYURL_PARAM].isArray()) {
            
            for (int i = 0; i < tp.m_data[PLAYURL_PARAM].size(); i++) {
                Json::Value element = tp.m_data[PLAYURL_PARAM].get(i, Json::Value::null);
                if (element.isString()) {
                    playUrl.push_back(element.asString());
                }
            }
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "RecvChangeVideoUrlTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        m_listener->OnRecvChangeVideoUrl(roomId, isAnchor, playUrl, userId);
        //m_listener->OnRecvChangeVideoUrl(roomId, isAnchor, playUrl);
		FileLog("ImClient", "RecvChangeVideoUrlTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "RecvChangeVideoUrlTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool RecvChangeVideoUrlTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "RecvChangeVideoUrlTask::GetSendData() begin");
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

	FileLog("ImClient", "RecvChangeVideoUrlTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string RecvChangeVideoUrlTask::GetCmdCode() const
{
	return CMD_RECVCHANGEVIDEOURL;
}

// 设置seq
void RecvChangeVideoUrlTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T RecvChangeVideoUrlTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool RecvChangeVideoUrlTask::IsWaitToRespond() const
{
	return false;
}

// 获取处理结果
void RecvChangeVideoUrlTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}


// 未完成任务的断线通知
void RecvChangeVideoUrlTask::OnDisconnect()
{

}
