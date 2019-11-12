package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import java.util.ArrayList;
import java.util.List;

/**
 * 购物车 礼品数量同步工具
 * @author Jagger 2019-10-11
 */
public class MyCartGiftsSynManager {
    enum Status{
        Loading,
        Waiting
    }

    public interface OnGiftsSynListener{
        void onSummitResult(boolean isSuccess);
    }

    public String anchorId = "", giftId = "";
    public int oldSum = 1, newSum = 1;
    private Status mStatus = Status.Waiting;
    private List<OnGiftsSynListener>  onGiftsSynListeners;

    public MyCartGiftsSynManager(){
        onGiftsSynListeners = new ArrayList<>();
    }

    public void addGiftsSynListener(OnGiftsSynListener onGiftsSynListener){
        onGiftsSynListeners.add(onGiftsSynListener);
    }

    public void summitChange(String anchorId, String giftId, int oldSum, int newSum){
        mStatus = Status.Loading;

        this.anchorId = anchorId;
        this.giftId = giftId;
        this.oldSum = oldSum;
        this.newSum = newSum;
    }

    public void confirmChange(){
        mStatus = Status.Waiting;
        for(OnGiftsSynListener listener:onGiftsSynListeners){
            listener.onSummitResult(true);
        }
        clean();
    }

    public void refuseChange(){
        mStatus = Status.Waiting;
        for(OnGiftsSynListener listener:onGiftsSynListeners){
            listener.onSummitResult(false);
        }
        clean();
    }

    public Status getStatus(){
        return mStatus;
    }

    private void clean(){
        anchorId = "";
        giftId = "";
        oldSum = 1;
        newSum = 1;
    }

    public void destroy(){
        onGiftsSynListeners.clear();
    }
}
