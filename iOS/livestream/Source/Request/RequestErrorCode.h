//
//  RequestErrorCode.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#ifndef RequestErrorCode_h
#define RequestErrorCode_h

/**
 *  参数不正确
 */
#define PARAM_ERROR 10001

/**
 *  Session失效
 */
#define SESSION_TIMEOUT 10002

/**
 系统错误
 */
#define SYSTEM_ERROR 10003

/**
 其他设备登录
 */
#define LOGIN_BY_OTHER_DEVICE 10004

/**
 *  验证码不正确
 */
#define CHECKCODE_EMPTY @"MBCE1012"
#define CHECKCODE_ERROR @"MBCE1013"

/**
 *  Livechat消费余额不足
 */
#define LIVECHAT_NO_MONEY @"ERROR00003"

#endif /* RequestErrorCode_h */
