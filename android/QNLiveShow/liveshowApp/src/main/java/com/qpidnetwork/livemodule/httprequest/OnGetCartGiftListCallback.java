package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSMyCartItem;

/**
 * 15.7.获取购物车My cart列表
 * @author Alex
 * @since 2019-10-08
 */
public interface OnGetCartGiftListCallback {
	public void onGetCartGiftList(boolean isSuccess, int errCode, String errMsg, int total, LSMyCartItem[] cartList);
}
