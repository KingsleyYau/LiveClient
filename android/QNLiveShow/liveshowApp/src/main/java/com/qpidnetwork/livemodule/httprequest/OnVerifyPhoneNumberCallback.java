package com.qpidnetwork.livemodule.httprequest;

/**
 * 验证手机号有效性回调
 * @author Hunter Mun
 *
 */
public interface OnVerifyPhoneNumberCallback {
	public void onVerifyPhoneNumber(boolean isSuccess, int errCode, String errMsg, boolean isRegister);
}
