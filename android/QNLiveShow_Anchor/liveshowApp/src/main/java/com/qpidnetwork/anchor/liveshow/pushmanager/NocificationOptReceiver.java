package com.qpidnetwork.anchor.liveshow.pushmanager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

/**
 * 处理通知栏事件的静态广播
 *
 * 需要在Manifest.xml中注册，
 * 并且添加Action
 *
 * @author Jagger 2017-9-11
 */
public class NocificationOptReceiver extends BroadcastReceiver {
    private static final String TAG = "NocificationOptReceiver";

    //*************************************
    //*****在Manifest.xml中注册这些Action****
    //*************************************

    @Override
    public void onReceive(Context context, Intent intent) {
        if(CommonConstant.ACTION_ANCHOR_PUSH_NOTIFICATION.equals(intent.getAction())) {
            //push url实现跳转
            Bundle bundle = intent.getExtras();
            if(bundle.containsKey(CommonConstant.KEY_PUSH_NOTIFICATION_URL)){
                String url = bundle.getString(CommonConstant.KEY_PUSH_NOTIFICATION_URL);
                LiveService liveService = LiveService.getInstance();
                if(liveService != null){
                    //服务已启动
                    if(liveService.checkServiceConflict(url)){
                        //与当前正在使用中的服务冲突
                        String confictTips = liveService.getServiceConflictTips(url);
                        ServiceConflictDialogActivity.launchServiceConflictDialog(context, confictTips, url);
                    }else{
                        //服务不冲突
                        if(LoginManager.getInstance().isLogined()){
                            //已经登录，直接跳到列表主页
                            liveService.openUrl(context, url);
                        }else{
                            liveService.openAppWithUrl(context, url);
                        }
                    }
                    //serviceManager分发push点击通知
                    LiveService.getInstance().onPushClickGAReport(url);
                }else{
                    //应用未启动直接打开应用
                    Intent jumpIntent = new Intent(context, LiveLoginActivity.class);
                    jumpIntent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, url);
                    jumpIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(jumpIntent);
                }
            }
        }
    }
}
