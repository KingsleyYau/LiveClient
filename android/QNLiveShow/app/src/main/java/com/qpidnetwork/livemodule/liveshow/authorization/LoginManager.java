package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.utils.SystemUtils;

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
                }else {
                    Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist",
                            "OnLoginManagerListener", "register",
                            listener.getClass().getSimpleName()));
                }
            }
            else {
                Log.e(TAG, String.format("%s::%s() fail, listener is null",
                        "OnLoginManagerListener", "register"));
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
            Log.e(TAG, String.format("%s::%s() fail, listener:%s",
                    "OnLoginManagerListener", "unRegister",
                    listener.getClass().getSimpleName()));
        }
        return result;
    }

    public boolean autoLogin(){
        boolean result = false;
        LoginParam param = getAccountInfo();
        if(param != null && !TextUtils.isEmpty(param.qnToken)){
            result = true;
            login(param.qnToken);
        }
        return result;
    }

    public void login(final String qnToken){
        if(mLoginStatus == LoginStatus.Default) {
            mLoginStatus = LoginStatus.Logining;
            String deviceId = SystemUtils.getDeviceId(mContext);
            RequestJniAuthorization.Login(qnToken, deviceId, new OnRequestLoginCallback() {
                public void onRequestLogin(boolean isSuccess,
                                           int errCode, String errMsg, LoginItem item) {
                    synchronized (mListenerList) {
                        Log.d(TAG,"onRequestLogin-isSuccess:"+isSuccess+" errCode:"+errCode
                            +" errMsg:"+errMsg+" item:"+item);
                        mLoginStatus = isSuccess ? LoginStatus.Logined : LoginStatus.Default;
                        if(isSuccess){
                            //登录成功则先本地缓存登录信息
                            LoginParam param = new LoginParam(qnToken);
                            saveAccountInfo(param);
                            mLoginItem = item;
                        }
                        for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                            IAuthorizationListener listener = iter.next();
                            listener.onLogin(isSuccess, errCode, errMsg, item);
                        }
                        if(isSuccess){
                            //更新礼物配置信息
                            if(!NormalGiftManager.getInstance().isLocalAllGiftConfigExisted()){
                                NormalGiftManager.getInstance().getAllGiftItems(
                                        new OnGetGiftListCallback() {
                                            @Override
                                            public void onGetGiftList(boolean isSuccess, int errCode,
                                                                      String errMsg, GiftItem[] giftList) {
                                                if(isSuccess){
                                                    //更新背包礼物配置信息
                                                    PackageGiftManager.getInstance().getAllPackageGiftItems(null);
                                                }
                                            }
                                        });

                            }
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
//        clearAccountInfo();
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
        param.qnToken = "";
        saveAccountInfo(param);
    }

}
