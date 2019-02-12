/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMSystemItem.h
 *   desc: 私信系统消息item
 */

#pragma once

#include <string>
#include "ILiveMessageDef.h"
using namespace std;

class LMSystemItem
{
public:
	LMSystemItem();
	virtual ~LMSystemItem();

public:
	// 初始化
	bool Init(const string& message, LMSystemType type);

public:
	string	m_message;		// 消息内容
    LMSystemType m_systemType;  // 系统消息类型
};
