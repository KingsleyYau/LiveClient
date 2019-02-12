package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.Gift;

public interface OnQueryChatVirtualGiftCallback {
	public void OnQueryChatVirtualGift(boolean isSuccess, String errno, String errmsg, Gift[] list,
                                       int totalCount, String path, String version);
}
