package com.qpidnetwork.livemodule.liveshow.sayhi;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSayHiResourceConfigCallback;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResourceConfigItem;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;

import java.util.ArrayList;
import java.util.List;

/**
 * SayHi本地配置管理类
 */
public class SayHiConfigManager {

    //本地缓存callback
    private List<OnGetSayHiResourceConfigCallback> mCallbackList;
    //本地缓存SayHi配置
    private SayHiResourceConfigItem mSayHiConfig;
    //是否需要刷新，一次登陆仅成功刷新一次即可
    private boolean mIsNeedRefresh = true;

    /**
     * 单例实现
     */
    private static class SayHiConfigManagerrHolder {

        private static final SayHiConfigManager INSTANCE = new SayHiConfigManager();

    }

    private SayHiConfigManager (){
        mCallbackList = new ArrayList<OnGetSayHiResourceConfigCallback>();
    }

    public static final SayHiConfigManager getInstance() {

        return SayHiConfigManagerrHolder.INSTANCE;

    }

    /**
     * 同步SayHi配置
     * @param callback
     * @return
     */
    public boolean GetSayHiResourceConfig(OnGetSayHiResourceConfigCallback callback){
        boolean result = false;
        if(!mIsNeedRefresh && mSayHiConfig != null){
            result = true;
            if(callback != null) {
                callback.onGetSayHiResourceConfig(true, 0, "", mSayHiConfig);
            }
        }else{
            result = GetSayHiResourceConfigInternal(callback);
        }
        return result;
    }

    /**
     * 发起同步配置请求
     * @param callback
     * @return
     */
    private boolean GetSayHiResourceConfigInternal(OnGetSayHiResourceConfigCallback callback){
        boolean result = false;

        if(isSynSayHiConfig()){
            result = true;
        }else{
            Long requestId = LiveRequestOperator.getInstance().GetSayHiResourceConfig( new OnGetSayHiResourceConfigCallback() {
                        @Override
                        public void onGetSayHiResourceConfig(boolean isSuccess, int errCode, String errMsg, SayHiResourceConfigItem configItem){
                            // TODO Auto-generated method stub
                            notifyAllPrivatePhotoCallbcak(isSuccess, errCode, errMsg, configItem);
                        }
                    });
            result = (requestId != LCRequestJni.InvalidRequestId);
        }

        if(result){
            //请求成功，添加callback
            if(callback != null){
                addToRequestingMap(callback);
            }
        }

        return result;
    }

    /**
     * 是否正在同步获取SayHi配置
     * @return
     */
    private boolean isSynSayHiConfig(){
        boolean isRequest = false;
        synchronized (mCallbackList){
            if(mCallbackList.size() > 0){
                isRequest = true;
            }
        }
        return isRequest;
    }

    /**
     * 加入带处理队列
     * @param callback
     */
    private void addToRequestingMap(OnGetSayHiResourceConfigCallback callback){
        synchronized (mCallbackList){
            mCallbackList.add(callback);
        }
    }

    /**
     * 通知所有监听者
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param configItem
     */
    private void notifyAllPrivatePhotoCallbcak(boolean isSuccess, int errCode, String errMsg, SayHiResourceConfigItem configItem){
        //本地缓存SayHi配置
        if(isSuccess && configItem != null){
            mIsNeedRefresh = false;
            mSayHiConfig = configItem;
        }
        synchronized (mCallbackList){
            for(OnGetSayHiResourceConfigCallback callback : mCallbackList){
                if(callback != null) {
                    callback.onGetSayHiResourceConfig(isSuccess, errCode, errMsg, configItem);
                }
            }
            mCallbackList.clear();
        }
    }

    /**
     * 注销时需要重置标志位，SayHi配置为每次登陆有效
     */
    public void resetSayHiConfig(){
        mIsNeedRefresh = true;
        synchronized (mCallbackList){
            mCallbackList.clear();
        }
    }

}
