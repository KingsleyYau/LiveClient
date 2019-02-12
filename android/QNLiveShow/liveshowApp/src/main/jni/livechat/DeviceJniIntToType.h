/*
 * DeviceJniIntToType.h
 *
 *  Created on: 2016-07-12
 *      Author: Samson.Fan
 * Description: 处理Device数值与类型之间的转换
 */

#include <ProtocolCommon/DeviceTypeDef.h>

// 协议值转类型
TDEVICE_TYPE IntToDeviceType(int value);
// 类型转协议值
int DeviceTypeToInt(TDEVICE_TYPE type);
