package com.qpidnetwork.liveshow.authorization;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.httprequest.OnRequestCallback;
import com.qpidnetwork.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.httprequest.RequestJniAuthorization;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.model.LoginParam;
import com.qpidnetwork.utils.SystemUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 登录管理类
 * Created by Hunter Mun on 2017/5/26.
 */

public class LoginManager {

    private static final String TAG = LoginManager.class.getName();

    public enum LoginStatus{
        Default,
        Logining,
        Logined
    }

    private Context mContext;
    private static LoginManager mLoginManager;
    private List<IAuthorizationListener> mListenerList;
    private LoginStatus mLoginStatus;
    private LoginItem mLoginItem;       //保存当前用户信息

    public static LoginManager getInstance(){
        return mLoginManager;
    }

    /**
     * 构建单例
     * @param context
     * @return
     */
    public static LoginManager newInstance(Context context){
        if(mLoginManager == null){
            mLoginManager = new LoginManager(context);
        }
        return mLoginManager;
    }

    private LoginManager(Context context){
        mContext = context;
        mListenerList = new ArrayList<IAuthorizationListener>();
        mLoginStatus = LoginStatus.Default;
    }

    /**
     * 注册监听器
     * @param listener
     * @return
     */
    public boolean register(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListenerList)
        {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                    IAuthorizationListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mListenerList.add(listener);
                }
                else {
                    Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", "OnLoginManagerListener", "register", listener.getClass().getSimpleName()));
                }
            }
            else {
                Log.e(TAG, String.format("%s::%s() fail, listener is null", "OnLoginManagerListener", "register"));
            }
        }
        return result;
    }

    /**
     * 注销监听器
     * @param listener
     * @return
     */
    public boolean unRegister(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListenerList) {
            result = mListenerList.remove(listener);
        }

        if (!result) {
            Log.e(TAG, String.format("%s::%s() fail, listener:%s", "OnLoginManagerListener", "unRegister", listener.getClass().getSimpleName()));
        }
        return result;
    }

    public boolean autoLogin(){
        boolean result = false;
        LoginParam param = getAccountInfo();
        if(param != null && !TextUtils.isEmpty(param.areaNumber)
                && !TextUtils.isEmpty(param.phoneNumber) && !TextUtils.isEmpty(param.password)){
            result = true;
            loginByPhone(param.areaNumber, param.phoneNumber, param.password, true);
        }
        return result;
    }

    /**
     *
     * @param areaNo
     * @param phoneNumber
     * @param password
     * @param isAutoLogin
     */
    public void loginByPhone(final String areaNo, final String phoneNumber, final String password, boolean isAutoLogin){
        if(mLoginStatus == LoginStatus.Default) {
            mLoginStatus = LoginStatus.Logining;
            String deviceId = SystemUtils.getDeviceId(mContext);
            RequestJniAuthorization.LoginWithPhoneNumber(phoneNumber, areaNo, password, deviceId, isAutoLogin, new OnRequestLoginCallback() {
                public void onRequestLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                    synchronized (mListenerList) {
                        mLoginStatus = isSuccess ? LoginStatus.Logined : LoginStatus.Default;
                        if(isSuccess){
                            try {
                                //登录成功则先本地缓存登录信息
                                LoginParam param = new LoginParam(areaNo, phoneNumber, password);
                                saveAccountInfo(param);
                                mLoginItem = item;
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }

                        for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                            IAuthorizationListener listener = iter.next();
                            listener.onLogin(isSuccess, errCode, errMsg, item);
                        }
                    }
                }
            });
        }else{
            //已登录成功，直接回调
            for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                IAuthorizationListener listener = iter.next();
                listener.onLogin(true, 0, "", mLoginItem);
            }
        }
    }

    /**
     * 注销
     */
    public void logout(){
        mLoginStatus = LoginStatus.Default;
        mLoginItem = null;
        clearAccountInfo();
        RequestJniAuthorization.Logout(new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                synchronized (mListenerList) {
                    for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                        IAuthorizationListener listener = iter.next();
                        listener.onLogout();
                    }
                }
            }
        });
    }

    /**
     * 手机注册接口
     * @param phoneNumber
     * @param countryCode
     * @param verifCode
     * @param password
     * @param callback
     */
    public void phoneNumRegister(final String phoneNumber, final String countryCode, final String verifCode, final String password, final OnRequestCallback callback){
        String deviceId = SystemUtils.getDeviceId(mContext);
        RequestJniAuthorization.PhoneNumberRegister(phoneNumber, countryCode, verifCode, password, deviceId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                LoginParam param = new LoginParam(countryCode, phoneNumber, password);
                saveAccountInfo(param);
                callback.onRequest(isSuccess, errCode, errMsg);
            }
        });
    }

    /**
     * 获取用户信息
     * @return
     */
    public LoginItem getmLoginItem(){
        return mLoginItem;
    }

    /**
     * 保存已登录账号信息
     * @param loginParam
     */
    private void saveAccountInfo(LoginParam loginParam){
        new LocalPreferenceManager(mContext).saveLoginAccountInfoItem(loginParam);
    }

    /**
     * 获取上次登录成功账号信息
     * @return
     */
    public LoginParam getAccountInfo(){
        return new LocalPreferenceManager(mContext).getLoginAccountInfoItem();
    }

    /**
     * 注销时清除本地保存账号信息（仅清除密码）
     */
    private void clearAccountInfo(){
        LoginParam param = getAccountInfo();
        param.password = "";
        saveAccountInfo(param);
    }

}
