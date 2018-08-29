package com.qpidnetwork.livemodule.liveshow.liveroom.rebate;

import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * 此类仅适用于直播间余额及返点信息管理
 * Created by Hunter Mun on 2017/9/8.
 */

public class LiveRoomCreditRebateManager {

    private static final String TAG = LiveRoomCreditRebateManager.class.getName();

    private static LiveRoomCreditRebateManager instance = null;
    private LiveRoomCreditRebateManager(){}

    public static LiveRoomCreditRebateManager getInstance(){
        if(null == instance){
            instance = new LiveRoomCreditRebateManager();
        }

        return instance;
    }
    //--------------------成员属性/方法-------------------

    private double mCredit = 0.0;
    private long mLastRebatUpdate = 0;
    private int mLastTimeValue = 0;
    private IMRebateItem imRebateItem = null;

    /**
     * 更新返点信息
     * @param rebateItem
     */
    public void setImRebateItem(IMRebateItem rebateItem){
        mLastRebatUpdate = System.currentTimeMillis();
        this.imRebateItem = rebateItem;
        if(rebateItem != null) {
            this.mLastTimeValue = rebateItem.cur_time;
        }
        Log.i(TAG, "setImRebateItem cur_time: " + imRebateItem.cur_time + " cur_credit: " + imRebateItem.cur_credit +
                " pre_time: " + imRebateItem.pre_time + " mLastRebatUpdate: " + mLastRebatUpdate);
    }

    /**
     * 刷新倒计时开始时间（解决进入直播间主播未推流时，需等待通知推流，返点倒计时才开始）
     */
    public void refreshRebateLastUpdate(){
        mLastRebatUpdate = System.currentTimeMillis();
    }

    /**
     * 获取返点信息
     * @return
     */
    public IMRebateItem getImRebateItem(){
        if(imRebateItem != null){
            synchronized (imRebateItem){
                int leftSeconds = 0;
                Log.i(TAG, "getImRebateItem reset before cur_time: " + imRebateItem.cur_time
                        + " cur_credit: " + imRebateItem.cur_credit
                        + " pre_time: " + imRebateItem.pre_time
                        + " mLastRebatUpdate: " + mLastRebatUpdate);

                long currTime = System.currentTimeMillis();
                int timeChanged = (int)((currTime - mLastRebatUpdate)/1000);
                leftSeconds = mLastTimeValue - timeChanged;
                Log.i(TAG,"getImRebateItem-currTime:"+currTime+" mLastRebatUpdate:"+mLastRebatUpdate
                        +" leftSeconds:"+leftSeconds+" timeChanged:"+timeChanged);
                if(leftSeconds <0){
                    leftSeconds = 0;
                }
                imRebateItem.cur_time = leftSeconds;
            }
            Log.i(TAG, "getImRebateItem reset after cur_time: " + imRebateItem.cur_time
                    + " cur_credit: " + imRebateItem.cur_credit +
                    " pre_time: " + imRebateItem.pre_time
                    + " mLastRebatUpdate: " + mLastRebatUpdate);
        }

        return imRebateItem;
    }

    /**
     * 更新返点总数
     * @param rebate_credit
     */
    public void updateRebateCredit(double rebate_credit){
        Log.i(TAG, "updateRebateCredit rebate_credit: " + rebate_credit);
        if(imRebateItem != null){
            imRebateItem.cur_credit = rebate_credit;
        }
    }

    /**
     * 更新本地账户余额
     * @param credit
     */
    public void setCredit(double credit){
        if(credit>=0){
            this.mCredit = credit;
        }
        Log.i(TAG, "setCredit credit: " + credit + " mCredit: " + mCredit);
    }

    /**
     * 获取当前信用点余额
     * @return
     */
    public double getCredit(){
        return mCredit;
    }
}
