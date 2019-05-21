package com.qpidnetwork.livemodule.liveshow.bubble;

/**
 * 冒泡消息数据Bean
 */
public class BubbleMessageBean {

    public BubbleMessageBean(){

    }

    public BubbleMessageBean(BubbleMessageType bubbleMsgType,
                             String anchorId,
                             String anchorName,
                             String anchorPhotoUrl,
                             String invitaionMsg){
        this.bubbleMsgType = bubbleMsgType;
        this.anchorId = anchorId;
        this.anchorName = anchorName;
        this.anchorPhotoUrl = anchorPhotoUrl;
        this.invitaionMsg = invitaionMsg;
    }

    public void updateAnchorFriendPhotoUrl(String anchorFriendPhotoUrl){
        this.anchorFriendPhotoUrl = anchorFriendPhotoUrl;
    }

    public void updateFirstShowTime(long firstShowTime){
        this.firstShowTime = firstShowTime;
    }

    public void  updateAutoInviteFlag(boolean isAuto){
        this.isAuto = isAuto;
    }

    public BubbleMessageType bubbleMsgType;
    public String anchorId;
    public String anchorName;
    public String anchorPhotoUrl;
    public String anchorFriendPhotoUrl;
    public String invitaionMsg;
    public long firstShowTime;      //纪录显示时当前事件，用于45秒倒计时使用,精确到毫秒
    public boolean isAuto;          //是否自动邀请（仅hangout使用）
}
