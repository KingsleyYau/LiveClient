/*
 * author: Alex
 *   date: 2017-08-18
 *   file: SendPrivateLiveInviteTask.h
 *   desc: 7.1.观众立即私密邀请 Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class SendPrivateLiveInviteTask : public ITask
{
public:
	SendPrivateLiveInviteTask(void);
	virtual ~SendPrivateLiveInviteTask(void);

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
	bool InitParam(const string& userId, const string& logId, bool force);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_userId;   // 主播ID
    string          m_logId;    // 主播邀请的记录ID（可无，则表示操作未《接收主播立即私密邀请通知》触发）
    bool            m_force;    // 是否强制发送邀请（0:不强制发送邀请，若主播与他人私密中则返回失败 1:强制发送邀请）
    
	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
};
