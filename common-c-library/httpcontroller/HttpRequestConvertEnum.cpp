/*
 * HttpRequestConvertEnum.cpp
 *
 *  Created on: 2018-9-19
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "HttpRequestConvertEnum.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


const char* GetHttpSiteId(HTTP_OTHER_SITE_TYPE siteType) {
    const char* siteId = "";
    
    switch (siteType) {
        case HTTP_OTHER_SITE_CL:
            siteId = HTTP_OTHER_SYNCONFIG_CL;
            break;
        case HTTP_OTHER_SITE_IDA:
            siteId = HTTP_OTHER_SYNCONFIG_IDA;
            break;
        case HTTP_OTHER_SITE_CD:
            siteId = HTTP_OTHER_SYNCONFIG_CD;
            break;
        case HTTP_OTHER_SITE_LA:
            siteId = HTTP_OTHER_SYNCONFIG_LA;
            break;
        case HTTP_OTHER_SITE_AD:
            siteId = HTTP_OTHER_SYNCONFIG_AD;
            break;
        case HTTP_OTHER_SITE_LIVE:
            siteId = HTTP_OTHER_SYNCONFIG_LIVE;
            break;
        case HTTP_OTHER_SITE_PAYMENT:
            siteId = HTTP_OTHER_SYNCONFIG_PAYMENT;
            break;
            
        case HTTP_OTHER_SITE_ALL:break;
    }
    return siteId;
}


HTTP_OTHER_SITE_TYPE GetHttpSiteTypeByServerSiteId(const string& siteId) {
    HTTP_OTHER_SITE_TYPE siteType = HTTP_OTHER_SITE_UNKNOW;
    if(siteId == HTTP_OTHER_SYNCONFIG_CL){
        siteType = HTTP_OTHER_SITE_CL;
    }else if(siteId == HTTP_OTHER_SYNCONFIG_IDA){
        siteType = HTTP_OTHER_SITE_IDA;
    }else if(siteId == HTTP_OTHER_SYNCONFIG_CD){
        siteType = HTTP_OTHER_SITE_CD;
    }else if(siteId == HTTP_OTHER_SYNCONFIG_LA){
        siteType = HTTP_OTHER_SITE_LA;
    }else if(siteId == HTTP_OTHER_SYNCONFIG_AD){
        siteType = HTTP_OTHER_SITE_AD;
    }else if(siteId == HTTP_OTHER_SYNCONFIG_LIVE){
        siteType = HTTP_OTHER_SITE_LIVE;
    }
    return siteType;
}

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

// 回复类型
static const char* HandleLetter_COMSUME_TYPE_ARRAY[] = {
    "",
    "credit",
    "stamp"
};
string GetLetterComsumeTypeStr(LSLetterComsumeType type) {
    string handleLetterComsumeType = "";
    if (LSLETTERCOMSUMETYPE_UNKNOW <= type && type < _countof(HandleLetter_COMSUME_TYPE_ARRAY))
    {
        handleLetterComsumeType = HandleLetter_COMSUME_TYPE_ARRAY[type];
    }
    return handleLetterComsumeType;
}

static const char* HandUnlock_Action_TYPE_ARRAY[] = {
    "unlockByCredit",
    "unlockByKey"
};
// 将解锁类型转为字符串
string GetUnlockActionTypStr(LSUnlockActionType type) {
    string handUnlockActionTyp = HandUnlock_Action_TYPE_ARRAY[0];
    if (LSUNLOCKACTIONTYPE_CREDIT <= type && type < _countof(HandUnlock_Action_TYPE_ARRAY))
    {
        handUnlockActionTyp = HandUnlock_Action_TYPE_ARRAY[type];
    }
    return handUnlockActionTyp;
}

HTTP_LCC_ERR_TYPE GetStringToHttpErrorType(const string& code) {
    HTTP_LCC_ERR_TYPE type = HTTP_LCC_ERR_FAIL;
    if (code.length() <= 0) {
        type = HTTP_LCC_ERR_SUCCESS;
    }
    else if (code == HTTP_STRING_ERROR_NOLOGIN) {
        type = HTTP_LCC_ERR_NO_LOGIN;
    }
    else if (code == HTTP_STRING_ERROR_NOMATCHMAIL) {
        type = HTTP_LCC_ERR_DEMAIN_NO_FIND_MAIL;
    }
    else if (code == HTTP_STRING_ERROR_NOENTERCODE) {
        type = HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION;
    }
    else if (code == HTTP_STRING_ERROR_CODEERROR) {
        type = HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG;
    }
    else if (code == HTTP_STRING_ERROR_CURRENTPASSWORD) {
        type = HTTP_LCC_ERR_DEMAIN_CURRENT_PASSWORD_WRONG;
    }
    else if (code == HTTP_STRING_ERROR_ALLFIELDS) {
        type = HTTP_LCC_ERR_DEMAIN_ALL_FIELDS_WRONG;
    }
    else if (code == HTTP_STRING_ERROR_THEOPERATIONFSILED) {
        type = HTTP_LCC_ERR_DEMAIN_THE_OPERATION_FAILED;
    }
    else if (code == HTTP_STRING_ERROR_PASSWORDFORMAT) {
        type = HTTP_LCC_ERR_DEMAIN_PASSWORD_FORMAT_WRONG;
    }
    else if (code == HTTP_STRING_ERROR_DATAUPDATE) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_ERR;
    }
    else if (code == HTTP_STRING_ERROR_NOEXISTKEY) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY;
    }
    else if (code == HTTP_STRING_ERROR_UNCHANGEVALUE) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE;
    }
    else if (code == HTTP_STRING_ERROR_UNPASSVALUE) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE;
    }
    else if (code == HTTP_STRING_ERROR_UPDATEINFODESCLOG) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG;
    }
    else if (code == HTTP_STRING_ERROR_INSERTINFODESCLOG) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG;
    }
    else if (code == HTTP_STRING_ERROR_UPDATEINFODESCLOGSETGROUPID) {
        type = HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID;
    }
    else if (code == HTTP_STRING_ERROR_APPEXISTLOGS) {
        type = HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS;
    }
    else if (code == HTTP_STRING_ERROR_TOKENOUTTIME) {
        type = HTTP_LCC_ERR_TOKEN_EXPIRE;
    }
    
    return type;
}
