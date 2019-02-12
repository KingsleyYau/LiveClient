/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCSystemItem.h
 *   desc: LiveChat系统消息item
 */

#include "LSLCSystemItem.h"
#include <common/CheckMemoryLeak.h>

LSLCSystemItem::LSLCSystemItem()
{
	m_codeType = MESSAGE;
	m_message = "";
}

LSLCSystemItem::~LSLCSystemItem()
{

}

bool LSLCSystemItem::Init(const string& message)
{
	m_codeType = MESSAGE;
	m_message = message;
	return true;
}
