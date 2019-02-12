/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMPrivateMsgItem.h
 *   desc: 私信消息item
 */

#include "LMPrivateMsgItem.h"
#include "LMMessageFilter.h"
#include <common/CheckMemoryLeak.h>

LMPrivateMsgItem::LMPrivateMsgItem()
{
	m_message = "";
    m_displayMsg = "";
	m_illegal = false;
}

LMPrivateMsgItem::~LMPrivateMsgItem()
{

}

bool LMPrivateMsgItem::Init(const string& message, bool isSend)
{
    // 消息内容
    m_message = message;

    // 判断是否包含非法字符
	m_illegal = LMMessageFilter::IsIllegalMessage(message);
    
    // 显示消息内容
    if (isSend || !m_illegal) {
        m_displayMsg = message;
    }
    else {
        m_displayMsg = LMMessageFilter::FilterIllegalMessage(message);
    }
	return true;
}

