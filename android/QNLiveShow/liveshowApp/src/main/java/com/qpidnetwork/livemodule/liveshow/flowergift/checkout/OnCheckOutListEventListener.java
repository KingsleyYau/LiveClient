package com.qpidnetwork.livemodule.liveshow.flowergift.checkout;

import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LSMyCartItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRecipientAnchorGiftItem;

/**
 * 购物车礼物列表点击事件
 * @author Jagger 2019-10-9
 */
public interface OnCheckOutListEventListener {
    /**
     * 修改一个礼物数量
     * @param newSum 修改后的总数
     */
    void onChangeGiftSum(String anchorId, LSCheckoutGiftItem giftItem, int newSum);

    /**
     * 移除一个礼物
     */
    void onDelGift(String anchorId, LSCheckoutGiftItem giftItem);
}
