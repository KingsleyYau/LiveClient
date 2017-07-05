package com.qpidnetwork.httprequest;

/**
 * 注册登录等认证模块接口
 * Created by Hunter Mun on 2017/5/17.
 */

public class RequestJniAuthorization {
	
	/**
	 * 验证手机号有效性
	 * @param phoneNumber
	 * @param areaNo
	 * @param callback
	 * @return
	 */
	static public native long VerifyPhoneNumber(String phoneNumber, String areaNo, OnVerifyPhoneNumberCallback callback);
	
	/**
	 * 获取手机验证码
	 * @param phoneNumber
	 * @param areaNo
	 * @param callback
	 * @return
	 */
	static public native long GetRegisterVerifyCode(String phoneNumber, String areaNo, OnRequestCallback callback);
	
	/**
	 * 手机号码注册接口
	 * @param phoneNumber
	 * @param areano
	 * @param verifyCode
	 * @param password
	 * @param deviceId
	 * @param callback
	 * @return
	 */
	static public native long PhoneNumberRegister(String phoneNumber, String areaNo, String verifyCode, String password,
			String deviceId, OnRequestCallback callback);
	
	/**
	 * 登录接口
	 * @param phoneNumber
	 * @param areaNo
	 * @param password
	 * @param deviceId
	 * @param autoLogin			//标记是否自动登录（用于延迟踢出另外一个端，需人工登录才能踢出）
	 * @param callback
	 * @return
	 */
    static public native long LoginWithPhoneNumber(String phoneNumber, String areaNo, String password, String deviceId, 
    		boolean autoLogin, OnRequestLoginCallback callback);
    
    /**
     * 注销
     * @param callback
     * @return
     */
    static public native long Logout(OnRequestCallback callback);
    
    /**
     * 上传push tokenId
     * @param pushTokenId
     * @param callback
     * @return
     */
    static public native long UploadPushTokenId(String pushTokenId, OnRequestCallback callback);

}
