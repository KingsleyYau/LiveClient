package com.qpidnetwork.qnbridgemodule.websitemanager;


import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.qnbridgemodule.interfaces.IModule;
import com.qpidnetwork.qnbridgemodule.interfaces.OnGetTokenCallback;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager.WebSiteType;

/**
 * 站点切换任务
 */
public class WebsiteChangeTask {

    private static final int GET_TOKEN_CALLBACK = 0;

    private WebSiteType mSourceSite;
    private WebSiteType mTargetSite;
    private OnWebsiteChangeTaskCallback mOnChangeWebsiteCallback;
    private Handler mHanler;


    public WebsiteChangeTask(WebSiteType sourceSite, WebSiteType targetSite){
        this.mSourceSite = sourceSite;
        this.mTargetSite = targetSite;
        mHanler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what){
                    case GET_TOKEN_CALLBACK:{
                        TokenBean tokenBean = (TokenBean)msg.obj;
                        onGetToken(tokenBean.token, tokenBean.userId);
                    }break;
                }
            }
        };
    }

    public void setOnChangeWebsiteCallback(OnWebsiteChangeTaskCallback callback){
        this.mOnChangeWebsiteCallback = callback;
    }

    /**
     * 启动换站
     */
    public void startTask(){
        final IModule module = WebSiteConfigManager.getInstance().getWebSiteModuleByType(mSourceSite);
        if(module != null && module.isModuleLogined()){
            module.getWebSiteToken(mTargetSite, new OnGetTokenCallback() {
                @Override
                public void onGetToken(String token, String userId) {
                    Message msg = Message.obtain();
                    msg.what = GET_TOKEN_CALLBACK;
                    msg.obj = new TokenBean(token, userId);
                    mHanler.sendMessage(msg);
                }
            });
        }else{
            //无需获取token
            onGetToken("", "");
        }
    }

    /**
     * 获取token返回处理
     * @param token
     */
    private void onGetToken(String token, String userId){
        IModule sourceModule = WebSiteConfigManager.getInstance().getWebSiteModuleByType(mSourceSite);
        sourceModule.logout();
        if(mOnChangeWebsiteCallback != null){
            mOnChangeWebsiteCallback.OnWebsiteChange(mTargetSite, token, userId);
        }
    }


    public interface OnWebsiteChangeTaskCallback{
        public void OnWebsiteChange(WebSiteType webSiteType, String token, String userId);
    }

    private class TokenBean{
        public String token = "";
        public String userId = "";

        public TokenBean(String token, String userId){
            this.token = token;
            this.userId = userId;
        }
    }

}
