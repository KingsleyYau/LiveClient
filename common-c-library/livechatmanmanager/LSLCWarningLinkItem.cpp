/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCWarningLinkItem.cpp
 *   desc: LiveChat警告消息item
 */

#include "LSLCWarningLinkItem.h"
#include <common/CheckMemoryLeak.h>

LSLCWarningLinkItem::LSLCWarningLinkItem()
{
	m_linkMsg = "";
	m_linkOptType = Unknow;
}

LSLCWarningLinkItem::LSLCWarningLinkItem(const LSLCWarningLinkItem& item)
{
	m_linkMsg = item.m_linkMsg;
	m_linkOptType = item.m_linkOptType;
}

LSLCWarningLinkItem::~LSLCWarningLinkItem()
{

}

bool LSLCWarningLinkItem::Init(const string& linkMsg, LinkOptType linkOptType)
{
	m_linkMsg = linkMsg;
	m_linkOptType = linkOptType;
	return true;
}

