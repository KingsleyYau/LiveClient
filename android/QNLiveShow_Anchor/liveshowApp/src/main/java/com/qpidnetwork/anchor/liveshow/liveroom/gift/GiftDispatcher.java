package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.app.Activity;

import com.qpidnetwork.anchor.im.IMManager;

/**
 * 礼物消息分发器
 * Created by Hunter Mun on 2017/6/23.
 */

public class GiftDispatcher {

    private IMManager mIManager;
    private Activity mContext;

    public GiftDispatcher(Activity context){
        mIManager = IMManager.getInstance();
        this.mContext = context;
    }



}
