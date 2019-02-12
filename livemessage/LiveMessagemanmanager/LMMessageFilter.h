/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMMessageFilter.h
 *   desc: LiveChat文本消息过滤器
 */

#pragma once

#include <string>
using namespace std;

class LMMessageFilter
{
public:
	// 检测是否带有非法字符消息
	static bool IsIllegalMessage(const string& message);
	// 过滤非法字符
	static string FilterIllegalMessage(const string& message);
};
