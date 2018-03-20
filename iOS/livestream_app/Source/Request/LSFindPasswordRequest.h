//
//  LSFindPasswordRequest.h
//  dating
//  2.7.找回密码（仅独立）接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSFindPasswordRequest : LSSessionRequest
/*
 * @param sendMail           用户注册的邮箱
 * @param checkCode          验证码
 */
@property (nonatomic, copy) NSString* _Nonnull sendMail;
@property (nonatomic, copy) NSString* _Nonnull checkCode;
@property (nonatomic, strong) FindPasswordFinishHandler _Nullable finishHandler;
@end
