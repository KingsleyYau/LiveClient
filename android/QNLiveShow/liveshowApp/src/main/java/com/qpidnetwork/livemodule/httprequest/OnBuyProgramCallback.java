package com.qpidnetwork.livemodule.httprequest;

/**
 * 购买节目回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnBuyProgramCallback {

	public void onBuyProgram(boolean isSuccess, int errCode, String errMsg, double leftCredit);
}
