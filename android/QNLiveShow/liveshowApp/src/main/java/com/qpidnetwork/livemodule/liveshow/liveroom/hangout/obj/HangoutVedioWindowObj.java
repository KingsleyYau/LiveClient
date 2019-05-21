package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/4/27.
 */
public class HangoutVedioWindowObj {
    public String targetUserId;
    public String photoUrl;
    public String nickName;
    public boolean isUserSelf = false;  //用户（男士）
//    public boolean isManUser = false;
    public boolean isOnLine = false;

    public HangoutVedioWindowObj(){}

    public HangoutVedioWindowObj(String targetUserId, String photoUrl, String nickName, boolean isUserSelf){
        this.targetUserId = targetUserId;
        this.photoUrl = photoUrl;
        this.nickName = nickName;
        this.isUserSelf = isUserSelf;
//        this.isManUser = isManUser;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("HangoutVedioWindowObj[");
        sb.append("targetUserId:"+targetUserId);
        sb.append(" photoUrl:"+photoUrl);
        sb.append(" nickName:"+nickName);
        sb.append(" isUserSelf:"+ isUserSelf);
//        sb.append(" isManUser:"+isManUser);
        sb.append(" isOnLine:"+isOnLine);
        sb.append("]");
        return sb.toString();
    }
}
