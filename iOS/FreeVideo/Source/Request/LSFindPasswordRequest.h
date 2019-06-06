//
//  LSFindPasswordRequest.h
//  dating
//  2.16.找回密码
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.16.找回密码接口
 *
 *  sendMail            用户注册的邮箱
 *  checkCode           验证码（ver3.0起）
 *  finishHandler    接口回调

 */
@interface LSFindPasswordRequest : LSSessionRequest
@property (nonatomic, copy) NSString * _Nullable sendMail;
@property (nonatomic, copy) NSString * _Nullable checkCode;
@property (nonatomic, strong) FindPasswordFinishHandler _Nullable finishHandler;
@end
