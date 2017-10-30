package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_TOKEN_EXPIRE;

/**
 * 登录管理类
 * Created by Hunter Mun on 2017/5/26.
 */

public class LoginManager {

    private static final String TAG = LoginManager.class.getName();
    private static final int LOGIN_CALLBACK = 1;
    private static final int LOGOUT_CALLBACK = 2;
    private static final int EVENT_MAINMODULE_LOGIN = 3;
    private static final int EVENT_MAINMODULE_LOGOUT = 4;

    private static final int RELOGIN_STAMP = 5 * 1000; //每5秒重新重登录一次

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

    //存储当前登陆token
    private String mUserId;
    private String mQNToken;
    private Handler mHandler;

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

        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.what){
                    case LOGIN_CALLBACK:{
                        if(mLoginStatus == LoginStatus.Default){
                            //处理登录中注销，由于停止不一定成功，即登录成功返回忽略不处理
                            return;
                        }
                        LoginItem item = (LoginItem)response.data;
                        if(response.isSuccess){
                            //登录成功则先本地缓存登录信息
                            mLoginStatus = LoginStatus.Logined;
                            LoginParam param = new LoginParam(mUserId, mQNToken);
                            saveAccountInfo(param);
                            mLoginItem = item;

                            //通知主模块显示广告界面
                            LiveService.getInstance().onAdvertShowNotify(item.isPushAd);

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
                            //表情配置
                            ChatEmojiManager.getInstance().getEmojiList(null);
                        }else{
                            mLoginStatus = LoginStatus.Default;
                            //登录失败，如果为Token无效时，通知主模块重新登录
                            if(TextUtils.isEmpty(mQNToken) || IntToEnumUtils.intToHttpErrorType(response.errCode) == HTTP_LCC_ERR_TOKEN_EXPIRE){
                                //token异常时通知服务器,自动重登录
                                onModuleSessionOverTime();
                            }else{
                                //普通错误，无限重新登录
                                postDelayed(new Runnable() {
                                    @Override
                                    public void run() {
                                        login(mUserId, mQNToken);
                                    }
                                }, RELOGIN_STAMP);
                            }
                        }
                        //通知登录返回结果
                        notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, item);
                    }break;

                    case LOGOUT_CALLBACK:{
                        //注销分发事件
                        notifyAllListenerLogout();
                    }break;

                    case EVENT_MAINMODULE_LOGIN:{
                        //主模块登录通知
                        if(mLoginStatus == LoginStatus.Logined){
                            //如果子模块当前登录状态，先注销再登录
                            logout(false);
                        }
                        if(response.isSuccess){
                            //主模块登录成功，子模块直接登录
                            LoginParam param = (LoginParam)response.data;
                            login(param.userId, param.qnToken);
                        }else{
                            //通知子模块监听登录listener登录失败（主模块失败即子模块失败），ps:session过期等处理
                            for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                                IAuthorizationListener listener = iter.next();
                                listener.onLogin(false, 0, "", null);
                            }
                        }

                    }break;

                    case EVENT_MAINMODULE_LOGOUT:{
                        //主模块注销
                        IQNService.LogoutType type = IQNService.LogoutType.values()[(Integer) response.data];
                        logout(type == IQNService.LogoutType.ManualLogout);
                    }break;
                }
            }
        };
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

    /**
     * 自动登录
     * @return
     */
    public boolean autoLogin(){
        boolean result = false;
        LoginParam param = getAccountInfo();
        if(param != null && !TextUtils.isEmpty(param.qnToken)){
            result = true;
            login(param.userId, param.qnToken);
        }
        return result;
    }

    /**
     * 模块内部登录接口
     * @param userId
     * @param qnToken
     */
    public void login(String userId,  final String qnToken){
        this.mQNToken = qnToken;
        this.mUserId = userId;
        switch (mLoginStatus){
            case Default:{
                //未登录状态
                loginInternal();
            }break;
            case Logined:{
                //已登录成功，直接回调
                for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                    IAuthorizationListener listener = iter.next();
                    listener.onLogin(true, 0, "", mLoginItem);
                }
            }break;
            case Logining:{
                //登陆中不处理
            }break;
        }
    }

    /**
     * 指定登录逻辑
     */
    private void loginInternal(){
        mLoginStatus = LoginStatus.Logining;
        String deviceId = SystemUtils.getDeviceId(mContext);
        RequestJniAuthorization.Login(mUserId, mQNToken, deviceId, new OnRequestLoginCallback() {
            public void onRequestLogin(boolean isSuccess,
                                       int errCode, String errMsg, LoginItem item) {
                Log.d(TAG,"onRequestLogin-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" item:"+item);
                Message msg = Message.obtain();
                msg.what = LOGIN_CALLBACK;
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
                msg.obj = response;
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 注销
     * @param isManual  是否手动
     */
    public void logout(boolean isManual){
        mLoginStatus = LoginStatus.Default;
        mLoginItem = null;
        mHandler.sendEmptyMessage(LOGOUT_CALLBACK);
        if(isManual) {
            clearAccountInfo();
            RequestJniAuthorization.Logout(new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                }
            });
        }
    }

    /**
     * 获取用户信息
     * @return
     */
    public LoginItem getLoginItem(){
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
     * 通知监听器，登录结果
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    private void notifyAllListenerLgoined(boolean isSuccess, int errCode, String errMsg, LoginItem item){
        //通知登录返回结果
        synchronized (mListenerList) {
            for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                IAuthorizationListener listener = iter.next();
                listener.onLogin(isSuccess, errCode, errMsg, item);
            }
        }
    }

    /**
     * 通知监听器，注销结果
     */
    private void notifyAllListenerLogout(){
        synchronized (mListenerList) {
            for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                IAuthorizationListener listener = iter.next();
                listener.onLogout();
            }
        }
    }

    /**
     * 注销时清除本地保存账号信息（仅清除密码）
     */
    private void clearAccountInfo(){
        LoginParam param = getAccountInfo();
        if(param != null){
            param.qnToken = "";
            saveAccountInfo(param);
        }
    }

    /**************************  模块对接管理  ********************************/

    /**
     * 主模块登录成功
     * @param isSuccess
     * @param token
     */
    public void onMainMoudleLogin(boolean isSuccess, String userId, String token, String ga_uid){
        //提交GA统计ga_uid
        AnalyticsManager.newInstance().setGAUserId(ga_uid);

        Log.d(TAG,"onMainMoudleLogin-isSuccess:" + isSuccess + " userId: " + userId + " token:" + token);
        Message msg = Message.obtain();
        msg.what = EVENT_MAINMODULE_LOGIN;
        HttpRespObject response = new HttpRespObject(isSuccess, 0, "", new LoginParam(userId, token));
        msg.obj = response;
        mHandler.sendMessage(msg);
    }

    /**
     * 主模块注销
     * @param type  手动／自动
     * @param tips
     */
    public void onMainMoudleLogout(IQNService.LogoutType type, String tips){
        Log.d(TAG,"onMainMoudleLogout-type:" + type.name() + " tips:" + tips);
        Message msg = Message.obtain();
        msg.what = EVENT_MAINMODULE_LOGOUT;
        HttpRespObject response = new HttpRespObject(true, 0, "", Integer.valueOf(type.ordinal()));
        msg.obj = response;
        mHandler.sendMessage(msg);
    }

    /**
     * session过期通知
     */
    public void onModuleSessionOverTime(){
        if(mLoginStatus == LoginStatus.Logining){
            //登录中，拦截session timeout事件
            return;
        }
        if(mLoginStatus == LoginStatus.Logined){
            logout(false);
        }
        LiveService.getInstance().onModuleSessionOverTime();
    }

}
