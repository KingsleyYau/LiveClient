/*
 * author: alex
 *   date: 2018-03-2
 *   file: IZBTask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#pragma once

#include "IZBTransportPacketHandler.h"
#include "ZBTaskDef.h"
#include "IZBImClient.h"
#include <list>
#include <json/json/json.h>

using namespace std;

class IZBImClientListener;
class IZBTask
{
public:
	static IZBTask* CreateTaskWithCmd(const string& cmd);

public:
	IZBTask(void) {};
	virtual ~IZBTask(void) {};

public:
	// 初始化
	virtual bool Init(IZBImClientListener* listener) = 0;
	// 处理已接收数据
	virtual bool Handle(const ZBTransportProtocol& tp) = 0;
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
	virtual void GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errmsg) = 0;
	// 未完成任务的断线通知
	virtual void OnDisconnect() = 0;
    // 任务已经发送
    virtual void OnSend();
    
protected:

};

// 定义任务列表
typedef list<IZBTask*> ZBTaskList;
