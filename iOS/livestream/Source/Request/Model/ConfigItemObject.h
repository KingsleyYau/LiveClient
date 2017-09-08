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
 * imSvrIp                   IM服务器ip或域名
 * imSvrPort                 IM服务器端口
 * httpSvrIp                 http服务器ip或域名
 * httpSvrPort		        http服务器端口
 * uploadSvrIp		        上传图片服务器ip或域名
 * uploadSvrPort		        上传图片服务器端口
 * addCreditsUrl		        充值页面URL
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrIp;
@property (nonatomic, assign) int imSvrPort;
@property (nonatomic, copy) NSString *_Nonnull httpSvrIp;
@property (nonatomic, assign) int httpSvrPort;
@property (nonatomic, copy) NSString *_Nonnull uploadSvrIp;
@property (nonatomic, assign) int uploadSvrPort;
@property (nonatomic, copy) NSString *_Nonnull addCreditsUrl;

@end
