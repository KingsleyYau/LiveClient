package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSDeliveryItem;

/**
 * 15.5.获取My delivery列表
 * @author Alex
 * @since 2019-10-08
 */
public interface OnGetDeliveryListCallback {
	public void onGetDeliveryList(boolean isSuccess, int errCode, String errMsg, LSDeliveryItem[] DeliveryList);
}
