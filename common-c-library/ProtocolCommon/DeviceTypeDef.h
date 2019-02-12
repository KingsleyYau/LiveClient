/*
 * author: Samson.Fan
 *   date: 2016-07-12
 *   file: DeviceTypeDef.h
 *   desc: 设备类型定义
 */

#pragma once


// 设备类型
typedef enum {
//    DEVICE_TYPE_WEB = 10,            // Web
//    DEVICE_TYPE_WAP = 20,            // WAP
//    DEVICE_TYPE_WAP_ANDROID = 21,    // WAP Android
//    DEVICE_TYPE_WAP_IPHONE = 22,    // WAP iPhone
//    DEVICE_TYPE_APP_ANDROID = 30,    // App Android
//    DEVICE_TYPE_APP_IPHONE = 31,    // App iPhone
//    DEVICE_TYPE_APP_IPAD = 32,        // App iPad
//    DEVICE_TYPE_APP_PC = 33,        // App PC
//    DEVICE_TYPE_UNKNOW,                // 未知
    
    DEVICE_TYPE_WEB = 10,            // Web
    DEVICE_TYPE_WEB_ANDROID_TABLET = 11,  // Web Android Tablet
    DEVICE_TYPE_WEB_IOS_IPAD = 12,        // Web iOS iPad
    DEVICE_TYPE_WEB_ANDROID_PHONE = 13,   // Web Android Phone
    DEVICE_TYPE_WEB_IOS_PHONE = 14,       // Web iOS Phone
    DEVICE_TYPE_WEB_OTHOR = 15,           // Web Other
    DEVICE_TYPE_WEB_NOFLASH = 16,         // Web noFlash
    DEVICE_TYPE_WAP = 20,            // WAP
    DEVICE_TYPE_WAP_ANDROID = 21,    // WAP Android
    DEVICE_TYPE_WAP_IPHONE = 22,    // WAP iPhone
    DEVICE_TYPE_APP_ANDROID = 30,    // App Android
    DEVICE_TYPE_APP_IPHONE = 31,    // App iPhone
    DEVICE_TYPE_APP_IPAD = 32,        // App iPad
    DEVICE_TYPE_APP_PC = 33,        // App PC
    DEVICE_TYPE_APP_ANDROID_TABLET = 34, // App Android Tablet
    DEVICE_TYPE_UNKNOW,                // 未知
} TDEVICE_TYPE;
