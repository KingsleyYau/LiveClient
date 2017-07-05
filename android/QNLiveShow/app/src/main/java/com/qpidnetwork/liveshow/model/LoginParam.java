package com.qpidnetwork.liveshow.model;

import com.qpidnetwork.httprequest.item.LoginItem;

import java.io.Serializable;

/**
 * 登录信息本地结构
 */
public class LoginParam implements Serializable{

    public LoginParam(){

    }

    public LoginParam(String areaNumber, String phoneNumber, String password){
        this.areaNumber = areaNumber;
        this.phoneNumber = phoneNumber;
        this.password = password;
    }
    public String areaNumber;
    public String phoneNumber;
    public String password;
}
