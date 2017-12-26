package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.VerifyCodeType;

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
    static private native long Login(String manId, String userSid, String deviceId, String model, String manufacturer, OnRequestLoginCallback callback);
    
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
     * 2.4.Facebook注册及登录（仅独立）
     * @param fToken                              Facebook登录返回的accessToken
     * @param versionCode                         客户端内部版本号
     * @param utmReferrer                         APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     * @param model                               设备型号
     * @param deviceId                            设备唯一标识
     * @param manufacturer                        制造厂商
     * @param inviteCode                          推荐码（可无）
     * @param email                               用户注册的邮箱（可无）
     * @param passWord                            登录密码（可无）
     * @param birthDay                            出生日期（可无，但未绑定时必须提交，格式为：2015-02-20）
     * @param callback
     * @return
     */
    static public native long FackBookLogin(String fToken, String versionCode, String utmReferrer, String model, String deviceId, String manufacturer, String inviteCode, String email, String passWord, String birthDay, OnRequestFackBookLoginCallback callback);

    /**
     * 2.5.邮箱注册（仅独立）
     * @param email                电子邮箱
     * @param passWord             密码
     * @param gender               性别（M：男，F：女）
     * @param nickName             昵称
     * @param birthDay             出生日期（格式为：2015-02-20）
     * @param inviteCode           推荐码（可无）
     * @param model                设备型号
     * @param deviceid             设备唯一标识
     * @param manufacturer         制造厂商
     * @param utmReferrer          APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     * @param callback
     * @return
     */
    static public long LSRegister(String email, String passWord, GenderType gender, String nickName, String birthDay, String inviteCode, String model, String deviceid, String manufacturer, String utmReferrer, OnRequestLSRegisterCallback callback){
        return LSRegister(email, passWord, gender.ordinal(), nickName, birthDay, inviteCode, model, deviceid, manufacturer, utmReferrer, callback);
    }
    static public native long LSRegister(String email, String passWord, int gender, String nickName, String birthDay, String inviteCode, String model, String deviceid, String manufacturer, String utmReferrer, OnRequestLSRegisterCallback callback);

    /**
     * 2.6.邮箱登录（仅独立）
     * @param email                         用户的email或id
     * @param passWord                      登录密码
     * @param versionCode                   客户端内部版本号
     * @param model                         设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
     * @param deviceid                      设备唯一标识
     * @param manufacturer                  制造厂商
     * @param checkCode                     验证码
     * @param callback
     * @return
     */
    static public native long LSMailLogin(String email, String passWord, String versionCode, String model, String deviceid, String manufacturer, String checkCode, OnRequestMailLoginCallback callback);

    /**
     * 2.7.找回密码（仅独立）
     * @param sendMail                      用户的email或id
     * @param checkCode                     验证码
     * @param callback
     * @return
     */
    static public native long LSFindPassword(String sendMail, String checkCode, OnRequestLSFindPasswordCallback callback);

    /**
     * 2.8.检测邮箱注册状态（仅独立）
     * @param email                      电子邮箱
     * @param callback
     * @return
     */
    static public native long LSCheckMail(String email, OnRequestLSCheckMailCallback callback);

    /**
     * 2.9.提交用户头像（仅独立）
     * @param photoName                     上传头像文件名
     * @param callback
     * @return
     */
    static public native long LSUploadPhoto(String photoName, OnRequestUploadPhotoCallback callback);

    /**
     * 2.10.获取验证码（仅独立）
     * @param verifyType                     证码种类，（“login”：登录；“findpw”：找回密码）
     * @param useCode                        是否需要验证码，（1：必须；0：不限，服务端自动检测ip国家）
     * @return
     */
    static public long LSGetVerificationCode(VerifyCodeType verifyType, boolean useCode, OnRequestGetVerificationCodeCallback callback){
        return LSGetVerificationCode(verifyType.ordinal(), useCode, callback);
    }
    static public native long LSGetVerificationCode(int verifyType, boolean useCode, OnRequestGetVerificationCodeCallback callback);


}
