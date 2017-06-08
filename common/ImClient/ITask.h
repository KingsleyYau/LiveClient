/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#pragma once

#include "ITransportPacketHandler.h"
#include "TaskDef.h"
#include "IImClient.h"
#include <list>
#include <json/json/json.h>

using namespace std;

class IImClientListener;
class ITask
{
public:
	static ITask* CreateTaskWithCmd(const string& cmd);

public:
	ITask(void) {};
	virtual ~ITask(void) {};

public:
	// 初始化
	virtual bool Init(IImClientListener* listener) = 0;
	// 处理已接收数据
	virtual bool Handle(const TransportProtocol& tp) = 0;
	// 获取待发送的json数据
	virtual bool GetSendData(Json::Value& data) = 0;
	// 获取命令号
	virtual string GetCmdCode() const = 0;
	// 设置seq
	virtual void SetSeq(SEQ_T seq) = 0;
	// 获取seq
	virtual SEQ_T GetSeq() const = 0;
	// 是否需要等待回复
	virtual bool IsWaitToRespond() const = 0;
	// 获取处理结果
	virtual void GetHandleResult(LCC_ERR_TYPE& errType, string& errmsg) = 0;
	// 未完成任务的断线通知
	virtual void OnDisconnect() = 0;
    // 任务已经发送
    virtual void OnSend();
    
protected:

};

// 定义任务列表
typedef list<ITask*> TaskList;
