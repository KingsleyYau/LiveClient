/*
 * author: Alex
 *   date: 2020-04-15
 *   file: LSLCScheduleInviteReplyItem.h
 *   desc:  LiveChat预付费邀请回复消息item
 */

#include "LSLCScheduleInviteReplyItem.h"
#include <common/CheckMemoryLeak.h>

LSLCScheduleInviteReplyItem::LSLCScheduleInviteReplyItem()
{
	m_scheduleId = "";
    m_isScheduleAccept = false;
    m_isScheduleFromMe = false;
    m_actionGmtTime = 0;
    m_durationAdjusted = 0;
}

LSLCScheduleInviteReplyItem::LSLCScheduleInviteReplyItem(LSLCScheduleInviteReplyItem * textItem) {
    if (NULL != textItem) {
        m_scheduleId = textItem->m_scheduleId;
        m_isScheduleAccept = textItem->m_isScheduleAccept;
        m_isScheduleFromMe = textItem->m_isScheduleFromMe;
        m_actionGmtTime = textItem->m_actionGmtTime;
        m_durationAdjusted = textItem->m_durationAdjusted;
    } else {
        m_scheduleId = "";
        m_isScheduleAccept = false;
        m_isScheduleFromMe = false;
        m_actionGmtTime = 0;
        m_durationAdjusted = 0;
    }
}

LSLCScheduleInviteReplyItem::~LSLCScheduleInviteReplyItem()
{

}

bool LSLCScheduleInviteReplyItem::Init(const string& scheduleId, bool isScheduleAccept, bool isScheduleFromMe, long long actionGmtTime, int durationAdjusted)
{
    m_scheduleId = scheduleId;
    m_isScheduleAccept = isScheduleAccept;
    m_isScheduleFromMe = isScheduleFromMe;
    m_actionGmtTime = actionGmtTime;
    m_durationAdjusted = durationAdjusted;
	return true;
}

