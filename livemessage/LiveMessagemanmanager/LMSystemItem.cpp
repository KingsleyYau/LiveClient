/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMSystemItem.cpp
 *   desc: 私信系统消息item
 */

#include "LMSystemItem.h"
#include <common/CheckMemoryLeak.h>

LMSystemItem::LMSystemItem()
{
	m_message = "";
}

LMSystemItem::~LMSystemItem()
{

}

bool LMSystemItem::Init(const string& message, LMSystemType type)
{
    // 消息内容
    m_message = message;
    m_systemType = type;
	return true;
}

