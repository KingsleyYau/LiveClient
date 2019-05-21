package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;

/**
 * 8.8.获取指定主播的Hang-out好友列表
 * @author Hunter Mun
 * @since 2018-4-18
 */
public interface OnGetHangoutFriendsCallback {
	public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList);
}
