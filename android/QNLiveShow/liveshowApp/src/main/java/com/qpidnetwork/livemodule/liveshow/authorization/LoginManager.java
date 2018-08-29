package com.qpidnetwork.livemodule.liveshow.authorization;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.livemodule.httprequest.OnSynConfigCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.RegionType;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SpeedTestManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.AdWebObj;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;

import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

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
    private static final int SYNCONFIG_CALLBACK = 5;
    private static final int RELOGIN_STAMP = 5 * 1000; //每5秒重新重登录一次

    public enum LoginStatus{
        Default,
        Logining,
        Logined
    }

    private Context mContext;
    private static LoginManager mLoginManager;
    //edit by Jagger 2018-3-7,由List改为CopyOnWriteArrayList,因为有时候会报java.util.ConcurrentModificationException
    private List<IAuthorizationListener> mListenerList;
    private LoginStatus mLoginStatus;
    private LoginItem mLoginItem;       //保存当前用户信息
    private LoginParam mQNLoginParam;   //QN传入的登录信息,用于重登录

    //同步配置信息
    private ConfigItem mConfigItem;     //同步配置返回信息
    private boolean isAdvertShow = false;       //QN展示广告一次启动仅显示一次

    //存储当前登陆token
    private String mUserId;
    private String mQNToken;
    private int mQNWebsiteId;
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

    @SuppressLint("HandlerLeak")
    private LoginManager(Context context){
        mContext = context;
        mListenerList = new CopyOnWriteArrayList<>();
        mLoginStatus = LoginStatus.Default;

        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                Log.i(TAG, "handleMessage msg.what:%d", msg.what);
                switch (msg.what){
                    case LOGIN_CALLBACK:{
                        if(mLoginStatus == LoginStatus.Default){
                            //处理登录中注销，由于停止不一定成功，即登录成功返回忽略不处理
                            return;
                        }
                        LoginItem item = (LoginItem)response.data;
                        if(response.isSuccess){
                            Log.i(TAG, "LOGIN_CALLBACK userId:%s token:%s nickname:%s isPushAd:%d srvlist.length:%d",
                                    item.userId, item.token, item.nickName, item.isPushAd?1:0, item.svrList!=null?item.svrList.length:0);
                            //登录成功则先本地缓存登录信息
                            mLoginStatus = LoginStatus.Logined;
                            LoginParam param = new LoginParam(mUserId, mQNToken, mQNWebsiteId);
                            saveAccountInfo(param);
                            mLoginItem = item;

                            //通知主模块显示广告界面(4格推荐主播广告)
                            if(!isAdvertShow && item.isPushAd){
                                //一次启动登录仅显示一次广告
                                LiveService.getInstance().onAdvertShowNotify(item.isPushAd);
                            }

                            //test
//                            item.qnMainAdId = "1";
//                            item.qnMainAdTitle = "title";
//                            item.qnMainAdUrl = "http://www.sina.com";
                            //通知主模块显示URL浮层广告
                            if(!TextUtils.isEmpty(item.qnMainAdId) && !TextUtils.isEmpty(item.qnMainAdUrl)){
                                AdWebObj adWeb = new AdWebObj();
                                adWeb.id = item.qnMainAdId;
                                adWeb.url = item.qnMainAdUrl;
                                adWeb.title = TextUtils.isEmpty(item.qnMainAdTitle)?"":item.qnMainAdTitle;
                                LiveService.getInstance().onURLAdvertShowNotify(true , adWeb);
                            }

                            //更新礼物配置信息
                            NormalGiftManager.getInstance().getAllGiftItems(null);

                            //表情配置
                            ChatEmojiManager.getInstance().getEmojiList(null);

                            //刷新预约列表未读数目
                            ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                            //测速
                            if(mLoginItem.svrList.length > 0){
                                SpeedTestManager.getInstance(mContext).doTest(mLoginItem.svrList);
                            }

                        }else{
                            mLoginStatus = LoginStatus.Default;
                            //登录失败，如果为Token无效时，通知主模块重新登录
                            if(TextUtils.isEmpty(mQNToken) || IntToEnumUtils.intToHttpErrorType(response.errCode) == HTTP_LCC_ERR_TOKEN_EXPIRE){
                                //token异常时通知服务器,自动重登录
                                onModuleSessionOverTime();
                            }
                            //del by Jagger 2018-3-6
//                            else{
//                                //普通错误，无限重新登录
//                                postDelayed(new Runnable() {
//                                    @Override
//                                    public void run() {
//                                        login(mUserId, mQNToken);
//                                    }
//                                }, RELOGIN_STAMP);
//                            }
                        }
                        //通知登录返回结果
                        notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, item);
                    }break;

                    case LOGOUT_CALLBACK:{
                        //注销分发事件
                        boolean isMannual = msg.arg1 == 1 ? true:false;
                        notifyAllListenerLogout(isMannual);
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
                            login(param.userId, param.qnToken, param.qnWebsiteId);

                            mQNLoginParam = param;
                        }else{
                            //通知子模块监听登录listener登录失败（主模块失败即子模块失败），ps:session过期等处理
                            notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, null);
                        }

                    }break;

                    case EVENT_MAINMODULE_LOGOUT:{
                        //主模块注销
                        IQNService.LogoutType type = IQNService.LogoutType.values()[(Integer) response.data];
                        logout(type == IQNService.LogoutType.ManualLogout);
                    }break;

                    case SYNCONFIG_CALLBACK:{
                        //同步配置返回
                        ConfigItem item = (ConfigItem)response.data;
                        if(response.isSuccess && (item != null)){
                            //同步配置成功，继续登录逻辑
                            mConfigItem = item;
                            Log.i(TAG, "SYNCONFIG_CALLBACK ConfigItem imServerUrl:%s httpServerUrl:%s addCreditsUrl:%s anchorPage:%s userLevel:%s intimacy:%s",
                                    mConfigItem.imServerUrl, mConfigItem.httpServerUrl, mConfigItem.addCreditsUrl, mConfigItem.anchorPage, mConfigItem.userLevel, mConfigItem.intimacy);
                            //设置app域名
                            RequestJni.SetWebSite(item.httpServerUrl);

                            if(mLoginStatus == LoginStatus.Logining){
                                //继续登录逻辑
                                loginInternal();
                            }
                        }else{
                            if(mLoginStatus == LoginStatus.Logining){
                                //登录中即为登录失败，启动延时重登录逻辑
                                mLoginStatus = LoginStatus.Default;
                                postDelayed(new Runnable() {
                                    @Override
                                    public void run() {
                                        login(mUserId, mQNToken, mQNWebsiteId);
                                    }
                                }, RELOGIN_STAMP);
                            }
                        }
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
            login(param.userId, param.qnToken, param.qnWebsiteId);
        }
        return result;
    }

    /**
     * 模块内部登录接口
     * @param userId
     * @param qnToken
     */
    public void login(String userId,  final String qnToken, int mQNWebsiteId){
        this.mQNToken = qnToken;
        this.mUserId = userId;
        this.mQNWebsiteId = mQNWebsiteId;
        switch (mLoginStatus){
            case Default:{
                //未登录状态
                mLoginStatus = LoginStatus.Logining;
                if(mConfigItem != null) {
                    //本地有配置文件，不需要再同步配置
                    loginInternal();
                }else{
                    startLogin();
                }
            }break;
            case Logined:{
                //已登录成功，直接回调
                notifyAllListenerLgoined(true, 0, "", mLoginItem);
            }break;
            case Logining:{
                //登陆中不处理
            }break;
        }
    }

    /**
     * 模块内部重登录接口
     */
    public void reLogin(){
        if(mQNLoginParam != null){
            login(mQNLoginParam.userId, mQNLoginParam.qnToken, mQNLoginParam.qnWebsiteId);
        }
    }

    /**
     * 启动登录逻辑，登录逻辑主要分为两步：
     *  1.获取同步配置；
     *  2.调用登录
     * 中间失败当成登录失败
     */
    private void startLogin(){

        RequestJniOther.SynConfig(new OnSynConfigCallback() {
            @Override
            public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem) {
                Message msg = Message.obtain();
                msg.what = SYNCONFIG_CALLBACK;
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, configItem);
                msg.obj = response;
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 指定登录逻辑
     */
    private void loginInternal(){
        mLoginStatus = LoginStatus.Logining;
        String deviceId = SystemUtils.getDeviceId(mContext);
        RequestJniAuthorization.Login(mUserId, mQNToken, deviceId, RegionType.valueOf(mQNWebsiteId), new OnRequestLoginCallback() {
            public void onRequestLogin(boolean isSuccess,
                                       int errCode, String errMsg, LoginItem item) {
                Log.d(TAG,"onRequestLogin-isSuccess:"+isSuccess+" errCode:" + errCode +" errMsg:" + errMsg+" item:"+item);
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
//        mConfigItem = null;

        Message msg = Message.obtain();
        msg.what = LOGOUT_CALLBACK;
        msg.arg1 = isManual?1:0;
        mHandler.sendMessage(msg);

        if(isManual) {
            isAdvertShow = false;
            RequestJni.CleanCookies();
            clearAccountInfo();
            RequestJniAuthorization.Logout(new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                }
            });

            //清除本地缓存
            ScheduleInvitePackageUnreadManager unreadManager = ScheduleInvitePackageUnreadManager.getInstance();
            if(unreadManager != null) {
                unreadManager.clearResetSelf();
            }
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
     * 获取同步配置配置内容
     * @return
     */
    public ConfigItem getSynConfig(){
        return mConfigItem;
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

    public ConfigItem getLocalConfigItem(){
        return mConfigItem;
    }

    /**
     * 获取当前登录状态
     * @return
     */
    public LoginStatus getLoginStatus() {
        return mLoginStatus;
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
    private void notifyAllListenerLogout(boolean isMannual){
        synchronized (mListenerList) {
            for (Iterator<IAuthorizationListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                IAuthorizationListener listener = iter.next();
                listener.onLogout(isMannual);
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
    public void onMainMoudleLogin(boolean isSuccess, String userId, String token, String ga_uid, int websiteId){
        //提交GA统计ga_uid
        AnalyticsManager.newInstance().setGAUserId(ga_uid);

        Log.d(TAG,"onMainMoudleLogin-isSuccess:" + isSuccess + " userId: " + userId + " token:" + token);
        Message msg = Message.obtain();
        msg.what = EVENT_MAINMODULE_LOGIN;
        //add by Jagger 2018-5-23 添加默认错误提示
        HttpLccErrType errType = HttpLccErrType.HTTP_LCC_ERR_SUCCESS;
        if(isSuccess){
            errType = HttpLccErrType.HTTP_LCC_ERR_SUCCESS;
        }else{
            errType = HttpLccErrType.HTTP_LCC_ERR_FAIL;
        }
        HttpRespObject response = new HttpRespObject(isSuccess, errType.ordinal(), mContext.getString(R.string.system_notice_qn_login_fail), new LoginParam(userId, token, websiteId));
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
        if(mLoginStatus == LoginStatus.Logined) {
            //直播未登录不处理token过期逻辑（和Samson确认过）
            if (mLoginStatus == LoginStatus.Logining) {
                //登录中，拦截session timeout事件
                return;
            }
            if (mLoginStatus == LoginStatus.Logined) {
                logout(false);
            }

            //发送广播通知界面
            Intent intent = new Intent(CommonConstant.ACTION_SESSION_TIMEOUT);
            mContext.sendBroadcast(intent);
        }
    }

}
