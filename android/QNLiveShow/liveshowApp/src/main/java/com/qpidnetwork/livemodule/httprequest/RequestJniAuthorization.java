package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;
import com.qpidnetwork.livemodule.httprequest.item.RegionType;

/**
 * 注册登录等认证模块接口
 * Created by Hunter Mun on 2017/5/17.
 */

public class RequestJniAuthorization {

    /**
     * 登录
     * @param manId
     * @param qnTokenId
     * @param deviceId
     * @param callback
     * @return
     */
    static public long Login(String manId, String qnTokenId, String deviceId, OnRequestLoginCallback callback){
    	return Login(manId, qnTokenId, deviceId, android.os.Build.MODEL, android.os.Build.MANUFACTURER, callback);
    }
    static private native long Login(String manId, String userSid, String deviceId, String model, String manufacturer,  OnRequestLoginCallback callback);

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

    /**
     * 2.13.可登录的站点列表
     * @param email             用户的email或id
     * @param password           登录密码
     * @param callback
     * @return
     */
    static public native long GetValidSiteId(String email, String password, OnGetValidSiteIdCallback callback);

    /**
     * 2.14.添加App token
     * @param token           app token值 (GCM ID)
     * @param appId           app唯一标识（App包名或iOS App ID，详情参考《“App ID”对照表》） (包名)
     * @param deviceId        设备id
     * @param callback
     * @return
     */
    static public native long AddToken(String token, String appId, String deviceId, OnRequestCallback callback);

    /**
     * 2.15.销毁App token
     * @param callback
     * @return
     */
    static public native long DestroyToken(OnRequestCallback callback);

    /**
     * 2.16.找回密码
     * @param sendMail           用户注册的邮箱
     * @param checkCode          验证码（ver3.0起）
     * @param callback
     * @return
     */
    static public native long FindPassword(String sendMail, String checkCode, OnRequestCallback callback);

    /**
     * 2.17.修改密码
     * @param passwordNew          新密码
     * @param passwordOld          旧密码
     * @param callback
     * @return
     */
    static public native long ChangePassword(String passwordNew, String passwordOld, OnRequestCallback callback);

    /**
     * 2.18.token登录认证
     * @param token
     * @param membetId
     * @param deviceId
     * @param versioncode
     * @param model
     * @param manufacturer
     * @param callback
     * @return
     */
    static public native long DoLogin(String token, String membetId, String deviceId,
                                         String versioncode, String model, String manufacturer, OnRequestCallback callback);


    /**
     * 2.19.获取认证token
     * @param siteId          站点ID（参考《11.10.“站点ID”对照表》）
     * @param callback
     * @return
     */
    static public native long GetAuthToken(int siteId, OnRequestSidCallback callback);

    /**
     * 2.20.帐号密码登录
     * @param email             用户的email或id
     * @param password          登录密码
     * @param authcode          验证码
     * @param afDeviceId        AppsFlyerSDK获取的设备ID
     * @param gaid              Google广告ID（Google’s Advertising ID）
     * @param deviceId          设备唯一标识
     * @param callback
     * @return
     */
    static public native long PasswordLogin(String email, String password, String authcode,
                                            String afDeviceId, String gaid, String deviceId,
                                            OnRequestSidCallback callback);

    /**
     * 2.21.token登录
     * @param memberId              用户id
     * @param sid                   用于登录其他站点的加密串，即其它站点获取的token
     * @param callback
     * @return
     */
    static public native long TokenLogin(String memberId, String sid,
                                         OnRequestSidCallback callback);

    /**
     * 2.22.获取验证码

     * @param
     * @param callback
     * @return
     */
    static public long GetValidateCode(LSValidateCodeType validateCodeType, OnRequestGetValidateCodeCallback callback) {
        return GetValidateCode(validateCodeType.ordinal(), callback);
    }

    static private native long GetValidateCode(int validateCodeType, OnRequestGetValidateCodeCallback callback);

    /**
     * 2.23.提交用户头像
     * @param photoName                上传头像文件名
     * @param callback
     * @return
     */
    static public native long UploadUserPhoto(String photoName,
                                              OnRequestCallback callback);

}
