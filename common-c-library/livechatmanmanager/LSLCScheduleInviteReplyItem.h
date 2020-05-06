/*
 * author: Alex
 *   date: 2020-04-15
 *   file: LSLCScheduleInviteReplyItem.h
 *   desc: LiveChat预付费邀请回复消息item
 */

#pragma once

#include <string>
using namespace std;

#include "livechat/livechatItem/LSLCScheduleInfoItem.h"
#include <manrequesthandler/item/LSLCRecord.h>

class LSLCScheduleInviteReplyItem
{
public:
	LSLCScheduleInviteReplyItem();
    LSLCScheduleInviteReplyItem(LSLCScheduleInviteReplyItem * textItem);
	virtual ~LSLCScheduleInviteReplyItem();

public:
	// 初始化
	bool Init(const string& scheduleId, bool isScheduleAccept, bool isScheduleFromMe, long long actionGmtTime, int durationAdjusted);

public:
	string	m_scheduleId;		// 预付费Id
    bool m_isScheduleAccept;    // 是否接受
    bool  m_isScheduleFromMe;   // 是否是男士回复
    long long m_actionGmtTime;  // 操作时间(接受，拒绝时间)
    int  m_durationAdjusted;    // 修改会话时长(没有修改就为0)
};
