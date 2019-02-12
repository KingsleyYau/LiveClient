/*
 * author: Samson.Fan
 *   date: 2015-04-11
 *   file: LSLiveChatPlayVideoTask.h
 *   desc: 播放视频Task实现类
 */

#pragma once

#include "ILSLiveChatTask.h"
#include <string>

using namespace std;

class LSLiveChatPlayVideoTask : public ILSLiveChatTask
{
public:
	LSLiveChatPlayVideoTask(void);
	virtual ~LSLiveChatPlayVideoTask(void);

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
	bool InitParam(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket);

private:
	ILSLiveChatClientListener*	m_listener;

	unsigned int	m_seq;			// seq
	LSLIVECHAT_LCC_ERR_TYPE	m_errType;		// 服务器返回的处理结果
	string			m_errMsg;		// 服务器返回的结果描述

	string			m_userId;		// 对方用户ID
	string			m_inviteId;		// 邀请ID
	string			m_videoId;		// 视频ID
	string			m_sendId;		// 服务器返回的sendId
	bool			m_charget;		// 是否已付费
	string			m_videoDesc;	// 视频描述
	int				m_ticket;		// 票根
};
