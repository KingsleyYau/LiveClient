/*
 * author: Alex
 *   date: 2017-08-28
 *   file: RecvInstantInviteReplyNoticeTask.h
 *   desc: 7.3.接收立即私密邀请回复通知 Task实现类
 */

#pragma once

#include "ITask.h"
#include <string>

using namespace std;

class RecvInstantInviteReplyNoticeTask : public ITask
{
public:
	RecvInstantInviteReplyNoticeTask(void);
	virtual ~RecvInstantInviteReplyNoticeTask(void);

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

private:
	IImClientListener*	m_listener;

	SEQ_T           m_seq;		// seq
    
    string          m_inviteId;   // 邀请ID
    ReplyType       m_replyType;  // 主播回复 （0:拒绝 1:同意）
    string          m_roomId;    // 直播间ID （可无，m_replyType ＝ 1存在）
    RoomType        m_roomType;   // 直播间类型
    string          m_anchorId;   // 主播ID
    string          m_nickName;   // 主播昵称
    string          m_avatarImg;  // 主播头像url
    string          m_msg;        // 提示文字

	LCC_ERR_TYPE	m_errType;	// 服务器返回的处理结果
	string			m_errMsg;	// 服务器返回的结果描述
    
};
