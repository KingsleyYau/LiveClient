package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

/**
 * 试聊卷消息内容
 * Created by Hunter Mun on 2017/6/15.
 */

public class IMVoucherMessageContent implements Serializable{

    public double roomPrice;
    public int useCoupon;

    public IMVoucherMessageContent(){

    }

    public IMVoucherMessageContent(double roomPrice, int useCoupon){
        this.roomPrice = roomPrice;
        this.useCoupon = useCoupon;
    }

}
