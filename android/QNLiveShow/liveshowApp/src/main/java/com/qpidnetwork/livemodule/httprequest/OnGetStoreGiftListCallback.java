package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSStoreFlowerGiftItem;

/**
 * 15.1.获取鲜花礼品列表
 * @author Alex
 * @since 2019-10-08
 */
public interface OnGetStoreGiftListCallback {
	public void onGetStoreGiftList(boolean isSuccess, int errCode, String errMsg, LSStoreFlowerGiftItem[] flowerGiftList);
}
