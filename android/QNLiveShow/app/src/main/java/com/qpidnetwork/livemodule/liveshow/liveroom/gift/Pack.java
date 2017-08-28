package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

/**
 * Description:背包礼物实体类-测试
 * <p>
 * Created by Harry on 2017/8/16.
 */

public class Pack {
    /**
     * 礼物Object
     */
    public GiftItem giftItem = null;
    /**
     * 礼物数量
     */
    public int num = 0;
    /**
     * 礼物获取时间
     */
    public long granted_date = 0l;
    /**
     * 过期时间
     */
    public long exp_date = 0l;

    public int[] send_num_list;


    public Pack(GiftItem giftItem, int num, long granted_date,
                long exp_date, int[] send_num_list){
        this.giftItem = giftItem;
        this.num = num;
        this.granted_date = granted_date;
        this.exp_date = exp_date;
        this.send_num_list = send_num_list;
    }

    @Override
    public String toString() {
        return "Pack[giftItem:"+giftItem
                +" num:"+num
                +" granted_date:"+granted_date
                +" exp_date:"+exp_date
                +" send_num_list:"+send_num_list
                +"]";
    }
}
