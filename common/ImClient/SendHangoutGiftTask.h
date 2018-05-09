/*
 * author: Alex
 *   date: 2018-04-13
 *   file: SendHangoutGiftTask.h
 *   desc: 10.7.发送多人互动直播间礼物消息
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class SendHangoutGiftTask : public ITask
{
public:
    SendHangoutGiftTask(void);
    virtual ~SendHangoutGiftTask(void);
    
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
    bool InitParam(const string& roomId, const string& nickName, const string& toUid, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, bool isPrivate);
    
private:
    IImClientListener*    m_listener;
    
    SEQ_T           m_seq;        // seq
    
    LCC_ERR_TYPE    m_errType;    // 服务器返回的处理结果
    string            m_errMsg;    // 服务器返回的结果描述
    
    string                      m_roomId;
    string                      m_nickName;
    string                      m_toUid;
    string                      m_giftId;
    string                      m_giftName;
    bool                        m_isBackPack;
    bool                        m_isPrivate;
    int                         m_giftNum;
    bool                        m_isMultiClick;
    int                         m_multiClickStart;
    int                         m_multiClickEnd;
    int                         m_multiClickId;
};

