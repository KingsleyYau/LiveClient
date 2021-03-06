/*
 * author: Alex
 *   date: 2018-03-07
 *   file: ZBRecvEnterRoomNoticeTask.h
 *   desc: 3.6.接收观众进入直播间通知Task实现类（观众端／主播端接收观众进入直播间通知）
 */

#pragma once

#include "IZBTask.h"
#include <string>

using namespace std;

class ZBRecvEnterRoomNoticeTask : public IZBTask
{
public:
	ZBRecvEnterRoomNoticeTask(void);
	virtual ~ZBRecvEnterRoomNoticeTask(void);

// ITask接口函数
public:
	// 初始化
	virtual bool Init(IZBImClientListener* listener);
	// 处理已接收数据
	virtual bool Handle(const ZBTransportProtocol& tp);
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
	virtual void GetHandleResult(ZBLCC_ERR_TYPE& errType, string& errMsg);
	// 未完成任务的断线通知
	virtual void OnDisconnect();


private:
	IZBImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_roomId;      // 直播间ID
    string          m_userId;      // 观众ID
    string          m_nickName;    // 观众昵称
    string          m_photourl;    // 观众头像url
    string          m_riderId;     // 座驾ID
    string          m_riderName;   // 座驾名称
    string          m_riderUrl;    // 座驾图片url
    int             m_fansNum;     // 观众人数
    bool          m_hasTicket;   // 是否已购票（0：否，1：是）

	ZBLCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
};
