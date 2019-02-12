/*
 * LSLiveChatRequestEnumDefine.cpp
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestEnumDefine.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

static char CountryArray[][3] = {
		"AF",
		"AL",
		"DZ",
		"AS",
		"AD",
		"AO",
		"AI",
		"AQ",
		"AG",
		"AR",
		"AM",
		"AW",
		"AC",
		"AU",
		"AT",
		"AZ",
		"BS",
		"BH",
		"BD",
		"BB",
		"BY",
		"BE",
		"BZ",
		"BJ",
		"BM",
		"BT",
		"BO",
		"BA",
		"BW",
		"BV",
		"BR",
		"IO",
		"BN",
		"BG",
		"BF",
		"BI",
		"KH",
		"CM",
		"CA",
		"CV",
		"KY",
		"CF",
		"TD",
		"CL",
		"CN",
		"CX",
		"CC",
		"CO",
		"KM",
		"CG",
		"CD",
		"CK",
		"CR",
		"CI",
		"HR",
		"CU",
		"CY",
		"CZ",
		"DK",
		"DJ",
		"DM",
		"DO",
		"TP",
		"EC",
		"EG",
		"SV",
		"FK",
		"FO",
		"FJ",
		"FI",
		"FR",
		"FX",
		"GF",
		"PF",
		"TF",
		"GA",
		"GM",
		"GE",
		"DE",
		"GH",
		"GI",
		"GR",
		"GL",
		"GD",
		"GP",
		"GU",
		"GT",
		"GN",
		"GW",
		"GY",
		"HT",
		"HM",
		"VA",
		"HN",
		"HK",
		"HU",
		"IS",
		"IN",
		"ID",
		"IR",
		"IQ",
		"IE",
		"IL",
		"IT",
		"JM",
		"JP",
		"JO",
		"KZ",
		"KE",
		"KI",
		"KP",
		"KR",
		"KW",
		"KG",
		"LA",
		"LV",
		"LB",
		"LS",
		"LR",
		"LY",
		"LI",
		"LT",
		"LU",
		"MO",
		"MK",
		"MG",
		"MW",
		"MY",
		"MV",
		"ML",
		"MT",
		"MH",
		"MQ",
		"MR",
		"MU",
		"YT",
		"MX",
		"FM",
		"MD",
		"MC",
		"MN",
		"MS",
		"MA",
		"MZ",
		"MM",
		"NA",
		"NR",
		"NP",
		"NL",
		"AN",
		"NC",
		"NZ",
		"NI",
		"NE",
		"NG",
		"NU",
		"NF",
		"MP",
		"NO",
		"OM",
		"PK",
		"PW",
		"PS",
		"PA",
		"PG",
		"PY",
		"PE",
		"PH",
		"PN",
		"PL",
		"PT",
		"PR",
		"QA",
		"RE",
		"RO",
		"RU",
		"RW",
		"KN",
		"LC",
		"VC",
		"WS",
		"SM",
		"ST",
		"SA",
		"SN",
		"SC",
		"SL",
		"SG",
		"SK",
		"SI",
		"SB",
		"SO",
		"ZA",
		"GS",
		"ES",
		"LK",
		"SH",
		"PM",
		"SD",
		"SR",
		"SJ",
		"SZ",
		"SE",
		"CH",
		"SY",
		"TW",
		"TJ",
		"TZ",
		"TH",
		"TG",
		"TK",
		"TO",
		"TT",
		"TN",
		"TR",
		"TM",
		"TC",
		"TV",
		"UG",
		"UA",
		"AE",
		"GB",
		"US",
		"UM",
		"UY",
		"UZ",
		"VU",
		"VE",
		"VN",
		"VG",
		"VI",
		"WF",
		"EH",
		"YE",
		"YU",
		"ZM",
		"ZW",
		"OT",
};

// 获取指定位置的国家代码
string GetCountryCode(int code)
{
	string country = CountryArray[GetOtherCountryCode()];
	if (0 <= code && code < _countof(CountryArray))
	{
		country = CountryArray[code];
	}
	return country;
}

// 获取指定国家代码的位置
int GetCountryCode(const string& code)
{
	int pos = GetOtherCountryCode();
	for (int i = 0; i < _countof(CountryArray); i++)
	{
		if (0 == code.compare(CountryArray[i]))
		{
			pos = i;
			break;
		}
	}
	return pos;
}

// 获取其它国家代码的位置
int GetOtherCountryCode()
{
	return _countof(CountryArray) - 1;
}

// 回复类型
static const char* HandleEmail_TYPE_ARRAY[] = {
    "SendChangeEmail",
    "ReSend"
};

// 获取指定位置的国家代码
string GetHandleEmailCode(int type)
{
    string handleEmailType = "";
    if (0 <= type && type < _countof(HandleEmail_TYPE_ARRAY))
    {
        handleEmailType = HandleEmail_TYPE_ARRAY[type];
    }
    return handleEmailType;
}
