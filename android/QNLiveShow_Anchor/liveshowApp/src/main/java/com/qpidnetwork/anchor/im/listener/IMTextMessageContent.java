package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

/**
 * Normal消息内容
 * Created by Hunter Mun on 2017/6/15.
 */

public class IMTextMessageContent implements Serializable{

    public IMTextMessageContent(){

    }

    public IMTextMessageContent(String message){
        this.message = message;
    }

    public String message;      //消息内容
}
