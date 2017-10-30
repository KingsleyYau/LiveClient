//
//  SubmitPhoneVerifyCodeRequest.h
//  dating
//  6.7.提交手机验证码
//  Created by Alex on 17/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface SubmitPhoneVerifyCodeRequest : LSSessionRequest

@property (nonatomic, copy) NSString *_Nonnull country;
@property (nonatomic, copy) NSString *_Nonnull areaCode;
@property (nonatomic, copy) NSString *_Nonnull phoneNo;
@property (nonatomic, copy) NSString *_Nonnull verifyCode;

@property (nonatomic, strong) SubmitPhoneVerifyCodeFinishHandler _Nullable finishHandler;
@end
