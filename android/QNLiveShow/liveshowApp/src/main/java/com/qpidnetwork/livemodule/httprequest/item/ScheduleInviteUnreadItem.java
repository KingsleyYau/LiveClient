package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Created by Hunter Mun on 2017/9/13.
 */

public class ScheduleInviteUnreadItem {

    public ScheduleInviteUnreadItem(){

    }

    public ScheduleInviteUnreadItem(int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount){
        this.total = total;
        this.pendingNum = pendingNum;
        this.confirmedUnreadCount = confirmedUnreadCount;
        this.otherUnreadCount = otherUnreadCount;
    }

    public int total;
    public int pendingNum;
    public int confirmedUnreadCount;
    public int otherUnreadCount;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("ScheduleInviteUnreadItem[");
        sb.append("total:"+total);
        sb.append(" pendingNum:"+pendingNum);
        sb.append(" confirmedUnreadCount:"+confirmedUnreadCount);
        sb.append(" otherUnreadCount:"+otherUnreadCount);
        sb.append("]");
        return sb.toString();
    }
}
