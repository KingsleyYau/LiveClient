package com.qpidnetwork.livemodule.httprequest;


/**
 * 15.12.生成订单
 * @author Alex
 * @since 2019-10-08
 */
public interface OnCreateGiftOrderCallback {
	public void onCreateGiftOrder(boolean isSuccess, int errCode, String errMsg, String orderNumber);
}
