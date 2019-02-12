/*
 * HttpRequestConvertEnum.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 */

#ifndef REQUESTCONVERTENUM_H_
#define REQUESTCONVERTENUM_H_

#include "HttpRequestEnum.h"
#include <string>
using namespace std;

// action(新用户类型)
static const char* HTTPOTHER_ACTION_TYPE[] =
{
    "1",    // 新安装（SETUP）
    "2",    // 新用户（NEWUSER）
};

// 网点转为字符串
const char* GetHttpSiteId(HTTP_OTHER_SITE_TYPE siteType);
// 字符串转为网点
HTTP_OTHER_SITE_TYPE GetHttpSiteTypeByServerSiteId(const string& siteId);
// 获取指定位置的国家代码
string GetCountryCode(int code);
// 获取指定国家代码的位置
int GetCountryCode(const string& code);
// 获取其它国家代码的位置
int GetOtherCountryCode();

// 获取邮箱处理方式（0：SendChangeEmail 1:ReSend ）
string GetHandleEmailCode(int type);

HTTP_LCC_ERR_TYPE GetStringToHttpErrorType(const string& code);

// 将支付类型转为字符串
string GetLetterComsumeTypeStr(LSLetterComsumeType type);

#endif

