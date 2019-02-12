/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCWarningItem.h
 *   desc: LiveChat警告消息item
 */

#pragma once

#include "LSLCWarningLinkItem.h"
#include <string>
using namespace std;

class LSLCWarningItem
{
public:


public:
	LSLCWarningItem();
    LSLCWarningItem(LSLCWarningItem* warningItem);
	virtual ~LSLCWarningItem();

public:
	// 初始化
	bool Init(const string& message);
	bool Init(const string& message, LSLCWarningLinkItem* linkItem);

public:
	WarningCodeType		m_codeType;		// 消息类型
	string				m_message;		// 消息内容
	LSLCWarningLinkItem*	m_linkItem;		// 链接item
};
