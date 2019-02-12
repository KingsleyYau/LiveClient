//
//  IErrorType.h
//  dating
//
//  Created by Max on 2018/9/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#ifndef IErrorType_h
#define IErrorType_h

// 登录状态类型
typedef enum {
    ErrorType_Success = 0,          // 成功
    ErrorType_UnknowError,          // 失败
    ErrorType_NetworkError,         // 网络错误
    ErrorType_CheckCodeError,       // 验证码错误
    ErrorType_PasswordError,        // 密码错误
    ErrorType_GetConfigError,       // 同步配置错误
    ErrorType_ChangeSiteError,      // 换站错误
    ErrorType_ShowSiteListError,    // 需要手动选站
} ErrorType;

#endif /* IErrorType_h */
