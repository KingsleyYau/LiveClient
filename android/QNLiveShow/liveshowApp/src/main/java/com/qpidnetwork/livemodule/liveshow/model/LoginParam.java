package com.qpidnetwork.livemodule.liveshow.model;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;

import java.io.Serializable;

/**
 * 登录信息本地结构
 */
public class LoginParam implements Serializable{

    public LoginParam(){

    }

    public LoginParam(String userId, String qnToken, int qnWebsiteId){
        this.userId = userId;
        this.qnToken = qnToken;
        this.qnWebsiteId = qnWebsiteId;
    }

    public String qnToken;
    public String userId;
    public int qnWebsiteId;
}
