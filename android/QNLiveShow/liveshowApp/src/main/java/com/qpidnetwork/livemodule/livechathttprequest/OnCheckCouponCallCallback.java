package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;

public interface OnCheckCouponCallCallback {
	public void OnCheckCoupon(long requestId, boolean isSuccess, String errno, String errmsg, Coupon item);
}
