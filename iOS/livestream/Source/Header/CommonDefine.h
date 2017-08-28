//
//  CommonDefine.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h

// 仅Debug模式输出consle log
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#define printf(...) printf{__VA_ARGS__}
#else
#define NSLog(...) {}
#define printf(...) {}
#endif

#define NSLocalizedStringFromSelf(key) NSLocalizedStringFromTable(key, [[self class] description], nil)
#define NSLocalizedStringFromErrorCode(key) NSLocalizedStringFromTable(key, @"LocalizableErrorCode", nil)

#define Color(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//16进制颜色转换
#define COLOR_WITH_16BAND_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define DESGIN_TRANSFORM_3X(V) (V*SCREEN_HEIGHT*1.0/640)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define ViewBoundsSize self.view.bounds.size

#define deviceTokenStringKEY @"deviceTokenString"

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#endif
