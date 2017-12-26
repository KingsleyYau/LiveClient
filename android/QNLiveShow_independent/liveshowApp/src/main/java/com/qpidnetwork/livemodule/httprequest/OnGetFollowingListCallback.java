package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;

public interface OnGetFollowingListCallback {
	public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList);
}
