package com.qpidnetwork.anchor.bean;

/**
 * Created by Hunter Mun on 2018/3/5.
 */

public class AnchorInCoinInfo {

    public AnchorInCoinInfo(){

    }

    public AnchorInCoinInfo(int monthCredit
                            , int monthCompleted
                            , int monthTarget
                            , int monthProgress){
        this.monthCredit = monthCredit;
        this.monthCompleted = monthCompleted;
        this.monthTarget = monthTarget;
        this.monthProgress = monthProgress;
    }

    public int monthCredit = 0;
    public int monthCompleted = 0;
    public int monthTarget = 0;
    public int monthProgress = 0;
}
