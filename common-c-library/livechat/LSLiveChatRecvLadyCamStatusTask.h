/*
 * author: Alex shum
 *   date: 2016-10-28
 *   file: LSLiveChatRecvLadyCamStatusTask.h
 *   desc: 女士Cam状态改变通知（仅男士端）Task实现类
 */

#pragma once

#include "ILSLiveChatTask.h"
#include <string>

using namespace std;

class LSLiveChatRecvLadyCamStatusTask : public ILSLiveChatTask
{
public:
	LSLiveChatRecvLadyCamStatusTask(void);
	virtual ~LSLiveChatRecvLadyCamStatusTask(void);

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


	string	                m_userId;		 // 女士Id
	USER_STATUS_PROTOCOL	m_statusId;	     // 状态类型（0：下线 1：上线 2：隐藏 3：绑定 4：解开 5：视频开放 6：视频关闭 7：Cam打开 8：Cam关闭）
	string	                m_server;	     // 服务器名称
	CLIENT_TYPE				m_clientType;	 // 客户端类型
	CamshareLadySoundType	m_sound;	     // 声音开关（0：开 1：关）（整形）
	string			        m_version;	     // 客户端版本号

};
