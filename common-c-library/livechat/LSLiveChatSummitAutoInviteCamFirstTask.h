/*
 * LSLiveChatSummitAutoInviteCamFirstTask.h
 * author: Hunter Mun
 * date: 2017-03-24
 * desc: 提交小助手Cam优先设置到服务器
 */

#pragma once

#include "ILSLiveChatTask.h"
#include <string>

using namespace std;

class LSLiveChatSummitAutoInviteCamFirstTask : public ILSLiveChatTask
{
public:
	LSLiveChatSummitAutoInviteCamFirstTask(void);
	virtual ~LSLiveChatSummitAutoInviteCamFirstTask(void);

// ITask接口函数
public:
	// 初始化
	virtual bool Init(ILSLiveChatClientListener* listener);
	// 处理已接收数据
	virtual bool Handle(const LSLiveChatTransportProtocol* tp);
	// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
	virtual bool GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen);
	// 获取待发送数据的类型
	virtual TASK_PROTOCOL_TYPE GetSendDataProtocolType();
	// 获取命令号
	virtual int GetCmdCode();
	// 设置seq
	virtual void SetSeq(unsigned int seq);
	// 获取seq
	virtual unsigned int GetSeq();
	// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
	virtual bool IsWaitToRespond();
	// 获取处理结果
	virtual void GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg);
	// 未完成任务的断线通知
	virtual void OnDisconnect();

public:
	// 初始化参数
	bool InitParam(bool camFirst);

private:
	ILSLiveChatClientListener*	m_listener;

	unsigned int	m_seq;		// seq
	LSLIVECHAT_LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述

	bool	m_camFirst;			// 小助手Cam优先标志位
};
