package com.qpidnetwork.anchor.liveshow.authorization;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.AccountInfoBean;
import com.qpidnetwork.anchor.httprequest.OnRequestGetVerificationCodeCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.anchor.httprequest.RequestJniAuthorization;
import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.anchor.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.anchor.liveshow.manager.AnchorInfoManager;
import com.qpidnetwork.anchor.liveshow.manager.ProgramUnreadManager;
import com.qpidnetwork.anchor.liveshow.manager.ScheduleInviteManager;
import com.qpidnetwork.anchor.liveshow.manager.SpeedTestManager;
import com.qpidnetwork.anchor.liveshow.manager.SynConfigManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

import java.util.ArrayList;
import java.util.Iterator;

import io.reactivex.functions.Consumer;

import static com.qpidnetwork.anchor.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL;
import static com.qpidnetwork.anchor.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_SUCCESS;

/**
 * 登录工具类
 * Created by Jagger on 2017/12/26.
 */

public class LoginManager {

    private static final String TAG = LoginManager.class.getName();
    private static final int EVENT_LOGIN_CALLBACK = 1;

    private Context mContext;

    //监听器
    private ArrayList<IAuthorizationListener> mListListener = new ArrayList<>();
    //登录成功，本地数据
    private LoginItem mLoginItem;
    //同步配置信息
    private ConfigItem mConfigItem;     //同步配置返回信息
    //登录状态
    private LoginStatus mLoginStatus = LoginStatus.Logout;
    //当前登录账号信息
    private AccountInfoBean mAccoutInfoBean = null;

    /**
     * 登录状态
     */
    private enum LoginStatus{
        Logout,
        Logging,
        Logged
    }

    private static LoginManager singleton;

    public static LoginManager getInstance(){
        return singleton;
    }

    public static LoginManager newInstance(Context c) {
        if (singleton == null) {
            singleton = new LoginManager(c);
        }

        return singleton;
    }

    /**
     * 初始化
     * @param c
     */
    private LoginManager(Context c) {
        mContext = c.getApplicationContext();
    }

    /**
     * 取用户信息结果处理
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case EVENT_LOGIN_CALLBACK:{
                    HttpRespObject response = (HttpRespObject)msg.obj;
                    if(response.isSuccess){
                        //登录成功，更新当前登录状态
                        mLoginItem = (LoginItem)response.data;
                        doUpdateLoginStatus(LoginStatus.Logged);

                        //保存这次登录信息，用于下次启动自动登录使用
                        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
                        localPreferenceManager.saveLoginAccountInfoItem(mAccoutInfoBean);

                        //更新礼物配置信息
                        NormalGiftManager.getInstance().getAllGiftItems(null);

                        //测速
                        if(mConfigItem != null && mConfigItem.svrList != null && mConfigItem.svrList.length > 0){
                            SpeedTestManager.getInstance(mContext).doTest(mConfigItem.svrList);
                        }

                        //表情配置
                        ChatEmojiManager.getInstance().getEmojiList(null);

                        //回调停止监听者
                        doLoginResultCallBack(true , response.errCode , response.errMsg , mLoginItem);

                    }else{
                        //更新当前登录状态
                        doUpdateLoginStatus(LoginStatus.Logout);
                        //如果错误
                        doLoginResultCallBack(false , response.errCode , response.errMsg , null);
                    }
                }break;
                default:
                    break;
            }

        }
    };

    /**
     * 注册监听器
     * @param listener
     * @return
     */
    public boolean addListener(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListListener)
        {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<IAuthorizationListener> iter = mListListener.iterator(); iter.hasNext(); ) {
                    IAuthorizationListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mListListener.add(listener);
                }else {
                    com.qpidnetwork.anchor.utils.Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist",
                            "OnLoginManagerListener", "addListener",
                            listener.getClass().getSimpleName()));
                }
            }
            else {
                com.qpidnetwork.anchor.utils.Log.e(TAG, String.format("%s::%s() fail, listener is null",
                        "OnLoginManagerListener", "addListener"));
            }
        }
        return result;
    }

    /**
     * 注销监听器
     * @param listener
     * @return
     */
    public boolean removeListener(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListListener) {
            result = mListListener.remove(listener);
        }

        if (!result) {
            com.qpidnetwork.anchor.utils.Log.e(TAG, String.format("%s::%s() fail, listener:%s",
                    "OnLoginManagerListener", "removeListener",
                    listener.getClass().getSimpleName()));
        }
        return result;
    }

    /**
     * 获取登录状态（是否登录了）
     * @return
     */
    public boolean isLogined(){
        return mLoginStatus == LoginStatus.Logged;
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
        return SynConfigManager.getSynConfigItem();
    }

    /**
     * 获取本地缓存账户信息
     * @return
     */
    public AccountInfoBean getLocalAccountInfo(){
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        return localPreferenceManager.getLoginAccountInfoItem();
    }

    /**
     * 登录接口
     * @param broadcasterId
     * @param password
     * @param verficationCode
     */
    public void login(final String broadcasterId, final String password, final String verficationCode){
        if(mLoginStatus == LoginStatus.Logging || mLoginStatus == LoginStatus.Logged){
            if(mLoginStatus == LoginStatus.Logged){
                //回调登录成功
                doLoginResultCallBack(true , HTTP_LCC_ERR_SUCCESS.ordinal() , "", mLoginItem);
            }
            return;
        }
        //缓存当前登录账号信息
        mAccoutInfoBean = new AccountInfoBean(broadcasterId, password);
        //更新当前登录状态
        doUpdateLoginStatus(LoginStatus.Logging);

        //登录分两步进行，先获取同步配置
        final SynConfigManager synConfigManager = new SynConfigManager(mContext);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                if(configResult.isSuccess){
                    //取同步配置成功
                    mConfigItem = configResult.item;

                    //登录去
                    loginInternal(broadcasterId, password, verficationCode);
                }else {
                    //同步配置失败，打断登录回调登录失败
                    Message msg = Message.obtain();
                    msg.what = EVENT_LOGIN_CALLBACK;
                    msg.obj = new HttpRespObject(false, HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal(), mContext.getString(R.string.liveroom_transition_audience_invite_network_error) ,null);
                    mHandler.sendMessage(msg);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();
    }

    /**
     * 同步获取验证码（需要先获取同步配置才能有域名）
     */
    public void getVerificationCode(final OnRequestGetVerificationCodeCallback callback){
        if(mConfigItem != null){
            getVerificationCodeInternal(callback);
        }else{
            //先同步配置
            final SynConfigManager synConfigManager = new SynConfigManager(mContext);
            synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
                @Override
                public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                    if(configResult.isSuccess){
                        //取同步配置成功
                        mConfigItem = configResult.item;

                        //获取验证码
                        getVerificationCodeInternal(callback);
                    }else {
                        //同步配置失败，获取验证码失败
                        callback.onGetVerificationCode(false, HTTP_LCC_ERR_CONNECTFAIL.ordinal(), "", null);
                    }

                    //取消监听
                    synConfigManager.dispose();
                }
            }).doRequestSynConfig();
        }
    }

    /**
     * 获取同步配置后，更新验证码
     * @param callback
     */
    private void getVerificationCodeInternal(final OnRequestGetVerificationCodeCallback callback){
        RequestJniAuthorization.LSGetVerificationCode(new OnRequestGetVerificationCodeCallback() {
            @Override
            public void onGetVerificationCode(boolean isSuccess, int errCode, String errMsg, byte[] date) {
                callback.onGetVerificationCode(isSuccess, errCode, errMsg, date);
            }
        });
    }

    /**
     * 同步配置完成，内部登录
     * @param broadcasterId
     * @param password
     * @param verficationCode
     */
    private void loginInternal(String broadcasterId, String password, String verficationCode){
        String model = android.os.Build.MODEL;
        String deviceId = SystemUtils.getDeviceId(mContext);
        String manufacturer = android.os.Build.MANUFACTURER;
        RequestJniAuthorization.Login(broadcasterId, password, verficationCode, deviceId, model, manufacturer, new OnRequestLoginCallback() {
            @Override
            public void onRequestLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                Message msg = Message.obtain();
                msg.what = EVENT_LOGIN_CALLBACK;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 能否自动更新
     * @return
     */
    public boolean isCanAutoLogin(){
        //再使用最近登录成功过的方式
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        AccountInfoBean accountInfoBean = localPreferenceManager.getLoginAccountInfoItem();
        return false;
    }

    /**
     * 自动登录
     * @return 能否自动登录
     */
    public void autoLogin(){
        //再使用最近登录成功过的方式
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        AccountInfoBean accountInfoBean = localPreferenceManager.getLoginAccountInfoItem();

    }

    /**
     * 注销
     */
    public void logout(){
        mLoginItem = null;
        //清除账号信息
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        AccountInfoBean bean = localPreferenceManager.getLoginAccountInfoItem();
        bean.password = "";
        localPreferenceManager.saveLoginAccountInfoItem(bean);

        //更新当前登录状态
        doUpdateLoginStatus(LoginStatus.Logout);

        //清除本地缓存数据
        ScheduleInviteManager.getInstance().clearResetSelf();
        AnchorInfoManager.getInstance().clearLocalCache();
        ProgramUnreadManager.getInstance().clearLocalParams();

        //回调到监听器
        doLogOutResultCallBack();
    }

    /**
     * 被踢下线处理
     * @param kickOffMsg
     */
    public void onKickedOff(String kickOffMsg){
        if(isLogined()) {
            //注销
            logout();
            //打开登录界面
            LiveLoginActivity.show(mContext, LiveLoginActivity.OPEN_TYPE_KICK_OFF, kickOffMsg);
            //关掉其它界面
            mContext.sendBroadcast(new Intent(CommonConstant.ACTION_KICKED_OFF));
        }
    }

    /**
     * 回调登录结果到外面
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    private void doLoginResultCallBack(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogin(isSuccess , errCode , errMsg , item);
        }
    }

    /**
     * 回调注销结果到外面
     */
    private void doLogOutResultCallBack() {
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogout(true);
        }
    }

    /**
     * 更新登录状态
     * @param loginStatus
     */
    private void doUpdateLoginStatus(LoginStatus loginStatus){
        mLoginStatus = loginStatus;
    }

}
