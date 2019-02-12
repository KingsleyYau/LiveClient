/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMWarningItem.h
 *   desc: 私信警告消息item
 */

#include "LMWarningItem.h"
#include <common/CheckMemoryLeak.h>

LMWarningItem::LMWarningItem()
{
	m_warnType = LMWarningType_Unknow;
}

LMWarningItem::~LMWarningItem()
{

}

bool LMWarningItem::Init(LMWarningType warnType)
{
    // 消息内容
    m_warnType = warnType;
	return true;
}

