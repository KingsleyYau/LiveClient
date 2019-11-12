package com.qpidnetwork.livemodule.liveshow.urlhandle;

import android.content.Context;

import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;

/**
 * 公共处理（url打开指定模块时换站及登录处理）
 * Created by Hunter on 17/10/20.
 */

public class AppUrlHandler {

    private Context mContext;

    public AppUrlHandler(Context context){
        this.mContext = context;
    }

    /**
     * url handler入口
     * @param url
     * @return 是否被处理了
     */
    public boolean urlHandle(String url){
        //处理解决qn旧url不包含service字段

        boolean isHanldle = false;
        if(!LiveModule.getInstance().urlCoreInterrupt(url)){
            //无需换站和服务冲突处理
            isHanldle = urlHandleLoginCheck(url);
        }else{
            isHanldle = true;
        }
        return isHanldle;
    }

    /**
     * url 是否需要登录检测
     * @param url
     * @return url是否被拦截处理
     */
    private boolean urlHandleLoginCheck(String url){
        boolean isCatch = false;
        if(URL2ActivityManager.doCheckNeedLogin(url)){
            // 需要登录
            if (CheckLogin(mContext, true, url)) {
                // 已经登录，直接进入界面
                isCatch = urlOpenActivity(url);
            } else {
                // 未登录，已经弹出登录界面，等待登录回调跳转即可
                isCatch = true;
            }
        }else{
            //不需要登录，直接打开
            isCatch = urlOpenActivity(url);
        }
        return isCatch;
    }

    /**
     * 检测完成，调用服务打开模块
     * @param url
     * @return url是否被拦截处理了
     */
    private boolean urlOpenActivity(String url){
        boolean isCatch = URL2ActivityManager.getInstance().URL2Activity(mContext, url);
        return isCatch;
    }

    private boolean CheckLogin(Context context, boolean bShowLoginActivity, String param) {
        boolean bFlag = false;
        // 判断是否登录
        switch (LoginManager.getInstance().getLoginStatus()) {
            case Default: {
                // 处于未登录状态
            }
            case Logining:{
                // 处于未登录状态, 点击弹出登录界面
                if( bShowLoginActivity ) {
                    LoginNewActivity.launchRegisterActivity(context, param);
                }
            }break;
            case Logined: {
                // 处于登录状态
                bFlag = true;
            }break;
            default:
                break;
        }
        return bFlag;
    }

}
