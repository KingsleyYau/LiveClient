package com.qpidnetwork.livemodule.liveshow.liveroom.rebate;

import com.qpidnetwork.livemodule.im.listener.IMRebateItem;

/**
 * 此类仅适用于直播间余额及返点信息管理
 * Created by Hunter Mun on 2017/9/8.
 */

public class LiveRoomCreditRebateManager {

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
    private IMRebateItem imRebateItem = null;

    /**
     * 更新返点信息
     * @param rebateItem
     */
    public void setImRebateItem(IMRebateItem rebateItem){
        mLastRebatUpdate = System.currentTimeMillis();
        this.imRebateItem = rebateItem;
    }

    /**
     * 获取返点信息
     * @return
     */
    public IMRebateItem getImRebateItem(){
        return imRebateItem;
    }

    /**
     * 更新返点总数
     * @param rebate_credit
     */
    public void updateRebateCredit(double rebate_credit){
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
    }

    /**
     * 获取当前信用点余额
     * @return
     */
    public double getCredit(){
        return mCredit;
    }
}
