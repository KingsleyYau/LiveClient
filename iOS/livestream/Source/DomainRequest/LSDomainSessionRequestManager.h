//
//  LSDomainSessionRequestManager.h
//  dating
//
//  Created by Max on 18/9/29.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <httpcontroller/HttpRequestEnum.h>

@class LSDomainSessionRequest;

#pragma mark - 需要重登陆的接口返回处理
@protocol DomainSessionRequestDelegate <NSObject>
/**
 *  请求返回
 *
 *  @param errnum 错误码
 *  @param errmsg 错误提示
 *
 *  @return YES:已经处理/NO:没有处理
 */
- (BOOL)request:(LSDomainSessionRequest* _Nonnull)request handleRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg;

/**
 *  请求处理完成
 *
 */
- (void)requestFinish:(LSDomainSessionRequest* _Nonnull)request;

@end

@interface LSDomainSessionRequestManager : NSObject <DomainSessionRequestDelegate>
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  发送请求
 *
 *  @param request 请求实例
 *
 *  @return YES:成功发起请求/NO:发起请求失败
 */
- (BOOL)sendRequest:(LSDomainSessionRequest* _Nonnull)request;

@end

