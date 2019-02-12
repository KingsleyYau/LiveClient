/*
 * author: Samson.Fan
 *   date: 2016-05-28
 *   file: LSLCCustomItem.h
 *   desc: LiveChat系统消息item
 */

#include "LSLCCustomItem.h"
#include <common/CheckMemoryLeak.h>

LSLCCustomItem::LSLCCustomItem()
{
	m_param = 0;
}

LSLCCustomItem::~LSLCCustomItem()
{

}

bool LSLCCustomItem::Init(long param)
{
	m_param = param;
	return true;
}
