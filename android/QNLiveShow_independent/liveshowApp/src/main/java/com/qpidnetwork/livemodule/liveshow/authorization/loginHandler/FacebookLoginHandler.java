package com.qpidnetwork.livemodule.liveshow.authorization.loginHandler;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnRequestFackBookLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.FacebookSDKManager;
import com.qpidnetwork.livemodule.liveshow.authorization.ThirdPlatformUserInfo;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandler;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandlerListener;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.onRegisterListener;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.ArrayList;

/**
 * Facebook登录业务
 * Created by Hunter Mun on 2017/12/25.
 */

public class FacebookLoginHandler implements ILoginHandler {

    private Context mContext;
    //登录成功 会返回SessionId如果有,则不用再调登录接口了
    private String mSessionId;
    private ThirdPlatformUserInfo mFacebookUserInfo;
    private ArrayList<ILoginHandlerListener> mListListener = new ArrayList<>();
    private LoginAccount mLoginAccount ;

    public FacebookLoginHandler(Context c){
        mContext = c;
        loadLoginAccount();
    }

    @Override
    public void autoLogin() {

        if (mLoginAccount.authToken != null){
            faceBookLogin(mLoginAccount.authToken );
        }
    }

    /**
     * facebook受权登录
     * @param activity
     * @return
     */
    @Override
    public boolean authorizedLogin(Activity activity) {
        //基于sdk登录
        FacebookSDKManager.getInstance().login(activity, new FacebookSDKManager.FacebookSDKLoginCallback() {
            @Override
            public void onLogin(FacebookSDKManager.OpearResultCode opearResultCode, String message, ThirdPlatformUserInfo userInfo) {
                //此处如非主线程，需转换
                if(opearResultCode == FacebookSDKManager.OpearResultCode.SUCCESS
                        && userInfo != null){
                    Log.i("Jagger" , "FacebookLoginHandler authorizedLogin-->" + "opearResultCode:" + opearResultCode + ",token:" + userInfo.token + ",\nemail:" + userInfo.email + ",\ngenger:" + userInfo.gender);

                    //成功，需要继续调用独立App Facebook根据token登录接口
                    mLoginAccount.authToken = userInfo.token;
                    mFacebookUserInfo = userInfo;

                    faceBookLogin(mLoginAccount.authToken);

                }else{
                    Log.i("Jagger" , "FacebookLoginHandler authorizedLogin-->" + "opearResultCode:" + opearResultCode + ",message:" + message);

                    //失败，回调通知LoginManager分发
                    onLoginResult(false , HttpLccErrType.LOCAL_ERR_FACEBOOL_LOGIN_FAIL.ordinal() , mContext.getString(R.string.live_login_facebook_failed_tips) , null);
                }
            }
        });
        return true;
    }

    @Override
    public boolean login(String email, String password) {
        //facebook登录成功后，
        return faceBookBindMailLogin(mLoginAccount.authToken, email, password);
    }

    @Override
    public boolean logout(boolean isManal) {
        //清空Session
        mSessionId = "";
        //清空本地帐号
        if(mLoginAccount != null){
            mLoginAccount.authToken = "";
        }
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        localPreferenceManager.saveFaceBookLoginAccount(mLoginAccount);

        //调用接口
        FacebookSDKManager.getInstance().logout();

        //通知外部
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogout();
        }

        return true;
    }

    @Override
    public boolean register(String email, String password, GenderType gender, String nickName, String birthday, String inviteCode , onRegisterListener listener) {
        return faceBookRegisterInternal(mLoginAccount.authToken, nickName, email, password, birthday, inviteCode , gender ,listener);
    }

    @Override
    public void addLoginListener(ILoginHandlerListener listener) {
        if(!mListListener.contains(listener)){
            mListListener.add(listener);
        }
    }

    @Override
    public void removeLoginListener(ILoginHandlerListener listener) {
        if(mListListener.contains(listener)) {
            mListListener.remove(listener);
        }
    }

    @Override
    public void onLoginResult(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLoginServer(isSuccess , errCode , errMsg , item);
        }
    }

    @Override
    public boolean isCanAutoLogin() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        LoginAccount loginAccount= localPreferenceManager.getFaceBookLoginAccount();
        if (loginAccount != null && !TextUtils.isEmpty(loginAccount.authToken)){
            Log.i("Jagger" , "FacebookLoginHandler isCanAutoLogin true authToken:" + loginAccount.authToken);
            return true;
        }

        Log.i("Jagger" , "FacebookLoginHandler isCanAutoLogin false authToken:" + loginAccount.authToken);
        return false;
    }

    @Override
    public void saveAccount() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        localPreferenceManager.saveFaceBookLoginAccount(mLoginAccount);
    }

    @Override
    public LoginAccount getLoginAccount() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        return localPreferenceManager.getFaceBookLoginAccount();
    }

    @Override
    public String getSessionId() {
        Log.i("Jagger" , "FacebookLoginHandler getSessionId mSessionId: " + mSessionId);
        return mSessionId;
    }

    @Override
    public Object getAuthorizedUserInfo() {
        return mFacebookUserInfo;
    }

    @Override
    public void destroy() {
        FacebookSDKManager.getInstance().logout();
    }

    /**
     * 取上次登录信息,如果有,则赋值到全局变量中
     * @return
     */
    private void loadLoginAccount(){
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        LoginAccount loginAccount= localPreferenceManager.getFaceBookLoginAccount();
        if (loginAccount != null){
            Log.i("Jagger" , "FacebookLoginHandler loadLoginAccount loginAccount != null");

            mLoginAccount = loginAccount;
        }else {
            mLoginAccount = new LoginAccount();
        }
    }

    /**
     * facebook登录（默认token登录）
     * @param faceBookToken
     * @return
     */
    private boolean faceBookLogin(String faceBookToken ){
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
    private boolean faceBookRegisterInternal(String facebookToken, String nickName , String email, String password, String birthday,
                                             String inviteCode, GenderType gender, final onRegisterListener listener){
        boolean result = true;

        //就算有mSessionId 也不能直接返回,因为这是用于注册

        //FaceBook注册登录接口
        String utmReference = new LocalPreferenceManager(mContext).getPromotionUtmReference();
//        String versionCode = "";
        String deviceId = SystemUtils.getDeviceId(mContext);
        long requestId = RequestJniAuthorization.FackBookLogin(facebookToken, nickName, utmReference, android.os.Build.MODEL,
                deviceId, android.os.Build.MANUFACTURER, inviteCode, email, password, birthday, gender, new OnRequestFackBookLoginCallback() {
                    @Override
                    public void onRequestFackBookLogin(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        Log.i("Jagger" , "FacebookLoginHandler faceBookRegisterInternal onRequestFackBookLogin:isSuccess:" + isSuccess + ",errCode:" + errCode);

                        //登录成功,保存Token
                        if(isSuccess){
                            mSessionId = sessionId;
                            saveAccount();
                        }

                        //注册回调处理
                        listener.onResult(isSuccess, errCode , errMsg , sessionId);
                    }
                });
        if(requestId == -1){
            //请求无效
            result = false;

            //注册回调处理
            listener.onResult(false, HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) , "");
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
        //如果有sessionId,直接返回登录成功
        if(!TextUtils.isEmpty(mSessionId)){
            onLoginResult(true , HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal() , "" , null);
            return result;
        }

        //FaceBook注册登录接口
        String utmReference = new LocalPreferenceManager(mContext).getPromotionUtmReference();
        String deviceId = SystemUtils.getDeviceId(mContext);
        long requestId = RequestJniAuthorization.FackBookLogin(facebookToken, "", utmReference, android.os.Build.MODEL,
                deviceId, android.os.Build.MANUFACTURER, "", email, password, "", GenderType.Unknown, new OnRequestFackBookLoginCallback() {
                    @Override
                    public void onRequestFackBookLogin(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        Log.i("Jagger" , "FacebookLoginHandler faceBookLoginInternal 接口返回:isSuccess:" + isSuccess
                                + ",errCode:" + errCode
                                + " SessionId: " + sessionId);
                        //test
//                        isSuccess = false;
//                        errCode = HttpLccErrType.HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX.ordinal();

                        //登录成功,保存Token
                        if(isSuccess){
                            mSessionId = sessionId;
                            saveAccount();
                        }

                        //登录回调处理
                        onLoginResult(isSuccess , errCode , errMsg , null);
                    }
                });
        if(requestId == -1){
            //请求无效
            result = false;
            onLoginResult(false , HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) , null);
        }
        return result;
    }
}
