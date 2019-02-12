/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCSystemItem.h
 *   desc: LiveChat系统消息item
 */

#pragma once

#include <string>
#include "ILSLiveChatManManagerEnumDef.h"
using namespace std;

class LSLCSystemItem
{
public:


public:
	LSLCSystemItem();
	virtual ~LSLCSystemItem();

public:
	bool Init(const string& message);

public:
	CodeType	m_codeType;	// 消息类型
	string	m_message;		// 消息内容
};
