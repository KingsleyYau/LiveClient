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
 * imSvrUrl                IM服务器ip或域名
 * httpSvrUrl              http服务器ip或域名
 * addCreditsUrl		   充值页面URL
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull addCreditsUrl;

@end
