package com.qpidnetwork.livemodule.httprequest;


/**
 * 15.5.获取My delivery列表
 * @author Alex
 * @since 2019-10-08
 */
public interface OnGetCartGiftTypeNumCallback {
	public void onGetCartGiftTypeNum(boolean isSuccess, int errCode, String errMsg, int num);
}
