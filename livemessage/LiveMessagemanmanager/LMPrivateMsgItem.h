/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMPrivateMsgItem.h
 *   desc: 私信消息item
 */

#pragma once

#include <string>
using namespace std;

class LMPrivateMsgItem
{
public:
	LMPrivateMsgItem();
	virtual ~LMPrivateMsgItem();

public:
	// 初始化
	bool Init(const string& message, bool isSend);

public:
	string	m_message;		// 消息内容
    string  m_displayMsg;   // 用于显示的消息内容
	bool 	m_illegal;		// 内容是否非法
};
