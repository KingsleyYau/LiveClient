package com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal;

import java.util.ArrayList;

/**
 * 直播礼物
 * Created by Jagger on 2017/6/8.
 */

public class LiveGift {
    private Object obj ;
    private String giftId ;
    private ArrayList<ClickRange> mClickRanges = new ArrayList<>();
    private ClickRange mNewClickRange;    //最新连击数

    public Object getObj() {
        return obj;
    }

    public void setObj(Object obj) {
        this.obj = obj;
    }

    public String getGiftId() {
        return giftId;
    }

    public void setGiftId(String giftId) {
        this.giftId = giftId;
    }

    public ArrayList<ClickRange> getRanges() {
        return mClickRanges;
    }

    public void setNewRange(ClickRange newClickRange) {
        mNewClickRange = newClickRange;
        //如果新来的连击数范围，比原有的还小，则不添加
        if(mClickRanges.size() > 0){
            if(newClickRange.getRangeEnd() < mClickRanges.get(mClickRanges.size() - 1).getRangeEnd()){
                return;
            }
        }
        mClickRanges.add(newClickRange);
    }

    public ClickRange getmNewClickRange() {
        return mNewClickRange;
    }

    /**
     * 连击范围
     */
    public static class ClickRange {
        private int rangeStart ;
        private int rangeEnd ;

        public ClickRange(int start , int end ){
            rangeStart = start;
            rangeEnd = end;
        }

        public int getRangeStart() {
            return rangeStart;
        }

        public void setRangeStart(int rangeStart) {
            this.rangeStart = rangeStart;
        }

        public int getRangeEnd() {
            return rangeEnd;
        }

        public void setRangeEnd(int rangeEnd) {
            this.rangeEnd = rangeEnd;
        }
    }

}
