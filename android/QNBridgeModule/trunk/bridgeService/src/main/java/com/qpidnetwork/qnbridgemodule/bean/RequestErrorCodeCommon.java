package com.qpidnetwork.qnbridgemodule.bean;

/**
 * 公共逻辑错误码（兼容多Module）
 */
public class RequestErrorCodeCommon {

    /**
     * 本地错误代码 , 连接超时
     */
    public static final String COMMON_LOCAL_ERROR_CODE_TIMEOUT	= "COMMON_LOCAL_ERROR_CODE_TIMEOUT";

    /**
     * 普通错误
     */
    public static final String COMMON_LOCAL_ERROR_DEFAULT =	"COMMON_LOCAL_ERROR_CODE_PARSEFAIL";

    /**
     * 用户名与密码不正确
     */
    public static final String COMMON_USERNAME_PASSWORD_ERROR = "COMMON_USERNAME_PASSWORD_ERROR";

    /**
     * 无效验证码
     */
    public static final String COMMON_VERIFYCODE_INVALID = "COMMON_VERIFYCODE_INVALID";

    /**
     * 禁止登录
     */
    public static final String COMMON_LOGIN_UNABLE_ERROR = "COMMON_LOGIN_UNABLE_ERROR";
}
