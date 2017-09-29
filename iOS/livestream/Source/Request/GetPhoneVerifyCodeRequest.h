//
//  GetPhoneVerifyCodeRequest.h
//  dating
//  6.6.获取手机验证码
//  Created by Alex on 17/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetPhoneVerifyCodeRequest : SessionRequest

@property (nonatomic, copy) NSString *_Nonnull country;
@property (nonatomic, copy) NSString *_Nonnull areaCode;
@property (nonatomic, copy) NSString *_Nonnull phoneNo;

@property (nonatomic, strong) GetPhoneVerifyCodeFinishHandler _Nullable finishHandler;
@end
