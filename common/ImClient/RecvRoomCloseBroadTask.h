/*
 * author: Alex
 *   date: 2017-05-31
 *   file: RecvRoomCloseBroadTask.h
 *   desc: 3.4.接收直播间关闭Task实现类（直播端收到服务器的直播间关闭通知）
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class RecvRoomCloseBroadTask : public ITask
{
public:
	RecvRoomCloseBroadTask(void);
	virtual ~RecvRoomCloseBroadTask(void);

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
	bool InitParam(const string& roomId, int fansNum, int income, int newFans, int shares, int duration);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_roomId;      // 直播间ID
    int             m_fansNum;     // 观众人数
    int             m_income;      // 收入
    int             m_newFans;     // 新收藏人数
    int             m_shares;      // 分享数
    int             m_duration;      // 直播时长（秒）

	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
};
