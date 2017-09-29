//
//  IQNService.h
//  dating
//
//  Created by Calvin on 17/9/8.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol IQNService  <NSObject>
@optional;

//获取模块名称
- (NSString *)getServiceName;

//打开URL
- (void)openUrl:(NSURL *)url fromVC:(UIViewController *)vc;

- (NSString *)getServiceConflict;

//是否需要停服务
- (BOOL)isStopService:(NSURL *)url;

//终止当前服务
- (void)stopService;

@end


