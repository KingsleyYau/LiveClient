package com.qpidnetwork.livemodule.httprequest;

/**
 * 关注/取消关注节目回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnFollowShowCallback {

	public void onFollowShow(boolean isSuccess, int errCode, String errMsg);
}
