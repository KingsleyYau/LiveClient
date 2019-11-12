/*
 * author: Alex
 *   date: 2019-11-07
 *   file: ZBAnchorSwitchFlowTask.cpp
 *   desc: 3.11.主播切换推流Task实现类
 */

#include "ZBAnchorSwitchFlowTask.h"
#include "IZBTaskManager.h"
#include "IZBImClient.h"
#include "ZBAmfPublicParse.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define ZBANCHORSWITCHFLOW_ROOMID_PARAM           "room_id"
#define ZBANCHORSWITCHFLOW_DEVICETYPE_PARAM       "device_type"

// 返回参数定义
#define ZBANCHORSWITCHFLOW_PUSHURL_PARAM           "push_url"
#define ZBANCHORSWITCHFLOW_DEVICETYPE_PARAM        "device_type"

ZBAnchorSwitchFlowTask::ZBAnchorSwitchFlowTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = ZBLCC_ERR_FAIL;
	m_errMsg = "";
    
    m_roomId = "";
    m_deviceType = IMDEVICETYPE_UNKNOW;
    
}

ZBAnchorSwitchFlowTask::~ZBAnchorSwitchFlowTask(void)
{
}

// 初始化
bool ZBAnchorSwitchFlowTask::Init(IZBImClientListener* listener)
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
bool ZBAnchorSwitchFlowTask::Handle(const ZBTransportProtocol& tp)
{
	bool result = false;

	FileLog("ImClient", "ZBAnchorSwitchFlowTask::Handle() begin, tp.isRespond:%d, tp.cmd:%s, tp.reqId:%d"
            , tp.m_isRespond, tp.m_cmd.c_str(), tp.m_reqId);
		
     list<string> pushUrl;
    IMDeviceType deviceType = IMDEVICETYPE_UNKNOW;
    // 协议解析
    if (tp.m_isRespond) {
        result = (ZBLCC_ERR_PROTOCOLFAIL != tp.m_errno);
        m_errType = (ZBLCC_ERR_TYPE)tp.m_errno;
        m_errMsg = tp.m_errmsg;
        
        if (tp.m_data[ZBANCHORSWITCHFLOW_PUSHURL_PARAM].isArray()) {
            int i = 0;
            for (i = 0; i < tp.m_data[ZBANCHORSWITCHFLOW_PUSHURL_PARAM].size(); i++) {
                Json::Value element = tp.m_data[ZBANCHORSWITCHFLOW_PUSHURL_PARAM].get(i, Json::Value::null);
                if (element.isString()) {
                    pushUrl.push_back(element.asString());
                }
            }
        }
        
        if (tp.m_data[ZBANCHORSWITCHFLOW_DEVICETYPE_PARAM].isIntegral()) {
            deviceType = GetIMDeviceTypeWithInt(tp.m_data[ZBANCHORSWITCHFLOW_DEVICETYPE_PARAM].asInt());
        }
        
    }
    
    // 协议解析失败
    if (!result) {
		m_errType = ZBLCC_ERR_PROTOCOLFAIL;
		m_errMsg = "";
	}

	FileLog("ImClient", "ZBAnchorSwitchFlowTask::Handle() m_errType:%d", m_errType);

	// 通知listener
	if (NULL != m_listener) {
        bool success = (m_errType == ZBLCC_ERR_SUCCESS);
        m_listener->OnAnchorSwitchFlow(GetSeq(), success, m_errType, m_errMsg, pushUrl, deviceType);
		FileLog("ImClient", "ZBAnchorSwitchFlowTask::Handle() callback end, result:%d", result);
	}
	
	FileLog("ImClient", "ZBAnchorSwitchFlowTask::Handle() end");

	return result;
}
	
// 获取待发送的Json数据
bool ZBAnchorSwitchFlowTask::GetSendData(Json::Value& data)
{
	bool result = false;
	
	FileLog("ImClient", "ZBAnchorSwitchFlowTask::GetSendData() begin");
    {
        // 构造json协议
        Json::Value value;
        value[ZBANCHORSWITCHFLOW_ROOMID_PARAM] = m_roomId;
        value[ZBANCHORSWITCHFLOW_DEVICETYPE_PARAM] = GetIntWithIMDeviceType(m_deviceType);
        data = value;
    }

    result = true;

	FileLog("ImClient", "ZBAnchorSwitchFlowTask::GetSendData() end, result:%d", result);

	return result;
}

// 获取命令号
string ZBAnchorSwitchFlowTask::GetCmdCode() const
{
	return ZB_CMD_ANCHORSWITCHFLOW;
}

// 设置seq
void ZBAnchorSwitchFlowTask::SetSeq(SEQ_T seq)
{
	m_seq = seq;
}

// 获取seq
SEQ_T ZBAnchorSwitchFlowTask::GetSeq() const
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool ZBAnchorSwitchFlowTask::IsWaitToRespond() const
{
	return true;
}

// 获取处理结果
void ZBAnchorSwitchFlowTask::GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 初始化参数
bool ZBAnchorSwitchFlowTask::InitParam(const string& roomId, IMDeviceType deviceType)
{
	bool result = true;
    if (!roomId.empty()) {
        m_roomId = roomId;
        m_deviceType = deviceType;
        result = true;
    }
	return result;
}

// 未完成任务的断线通知
void ZBAnchorSwitchFlowTask::OnDisconnect()
{
	if (NULL != m_listener) {
        list<string> pushUrl;
        m_listener->OnAnchorSwitchFlow(m_seq, false, ZBLCC_ERR_CONNECTFAIL, IMLOCAL_ERROR_CODE_PARSEFAIL_DESC, pushUrl, IMDEVICETYPE_UNKNOW);
	}
}
