/*
 * author: Samson.Fan
 *   date: 2015-05-30
 *   file: Hearbeat.h
 *   desc: 心跳Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class HearbeatTask : public ITask
{
public:
	HearbeatTask(void);
	virtual ~HearbeatTask(void);

// ITask接口函数
public:
	// 初始化
	virtual bool Init(IImClientListener* listener);
	// 处理已接收数据
	virtual bool Handle(const TransportProtocol& tp);
	// 获取待发送的json数据
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

private:
	IImClientListener*	m_listener;
	SEQ_T	m_seq;
};
