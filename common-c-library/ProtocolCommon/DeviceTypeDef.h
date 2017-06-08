/*
 * author: Samson.Fan
 *   date: 2016-07-12
 *   file: DeviceTypeDef.h
 *   desc: 设备类型定义
 */

#pragma once


// 设备类型
typedef enum {
	DEVICE_TYPE_WEB = 10,			// Web
	DEVICE_TYPE_WAP = 20,			// WAP
	DEVICE_TYPE_WAP_ANDROID = 21,	// WAP Android
	DEVICE_TYPE_WAP_IPHONE = 22,	// WAP iPhone
	DEVICE_TYPE_APP_ANDROID = 30,	// App Android
	DEVICE_TYPE_APP_IPHONE = 31,	// App iPhone
	DEVICE_TYPE_APP_IPAD = 32,		// App iPad
	DEVICE_TYPE_APP_PC = 33,		// App PC
	DEVICE_TYPE_UNKNOW,				// 未知
} TDEVICE_TYPE;
