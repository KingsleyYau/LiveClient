//
//  ConfigItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSvrItemObject.h"

@interface ConfigItemObject : NSObject
/**
 * 同步配置结构体
 * imSvrUrl                   IM服务器ip或域名
 * httpSvrUrl                 http服务器ip或域名
 * addCreditsUrl		      充值页面URL
 * anchorPage                 主播资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * userLevel                  观众等级页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * intimacy                   观众与主播亲密度页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * userProtocol               观众协议页URL
 * termsOfUse                 使用条款URL（仅独立）
 * privacyPolicy              私隐政策URL（仅独立）
 * minAavilableVer            App最低可用的内部版本号（整型）
 * minAvailableMsg            App强制升级提示
 * newestVer                  App最新的内部版本号（整型）
 * newestMsg                  App普通升级提示
 * downloadAppUrl             下载App的url
 * svrList          流媒体服务器列表
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull addCreditsUrl;
@property (nonatomic, copy) NSString *_Nonnull anchorPage;
@property (nonatomic, copy) NSString *_Nonnull userLevel;
@property (nonatomic, copy) NSString *_Nonnull intimacy;
@property (nonatomic, copy) NSString *_Nonnull userProtocol;
@property (nonatomic, copy) NSString *_Nonnull termsOfUse;
@property (nonatomic, copy) NSString *_Nonnull privacyPolicy;
@property (nonatomic, assign) int minAavilableVer;
@property (nonatomic, copy) NSString *_Nonnull minAvailableMsg;
@property (nonatomic, assign) int newestVer;
@property (nonatomic, copy) NSString *_Nonnull newestMsg;
@property (nonatomic, copy) NSString *_Nonnull downloadAppUrl;
@property (nonatomic, strong) NSArray<LSSvrItemObject *>* _Nullable svrList;

@end
