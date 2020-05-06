/*
 * author: Alex
 *   date: 2020-04-10
 *   file: LSLCScheduleInviteItem.h
 *   desc: LiveChat预付费邀请消息item
 */

#pragma once

#include <string>
using namespace std;

#include "livechat/livechatItem/LSLCScheduleInfoItem.h"
#include <manrequesthandler/item/LSLCRecord.h>
#include <manrequesthandler/item/LSLCLiveScheduleSessionItem.h>

class LSLCScheduleInviteItem
{
public:
	LSLCScheduleInviteItem();
    LSLCScheduleInviteItem(LSLCScheduleInviteItem * textItem);
	virtual ~LSLCScheduleInviteItem();

public:
	// 初始化
	bool Init(const LSLCScheduleMsgItem& msgItem);
    bool InitRecord(const LSLCHttpScheduleInviteItem& msgItem);
    bool InitHttpRecord(const LSLCLiveScheduleSessionItem& msgItem);

public:
	string	m_sessionId;		// 消息内容
    SCHEDULEINVITE_TYPE m_type; //操作方式（SCHEDULEINVITE_PENDING:发送   SCHEDULEINVITE_CONFIRMED:接受    SCHEDULEINVITE_DECLINED:拒绝）
    string  m_timeZone;         // 时区字符串(HK (GMT +08:00))
    int  m_timeZoneValue;       // 时区值(8)
    int  m_sessionDuration;     // 原来会话时长(当是发送是)
    int  m_durationAdjusted;    // 修改会话时长(没有修改就为0)
    long long m_startGmtTime;   // 预约开始时间
    string  m_timePeriod;       // 时间周期(Mar 21, 14:00 - 15:00)
    long long m_actionGmtTime;  // 操作时间(接受，拒绝时间)
    long long m_sendGmtTime;    // 发送时间（发送或接收到的时间）
};
