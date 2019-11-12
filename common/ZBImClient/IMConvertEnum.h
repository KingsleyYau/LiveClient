/*
 * IMConvertEnum.h
 *
 *  Created on: 2019-11-08
 *      Author: Alex
 */

#ifndef IMCONVERTENEM_H_
#define IMCONVERTENEM_H_

#include "IZBImClientDef.h"
#include <string>
using namespace std;


// 网点转为字符串
int GetIntWithIMDeviceType(IMDeviceType type);
// 字符串转为网点
IMDeviceType GetIMDeviceTypeWithInt(int value);


#endif

