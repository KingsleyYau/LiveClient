package com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/26.
 */

public interface OnLiveGiftSentListener {

    /**
     * 发送普通连击礼物回调
     * @param giftItem              //选中礼物Item
     * @param isMultiClick          //是否连击礼物
     * @param multi_click_start     //连击开始位置
     * @param multi_click_end       //连击结束位置
     * @param multiClickId          //连击ID（用于标记是否同一次连击，生成方式当前timestamp/秒为单位）
     */
    void onGiftSent(GiftItem giftItem, boolean isMultiClick, int multi_click_start, int multi_click_end, int multiClickId);

}
