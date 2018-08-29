package com.qpidnetwork.anchor.liveshow.model;

import java.io.Serializable;

/**
 * 登录信息本地结构
 */
public class LoginParam implements Serializable{

    public LoginParam(){

    }

    public LoginParam(String userId, String qnToken){
        this.userId = userId;
        this.qnToken = qnToken;
    }

    public String qnToken;
    public String userId;
}
