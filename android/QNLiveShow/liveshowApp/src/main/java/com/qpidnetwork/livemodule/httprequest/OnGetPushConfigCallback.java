package com.qpidnetwork.livemodule.httprequest;

public interface OnGetPushConfigCallback {
	// isPriMsgAppPush : 是否接收私信推送通知,  isMailAppPush : 是否接收私信推送通知
	public void onGetPushConfig(boolean isSuccess, int errCode, String errMsg, boolean isPriMsgAppPush, boolean isMailAppPush);
}
