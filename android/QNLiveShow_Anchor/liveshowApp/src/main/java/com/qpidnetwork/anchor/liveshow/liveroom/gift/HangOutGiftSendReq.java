package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;

/**
 * Description:送礼请求实体封装类
 * <p>
 * Created by Harry on 2017/8/11.
 */

public class HangOutGiftSendReq {
    public GiftItem giftItem;
    public String mRoomId;
    public int count;
    public boolean isMultiClick;
    public int multiStart;
    public int multiEnd;
    public int multiClickId;
    public boolean isPackage = false;
    public boolean isPrivate = false;
    public String toUid;
    public String toUsername;

    public HangOutGiftSendReq(GiftItem giftItem, String mRoomId
            , String toUid, String toUsername, int count, boolean isMultiClick
            , int multiStart, int multiEnd, int multiClickId,
            boolean isPackage,boolean isPrivate){
        this.giftItem = giftItem;
        this.mRoomId = mRoomId;
        this.toUid = toUid;
        this.toUsername = toUsername;
        this.count = count;
        this.isMultiClick = isMultiClick;
        this.multiStart = multiStart;
        this.multiEnd = multiEnd;
        this.multiClickId = multiClickId;
        this.isPackage = isPackage;
        this.isPrivate = isPrivate;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("GiftSendReq[");
        sb.append("giftItem:");
        sb.append(giftItem);
        sb.append(" mRoomId:");
        sb.append(mRoomId);
        sb.append(" toUid:");
        sb.append(toUid);
        sb.append(" toUsername:");
        sb.append(toUsername);
        sb.append(" count:");
        sb.append(count);
        sb.append(" isMultiClick:");
        sb.append(isMultiClick);
        sb.append(" multiStart:");
        sb.append(multiStart);
        sb.append(" multiEnd:");
        sb.append(multiEnd);
        sb.append(" multiClickId:");
        sb.append(multiClickId);
        sb.append(" isPackage:");
        sb.append(isPackage);
        sb.append(" isPrivate:");
        sb.append(isPrivate);
        sb.append("]");
        return sb.toString();
    }
}
