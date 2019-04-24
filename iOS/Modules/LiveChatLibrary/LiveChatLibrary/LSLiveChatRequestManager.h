//
//  LSLiveChatRequestManager.h
//  dating
//
//  Created by Max on 18/11/10.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <httpclient/HttpRequestDefine.h>
#include <manrequesthandler/LSLiveChatRequestDefine.h>
#include <manrequesthandler/LSLiveChatRequestLadyDefine.h>

#import "LSLCCookiesItemObject.h"
#import "LSLCRecentVideoItemObject.h"

@interface LSLiveChatRequestManager : NSObject
@property (nonatomic, strong) NSString *versionCode;
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

#pragma mark - 公共模块
/**
 *  设置是否打印日志
 *
 *  @param enable enable 是否启用日志
 */
- (void)setLogEnable:(BOOL)enable;

/**
 *  设置接口目录
 *
 *  @param directory 可写入目录
 */
- (void)setLogDirectory:(NSString *)directory;

/**
 *  设置接口服务器域名
 *
 *  @param webSite Web接口服务器域名
 *  @param appSite App接口服务器域名
 */
- (void)setWebSite:(NSString *)webSite appSite:(NSString *)appSite wapSite:(NSString *)wapSite;

/**
 *  设置假服务器域名
 *
 *  @param fakeSite 假服务器域名
 */
- (void)setFakeSite:(NSString *)fakeSite;

/**
 *  设置换站域名(中心域名)
 *
 *  @param changeSite 换站域名(中心域名)
 */
- (void)setChangeSite:(NSString *)changeSite;

/**
 *  获取Web服务器域名
 */
- (NSString *)getWebSite;
/**
 *  获取app接口域名
 */
- (NSString *)getAppSite;
/**
 *  获取app接口域名
 */
- (NSString *)getWapSite;
/**
 *  获取换站域名(中心域名)
 */
- (NSString *)getChangeSite;

/**
 *  设置语音服务器域名
 *
 *  @param pubSite 语音服务器域名
 */
- (void)setVoiceSite:(NSString *)voiceSite;

/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString *)user password:(NSString *)password;

/**
 *  清除Cookies
 */
- (void)cleanCookies;

/**
 *  根据域名获取Cookies
 *
 *  @param site 域名
 */
- (void)getCookies:(NSString *)site;

/**
 *  获取所有CookiesItem
 *
 */
- (NSArray<LSLCCookiesItemObject *> *)getCookiesItem;

- (NSArray<NSHTTPCookie *> *)getHttpCookies;
/**
 *  停止请求接口
 *
 *  @param requestId 请求Id
 */
- (void)stopRequest:(NSInteger)requestId;

/**
 *  停止所有请求接口
 *
 */
- (void)stopAllRequest;

/**
 *  获取设备Id
 *
 *  @return 设备Id
 */
- (NSString *)getDeviceId;



#pragma mark - licvChat
/**
 *  12.13.获取最近已看微视频列表接口回调
 *
 *  @param success      成功失败
 *  @param total        邮件数
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param memberType   会员类型
 */

typedef void (^QueryRecentVideoListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSArray<LSLCRecentVideoItemObject*> *itemArray);
/**
 *  12.13.获取最近已看微视频列表接口
 *
 *  @param userSid          登录成功返回的sessionid
 *  @param userId           登录成功返回的manid
 *  @param womanId          主播ID
 *  @param finishHandler    回调
 */
- (NSInteger)queryRecentVideoList:(NSString *)userSid
                           userId:(NSString *)userId
                          womanId:(NSString *)womanId
                           finish:(QueryRecentVideoListFinishHandler)finishHandler;



@end
