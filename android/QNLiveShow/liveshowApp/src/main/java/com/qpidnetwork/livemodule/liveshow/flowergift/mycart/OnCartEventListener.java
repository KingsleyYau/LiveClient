package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LSMyCartItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRecipientAnchorGiftItem;

/**
 * 购物车礼物列表点击事件
 * @author Jagger 2019-10-9
 */
public interface OnCartEventListener {
    /**
     * 修改一个礼物数量
     * @param newSum 修改后的总数
     */
    void onChangeGiftSum(LSRecipientAnchorGiftItem anchor, LSFlowerGiftBaseInfoItem giftBaseInfoItem, int oldSum, int newSum);

    /**
     * 移除一个礼物
     */
    void onDelGift(LSRecipientAnchorGiftItem anchor, LSFlowerGiftBaseInfoItem giftBaseInfoItem);
    void onCheckout(LSMyCartItem cartItem);
    void onContinueShop(LSMyCartItem cartItem);
    void onAnchorClicked(LSRecipientAnchorGiftItem anchor);
    void onGiftClicked(LSFlowerGiftBaseInfoItem giftBaseInfoItem);
}
