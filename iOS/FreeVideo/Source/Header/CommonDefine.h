//
//  CommonDefine.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h

#import <Foundation/Foundation.h>

#import "LiveBundle.h"
#import "Config.h"
#import "LSGoogleAnalyticsAction.h"

#define BOOL2YES(flag) flag?@"YES":@"NO"
#define BOOL2SUCCESS(flag) flag?@"Success":@"Fail"

#define ROW_TYPE @"ROW_TYPE"
#define ROW_SIZE @"ROW_SIZE"

#define WeakObject(Obj, weakObj) __weak typeof(Obj) weakObj = Obj

#ifdef DEBUG
#define DEBUG_STRING(str) str
#else
#define DEBUG_STRING(str) @""
#endif

#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
[[LiveBundle mainBundle] localizedStringForKey:key value:comment table:nil]
//#define NSLocalizedStringFromErrorCode(key) NSLocalizedStringFromTable(key, @"LocalizableErrorCode", nil)
#define NSLocalizedStringFromErrorCode(key) \
[[LiveBundle mainBundle] localizedStringForKey:key value:nil table:@"LocalizableErrorCode"]
//#define NSLocalizedStringFromSelf(key) NSLocalizedStringFromTable(key, [[self class] description], nil)
#define NSLocalizedStringFromSelf(key) \
[[LiveBundle mainBundle] localizedStringForKey:key value:nil table:[[self class] description]]

#define Color(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//16进制颜色转换
#define COLOR_WITH_16BAND_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_WITH_16BAND_RGB_ALPHA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]

#define DESGIN_TRANSFORM_3X(V) (V*SCREEN_HEIGHT*1.0/640)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define ViewBoundsSize self.view.bounds.size

#define IS_IPHONE_X (State_Bar_H != 20.0f) ? YES : NO

#define State_Bar_H (![[UIApplication sharedApplication] isStatusBarHidden] ? [[UIApplication sharedApplication] statusBarFrame].size.height : (IS_IPHONEX_SET ? 44.f : 20.f)) // 根据是否隐藏导航栏 判断导航栏高度
#define IS_IPHONEX_SET (SCREEN_HEIGHT == 812.f || SCREEN_HEIGHT == 896.f) // 是否是iPhoneX系列手机

#define deviceTokenStringKEY @"deviceTokenString"
#define DialogTag -1
#define IsDialog(view) ((view.tag & 0x8FFFFFFF) >> 31)

#endif
