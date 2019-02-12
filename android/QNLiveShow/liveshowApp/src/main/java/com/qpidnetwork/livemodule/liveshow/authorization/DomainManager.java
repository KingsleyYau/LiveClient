package com.qpidnetwork.livemodule.liveshow.authorization;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestSidCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 登录管理类
 * Created by Hunter Mun on 2017/5/26.
 */

public class DomainManager {

    private static final String TAG = DomainManager.class.getName();
    private static final int GETAUTHTOKEN_CALLBACK = 1;
    private static final int AUTHDOMAINTOKEN_CALLBACK = 2;

    public enum DomainRequestStatus{
        Default,
        Requesting,
        Requested
    }

    private Context mContext;
    private static DomainManager mLoginManager;
    //edit by Jagger 2018-3-7,由List改为CopyOnWriteArrayList,因为有时候会报java.util.ConcurrentModificationException
    private List<IDomainListener> mListenerList;
    private DomainRequestStatus mRequestStatus;

    //同步配置信息
//    private ConfigItem mConfigItem;     //同步配置返回信息
    private boolean isAdvertShow = false;       //QN展示广告一次启动仅显示一次

    //存储当前用户UserId
    private String mMemberId;
    //存储当前域名Token
    private String mDomainToken;
    private Handler mHandler;

    /**
     * 登录QN返回的数据
     */
    class QNLoginData{
        public String memberId;
        public String sid;
    }

    public static DomainManager getInstance(){
        return mLoginManager;
    }

    /**
     * 构建单例
     * @param context
     * @return
     */
    public static DomainManager newInstance(Context context){
        if(mLoginManager == null){
            mLoginManager = new DomainManager(context);
        }
        return mLoginManager;
    }

    @SuppressLint("HandlerLeak")
    private DomainManager(Context context){
        mContext = context;
        mListenerList = new CopyOnWriteArrayList<>();
        mRequestStatus = mRequestStatus.Default;

        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.what){
                    case GETAUTHTOKEN_CALLBACK:{
                        if(response.isSuccess && response.data != null){
//                            //QN登录成功了
//                            QNLoginData qnLoginData = (QNLoginData)response.data;
//                            //登录直播
//                            loginToLive(qnLoginData.memberId, qnLoginData.sid);
                            // 获取认证token成功后，再调用2.18.mobile域名token登录认证
                            authDomainToken();
                        }else{
                            //mRequestStatus = mRequestStatus.Default;
                            notifyAllListener(response.isSuccess, response.errCode, response.errMsg);
                        }
                    }break;

                    case AUTHDOMAINTOKEN_CALLBACK:{
                        if(response.isSuccess && response.data != null){
                            // 域名Token认证成功后，在重新调用域名接口
                        }else{
                            // 回调上一层
                        }

                        //通知登录返回结果
                        //notifyAllListenerLgoined(response.isSuccess, response.errCode, response.errMsg, item);
                        notifyAllListener(response.isSuccess, response.errCode, response.errMsg);
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
    public boolean register(IDomainListener listener){
        boolean result = false;
        synchronized(mListenerList)
        {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<IDomainListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                    IDomainListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mListenerList.add(listener);
                }else {

                }
            }
            else {

            }
        }
        return result;
    }

    /**
     * 注销监听器
     * @param listener
     * @return
     */
    public boolean unRegister(IDomainListener listener){
        boolean result = false;
        synchronized(mListenerList) {
            result = mListenerList.remove(listener);
        }

        if (!result) {

        }
        return result;
    }

    public void setmRequestStatus(DomainRequestStatus mRequestStatus) {
        this.mRequestStatus = mRequestStatus;
    }

    /**
     * 获取认证token（当域名接口身份失效（MBCE0003））
     */
    public void getAuthToken() {
        if (mRequestStatus != DomainRequestStatus.Requesting) {

            WebSiteBean webSiteBean = WebSiteConfigManager.getInstance().getCurrentWebSite();
            if(webSiteBean != null){
                LiveRequestOperator.getInstance().GetAuthToken(webSiteBean.getSiteId(), new OnRequestSidCallback() {
                    @Override
                    public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid) {
                        //切换线程处理拦截任务
                        if (isSuccess) {
                            mMemberId = memberId;
                            mDomainToken = sid;
                        }
                        Message msg = Message.obtain();
                        msg.what = GETAUTHTOKEN_CALLBACK;
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, sid);
                        msg.obj = response;
                        mHandler.sendMessage(msg);
                    }
                });
            }else{
                //切换线程处理拦截任务
                Message msg = Message.obtain();
                msg.what = GETAUTHTOKEN_CALLBACK;
                HttpRespObject response = new HttpRespObject(false, 0, "", "");
                msg.obj = response;
                mHandler.sendMessage(msg);
            }

        }
    }

    public void authDomainToken()  {
        String deviceId = SystemUtils.getDeviceId(mContext);
        String versionCode = "-1";

        try {
            PackageManager pm = mContext.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(mContext.getPackageName(), PackageManager.GET_ACTIVITIES);
            versionCode = String.valueOf(pi.versionCode);
        } catch (PackageManager.NameNotFoundException e) {
            // Swallow
        }

        RequestJniAuthorization.DoLogin(mDomainToken, mMemberId, deviceId, versionCode, android.os.Build.MODEL, android.os.Build.MANUFACTURER, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                //切换线程处理拦截任务
                Message msg = Message.obtain();
                msg.what = AUTHDOMAINTOKEN_CALLBACK;
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, "");
                msg.obj = response;
                mHandler.sendMessage(msg);
            }
        });
    }


    /**
     * 域名处理完成通知其他模块
     * @param isSuccess
     * @param errCode
     * @param errMsg
     */
    private void notifyAllListener(boolean isSuccess, int errCode, String errMsg){
        //通知登录返回结果
        synchronized (mListenerList) {
            for (Iterator<IDomainListener> iter = mListenerList.iterator(); iter.hasNext(); ) {
                IDomainListener listener = iter.next();
                listener.onDomainHandle(isSuccess, errCode, errMsg);
            }
        }
    }

//    /**
//     * 域名接口身份失效（MBCE0003）
//     */
//    public void onModuleSessionOverTime(){
//        //if(mRequestStatus == DomainRequestStatus.Logined) {
//            //直播未登录不处理token过期逻辑（和Samson确认过）
//            if (mRequestStatus == DomainRequestStatus.Requesting) {
//                //登录中，拦截session timeout事件
//                return;
//            }
//            if (mRequestStatus == DomainRequestStatus.Requested) {
//                //logout(false);
//            }
//
//            //发送广播通知界面
//            Intent intent = new Intent(CommonConstant.ACTION_SESSION_TIMEOUT);
////            mContext.sendBroadcast(intent);
//            BroadcastManager.sendBroadcast(mContext,intent);
//        //}
//    }

}
