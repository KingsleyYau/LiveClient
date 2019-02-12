/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTask.h
 *   desc: LSLiveChatTask（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#pragma once

#include "ILSLiveChatTransportPacketHandler.h"
#include "LSLiveChatTaskDef.h"
#include "ILSLiveChatClient.h"
#include <list>

using namespace std;

class ILSLiveChatClientListener;
class ILSLiveChatTask
{
public:
	static ILSLiveChatTask* CreateTaskWithCmd(int cmd);

public:
	ILSLiveChatTask(void) {};
	virtual ~ILSLiveChatTask(void) {};

public:
	// 初始化
	virtual bool Init(ILSLiveChatClientListener* listener) = 0;
	// 处理已接收数据
	virtual bool Handle(const LSLiveChatTransportProtocol* tp) = 0;
	// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
	virtual bool GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen) = 0;
	// 获取待发送数据的类型
	virtual TASK_PROTOCOL_TYPE GetSendDataProtocolType() = 0;
	// 获取命令号
	virtual int GetCmdCode() = 0;
	// 设置seq
	virtual void SetSeq(unsigned int seq) = 0;
	// 获取seq
	virtual unsigned int GetSeq() = 0;
	// 是否需要等待回复
	virtual bool IsWaitToRespond() = 0;
	// 获取处理结果
	virtual void GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errmsg) = 0;
	// 未完成任务的断线通知
	virtual void OnDisconnect() = 0;
    // 任务已经发送
    virtual void OnSend();
};

// 定义任务列表
typedef list<ILSLiveChatTask*> TaskList;
