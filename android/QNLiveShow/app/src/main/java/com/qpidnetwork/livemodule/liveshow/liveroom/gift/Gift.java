package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

/**
 * Description:背包礼物实体类-测试
 * <p>
 * Created by Harry on 2017/8/16.
 */

public class Gift {
    /**
     * 礼物Object
     */
    public GiftItem giftItem = null;

    public int[] send_num_list;


    public Gift(GiftItem giftItem,int[] send_num_list){
        this.giftItem = giftItem;
        this.send_num_list = send_num_list;
    }

    @Override
    public String toString() {
        return "Gift[giftItem:"+giftItem
                +" send_num_list:"+send_num_list
                +"]";
    }
}
