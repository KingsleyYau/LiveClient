package com.qpidnetwork.anchor.httprequest;


/**
 * 注册登录等认证模块接口
 * Created by Hunter Mun on 2017/5/17.
 */

public class RequestJniAuthorization {

    /**
     * 2.1.登录
     * @param sn                    主播ID
     * @param password              密码
     * @param code                  验证码
     * @param deviceId              设备唯一标识
     * @param model                 设备型号（格式：设备型号-系统版本号）
     * @param manufacturer          制造厂商
     * @param callback
     * @return
     */

    static public native long Login(String sn, String password, String code, String deviceId, String model, String manufacturer, OnRequestLoginCallback callback);
    

    /**
     * 2.2.上传push tokenId
     * @param pushTokenId
     * @param callback
     * @return
     */
    static public native long UploadPushTokenId(String pushTokenId, OnRequestCallback callback);

    /**
     * 2.3.获取验证码
     * @return
     */
    static public native long LSGetVerificationCode(OnRequestGetVerificationCodeCallback callback);


}
