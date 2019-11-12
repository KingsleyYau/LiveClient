package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;

/**
 * @author Jagger 2019-10-14
 */
public interface OnDeliveryItemEventListener {
    void onAnchorClicked(String anchorId);
    void onGiftClicked(LSFlowerGiftBaseInfoItem giftBaseInfoItem);
    void onStatusClicked();
}
