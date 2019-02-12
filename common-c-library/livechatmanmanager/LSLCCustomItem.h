/*
 * author: Samson.Fan
 *   date: 2016-05-28
 *   file: LSLCCustomItem.h
 *   desc: LiveChat自定义消息item
 */

#pragma once

#include <string>
using namespace std;

class LSLCCustomItem
{
public:
	LSLCCustomItem();
	virtual ~LSLCCustomItem();

public:
	bool Init(long param);

public:
	long m_param;		// 消息参数
};
