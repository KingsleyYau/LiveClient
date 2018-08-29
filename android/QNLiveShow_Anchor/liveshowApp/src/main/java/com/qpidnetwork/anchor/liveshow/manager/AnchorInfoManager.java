package com.qpidnetwork.anchor.liveshow.manager;

import com.qpidnetwork.anchor.bean.AnchorInCoinInfo;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetTodayCreditCallback;

/**
 * 主播信息管理类
 * Created by Hunter Mun on 2018/3/5.
 */

public class AnchorInfoManager {


    private static AnchorInfoManager mAnchorInfoManager;
    private AnchorInCoinInfo mAnchorInCoinInfo;

    /**
     * 构建单例
     * @return
     */
    public static AnchorInfoManager getInstance(){
        if(mAnchorInfoManager == null){
            mAnchorInfoManager = new AnchorInfoManager();
        }
        return mAnchorInfoManager;
    }

    private AnchorInfoManager(){

    }

    /**
     * 读取本地Anchor coins info
     * @return
     */
    public AnchorInCoinInfo getLocalAnchorInCoinInfo(){
        return mAnchorInCoinInfo;
    }

    /**
     * 获取主播收入信息
     * @param callback
     */
    public void GetInCoinsInfo(final OnGetTodayCreditCallback callback){
        if(mAnchorInCoinInfo != null){
            callback.onGetTodayCredit(true, 0, "", mAnchorInCoinInfo.monthCredit, mAnchorInCoinInfo.monthCompleted, mAnchorInCoinInfo.monthTarget, mAnchorInCoinInfo.monthProgress);
            return;
        }
        LiveRequestOperator.getInstance().GetTodayCredit(new OnGetTodayCreditCallback() {
            @Override
            public void onGetTodayCredit(boolean isSuccess, int errCode, String errMsg, int monthCredit, int monthCompleted, int monthTarget, int monthProgress) {
                if(isSuccess){
                    mAnchorInCoinInfo = new AnchorInCoinInfo(monthCredit, monthCompleted, monthTarget, monthProgress);
                }
                callback.onGetTodayCredit(isSuccess, errCode, errMsg, monthCredit, monthCompleted, monthTarget, monthProgress);
            }
        });
    }

    /**
     * 清除本地缓存
     */
    public void clearLocalCache(){
        mAnchorInCoinInfo = null;
    }
}
