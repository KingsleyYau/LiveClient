/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCWarningLinkItem.h
 *   desc: LiveChat警告消息的link item
 */

#pragma once

#include <string>
#include "ILSLiveChatManManagerEnumDef.h"
using namespace std;

class LSLCWarningLinkItem
{


public:
	LSLCWarningLinkItem();
	LSLCWarningLinkItem(const LSLCWarningLinkItem& item);
	virtual ~LSLCWarningLinkItem();

public:
	// 初始化
	bool Init(const string& linkMsg, LinkOptType linkOptType);

public:
	string		m_linkMsg;		// 链接文字内容
	LinkOptType	m_linkOptType;	// 链接操作类型
};
