//
//  ConfigItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull addCreditsUrl;
@property (nonatomic, copy) NSString *_Nonnull anchorPage;
@property (nonatomic, copy) NSString *_Nonnull userLevel;
@property (nonatomic, copy) NSString *_Nonnull intimacy;
@property (nonatomic, copy) NSString *_Nonnull userProtocol;

@end
