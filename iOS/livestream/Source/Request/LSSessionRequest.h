//
//  LSSessionRequest.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSRequestManager.h"
#import "LSSessionRequestManager.h"

@interface LSSessionRequest : NSObject

/**
 *  是否已经处理
 */
@property (nonatomic, assign) BOOL isHandleAlready;

/**
 *  接口返回处理器
 */
@property (nonatomic, weak) _Nullable id<SessionRequestDelegate> delegate;

/**
 *  请求管理器
 */
@property (nonatomic, strong) LSRequestManager* _Nonnull manager;

/**
 统一参数
 */
@property (nonatomic, strong) NSString* _Nullable token;

/**
 *  发送请求
 *
 *  @return YES:成功发起请求/NO:发起请求失败
 */
- (BOOL)sendRequest;

/**
 *  登陆失败, 调用返回
 *
 *  @param errnum 错误码
 *  @param errmsg 错误提示
 */
- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg;

- (void)finishRequest;
@end
