/*
 * author: Alex
 *   date: 2018-04-13
 *   file: EnterHangoutRoomTask.h
 *   desc: 10.3.观众新建/进入多人互动直播间（观众端新建/进入多人互动直播间）
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class EnterHangoutRoomTask : public ITask
{
public:
    EnterHangoutRoomTask(void);
    virtual ~EnterHangoutRoomTask(void);
    
    // ITask接口函数
public:
    // 初始化
    virtual bool Init(IImClientListener* listener);
    // 处理已接收数据
    virtual bool Handle(const TransportProtocol& tp);
    // 获取待发送的Json数据
    virtual bool GetSendData(Json::Value& data);
    // 获取命令号
    virtual string GetCmdCode() const;
    // 设置seq
    virtual void SetSeq(SEQ_T seq);
    // 获取seq
    virtual SEQ_T GetSeq() const;
    // 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
    virtual bool IsWaitToRespond() const;
    // 获取处理结果
    virtual void GetHandleResult(LCC_ERR_TYPE& errType, string& errMsg);
    // 未完成任务的断线通知
    virtual void OnDisconnect();
    
public:
    // 初始化参数
    bool InitParam(const string& roomId, bool isCreateOnly);
    
private:
    IImClientListener*    m_listener;
    
    SEQ_T           m_seq;        // seq
    
    string          m_roomId;      // 直播间ID（可无，无则表示新建，否则表示进入）
    bool            m_isCreateOnly; // 是否仅创建新的Hangout直播间，若已有Hangout直播间则先关闭（0：否，1：是）
    
    
    LCC_ERR_TYPE    m_errType;    // 服务器返回的处理结果
    string          m_errMsg;    // 服务器返回的结果描述
    
};

