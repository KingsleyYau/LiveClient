package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;

/**
 * 15.2.获取鲜花礼品详情
 * @author Alex
 * @since 2019-10-08
 */
public interface OnGetFlowerGiftDetailCallback {
	public void onGetFlowerGiftDetail(boolean isSuccess, int errCode, String errMsg, LSFlowerGiftItem glowerGiftItem);
}
