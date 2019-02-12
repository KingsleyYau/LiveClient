/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMTimeMsgItem.h
 *   desc: 私信时间消息item
 */

#include "LMTimeMsgItem.h"
#include <common/CheckMemoryLeak.h>

LMTimeMsgItem::LMTimeMsgItem()
{
	m_msgTime = 0;
}

LMTimeMsgItem::~LMTimeMsgItem()
{

}

bool LMTimeMsgItem::Init(long msgTime)
{
    // 消息内容
    m_msgTime = msgTime;
	return true;
}

