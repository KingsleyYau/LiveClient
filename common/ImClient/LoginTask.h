/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LoginTask.h
 *   desc: 2.1.登录Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>


using namespace std;

class LoginTask : public ITask
{
public:
	LoginTask(void);
	virtual ~LoginTask(void);

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
	bool InitParam(const string& token, PageNameType pageName, LoginVerifyType type = LOGINVERIFYTYPE_TOKEN);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq

	string			m_token;	// 统一验证身份标识
    PageNameType    m_pageName; // socket所在的页面
    LoginVerifyType m_type;       // 验证类型（1：token，2：cookice）（整型）
    

	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
};
