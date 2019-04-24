/*
 * LSLiveChatEnumDefine.cpp
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatEnumDefine.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


// 根据错误码判断是否余额不足
bool IsNotSufficientFundsWithErrCode(const string& errCode) {
    bool result = false;
    if (0 == errCode.compare(LIVECHATERRCODE_NO_MONEY)) {
        result = true;
    }
    else if (0 == errCode.compare(LIVECHAT_NO_MONEY)) {
        result = true;
    }
    return result;
}

// 根据错误码判断是否Token过期通过字符串错误码
bool IsTokenOverWithString(const string& errCode) {
    bool result = false;
    if (0 == errCode.compare(LIVECHATERRCODE_TOKEN_OVER)) {
        result = true;
    }
    return result;
}

// 根据错误码判断是否Token过期通过整型错误码
bool IsTokenOverWithInt(int errCode) {
    bool result = false;
    if (errCode == 10004 || errCode == 10002) {
        result = true;
    }
    return result;
}


