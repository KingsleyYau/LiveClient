//
//  LSGetValidateCodeRequest.h
//  dating
//  2.22.获取验证码
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.22.获取验证码接口
 *
 *  validateCodeType   LSVALIDATECODETYPE_LOGIN:登录获取  LSVALIDATECODETYPE_FINDPW:找回密码获取
 *  finishHandler    接口回调

 */
@interface LSGetValidateCodeRequest : LSSessionRequest
@property (nonatomic, assign) LSValidateCodeType validateCodeType;
@property (nonatomic, strong) GetValidateCodeFinishHandler _Nullable finishHandler;
@end
