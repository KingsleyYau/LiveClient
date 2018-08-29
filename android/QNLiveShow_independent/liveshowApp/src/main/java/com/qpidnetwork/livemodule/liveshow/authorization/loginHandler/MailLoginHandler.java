package com.qpidnetwork.livemodule.liveshow.authorization.loginHandler;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnRequestLSRegisterCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestMailLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandler;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandlerListener;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.onRegisterListener;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.ArrayList;

/**
 * Created by Hunter Mun on 2017/12/25.
 */

public class MailLoginHandler implements ILoginHandler {

    private Context mContext;
    //登录成功 会返回SessionId如果有,则不用再调登录接口了
    private String mSessionId;
    private ArrayList<ILoginHandlerListener> mListListener = new ArrayList<>();
    private LoginAccount mLoginAccount = new LoginAccount();

    public MailLoginHandler(Context c){
        mContext = c;
    }

    @Override
    public void autoLogin() {
        loadLoginAccount();

        if(!TextUtils.isEmpty(mLoginAccount.email) && !TextUtils.isEmpty(mLoginAccount.passWord)){
            login(mLoginAccount.email , mLoginAccount.passWord);
        }

    }

    @Override
    public boolean login(final String email, final String password) {
        boolean result = true;

        //Email登录接口
        String utmReference = new LocalPreferenceManager(mContext).getPromotionUtmReference();
        String model = android.os.Build.MODEL;
        String manufacturer = android.os.Build.MANUFACTURER;
        String deviceId = SystemUtils.getDeviceId(mContext);
        long requestId = RequestJniAuthorization.LSMailLogin(email , password  , model , deviceId , manufacturer , new OnRequestMailLoginCallback() {
                    @Override
                    public void onRequestMailLogin(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        Log.i("Jagger" , "MailLoginHandler login 接口返回:isSuccess:" + isSuccess + ",errCode:" + errCode);
                        //登录成功,保存Token
                        if(isSuccess){
                            mSessionId = sessionId;
                            mLoginAccount.email = email;
                            mLoginAccount.passWord = password;
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

    @Override
    public boolean authorizedLogin(Activity activity) {
        //不用实现这个方法
        return false;
    }

    @Override
    public boolean logout(boolean isManal) {
        //清空Session
        mSessionId = "";
        //清空本地帐号密码
        if(mLoginAccount != null){
            mLoginAccount.passWord = "";
        }
        //保存
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        localPreferenceManager.saveEmailLoginAccount(mLoginAccount);

        //调用接口

        //通知外部
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogout();
        }

        return true;
    }

    @Override
    public boolean register(final String email, final String password, GenderType gender, String nickName, String birthday, String inviteCode , final onRegisterListener listener) {
        boolean result = true;

        //2.5.邮箱注册
        String utmReference = new LocalPreferenceManager(mContext).getPromotionUtmReference();
        String model = android.os.Build.MODEL;
        String deviceId = SystemUtils.getDeviceId(mContext);
        String manufacturer = android.os.Build.MANUFACTURER;
        long requestId = RequestJniAuthorization.LSRegister(email, password, gender, nickName, birthday, inviteCode, model, deviceId, manufacturer, utmReference, new OnRequestLSRegisterCallback() {
            @Override
            public void onRequestLSRegister(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                Log.i("Jagger" , "MailLoginHandler addListener 接口返回:isSuccess:" + isSuccess + ",errCode:" + errCode);
                //登录成功,保存Token
                if(isSuccess){
                    mSessionId = sessionId;
                    mLoginAccount.email = email;
                    mLoginAccount.passWord = password;
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
            listener.onResult(false, HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) , "");
        }

        return result;
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
        Log.i("Jagger" , "EmailLoginHandler onLoginResult mListListener.size():" + mListListener.size());
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLoginServer(isSuccess , errCode , errMsg , item);
        }
    }

    @Override
    public boolean isCanAutoLogin() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        LoginAccount loginAccount= localPreferenceManager.getEmailLoginAccount();
        if (loginAccount != null && !TextUtils.isEmpty(loginAccount.email) && !TextUtils.isEmpty(loginAccount.passWord)){
            Log.i("Jagger" , "MailLoginHandler isCanAutoLogin email:" + loginAccount.email);
            return true;
        }

        Log.i("Jagger" , "MailLoginHandler isCanAutoLogin email:" + loginAccount.email);
        return false;
    }

    @Override
    public void saveAccount() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        localPreferenceManager.saveEmailLoginAccount(mLoginAccount);
    }

    @Override
    public LoginAccount getLoginAccount() {
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        return localPreferenceManager.getEmailLoginAccount();
    }

    @Override
    public String getSessionId() {
        return mSessionId;
    }

    @Override
    public Object getAuthorizedUserInfo() {
        return null;
    }

    @Override
    public void destroy() {

    }

    /**
     * 取上次登录信息,如果有,则赋值到全局变量中
     * @return
     */
    private void loadLoginAccount(){
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        LoginAccount loginAccount= localPreferenceManager.getEmailLoginAccount();
        if (loginAccount != null){
            Log.i("Jagger" , "EmailLoginHandler loadLoginAccount loginAccount email:" + loginAccount.email + ",pw:" + loginAccount.passWord);

            mLoginAccount = loginAccount;
        }
    }

}
