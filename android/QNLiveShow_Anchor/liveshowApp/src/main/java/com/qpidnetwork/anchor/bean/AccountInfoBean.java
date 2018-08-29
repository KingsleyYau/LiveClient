package com.qpidnetwork.anchor.bean;

import java.io.Serializable;

/**
 * Created by Hunter Mun on 2018/3/5.
 */

public class AccountInfoBean implements Serializable{

    public AccountInfoBean(){

    }

    public AccountInfoBean(String broadcasterId
                            , String password){
        this.broadcasterId = broadcasterId;
        this.password = password;
    }

    public String broadcasterId;
    public String password;
}
