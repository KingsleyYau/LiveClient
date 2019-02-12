/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCTextItem.h
 *   desc: LiveChat文本消息item
 */

#include "LSLCTextItem.h"
#include "LSLCMessageFilter.h"
#include <common/CheckMemoryLeak.h>

LSLCTextItem::LSLCTextItem()
{
	m_message = "";
    m_displayMsg = "";
	m_illegal = false;
}

LSLCTextItem::LSLCTextItem(LSLCTextItem * textItem) {
    if (NULL != textItem) {
        m_message = textItem->m_message;
        m_displayMsg = textItem->m_displayMsg;
        m_illegal = textItem->m_illegal;
    } else {
        m_message = "";
        m_displayMsg = "";
        m_illegal = false;
    }
}

LSLCTextItem::~LSLCTextItem()
{

}

bool LSLCTextItem::Init(const string& message, bool isSend)
{
    // 消息内容
    m_message = message;

    // 判断是否包含非法字符
	m_illegal = LSLCMessageFilter::IsIllegalMessage(message);
    
    // 显示消息内容
    if (isSend || !m_illegal) {
        m_displayMsg = message;
    }
    else {
        m_displayMsg = LSLCMessageFilter::FilterIllegalMessage(message);
    }
	return true;
}

