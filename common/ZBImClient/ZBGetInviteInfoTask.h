/*
 * author: Alex
 *   date: 2018-03-08
 *   file: ZBGetInviteInfoTask.h
 *   desc: 9.5.获取指定立即私密邀请信息Task实现类
 */

#pragma once

#include "IZBTask.h"
#include <string>

using namespace std;

class ZBGetInviteInfoTask : public IZBTask
{
public:
	ZBGetInviteInfoTask(void);
	virtual ~ZBGetInviteInfoTask(void);

// ITask接口函数
public:
	// 初始化
	virtual bool Init(IZBImClientListener* listener);
	// 处理已接收数据
	virtual bool Handle(const ZBTransportProtocol& tp);
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
	virtual void GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg);
	// 未完成任务的断线通知
	virtual void OnDisconnect();

public:
	// 初始化参数
	bool InitParam(const string& invitationId);

private:
	IZBImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_invitationId;   // 邀请ID

	ZBLCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
};
