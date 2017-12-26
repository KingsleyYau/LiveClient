package com.qpidnetwork.livemodule.liveshow.authorization;

import android.app.Activity;
import com.qpidnetwork.livemodule.httprequest.OnRequestFackBookLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;

/**
 * Created by Hunter Mun on 2017/12/25.
 */

public class FacebookLoginHandler implements ILoginManager{

    private String mFaceBookToken;
    private ThirdPlatformUserInfo mFacebookSDKInfo;

    public FacebookLoginHandler(){

    }

    @Override
    public boolean Autologin() {
        return false;
    }


    /**
     * facebook类专属方法
     * @param activity
     * @return
     */
    public boolean login(Activity activity) {
        //基于sdk登录
        FacebookSDKManager.getInstance().login(activity, new FacebookSDKManager.FacebookSDKLoginCallback() {
            @Override
            public void onLogin(FacebookSDKManager.OpearResultCode opearResultCode, String message, ThirdPlatformUserInfo userInfo) {
                //此处如非主线程，需转换
                if(opearResultCode == FacebookSDKManager.OpearResultCode.SUCCESS
                        && userInfo != null){
                    //成功，需要继续调用独立App Facebook根据token登录接口
                    mFacebookSDKInfo = userInfo;
                    mFaceBookToken = userInfo.token;
                    faceBookLogin(mFaceBookToken);
                }else{
                    //失败，回调通知LoginManager分发
                }
            }
        });
        return true;
    }

    @Override
    public boolean login(String email, String password) {
        //facebook登录成功后，
        return faceBookBindMailLogin(mFaceBookToken, email, password);
    }

    @Override
    public boolean logout(boolean isManal) {
        return false;
    }

    @Override
    public boolean register(String email, String password, int gender, String nickName, String birthday, String inviteCode) {
        return faceBookRegisterInternal(mFaceBookToken, email, birthday, inviteCode);
    }

    /**
     * facebook登录（默认token登录）
     * @param faceBookToken
     * @return
     */
    private boolean faceBookLogin(String faceBookToken){
        return faceBookLoginInternal(faceBookToken, "", "");
    }

    /**
     * 绑定独立app已存在的邮箱登录
     * @param token
     * @param email
     * @param password
     * @return
     */
    private boolean faceBookBindMailLogin(String token, String email, String password){
        return faceBookLoginInternal(token, email, password);
    }

    /**
     * facebook 注册
     * @param facebookToken
     * @param email
     * @param birthday
     * @param inviteCode
     * @return
     */
    private boolean faceBookRegisterInternal(String facebookToken, String email, String birthday,
                                                        String inviteCode){
        boolean result = true;
        //FaceBook注册登录接口
        String utmReference = "";
        String versionCode = "";
        String deviceId = "";
        long requestId = RequestJniAuthorization.FackBookLogin(facebookToken, versionCode, utmReference, android.os.Build.MODEL,
                deviceId, android.os.Build.MANUFACTURER, inviteCode, email, "", birthday, new OnRequestFackBookLoginCallback() {
                    @Override
                    public void onRequestFackBookLogin(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        //注册回调处理
                    }
                });
        if(requestId == -1){
            //请求无效
            result = false;
        }
        return result;
    }

    /**
     * app 内部登录（已绑定邮箱和绑定邮箱登录两种）
     * @param facebookToken
     * @param email
     * @param password
     * @return
     */
    private boolean faceBookLoginInternal(String facebookToken, String email, String password){
        boolean result = true;
        //FaceBook注册登录接口
        String utmReference = "";
        String versionCode = "";
        String deviceId = "";
        long requestId = RequestJniAuthorization.FackBookLogin(facebookToken, versionCode, utmReference, android.os.Build.MODEL,
                deviceId, android.os.Build.MANUFACTURER, "", email, password, "", new OnRequestFackBookLoginCallback() {
                    @Override
                    public void onRequestFackBookLogin(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        //登录回调处理
                    }
                });
        if(requestId == -1){
            //请求无效
            result = false;
        }
        return result;
    }
}
