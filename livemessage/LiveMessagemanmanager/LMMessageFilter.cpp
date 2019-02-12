/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMMessageFilter.cpp
 *   desc: LiveChat文本消息过滤器
 */

#include "LMMessageFilter.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

#ifndef _WIN32
#include <regex.h>
#endif

static const char* s_pCheckArr[] = {
    "http://|HTTP://",
    "https://|HTTPS://",
    "ftp://|FTP://",
    "(([0-9]{3,4})+[-|\\s+])*[0-9]{5,11}",
    "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+",
    "((([0-9]{1,})+[-|\\s+]{1,}){3,})+([0-9]{1,})*",
    "((([0-9]{3,})+[\\n|\\r]{1,}){1,})+([0-9]{1,})*",
    "([0-9a-zA-Z])*[0-9a-zA-Z]+@([0-9a-zA-Z]+([\\s+]{0,})+[.]+[\\s+]{0,})+(com|net|cn|org|ru)+[\\s+]{0,}",
    "([0-9a-zA-Z]+[-._+&])*([0-9a-zA-Z]+([\\s+]{0,})+[.]+[\\s+]{0,})+(com|net|cn|org|ru)+[\\s+]{1,}",
    "([^A-Za-z]|^)fuck([^A-Za-z]|$)",
    "([^A-Za-z]|^)fucking([^A-Za-z]|$)",
    "([^A-Za-z]|^)fucked([^A-Za-z]|$)",
    "([^A-Za-z]|^)ass([^A-Za-z]|$)",
    "([^A-Za-z]|^)asshole([^A-Za-z]|$)",
    "([^A-Za-z]|^)cock([^A-Za-z]|$)",
    "([^A-Za-z]|^)dick([^A-Za-z]|$)",
    "([^A-Za-z]|^)suck([^A-Za-z]|$)",
    "([^A-Za-z]|^)sucking([^A-Za-z]|$)",
    "([^A-Za-z]|^)tit([^A-Za-z]|$)",
    "([^A-Za-z]|^)tits([^A-Za-z]|$)",
    "([^A-Za-z]|^)nipples([^A-Za-z]|$)",
    "([^A-Za-z]|^)horn([^A-Za-z]|$)",
    "([^A-Za-z]|^)horny([^A-Za-z]|$)",
    "([^A-Za-z]|^)pussy([^A-Za-z]|$)",
    "([^A-Za-z]|^)wet[^A-Za-z]+pussy([^A-Za-z]|$)",
    "([^A-Za-z]|^)shit([^A-Za-z]|$)",
    "([^A-Za-z]|^)make[^A-Za-z]+love([^A-Za-z]|$)",
    "([^A-Za-z]|^)making[^A-Za-z]love([^A-Za-z]|$)",
    "([^A-Za-z]|^)penis([^A-Za-z]|$)",
    "([^A-Za-z]|^)climax([^A-Za-z]|$)",
    "([^A-Za-z]|^)lick([^A-Za-z]|$)",
    "([^A-Za-z]|^)vagina([^A-Za-z]|$)",
    "([^A-Za-z]|^)sex([^A-Za-z]|$)",
    "([^A-Za-z]|^)oral[^A-Za-z]+sex([^A-Za-z]|$)",
    "([^A-Za-z]|^)anal[^A-Za-z]+sex([^A-Za-z]|$)"
};

static const char* s_pFilterStr = "******";

// 检测是否带有非法字符消息
bool LMMessageFilter::IsIllegalMessage(const string& message)
{
	bool result = false;

#ifndef _WIN32
	regex_t ex = {0};
	for (int i = 0; i < _countof(s_pCheckArr); i++)
	{
       string checkRegex("");
        // checkRegex = "(?i)";
        checkRegex += s_pCheckArr[i];
		if ( 0 == regcomp(&ex, checkRegex.c_str(), REG_EXTENDED|REG_NOSUB|REG_ICASE) )
		{
			result = (0 == regexec(&ex, message.c_str(), 0, NULL, 0));
			regfree(&ex);

			// 找到可匹配
			if ( result )
			{
				break;
			}
		}
	}
#endif

	return result;
}

// 过滤非法字符
string LMMessageFilter::FilterIllegalMessage(const string& message)
{
	string result("");

#ifndef _WIN32
	regex_t ex = {0};

	
    // 查找匹配字符串，并替换
    size_t begin = 0;
    while (true)
    {
        bool found = false;
        
        // 遍历正则表达式
        for (int i = 0; i < _countof(s_pCheckArr); i++)
        {
            // 新建正则表达式对象
            if ( 0 == regcomp(&ex, s_pCheckArr[i], REG_EXTENDED|REG_ICASE) )
            {
                regmatch_t pm = {0};
                if ( 0 == regexec(&ex, message.c_str() + begin, 1, &pm, 0) )
                {
                    // 找到匹配字符串
                    if ( pm.rm_so > 0 ) {
                        // 添加匹配位置之前的字符
                        result += message.substr(begin, (string::size_type)pm.rm_so);
                    }
                    // 起始位置偏移，过滤匹配字符
                    begin += pm.rm_eo;
                    // 添加替换字符
                    result += s_pFilterStr;
                    
                    found = true;
                }
                
                // 释放正则表达式对象
                regfree(&ex);
                // 匹配成功也要regfree（否则会内存漏）
                if (found) {
                    break;
                }
            }
        }
        
        if (!found)
        {
            // 添加没有匹配成功的字符
            result += message.at(begin);
            begin++;
        }
        
        if (begin >= message.length())
        {
            break;
        }
    }
#else
	result = message;
#endif

	return result;
}
