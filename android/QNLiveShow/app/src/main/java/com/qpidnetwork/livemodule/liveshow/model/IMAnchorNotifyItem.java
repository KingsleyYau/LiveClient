package com.qpidnetwork.livemodule.liveshow.model;

import java.io.Serializable;

/**
 * 服务器通知主播端房间关闭数据Mode
 * Created by Hunter Mun on 2017/6/29.
 */

public class IMAnchorNotifyItem implements Serializable{

    public IMAnchorNotifyItem(){

    }

    public IMAnchorNotifyItem(String roomId,
                              int fansNum,
                              int income,
                              int newFans,
                              int shares,
                              int duration){
        this.roomId = roomId;
        this.fansNum = fansNum;
        this.income = income;
        this.newFans = newFans;
        this.shares = shares;
        this.duration = duration;
    }

    public String roomId;
    public int fansNum;
    public int income;//总收入
    public int newFans;
    public int shares;
    public int duration;//直播时长，后台返回时间戳差值，单位为秒
}
