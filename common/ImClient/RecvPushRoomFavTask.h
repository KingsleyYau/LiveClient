/*
 * author: Alex
 *   date: 2017-06-12
 *   file: RecvPushRoomFavTask.h
 *   desc: 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class RecvPushRoomFavTask : public ITask
{
public:
	RecvPushRoomFavTask(void);
	virtual ~RecvPushRoomFavTask(void);

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
	bool InitParam(const string& roomId, const string& fromId);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
    string          m_roomId;   // 直播间ID
    string          m_fromId;   // 发送方的用户ID
    string          m_nickName; // 发送人昵称
    bool            m_first;    // 是否第一次点赞（0:否 1:是）

};
