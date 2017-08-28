package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

/**
 * Description:送礼请求实体封装类
 * <p>
 * Created by Harry on 2017/8/11.
 */

public class GiftSendReq {
    public GiftItem giftItem;
    public String mRoomId;
    public int count;
    public boolean isMultiClick;
    public int multiStart;
    public int multiEnd;
    public int multiClickId;

    public GiftSendReq(GiftItem giftItem,String mRoomId
            ,int count,boolean isMultiClick
            ,int multiStart,int multiEnd,int multiClickId){
        this.giftItem = giftItem;
        this.mRoomId = mRoomId;
        this.count = count;
        this.isMultiClick = isMultiClick;
        this.multiStart = multiStart;
        this.multiEnd = multiEnd;
        this.multiClickId = multiClickId;

    }

    @Override
    public String toString() {
        return "GiftSendReq[giftItem:"+giftItem
                +" mRoomId:"+mRoomId
                +" count:"+count
                +" isMultiClick:"+isMultiClick
                +" multiStart:"+multiStart
                +" multiEnd:"+multiEnd
                +" multiClickId:"+multiClickId
                +"]";
    }
}
