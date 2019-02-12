/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCWarningItem.h
 *   desc: LiveChat警告消息item
 */

#include "LSLCWarningItem.h"
#include <common/CheckMemoryLeak.h>

LSLCWarningItem::LSLCWarningItem()
{
	m_codeType = WARNING_MESSAGE;
	m_message = "";
	m_linkItem = NULL;
}

LSLCWarningItem::LSLCWarningItem(LSLCWarningItem* warningItem) {
    if (NULL != warningItem) {
        m_codeType = warningItem->m_codeType;
        m_message = warningItem->m_message;
        m_linkItem = new LSLCWarningLinkItem(*(warningItem->m_linkItem));
    }
}

LSLCWarningItem::~LSLCWarningItem()
{

}

bool LSLCWarningItem::Init(const string& message)
{
	m_codeType = WARNING_MESSAGE;
	m_message = message;
	return true;
}

bool LSLCWarningItem::Init(const string& message, LSLCWarningLinkItem* linkItem)
{
	m_codeType = WARNING_MESSAGE;
	m_message = message;
	m_linkItem = linkItem;
	return true;
}
