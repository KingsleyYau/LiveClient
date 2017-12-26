package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.app.Activity;
import android.content.Context;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal.LiveGift;

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
