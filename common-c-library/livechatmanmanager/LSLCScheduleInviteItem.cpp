/*
 * author: Alex
 *   date: 2020-04-10
 *   file: LSLCScheduleInviteItem.h
 *   desc:  LiveChat预付费邀请消息item
 */

#include "LSLCScheduleInviteItem.h"
#include <common/CheckMemoryLeak.h>

LSLCScheduleInviteItem::LSLCScheduleInviteItem()
{
	m_sessionId = "";
    m_type = SCHEDULEINVITE_PENDING;
    m_timeZone = "";
	m_timeZoneValue = 0;
    m_sessionDuration = 0;
    m_durationAdjusted = 0;
    m_startGmtTime = 0;
    m_timePeriod = "";
    m_actionGmtTime = 0;
    m_sendGmtTime = 0;
}

LSLCScheduleInviteItem::LSLCScheduleInviteItem(LSLCScheduleInviteItem * textItem) {
    if (NULL != textItem) {
        m_sessionId = textItem->m_sessionId;
        m_type = textItem->m_type;
        m_timeZone = textItem->m_timeZone;
        m_timeZoneValue = textItem->m_timeZoneValue;
        m_sessionDuration = textItem->m_sessionDuration;
        m_durationAdjusted = textItem->m_durationAdjusted;
        m_startGmtTime = textItem->m_startGmtTime;
        m_timePeriod = textItem->m_timePeriod;
        m_actionGmtTime = textItem->m_actionGmtTime;
        m_sendGmtTime = textItem->m_sendGmtTime;
    } else {
        m_sessionId = "";
        m_type = SCHEDULEINVITE_PENDING;
        m_timeZone = "";
        m_timeZoneValue = 0;
        m_sessionDuration = 0;
        m_durationAdjusted = 0;
        m_startGmtTime = 0;
        m_timePeriod = "";
        m_actionGmtTime = 0;
        m_sendGmtTime = 0;
    }
}

LSLCScheduleInviteItem::~LSLCScheduleInviteItem()
{

}

bool LSLCScheduleInviteItem::Init(const LSLCScheduleMsgItem& msgItem)
{
    m_sessionId = msgItem.sessionId;
    m_type = msgItem.type;
    m_timeZone = msgItem.timeZone;
    m_timeZoneValue = msgItem.timeZoneOffSet;
    m_sessionDuration = msgItem.sessionDuration;
    m_durationAdjusted = msgItem.durationAdjusted;
    m_startGmtTime = msgItem.startGmtTime;
    m_timePeriod = msgItem.timePeriod;
    if (msgItem.type == SCHEDULEINVITE_PENDING) {
        m_sendGmtTime = msgItem.actionGmtTime;;
    }
    else if (msgItem.type == SCHEDULEINVITE_CONFIRMED || msgItem.type == SCHEDULEINVITE_DECLINED) {
        m_actionGmtTime = msgItem.actionGmtTime;
    }
	return true;
}

bool LSLCScheduleInviteItem::InitRecord(const LSLCHttpScheduleInviteItem& msgItem)
{
    m_sessionId = msgItem.sessionId;
    m_type = GetScheduleInviteType(msgItem.type);
    m_timeZone = msgItem.timeZone;
    m_timeZoneValue = msgItem.timeZoneOffSet;
    m_sessionDuration = msgItem.sessionDuration;
    m_durationAdjusted = msgItem.durationAdjusted;
    m_startGmtTime = msgItem.startGmtTime;
    m_timePeriod = msgItem.timePeriod;
    if (m_type == SCHEDULEINVITE_PENDING) {
        m_sendGmtTime = msgItem.actionGmtTime;;
    }
    else if (m_type == SCHEDULEINVITE_CONFIRMED || m_type == SCHEDULEINVITE_DECLINED) {
        m_actionGmtTime = msgItem.actionGmtTime;
    }
    return true;
}

bool LSLCScheduleInviteItem::InitHttpRecord(const LSLCLiveScheduleSessionItem& msgItem)
{
    m_sessionId = msgItem.inviteId;
    m_type = GetScheduleInviteType(msgItem.status);
    m_timeZone = msgItem.timeZoneCity + "(GMT " + msgItem.timeZoneValue + ")";
    m_timeZoneValue = 0;
    m_sessionDuration = msgItem.duration;
    m_durationAdjusted = msgItem.duration;
    m_startGmtTime = msgItem.startTime;
    m_timePeriod = "";
    m_sendGmtTime = msgItem.addTime;
    m_actionGmtTime = msgItem.statusUpdateTime;
    
    return true;
}

