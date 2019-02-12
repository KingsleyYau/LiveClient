/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMTimeMsgItem.h
 *   desc: 私信时间消息item
 */

#pragma once

#include <string>
#include "ILiveMessageDef.h"
using namespace std;

class LMTimeMsgItem
{
public:
	LMTimeMsgItem();
	virtual ~LMTimeMsgItem();

public:
	// 初始化
	bool Init(long msgTime);

public:
	long	m_msgTime;		// 警告类型
};
