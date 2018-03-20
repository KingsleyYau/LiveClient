//
// LSGetVerificationCodeRequest.h
//  dating
//  2.10.获取验证码（仅独立））接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetVerificationCodeRequest : LSSessionRequest
//verifyType       验证码种类，（VERIFYCODETYPE_LOGIN：登录；VERIFYCODETYPE_FINDPW：找回密码）
@property (nonatomic, assign) VerifyCodeType verifyType;
//useCode          是否需要验证码，（1：必须；0：不限，服务端自动检测ip国家）
@property (nonatomic, assign) BOOL useCode;
@property (nonatomic, strong) GetVerificationCodeFinishHandler _Nullable finishHandler;
@end
