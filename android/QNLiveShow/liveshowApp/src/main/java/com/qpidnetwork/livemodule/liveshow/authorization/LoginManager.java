package com.qpidnetwork.livemodule.liveshow.authorization;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import com.appsflyer.AppsFlyerLib;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSayHiResourceConfigCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestSidCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResourceConfigItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftTypeListManager;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SpeedTestManager;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigerManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.MyProfilePerfenceLive;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiConfigManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.AccountInfoBean;
import com.qpidnetwork.qnbridgemodule.datacache.LocalCorePreferenceManager;
import com.qpidnetwork.qnbridgemodule.fcm.FCMPushManager;
import com.qpidnetwork.qnbridgemodule.ga.GaidManager;
import com.qpidnetwork.qnbridgemodule.interfaces.OnGcmGenerateRegisterIdCallback;
import com.qpidnetwork.qnbridgemodule.statics.PhoneInfoCheckResult;
import com.qpidnetwork.qnbridgemodule.statics.PhoneInfoManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import io.reactivex.functions.Consumer;

import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS;

/**
 * 登录管理类
 * Created by Hunter Mun on 2017/5/26.
 */

public class LoginManager {

    private static final String TAG = LoginManager.class.getName();
    private static final int LOGIN_CALLBACK = 1;
    private static final int LOGOUT_CALLBACK = 2;
//    private static final int EVENT_MAINMODULE_LOGIN = 3;
//    private static final int EVENT_MAINMODULE_LOGOUT = 4;
    private static final int LOGIN_QN_CALLBACK = 6;
    private static final int IM_LOGIN_CALLBACK = 7;     //IM登陆返回

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
    private LoginItem mLoginItem;       //缓存当前用户资料
    private LoginParam mLoginParam;     //缓存登录信息

    //同步配置信息
//    private ConfigItem mConfigItem;     //同步配置返回信息

    private int mQNWebsiteId = 41;  //默认为41 参考文档
    private Handler mHandler;

    /**
     * 登录QN返回的数据
     */
    class QNLoginData{
        public String memberId;
        public String sid;
    }

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
        mLoginParam = new LoginParam();

        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                Log.i(TAG, "handleMessage msg.what:%d", msg.what);
                switch (msg.what){
                    case LOGIN_QN_CALLBACK:{
                        if(response.isSuccess && response.data != null){
                            //QN登录成功了
                            QNLoginData qnLoginData = (QNLoginData)response.data;
                            //登录直播
                            loginToLive(qnLoginData.memberId, qnLoginData.sid);
                        }else{
                            mLoginStatus = LoginStatus.Default;
                        }
                    }break;

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
                            if(mLoginParam.loginType == LoginParam.LoginType.Password){
                                saveAccountInfo(mLoginParam);
                            }
                            mLoginItem = item;

                            //清空上一个帐号个人资料(缓存)]
                            MyProfilePerfenceLive.clearProfileItem(mContext);

                            //上传phoneInfo
                            uploadPhoneInfo(mLoginItem);

                            //登陆成功刷新SayHi配置
                            if(item.userPriv != null && item.userPriv.isSayHiPriv) {
                                SayHiConfigManager.getInstance().GetSayHiResourceConfig(new OnGetSayHiResourceConfigCallback() {
                                    @Override
                                    public void onGetSayHiResourceConfig(boolean isSuccess, int errCode, String errMsg, SayHiResourceConfigItem configItem) {

                                    }
                                });
                            }

                            //通知IM登陆，IM登陆成功才算登陆成功
                            notifyImLogin(response.isSuccess, response.errCode, response.errMsg, item);
                        }else{
                            mLoginStatus = LoginStatus.Default;

                            //通知IM登陆清除部分数据
                            notifyImLogin(response.isSuccess, response.errCode, response.errMsg, item);

                            //php登陆失败，登陆终止，通知登陆失败
                            notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, item);
                        }
                    }break;

                    case LOGOUT_CALLBACK:{
                        //注销分发事件
                        boolean isMannual = msg.arg1 == 1 ? true:false;
                        notifyAllListenerLogout(isMannual);

                    }break;

                    case IM_LOGIN_CALLBACK:{
                        IMManager.getInstance().unregisterIMOtherEventListener(mImOtherEventListener);
                        if(mLoginStatus == LoginStatus.Default){
                            //处理登录中注销，由于停止不一定成功，即登录成功返回忽略不处理
                            return;
                        }
                        if(response.isSuccess){
                            //成功
                            mLoginStatus = LoginStatus.Logined;

                            //绑定GCM
                            doBindGCMRegistationId();

                            //更新礼物配置信息
                            NormalGiftManager.getInstance().getAllGiftItems(null);

                            // 2019/9/4 Hardy 更新礼物分类
                            RoomGiftTypeListManager.getInstance().getGiftTypeItemList(RequestJniLiveShow.GiftRoomType.Private, null);

                            //表情配置
                            ChatEmojiManager.getInstance().getEmojiList(null);

                            //刷新预约列表未读数目
                            ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                            //测速
                            if(mLoginItem.svrList.length > 0){
                                SpeedTestManager.getInstance(mContext).doTest(mLoginItem.svrList);
                            }
                            //ga统计gaUserId
                            if(mLoginItem != null) {
                                AnalyticsManager.newInstance().setGAUserId(mLoginItem.gaUid);
                            }

                            //IM登陆成功，通知登陆成功
                            notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, mLoginItem);

                        }else{
                            mLoginStatus = LoginStatus.Default;
                            //失败通知其他模块
                            notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, null);
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

    //del by Jagger 2018-9-29 旧登录逻辑不要了
//    /**
//     * 自动登录
//     * @return
//     */
//    public boolean autoLogin(){
//        boolean result = false;
//        LoginParam param = getAccountInfo();
//        if(param != null && !TextUtils.isEmpty(param.qnToken)){
//            result = true;
//            login(param.userId, param.qnToken, param.qnWebsiteId);
//        }
//        return result;
//    }
//
//    /**
//     * 模块内部登录接口
//     * @param userId
//     * @param qnToken
//     */
//    public void login(String userId,  final String qnToken, int mQNWebsiteId){
//        this.mQNToken = qnToken;
//        this.mUserId = userId;
//        this.mQNWebsiteId = mQNWebsiteId;
//        switch (mLoginStatus){
//            case Default:{
//                //未登录状态
//                mLoginStatus = LoginStatus.Logining;
//                if(SynConfigerManager.getInstance(mContext).getConfigItemCache() != null) {
//                    //本地有配置文件，不需要再同步配置
//                    loginInternal();
//                }else{
//                    startLogin();
//                }
//            }break;
//            case Logined:{
//                //已登录成功，直接回调
//                notifyAllListenerLgoined(true, 0, "", mLoginItem);
//            }break;
//            case Logining:{
//                //登陆中不处理
//            }break;
//        }
//    }
//
//    /**
//     * 模块内部重登录接口
//     */
//    public void reLogin(){
//        if(mQNLoginParam != null){
//            login(mQNLoginParam.userId, mQNLoginParam.qnToken, mQNLoginParam.qnWebsiteId);
//        }
//    }
//
//    /**
//     * 启动登录逻辑，登录逻辑主要分为两步：
//     *  1.获取同步配置；
//     *  2.调用登录
//     * 中间失败当成登录失败
//     */
//    private void startLogin(){
//
////        RequestJniOther.SynConfig(new OnSynConfigCallback() {
////            @Override
////            public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem) {
////                Message msg = Message.obtain();
////                msg.what = SYNCONFIG_CALLBACK;
////                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, configItem);
////                msg.obj = response;
////                mHandler.sendMessage(msg);
////            }
////        });
//
//        SynConfigerManager.getInstance(mContext).setSynConfigResultObserver(new Consumer<SynConfigerManager.ConfigResult>() {
//            @Override
//            public void accept(SynConfigerManager.ConfigResult configResult){
//                if(configResult.isSuccess && (configResult.item != null)){
//                    //同步配置成功，继续登录逻辑
//                    Log.i(TAG, "SYNCONFIG_CALLBACK ConfigItem imServerUrl:%s httpServerUrl:%s addCreditsUrl:%s anchorPage:%s userLevel:%s intimacy:%s",
//                            configResult.item.imServerUrl, configResult.item.httpServerUrl, configResult.item.addCreditsUrl, configResult.item.anchorPage, configResult.item.userLevel, configResult.item.intimacy);
//                    //设置app域名
//                    RequestJni.SetWebSite(configResult.item.httpServerUrl);
//
//                    if(mLoginStatus == LoginStatus.Logining){
//                        //继续登录逻辑
//                        loginInternal();
//                    }
//                }else{
//                    if(mLoginStatus == LoginStatus.Logining){
//                        //登录中即为登录失败，启动延时重登录逻辑
//                        mLoginStatus = LoginStatus.Default;
//                        mHandler.postDelayed(new Runnable() {
//                            @Override
//                            public void run() {
//                                login(mUserId, mQNToken, mQNWebsiteId);
//                            }
//                        }, RELOGIN_STAMP);
//                    }
//                }
//            }
//        }).getSynConfig();
//    }
//
//    /**
//     * 指定登录逻辑
//     */
//    private void loginInternal(){
//        mLoginStatus = LoginStatus.Logining;
//        String deviceId = SystemUtils.getDeviceId(mContext);
//        RequestJniAuthorization.Login(mUserId, mQNToken, deviceId, new OnRequestLoginCallback() {
//            public void onRequestLogin(boolean isSuccess,
//                                       int errCode, String errMsg, LoginItem item) {
//                Log.d(TAG,"onRequestLogin-isSuccess:"+isSuccess+" errCode:" + errCode +" errMsg:" + errMsg+" item:"+item);
//                Message msg = Message.obtain();
//                msg.what = LOGIN_CALLBACK;
//                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
//                msg.obj = response;
//                mHandler.sendMessage(msg);
//            }
//        });
//    }

    //---------------- 新登录逻辑(2018-9-26) start-----------------
    //----　流程：
    //----　1.获取同步配置
    //----　2.可分别使用两种登录方式：
    //----　 a.帐号密码登录 对应接口文档<2.20>
    //----　 b.token登录　 对应接口文档<2.21>
    //----　3.使用登录返回user_sid，再调用直播HTTP登录 对应接口文档<2.1>

    /**
     * 帐号密码登录 对应接口文档<2.20>
     * @param email　用户ID或EMAIL
     * @param password　密码
     * @param authCode　验证码
     */
    public void loginByUsernamePassword(final String email, final String password, final String authCode){
        //避免重复登录
        if(mLoginStatus != LoginStatus.Default){
            return;
        }

        //
        mLoginStatus = LoginStatus.Logining;
        mLoginParam.loginType = LoginParam.LoginType.Password;
        mLoginParam.account = email;
        mLoginParam.password = password;

        //
        SynConfigerManager.getInstance().setSynConfigResultObserver(new Consumer<SynConfigerManager.ConfigResult>() {
            @Override
            public void accept(SynConfigerManager.ConfigResult configResult){
                if(configResult.isSuccess && (configResult.item != null)){
                    //同步配置成功，继续登录逻辑
                    Log.i(TAG, "SYNCONFIG_CALLBACK ConfigItem imServerUrl:%s httpServerUrl:%s addCreditsUrl:%s anchorPage:%s userLevel:%s intimacy:%s",
                            configResult.item.imServerUrl, configResult.item.httpServerUrl, configResult.item.addCreditsUrl, configResult.item.anchorPage, configResult.item.userLevel, configResult.item.intimacy);
                    //设置app域名
//                    RequestJni.SetWebSite(configResult.item.httpServerUrl);

                    if(mLoginStatus == LoginStatus.Logining){

                        //TODO
                        //取Google广告ID
                        GaidManager.getInstance().loadGaid(new GaidManager.OnGetGaidCallback() {
                            @Override
                            public void onGetGaid(String gaid) {
                                String appFlywerID = AppsFlyerLib.getInstance().getAppsFlyerUID(mContext);
                                String deviceId = SystemUtils.getDeviceId(mContext);

                                //继续登录QN逻辑+
                                RequestJniAuthorization.PasswordLogin(email, password, authCode, appFlywerID, gaid, deviceId, new OnRequestSidCallback() {
                                    @Override
                                    public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid) {
                                        //登录QN返回
                                        if(isSuccess){
                                            QNLoginData qnLoginData = new QNLoginData();
                                            qnLoginData.memberId = memberId;
                                            qnLoginData.sid = sid;

                                            Message msg = Message.obtain();
                                            msg.what = LOGIN_QN_CALLBACK;
                                            HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, qnLoginData);
                                            msg.obj = response;
                                            mHandler.sendMessage(msg);

                                            //只作缓存
                                            mLoginParam.memberId = memberId;
                                        }else {
                                            //即为登录失败
                                            Message msg = Message.obtain();
                                            msg.what = LOGIN_CALLBACK;
                                            HttpRespObject response = new HttpRespObject(false, errCode, errMsg, null);
                                            msg.obj = response;
                                            mHandler.sendMessage(msg);
                                        }

                                    }
                                });
                            }
                        });
                    }
                }else{
                    //即为登录失败
                    Message msg = Message.obtain();
                    msg.what = LOGIN_CALLBACK;
                    HttpRespObject response = new HttpRespObject(false, configResult.errno, configResult.errmsg, null);
                    msg.obj = response;
                    mHandler.sendMessage(msg);
                }
            }
        }).getSynConfig();
    }

    /**
     * token登录　 对应接口文档<2.21>
     * @param token　　其它站点的加密串
     */
    public void loginByToken(final String token){
        //读取本地帐号密码登录
        LoginParam loginParam = getAccountInfo();
        if(loginParam != null && !TextUtils.isEmpty(loginParam.memberId)){
            loginByToken(loginParam.memberId, token);
        }
    }

    /**
     * token登录　 对应接口文档<2.21>
     * @param memberId 用户ID(CM2178)
     * @param token　　其它站点的加密串
     */
    public void loginByToken(final String memberId, final String token){
        Log.i("Jagger" , "LIVE LoginManager memberId:" + memberId + ",token:" + token);
        //避免重复登录
        if(mLoginStatus != LoginStatus.Default){
            return;
        }

        //只作缓存
        mLoginStatus = LoginStatus.Logining;
        mLoginParam.loginType = LoginParam.LoginType.Token;
        mLoginParam.token4Qn = token;
        mLoginParam.memberId = memberId;

        //
        SynConfigerManager.getInstance().setSynConfigResultObserver(new Consumer<SynConfigerManager.ConfigResult>() {
            @Override
            public void accept(SynConfigerManager.ConfigResult configResult){
                if(configResult.isSuccess && (configResult.item != null)){
                    //同步配置成功，继续登录逻辑
                    Log.i(TAG, "SYNCONFIG_CALLBACK ConfigItem imServerUrl:%s httpServerUrl:%s addCreditsUrl:%s anchorPage:%s userLevel:%s intimacy:%s",
                            configResult.item.imServerUrl, configResult.item.httpServerUrl, configResult.item.addCreditsUrl, configResult.item.anchorPage, configResult.item.userLevel, configResult.item.intimacy);
                    //设置app域名
//                    RequestJni.SetWebSite(configResult.item.httpServerUrl);

                    if(mLoginStatus == LoginStatus.Logining){
                        //TODO
                        //继续登录QN逻辑
                        RequestJniAuthorization.TokenLogin(memberId, token, new OnRequestSidCallback() {
                            @Override
                            public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid) {
                                //登录QN返回
                                if(isSuccess){
                                    QNLoginData qnLoginData = new QNLoginData();
                                    qnLoginData.memberId = memberId;
                                    qnLoginData.sid = sid;

                                    Message msg = Message.obtain();
                                    msg.what = LOGIN_QN_CALLBACK;
                                    HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, qnLoginData);
                                    msg.obj = response;
                                    mHandler.sendMessage(msg);
                                }else {
                                    //即为登录失败
                                    Message msg = Message.obtain();
                                    msg.what = LOGIN_CALLBACK;
                                    HttpRespObject response = new HttpRespObject(false, errCode, errMsg, null);
                                    msg.obj = response;
                                    mHandler.sendMessage(msg);
                                }

                            }
                        });
                    }
                }else{
                    //即为登录失败
                    Message msg = Message.obtain();
                    msg.what = LOGIN_CALLBACK;
                    HttpRespObject response = new HttpRespObject(false, configResult.errno, configResult.errmsg, null);
                    msg.obj = response;
                    mHandler.sendMessage(msg);
                }
            }
        }).getSynConfig();
    }

    /**
     * 自动登录
     * (使用本地帐号密码登录)
     */
    public void autoLogin(){
        //避免重复登录
        if(mLoginStatus != LoginStatus.Default){
            return;
        }

        //读取本地帐号密码登录
        LoginParam loginParam = getAccountInfo();
        if(loginParam != null && !TextUtils.isEmpty(loginParam.account) && !TextUtils.isEmpty(loginParam.password)){
            loginByUsernamePassword(loginParam.account, loginParam.password, "");
        }
    }

    /**
     * 使用登录返回user_sid，再调用直播HTTP登录 对应接口文档<2.1>
     * @param memberId
     * @param userId
     */
    private void loginToLive(String memberId,String userId){
        mLoginStatus = LoginStatus.Logining;
        String deviceId = SystemUtils.getDeviceId(mContext);
        RequestJniAuthorization.Login(memberId, userId, deviceId, new OnRequestLoginCallback() {
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

    //---------------- 新登录逻辑(2018-9-26) end-----------------

    /**
     * 清除账号信息并注销（主要用于区分换站需注销IM但是不用清除账号信息）
     * @param isManual
     */
    public void LogoutAndClean(boolean isManual){
        //清除账号信息
        clearAccountInfo();
        logout(isManual, true);
    }

    /**
     * session过期等处理
     * @param isManual
     */
    public void logout(boolean isManual){
        logout(isManual, false);
    }

    /**
     * 注销
     * @param isManual  是否手动
     * @param isUnbindGCM 解绑GCM
     */
    public void logout(boolean isManual, boolean isUnbindGCM){
        mLoginStatus = LoginStatus.Default;
        mLoginItem = null;
//        mConfigItem = null;

        Message msg = Message.obtain();
        msg.what = LOGOUT_CALLBACK;
        msg.arg1 = isManual?1:0;
        mHandler.sendMessage(msg);

        //注销IM
        notifyIMLogout(isManual);

        if(isUnbindGCM){
            //解绑GCM
            doUnbindGCMRegisterId(new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    RequestJni.CleanCookies();
                }
            });
        }else{
            RequestJni.CleanCookies();
        }

        //手动注销
        if(isManual) {
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

            //重置SayHiConfig刷新标志位
            SayHiConfigManager.getInstance().resetSayHiConfig();

            //手动注销清空通知栏
            PushManager.getInstance().CancelAll();

            //直播间虚拟礼物相关
            NormalGiftManager.getInstance().onDestroy();
            RoomGiftTypeListManager.getInstance().onDestroy();
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
     * 获取Livechat是否有发送语音权限
     * @return
     */
    public boolean isLivechatSendVoicePermit(){
        boolean isPermit = false;
        if(mLoginItem != null && mLoginItem.userPriv != null && mLoginItem.userPriv.liveChatPriv != null){
            isPermit = mLoginItem.userPriv.liveChatPriv.isSendLiveChatVoicePriv;
        }
        return isPermit;
    }

    /**
     * 获取同步配置配置内容
     * @return
     */
    public ConfigItem getSynConfig(){
        return SynConfigerManager.getInstance().getConfigItemCache();
    }

    /**
     * 保存已登录账号信息
     * @param loginParam
     */
    private void saveAccountInfo(LoginParam loginParam){
//        new LocalPreferenceManager(mContext).saveLoginAccountInfoItem(loginParam);
        if(loginParam != null && !TextUtils.isEmpty(loginParam.account)){
            //转化数据结构
            AccountInfoBean accountInfoBean = new AccountInfoBean();
            accountInfoBean.account = loginParam.account;
            accountInfoBean.password = loginParam.password;
            accountInfoBean.userId = loginParam.memberId;
            accountInfoBean.type = AccountInfoBean.LoginType.Default;
            //保存到公共模块
            LocalCorePreferenceManager localCorePreferenceManager = new LocalCorePreferenceManager(mContext);
            localCorePreferenceManager.saveAccountInfo(accountInfoBean);
        }
    }

    /**
     * 获取上次登录成功账号信息
     * @return
     */
    public LoginParam getAccountInfo(){
//        return new LocalPreferenceManager(mContext).getLoginAccountInfoItem();
        //从公共模块取上次登录信息
        LocalCorePreferenceManager localCorePreferenceManager = new LocalCorePreferenceManager(mContext);
        AccountInfoBean accountInfoBean = localCorePreferenceManager.getAccountInfo();

        //转化数据结构
        LoginParam loginParam = new LoginParam();
        if(accountInfoBean != null){
            loginParam.account = accountInfoBean.account;
            loginParam.password = accountInfoBean.password;
            loginParam.memberId = accountInfoBean.userId;
        }

        return loginParam;
    }

    /**
     * 更新共享数据库中密码
     * @param newPassword
     */
    public void updatePassword(String newPassword){
        LoginParam tempLoginParam = getAccountInfo();
        tempLoginParam.password = newPassword;

        saveAccountInfo(tempLoginParam);

    }

    /**
     * 取同步配置缓存
     * @return
     */
    public ConfigItem getLocalConfigItem(){
        return SynConfigerManager.getInstance().getConfigItemCache();
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
            param.password = "";
            saveAccountInfo(param);
        }
    }

    /**************************  模块对接管理  ********************************/

//    /**
//     * 主模块登录成功
//     * @param isSuccess
//     * @param token
//     */
//    public void onMainMoudleLogin(boolean isSuccess, String userId, String token, String ga_uid, int websiteId){
//        //提交GA统计ga_uid
//        AnalyticsManager.newInstance().setGAUserId(ga_uid);
//
//        Log.d(TAG,"onMainMoudleLogin-isSuccess:" + isSuccess + " userId: " + userId + " token:" + token);
//        Message msg = Message.obtain();
//        msg.what = EVENT_MAINMODULE_LOGIN;
//        //add by Jagger 2018-5-23 添加默认错误提示
//        HttpLccErrType errType = HttpLccErrType.HTTP_LCC_ERR_SUCCESS;
//        if(isSuccess){
//            errType = HttpLccErrType.HTTP_LCC_ERR_SUCCESS;
//        }else{
//            errType = HttpLccErrType.HTTP_LCC_ERR_FAIL;
//        }
//        HttpRespObject response = new HttpRespObject(isSuccess, errType.ordinal(), mContext.getString(R.string.system_notice_qn_login_fail), new LoginParam(userId, token, websiteId));
//        msg.obj = response;
//        mHandler.sendMessage(msg);
//    }

//    /**
//     * 主模块注销
//     * @param type  手动／自动
//     * @param tips
//     */
//    public void onMainMoudleLogout(IQNService.LogoutType type, String tips){
//        Log.d(TAG,"onMainMoudleLogout-type:" + type.name() + " tips:" + tips);
//        Message msg = Message.obtain();
//        msg.what = EVENT_MAINMODULE_LOGOUT;
//        HttpRespObject response = new HttpRespObject(true, 0, "", Integer.valueOf(type.ordinal()));
//        msg.obj = response;
//        mHandler.sendMessage(msg);
//    }

    /**
     * session过期通知
     */
    public void onModuleSessionOverTime(){
        //del by Jagger 2018-10-10
//        if(mLoginStatus == LoginStatus.Logined) {
//            //直播未登录不处理token过期逻辑（和Samson确认过）
//            if (mLoginStatus == LoginStatus.Logining) {
//                //登录中，拦截session timeout事件
//                return;
//            }
//            if (mLoginStatus == LoginStatus.Logined) {
//                logout(false);
//            }
//
//            //发送广播通知界面
//            Intent intent = new Intent(CommonConstant.ACTION_SESSION_TIMEOUT);
////            mContext.sendBroadcast(intent);
        //            BroadcastManager.sendBroadcast(mContext,intent);
//        }

        //edit by Jagger 2018-10-10
        //直播未登录不处理token过期逻辑（和Samson确认过）
        if (mLoginStatus == LoginStatus.Logining) {
            //登录中，拦截session timeout事件
            return;
        }else if(mLoginStatus == LoginStatus.Logined
                || mLoginStatus == LoginStatus.Default) {
            //add by hunter,增加支持未登录自动登陆
            logout(false);

            //重登录
            autoLogin();
        }
    }

    //------------------- GCM start -----------------
    /**
     * 登录成功，绑定启动GCM RegId
     */
    private void doBindGCMRegistationId(){
//        GCMPushManager.getInstance(mContext).generateRegId(new OnGcmGenerateRegisterIdCallback() {
        FCMPushManager.getInstance(mContext).generateRegId(new OnGcmGenerateRegisterIdCallback() {
            @Override
            public void onGcmGenerateRegisterId(String gcmRegId) {
                //ps: gcmRegId为空 2018-10-8
                Log.i("Jagger" , "LoginManager doBindGCMRegistationId gcmRegId:" + gcmRegId);
                //生成GCM regId
                if(!TextUtils.isEmpty(gcmRegId)){
                    String deviceId = SystemUtils.getDeviceId(mContext);
                    LiveDomainRequestOperator.getInstance().AddToken(gcmRegId, mContext.getPackageName(), deviceId, new OnRequestCallback(){

                        @Override
                        public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                            Log.i("Jagger" , "LoginManager doBindGCMRegistationId AddToken isSuccess:" + isSuccess);
                        }
                    });
                }
            }
        });
    }

    /**
     * 解绑GCM绑定
     */
    private void doUnbindGCMRegisterId(OnRequestCallback callback){
        LiveDomainRequestOperator.getInstance().DestroyToken(callback);
    }
    //------------------- GCM end -----------------

    //------------------- IM 登陆 -----------------

    /**
     * 通知IM登陆
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    private void notifyImLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item){
        IMManager imManager = IMManager.getInstance();
        imManager.registerIMOtherEventListener(mImOtherEventListener);
        imManager.onLogin(isSuccess, errCode, errMsg, item);
    }

    private IMOtherEventListener mImOtherEventListener = new IMOtherEventListener() {
        @Override
        public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
            Message msg = Message.obtain();
            msg.what = IM_LOGIN_CALLBACK;
            boolean isSuccess = errType == LCC_ERR_SUCCESS ? true:false;
            msg.obj = new HttpRespObject(isSuccess, 0, errMsg, null);
            mHandler.sendMessage(msg);
        }

        @Override
        public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

        }

        @Override
        public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

        }

        @Override
        public void OnRecvLackOfCreditNotice(String roomId, String message, double credit, IMClientListener.LCC_ERR_TYPE err) {

        }

        @Override
        public void OnRecvCreditNotice(String roomId, double credit) {

        }

        @Override
        public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

        }

        @Override
        public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

        }

        @Override
        public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

        }

        @Override
        public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

        }

        @Override
        public void OnRecvLevelUpNotice(int level) {

        }

        @Override
        public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {

        }

        @Override
        public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

        }
    };

    /**
     * 通知IM注销
     * @param isMannual
     */
    private void notifyIMLogout(boolean isMannual){
        IMManager imManager = IMManager.getInstance();
        imManager.unregisterIMOtherEventListener(mImOtherEventListener);
        imManager.onLogout(isMannual);
    }

    /**
     * 上传手机信息
     */
    @SuppressLint("MissingPermission")
    private void uploadPhoneInfo(LoginItem loginItem){
        PhoneInfoCheckResult result = PhoneInfoManager.CheckRequestPhoneInfo(mContext, loginItem.userId);
        if(result != null && result.isRequst){
            RequestJniOther.LSActionType actionType = result.isNewUser ? RequestJniOther.LSActionType.NEWUSER : RequestJniOther.LSActionType.SETUP;
            TelephonyManager tm = (TelephonyManager)mContext.getSystemService(Context.TELEPHONY_SERVICE);
            int siteId = WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
            DisplayMetrics dm = new DisplayMetrics();
            WindowManager wm = (WindowManager)mContext.getSystemService(Context.WINDOW_SERVICE);
            wm.getDefaultDisplay().getMetrics(dm);

            int versionCode = 1;
            String versionName = "";
            try {
                PackageManager pm = mContext.getPackageManager();
                PackageInfo pi = pm.getPackageInfo(mContext.getPackageName(), PackageManager.GET_ACTIVITIES);
                if (pi != null) {
                    // 版本号
                    versionCode = pi.versionCode;
                    versionName = pi.versionName;
                }
            } catch (PackageManager.NameNotFoundException e) {
            }
            LiveDomainRequestOperator.getInstance().PhoneInfo(
                    loginItem.userId,
                    versionCode,
                    versionName,
                    actionType,
                    siteId,
                    dm.density,
                    dm.widthPixels,
                    dm.heightPixels,
                    tm.getLine1Number(),
                    tm.getSimOperatorName(),
                    tm.getSimOperator(),
                    tm.getSimCountryIso(),
                    String.valueOf(tm.getSimState()),
                    tm.getPhoneType(),
                    tm.getNetworkType(),
                    SystemUtils.getDeviceId(mContext),
                    null);
        }
    }

}
