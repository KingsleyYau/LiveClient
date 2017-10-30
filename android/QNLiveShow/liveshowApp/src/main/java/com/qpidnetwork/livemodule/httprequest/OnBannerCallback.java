package com.qpidnetwork.livemodule.httprequest;

public interface OnBannerCallback {
	public void onBanner(boolean isSuccess, int errCode, String errMsg, String bannerImg, String bannerLink);
}
