//
//  PhoneInfoObject.h
//  dating
//
//  Created by test on 17/11/29.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "LSLoginManager.h"

@interface LSPhoneInfoObject : NSObject

/** 移动设备型号 */
@property (nonatomic,copy) NSString * _Nonnull model;
/** 制造厂商 */
@property (nonatomic,copy) NSString * _Nonnull manufacturer;
/** 操作系统类型（如：Android等） */
@property (nonatomic,copy) NSString * _Nonnull osType;
/** 操作系统版本号 */
@property (nonatomic,copy) NSString * _Nonnull releaseVer;
/** SDK版本号 */
@property (nonatomic,copy) NSString * _Nonnull sdk;
/** 屏幕密度 */
@property (nonatomic,assign) double density;
/** 屏幕DPI */
@property (nonatomic,copy) NSString * _Nonnull densityDpi;
/** 屏幕宽度 */
@property (nonatomic,assign) int width;
/** 屏幕高度 */
@property (nonatomic,assign) int height;
/** 当前用户帐号（格式：P0:[manid]，manid为《登录》或《注册》接口返回） */
@property (nonatomic,copy) NSString * _Nonnull manId;
/** 客户端内部版本号 */
@property (nonatomic,assign) int verCode;
/** 客户端显示版本号 */
@property (nonatomic,copy) NSString * _Nonnull verName;
/** 手机类型 */
@property (nonatomic,assign) int phoneType;
/** 网络类型 */
@property (nonatomic,assign) int networkType;
/** 设备当前使用语言 */
@property (nonatomic,copy) NSString * _Nonnull language;
/** 设备当前国家 */
@property (nonatomic,copy) NSString *_Nonnull country;
/** 站点ID */
@property (nonatomic,assign) HTTP_OTHER_SITE_TYPE siteId;
/** 新用户类型（0：新安装，1：新用户） 注意（文档是1：新安装，2：新用户，但是c代码用了数组从0开始）*/
@property (nonatomic,assign) int action;
/** 手机号 */
@property (nonatomic,copy) NSString * _Nonnull lineNumber;
/** 设备唯一标识 */
@property (nonatomic,copy) NSString * _Nonnull deviceId;
/** sim卡服务商名字 */
@property (nonatomic,copy) NSString * _Nonnull simOptName;
/** sim卡移动国家码 */
@property (nonatomic,copy) NSString * _Nonnull simOpt;
/** sim卡ISO国家码 */
@property (nonatomic,copy) NSString * _Nonnull simCountryIso;
/** sim卡状态 */
@property (nonatomic,copy) NSString * _Nonnull simState;

- (LSPhoneInfoObject * _Nullable)initWithAction:(int)actionType;

+ (NSString* _Nonnull)iphoneType;

@end
