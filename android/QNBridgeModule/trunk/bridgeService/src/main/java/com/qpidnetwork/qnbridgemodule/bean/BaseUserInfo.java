package com.qpidnetwork.qnbridgemodule.bean;

import java.io.Serializable;

public class BaseUserInfo implements Serializable {

    private static final long serialVersionUID = -1540267980670737719L;

    public BaseUserInfo(){

    }

    public BaseUserInfo(String userId, String userName, String photoUrl){
        this.userId = userId;
        this.userName = userName;
        this.photoUrl = photoUrl;
    }

    public String userId;
    public String userName;
    public String photoUrl;
}
