package com.qpidnetwork.anchor.httprequest;

/**
 * 6.5.发起敲门请求回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnSendKnockRequestCallback {

	/**
	 * 发起敲门请求回调
	 * @param knockId	敲门ID（可无，若expire=0则无，表示可直接进入）
	 * @param expire	敲门请求的有效秒数（整型）（可无，若无或为0则表示可直接进入）
	 * @author Hunter Mun
	 * @since 2017-5-22
	 */
	public void onSendKnockRequest(boolean isSuccess, int errCode, String errMsg, String knockId, int expire);
}
