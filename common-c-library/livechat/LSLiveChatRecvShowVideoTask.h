/*
 * author: Samson.Fan
 *   date: 2016-01-06
 *   file: LSLiveChatRecvShowVideoTask.h
 *   desc: 接收微视频被查看Task实现类
 */

#pragma once

#include "ILSLiveChatTask.h"
#include <string>

using namespace std;

class LSLiveChatRecvShowVideoTask : public ILSLiveChatTask
{
public:
	LSLiveChatRecvShowVideoTask(void);
	virtual ~LSLiveChatRecvShowVideoTask(void);

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

private:
	ILSLiveChatClientListener*	m_listener;

	unsigned int	m_seq;		// seq
	LSLIVECHAT_LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述

	string			m_toId;			// 接收用户Id（自己）
	string			m_fromId;		// 发送用户Id（对方）
	string			m_fromName;		// 发送用户名称
	string			m_inviteId;		// 邀请Id
	string			m_videoId;		// 微视频Id
	string			m_videoDesc;	// 微视频描述
	string			m_sendId;		// sendId
	bool			m_charget;		// 是否已付费
	int				m_ticket;		// 票根
};
