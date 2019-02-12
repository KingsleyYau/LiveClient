package com.qpidnetwork.qnbridgemodule.bean;

import java.io.Serializable;

public class AccountInfoBean implements Serializable {
    /**
     * 登录方式
     *
     */
    public enum LoginType {
        Default,
        Facebook,
    }

    public AccountInfoBean() {
        this.account = "";
        this.password = "";
        this.accessToken = "";
        this.type = LoginType.Default;
    }

    /**
     * 登录成功回调
     * @param account				电子邮箱
     * @param password			密码
     * @param type				登录方式(0:普通/1:facebook)
     */
    public AccountInfoBean(
            String account,
            String password,
            String accessToken,
            LoginType type,
            String userId
    ) {
        this.account = account;
        this.password = password;
        this.accessToken = accessToken;
        this.type = type;
        this.userId = userId;
    }
    public String account;
    public String password;
    public String accessToken;
    public LoginType type;
    public String userId;
}
