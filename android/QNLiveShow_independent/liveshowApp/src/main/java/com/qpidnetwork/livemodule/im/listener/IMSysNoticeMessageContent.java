package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

/**
 * SysNotice消息内容
 * Created by Hunter Mun on 2017/6/15.
 */

public class IMSysNoticeMessageContent implements Serializable{

    /**
     * 消息类型，用于界面显示
     */
    public enum SysNoticeType{
        Normal,			//普通文本
        PrivateChat,    //私聊
        CarIn,            //座驾入场
        Warning            //警告
    }

    public IMSysNoticeMessageContent(){

    }

    public IMSysNoticeMessageContent(String message,String link,SysNoticeType sysNoticeType){
        this.message = message;
        this.link = link;
        this.sysNoticeType = sysNoticeType;
    }

    public String message;      //消息内容
    public String link;      //链接URL
    public SysNoticeType sysNoticeType;
}
