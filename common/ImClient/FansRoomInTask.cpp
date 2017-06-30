/*
 * author: Alex
 *   date: 2017-05-27
 *   file: FansRoomInTask.cpp
 *   desc: 3.1.观众进入直播间Task实现类
 */

#include "FansRoomInTask.h"
#include "ITaskManager.h"
#include "IImClient.h"
#include "AmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define TOKEN_PARAM            "token"
#define ROOMID_PARAM           "roomid"

// 返回参数定义
#define USERID_PARAM           "userid"
#define NICKNAME_PARAM         "nickname"
#define PHOTOURL_PARAM         "photourl"
#define COUNTRY_PARAM          "country"
#define VIDEOURL_PARAM         "videourl"
#define FANSNUM_PARAM          "fansnum"
#define CONTRIBUTE_PARAM       "contribute"
#define TOPFANS_PARAM          "topfans"
#define FANS_USERID_PARAM      "userid"
#define FANS_NICKNAME_PARAM    "nickname"
#define FANS_PHOTOURL_PARAM    "photourl"

FansRoomInTask::FansRoomInTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LCC_ERR_FAIL;
	m_errMsg = "";
    
    m_token = "";
    m_roomId = "";
    
    m_userId = "";
    m_nickName = "";
    m_photoUrl = "";
    m_country = "";
    m_fansNum = 0;
    m_contribute = 0;
}

FansRoomInTask::~FansRoomInTask(void)
{
}

// 初始化
bool FansRoomInTask::Init(IImClientListener* listener)
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
bool FansRoomInTask::Handle(const TransportProtocol& tp)
{
	bool result = false;

	FileLog("LiveChatClient", "AudienceRoomInTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
    RoomTopFanList list;
    // 协议解析
    if (tp.m_isRespond) {
        result = (LCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (LCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[USERID_PARAM].isString()) {
            m_userId = tp.m_data[USERID_PARAM].asString();
        }
        if (tp.m_data[NICKNAME_PARAM].isString()) {
            m_nickName = tp.m_data[NICKNAME_PARAM].asString();
        }
        if (tp.m_data[PHOTOURL_PARAM].isString()) {
            m_photoUrl = tp.m_data[PHOTOURL_PARAM].asString();
        }
        if (tp.m_data[COUNTRY_PARAM].isString()) {
            m_country = tp.m_data[COUNTRY_PARAM].asString();
        }
        if (tp.m_data[VIDEOURL_PARAM].isString()) {
            string strVideosURL = tp.m_data[VIDEOURL_PARAM].asString();
            
            size_t startPos = 0;
            size_t endPos = 0;
            while (true)
            {
                endPos = strVideosURL.find(VIDEOURL_PARAM, startPos);
                if (string::npos != endPos) {
                    // 获取photoURL并添加至列表
                    string strPhotoURL = strVideosURL.substr(startPos, endPos - startPos);
                    if (!strPhotoURL.empty()) {
                        m_videoUrl.push_back(strPhotoURL);
                    }
                    
                    // 移到下一个photoURL起始
                    startPos = endPos + strlen(VIDEOURL_PARAM);
                }
                else {
                    // 添加最后一个URL
                    string lastPhotoURL = strVideosURL.substr(startPos);
                    if (!lastPhotoURL.empty()) {
                        m_videoUrl.push_back(lastPhotoURL);
                    }
                    break;
                }
            }
        }
        if (tp.m_data[FANSNUM_PARAM].isInt()) {
            m_fansNum = tp.m_data[FANSNUM_PARAM].asInt();
        }
        if (tp.m_data[CONTRIBUTE_PARAM].isInt()) {
            m_contribute = tp.m_data[CONTRIBUTE_PARAM].asInt();
        }
        
        if (tp.m_data[TOPFANS_PARAM].isArray()) {
            int i = 0;
            for (i = 0; i < tp.m_data[TOPFANS_PARAM].size(); i++) {
                RoomTopFan item;
                Json::Value jItem = tp.m_data[TOPFANS_PARAM].get(i, Json::Value::null);
                if (jItem.isObject()) {
                    if (jItem[FANS_USERID_PARAM].isString()) {
                        item.userId = jItem[FANS_USERID_PARAM].asString();
                    }
                    if (jItem[FANS_NICKNAME_PARAM].isString()) {
                        item.nickName = jItem[FANS_NICKNAME_PARAM].asString();
                    }
                    if (jItem[FANS_PHOTOURL_PARAM].isString()) {
                        item.photoUrl = jItem[FANS_PHOTOURL_PARAM].asString();
                    }
                }
                list.push_back(item);
                
            }
        }

    }
    
    // 协议解析失败
    if (!result) {
		m_errType = LCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("LiveChatClient", "AudienceRoomInTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == LCC_ERR_SUCCESS);
        m_listener->OnFansRoomIn(GetSeq(), success, m_errType, m_errMsg, m_userId, m_nickName, m_photoUrl, m_country, m_videoUrl, m_fansNum, m_contribute, list);
		FileLog("LiveChatClient", "AudienceRoomInTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("LiveChatClient", "AudienceRoomInTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool FansRoomInTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("LiveChatClient", "AudienceRoomInTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[TOKEN_PARAM] = m_token;
        value[ROOMID_PARAM] = m_roomId;
        data = value;
    }

    result = true;

	FileLog("LiveChatClient", "AudienceRoomInTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string FansRoomInTask::GetCmdCode() const
{
	return CMD_FANSROOMIN;
}

// 设置seq
void FansRoomInTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T FansRoomInTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool FansRoomInTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void FansRoomInTask::GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool FansRoomInTask::InitParam(const string& token, const string& roomId)
{
	bool result = false;
    if (!token.empty()
        && !roomId.empty()) {
        m_token = token;
        m_roomId = roomId;
        
        result = true;
        
    }

	return result;
}

// 未完成任务的断线通知
void FansRoomInTask::OnDisconnect()
{
	if (NULL != m_listener) {
        list<string> videoUrls;
        RoomTopFanList list;
        m_listener->OnFansRoomIn(0, false, LCC_ERR_CONNECTFAIL, "", "", "", "", "", videoUrls, 0, 0, list);
	}
}
