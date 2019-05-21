package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/4/26.
 */
public class HangOutBarGiftListItem {

    public String giftId;
    public String middleImgUrl;
    public int count = 0;

    public HangOutBarGiftListItem(){

    }

    public HangOutBarGiftListItem(String giftId, String middleImgUrl, int count){
        this.giftId =giftId;
        this.middleImgUrl =middleImgUrl;
        this.count =count;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("HangOutBarGiftListItem[");
        sb.append("giftId:");
        sb.append(giftId);
        sb.append(" middleImgUrl:");
        sb.append(middleImgUrl);
        sb.append(" count:");
        sb.append(count);
        sb.append("]");
        return sb.toString();
    }
}
