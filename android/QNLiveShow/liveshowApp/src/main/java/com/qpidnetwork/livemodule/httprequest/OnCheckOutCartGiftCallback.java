package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutItem;

/**
 * 15.2.获取鲜花礼品详情
 * @author Alex
 * @since 2019-10-08
 */
public interface OnCheckOutCartGiftCallback {
	public void onCheckOutCartGift(boolean isSuccess, int errCode, String errMsg, LSCheckoutItem checkoutItem);
}
