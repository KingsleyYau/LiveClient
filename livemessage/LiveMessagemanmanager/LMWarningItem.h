/*
 * author: Alex.Shum
 *   date: 2018-7-24
 *   file: LMWarningItem.h
 *   desc: 私信警告消息item
 */

#pragma once

#include <string>
#include "ILiveMessageDef.h"
using namespace std;

class LMWarningItem
{
public:
	LMWarningItem();
	virtual ~LMWarningItem();

public:
	// 初始化
	bool Init(LMWarningType warnType);

public:
	LMWarningType	m_warnType;		// 警告类型
};
