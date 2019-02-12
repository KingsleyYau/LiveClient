/*
 * DeviceJniIntToType.cpp
 *
 *  Created on: 2016-07-12
 *      Author: Samson.Fan
 * Description: 处理Device数值与类型之间的转换
 */

#include "DeviceJniIntToType.h"
#include <common/CommonFunc.h>

// 类型数组定义
static const int DeviceTypeArray[] = {
	DEVICE_TYPE_UNKNOW,			// 未知
	DEVICE_TYPE_WEB,			// Web
	DEVICE_TYPE_WEB_ANDROID_TABLET,  // Web Android Tablet
	DEVICE_TYPE_WEB_IOS_IPAD,        // Web iOS iPad
	DEVICE_TYPE_WEB_ANDROID_PHONE,   // Web Android Phone
	DEVICE_TYPE_WEB_IOS_PHONE,       // Web iOS Phone
	DEVICE_TYPE_WEB_OTHOR,           // Web Other
	DEVICE_TYPE_WEB_NOFLASH,         // Web noFlash
	DEVICE_TYPE_WAP,			// WAP
	DEVICE_TYPE_WAP_ANDROID,	// WAP Android
	DEVICE_TYPE_WAP_IPHONE,		// WAP iPhone
	DEVICE_TYPE_APP_ANDROID,	// App Android
	DEVICE_TYPE_APP_IPHONE,		// App iPhone
	DEVICE_TYPE_APP_IPAD,		// App iPad
	DEVICE_TYPE_APP_PC,			// App PC
	DEVICE_TYPE_APP_ANDROID_TABLET,  // App Android Tablet
};

// 协议值转类型
TDEVICE_TYPE IntToDeviceType(int value)
{
	return (TDEVICE_TYPE)(value < _countof(DeviceTypeArray) ? DeviceTypeArray[value] : DeviceTypeArray[0]);
}

// 类型转协议值
int DeviceTypeToInt(TDEVICE_TYPE type)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(DeviceTypeArray); i++)
	{
		if (type == DeviceTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}
