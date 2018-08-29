package com.qpidnetwork.livemodule.liveshow.model;

import java.io.Serializable;

/**
 * 登录帐号信息
 * Created by Jagger on 2017/12/26.
 */

public class LoginAccount implements Serializable {
    /**
     * 第三方平台Token
     */
    public String authToken = "";

    /**
     * 邮箱
     */
    public String email = "";

    /**
     * 密码
     */
    public String passWord = "";
}
