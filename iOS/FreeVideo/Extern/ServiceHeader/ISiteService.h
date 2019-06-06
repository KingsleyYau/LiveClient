//
//  ISiteService.h
//  dating
//  换站服务接口类
//  Created by Max on 2018/9/10.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#ifndef ISiteService_h
#define ISiteService_h

/**
 换站服务接口类
 */
@protocol ISiteService <NSObject>

#pragma mark - 获取换站身份接口
// 获取站点通用Token结果回调
typedef void (^AppChangeSitehHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *token);

/**
 初始化站点属性

 @param siteId 站点Id
 @param webSiteUrl 站点web域名
 @param appSiteUrl 站点app域名
 @param wapSiteUrl 站点msite域名
 */
- (void)initSite:(NSString *)siteId webSiteUrl:(NSString *)webSiteUrl appSiteUrl:(NSString *)appSiteUrl wapSiteUrl:(NSString *)wapSiteUrl;

/**
 使站点生效
 
 */
- (void)activeSite;

/**
 使站点失效
 
 */
- (void)inactiveSite;

/**
 切换到目标站点

 @param siteId 目标站点Id
 @param local 是否本地切换
 @param handler 切换结果回调
 */
- (void)changeSite:(NSString *)siteId local:(BOOL)local handler:(AppChangeSitehHandler)handler;

/**
 cleanCookies
 
 */
- (void)cleanCookies;
@end

#endif /* ISiteService_h */
