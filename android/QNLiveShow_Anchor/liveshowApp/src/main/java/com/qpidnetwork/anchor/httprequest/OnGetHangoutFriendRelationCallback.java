package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;

/**
 * 6.10.获取好友关系信息回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetHangoutFriendRelationCallback {

	/**
	 * 6.10.获取好友关系信息回调
	 * @param item	好友关系信息
	 * @author Hunter Mun
	 * @since 2017-5-22
	 */
	public void onGetHangoutFriendRelation(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem item);
}
