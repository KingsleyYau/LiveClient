/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCTextItem.h
 *   desc: LiveChat文本消息item
 */

#pragma once

#include <string>
using namespace std;

class LSLCTextItem
{
public:
	LSLCTextItem();
    LSLCTextItem(LSLCTextItem * textItem);
	virtual ~LSLCTextItem();

public:
	// 初始化
	bool Init(const string& message, bool isSend);

public:
	string	m_message;		// 消息内容
    string  m_displayMsg;   // 用于显示的消息内容
	bool 	m_illegal;		// 内容是否非法
};
