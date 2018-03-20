/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTransportPacketHandler.cpp
 *   desc: 传输包处理实现类
 */

#include "ZBTransportPacketHandler.h"
#include "IZBTask.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
#include <json/json/json.h>


ZBCTransportPacketHandler::ZBCTransportPacketHandler(void)
{

}

ZBCTransportPacketHandler::~ZBCTransportPacketHandler(void)
{
}

// 组包
bool ZBCTransportPacketHandler::Packet(IZBTask* task, void* data, size_t dataSize, size_t& dataLen)
{
	//printf("CTransportPacketHandler::Packet() task:%p, data:%p, dataLen:%d\n", task, data, dataLen);

	FileLog("ZBImClient", "ZBCTransportPacketHandler::Packet() begin");

	// 获取task数据
    Json::Value req_data;
    task->GetSendData(req_data);
    
    // 组json
    Json::Value root;
    root[ZB_ROOT_ID] = task->GetSeq();
    root[ZB_ROOT_CMD] = task->GetCmdCode();
//    // 如果是回复服务器主动请求， 使用的是root_res
//    if (!IsRequestCmd(task->GetCmdCode())) {
//        root[ROOT_RES] = req_data;
//    } else {
//        if (!req_data.isNull()) {
//            root[ROOT_REQ] = req_data;
//        }
//    }
    
    if (!req_data.isNull()) {
        root[ZB_ROOT_REQ] = req_data;
    }
    // json转为字符串
    Json::FastWriter writer;
    string strData = writer.write(root);
    if (!strData.empty()
        && strData.c_str()[strData.length()-1] == '\0')
    {
        strData.erase(strData.length()-1, 1);
    }
    
    // copy至发送buffer
    bool result = false;
    if (dataSize > strData.length()) {
        strcpy((char*)data, strData.c_str());
        dataLen = strData.length();
        
        result = true;
    }
	
	FileLog("ZBImClient", "ZBCTransportPacketHandler::Packet() end, result:%d, strData:%s", result,  strData.c_str());

	return result;
}
	
// 解包
ZBUNPACKET_RESULT_TYPE ZBCTransportPacketHandler::Unpacket(const void* data, size_t dataLen, ZBTransportProtocol& tp)
{
    
	ZBUNPACKET_RESULT_TYPE result = ZBUNPACKET_FAIL;
    Json::Value root;
    Json::Reader reader;
    if (reader.parse((const char*)data, (const char*)data+dataLen, root))
    {
        do {
            // 解析id
            Json::Value reqId = root[ZB_ROOT_ID];
            if (reqId.isIntegral()) {
                tp.m_reqId = reqId.asUInt();
            }
            else {
                break;
            }
            
            // 解析route
            Json::Value cmd = root[ZB_ROOT_CMD];
            if (cmd.isString()) {
                tp.m_cmd = cmd.asString();
            }
            else {
                break;
            }
            
            // 解析req_data
            Json::Value reqData = root[ZB_ROOT_REQ];
            if (!reqData.isNull() && reqData.isObject()) {
                tp.m_isRespond = false;
                tp.m_data = reqData;
                // 解析字段成功设置错误码为0                                                                                                                                                                                                
                tp.m_errno = 0;
                tp.m_errmsg = "";
                
                result = ZBUNPACKET_SUCCESS;
            }
            
            // 解析res_data
            Json::Value resData = root[ZB_ROOT_RES];
            if (!resData.isNull() && resData.isObject()) {
                tp.m_isRespond = true;
                if (resData[ZB_ROOT_ERRNO].isInt()) {
                    tp.m_errno = resData[ZB_ROOT_ERRNO].asInt();
                }
                if (resData[ZB_ROOT_ERRMSG].isString()) {
                    tp.m_errmsg = resData[ZB_ROOT_ERRMSG].asString();
                }
                tp.m_data = resData[ZB_ROOT_DATA];
            
                result = ZBUNPACKET_SUCCESS;
            }
            
        } while (false);
    }
    
    if (result != ZBUNPACKET_SUCCESS) {
        tp.clear();
    }

	return result;
}
