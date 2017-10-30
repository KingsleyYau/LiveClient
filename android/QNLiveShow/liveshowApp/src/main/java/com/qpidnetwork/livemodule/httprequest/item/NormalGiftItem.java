package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 礼物列表item信息
 * @author Hunter Mun
 *
 */
public class NormalGiftItem {

    public NormalGiftItem(){

    }

    /**
     * @param gift			礼物（Object）
     * @param giftChooser	可选数目数组
     */
    public NormalGiftItem(GiftItem gift,
                          int[] giftChooser){
        this.gift = gift;
        this.giftChooser = giftChooser;
    }

    public GiftItem gift;
    public int[] giftChooser;

}
