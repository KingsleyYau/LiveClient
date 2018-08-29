package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

/**
 * RoomIn消息内容
 * Created by Hunter Mun on 2017/6/15.
 */

public class IMRoomInMessageContent implements Serializable{

    public IMRoomInMessageContent(){

    }

    public IMRoomInMessageContent(String nickname,String riderId,String riderName,String riderImgLocalPath) {
        this.nickname = nickname;
        this.riderId = riderId;
        this.riderName = riderName;
        this.riderImgLocalPath = riderImgLocalPath;
    }

    public String nickname;      //谁
    public String riderId;      //座驾ID
    public String riderName;     //座驾名称
    public String riderImgLocalPath;     //座驾名称
}
