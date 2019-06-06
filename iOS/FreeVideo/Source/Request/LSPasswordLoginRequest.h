//
//  LSPasswordLoginRequest.h
//  dating
//  2.20.帐号密码登录
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.20.帐号密码登录接口
 *
 * email             用户的email或id
 * password          登录密码
 * authCode          验证码
 *  finishHandler    接口回调

 */
@interface LSPasswordLoginRequest : LSSessionRequest
@property (nonatomic, copy) NSString * _Nullable email;
@property (nonatomic, copy) NSString * _Nullable password;
@property (nonatomic, copy) NSString * _Nullable authCode;
@property (nonatomic, strong) LoginWithPasswordFinishHandler _Nullable finishHandler;
@end
