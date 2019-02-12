package com.qpidnetwork.livemodule.liveshow.model;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;

import java.io.Serializable;

/**
 * 登录信息本地结构
 */
public class LoginParam implements Serializable{

    public enum LoginType{
        Password,   //帐号密码登录
        Token       //QN TOKEN 登录
    }

    public LoginParam(){

    }

//    public LoginParam(String userId, String qnToken, int qnWebsiteId){
//        this.userId = userId;
//        this.qnToken = qnToken;
//        this.qnWebsiteId = qnWebsiteId;
//    }

    public LoginType loginType = LoginType.Password;
    public String account;
    public String password;
    public String token4Qn;
    public String memberId; //QN真实帐号 如:CM123465
}
