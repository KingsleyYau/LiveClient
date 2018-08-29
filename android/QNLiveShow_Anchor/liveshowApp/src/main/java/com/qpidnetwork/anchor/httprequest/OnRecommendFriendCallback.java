package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;

/**
 * 主播推荐好友给观众回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnRecommendFriendCallback {

	/**
	 * 主播推荐好友给观众回调
	 * @param recommendId	推荐ID
	 * @author Hunter Mun
	 * @since 2017-5-22
	 */
	public void onRecommendFriend(boolean isSuccess, int errCode, String errMsg, String recommendId);
}
