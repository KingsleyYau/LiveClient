//
//  IServiceManager.h
//  dating
//
//  Created by Calvin on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQNService.h"

@interface IServiceManager : NSObject

+ (instancetype _Nonnull)shareInstance;

- (void)addService:(id <IQNService> _Nonnull)service;

- (void)removeService:(id <IQNService> _Nonnull)service;

//注册互斥服务
- (void)startService:(id <IQNService> _Nonnull)service;

//注销互斥服务
- (void)stopService:(id <IQNService> _Nullable)service;

- (void)openSpecifyService:(NSURL * _Nonnull)url fromVC:(UIViewController * _Nonnull)vc;

@end
