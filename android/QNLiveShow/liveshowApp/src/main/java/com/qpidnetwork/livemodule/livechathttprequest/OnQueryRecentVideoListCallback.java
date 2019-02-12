package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem;

public interface OnQueryRecentVideoListCallback {
	public void OnQueryRecentVideoList(boolean isSuccess, String errno, String errmsg, LCVideoItem[] itemList);
}
