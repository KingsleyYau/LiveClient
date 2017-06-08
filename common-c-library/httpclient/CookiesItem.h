/*
 * CookiesItem.h
 *
 *  Created on: 2016-09-28
 *      Author: Alex.shum
 * 
 */

#pragma once

#include <string>
using namespace std;

class CookiesItem
{
public:
	CookiesItem()
    {
        m_domain = "";
        m_accessOtherWeb = "";
        m_symbol = "";
        m_isSend = "";
        m_expiresTime = "";
        m_cName = "";
        m_value = "";
    }
	virtual ~CookiesItem()
    {
    }

public:
    // cookies的域
	string m_domain;
    // cookies的域
	string m_accessOtherWeb;
    // cookies是否接受其他web
	string m_symbol;
    // cookies的符号
	string m_isSend;
    // cookies的过期时间
	string m_expiresTime;
    // cookies的名字
	string m_cName;
    // cookies的值
	string m_value;
};

