/*
 * author: Alex
 *   date: 2017-06-12
 *   file: SendRoomGiftTask.h
 *   desc: 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class SendRoomGiftTask : public ITask
{
public:
	SendRoomGiftTask(void);
	virtual ~SendRoomGiftTask(void);

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
	bool InitParam(const string& roomId, const string token, const string nickName, const string giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_roomId;   // 直播间ID
    string          m_token;   // 直播系统不同服务器的统一验证身份标识
    string          m_nickName;  // 发送人昵称
    string          m_giftId;  // 礼物ID
    int             m_giftNum;  // 本次发送礼物的数量
    bool            m_multi_click;  // 是否连击礼物
    int             m_multi_click_start;  // 连击起始数
    int             m_multi_click_end;  // 连击结束数
    int             m_multi_click_id;   // 连击ID，相同则表示是同一次连击（生成方式：timestamp秒％10000）
    
	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
    double          m_coins;    // 剩余金币数

};
