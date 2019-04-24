/*
 * LSLiveChatEnumDefine.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATENUMDEFINE_H_
#define LSLIVECHATENUMDEFINE_H_

#include <string>
#include "ILSLiveChatErrCode.h"
using namespace std;


// 根据错误码判断是否余额不足
bool IsNotSufficientFundsWithErrCode(const string& errCode);
// 根据错误码判断是否Token过期通过字符串错误码
bool IsTokenOverWithString(const string& errCode);
// 根据错误码判断是否Token过期通过整型错误码
bool IsTokenOverWithInt(int errCode);

#endif /* LSLIVECHATENUMDEFINE_H_ */
