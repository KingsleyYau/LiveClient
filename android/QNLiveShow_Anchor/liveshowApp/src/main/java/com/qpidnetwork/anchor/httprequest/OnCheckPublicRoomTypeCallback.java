package com.qpidnetwork.anchor.httprequest;

/**
 * 7.4.检测公开直播开播类型回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnCheckPublicRoomTypeCallback {

	/**
	 * 7.4.检测公开直播开播类型回调
	 * @param liveShowType	转 PublicRoomType	 公开直播间类型（Common：公开，Program：节目）
	 * @param liveShowId         节目ID
	 * @since 2017-5-22
	 */
	public void onCheckPublicRoomType(boolean isSuccess, int errCode, String errMsg, int liveShowType, String liveShowId);
}
