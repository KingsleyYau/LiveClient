/*
 * author: Alex
 *   date: 2017-05-27
 *   file: FansRoomInTask.h
 *   desc: 3.1.观众进入直播间Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class FansRoomInTask : public ITask
{
public:
	FansRoomInTask(void);
	virtual ~FansRoomInTask(void);

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
	bool InitParam(const string& token, const string& roomId);

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_token;    // 直播系统不同服务器的统一验证身份标识
    string          m_roomId;   // 直播间ID

	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
    string          m_userId;               // 主播ID
    string          m_nickName;             // 主播昵称
    string          m_photoUrl;             // 主播头像url
    string          m_country;              // 主播国家／地区
    list<string>          m_videoUrl;       // 视频流url
    int          m_fansNum;                 // 观众人数
    int          m_contribute;              // 贡献值
};
