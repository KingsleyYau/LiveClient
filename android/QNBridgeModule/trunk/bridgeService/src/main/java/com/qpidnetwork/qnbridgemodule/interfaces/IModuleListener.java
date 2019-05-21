package com.qpidnetwork.qnbridgemodule.interfaces;

import android.app.Activity;

import com.qpidnetwork.qnbridgemodule.bean.AccountInfoBean;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

/**
 * 模块监听公共接口类
 */
public interface IModuleListener {
    /**
     * 通知消息中心发送push
     * @param type
     * @param title
     * @param tickerText
     * @param pushActionUrl
     * @param isAutoCancel
     */
    public void onPushNotification(NotificationTypeEnum type, String title, String tickerText, String pushActionUrl, boolean isAutoCancel);

    /**
     * 清除指定类型push
     * @param type
     */
    public void cancelNotification(NotificationTypeEnum type);

    /**
     * 清除通知中心所有消息
     */
    public void cancelAllNotification();

    /**
     * 模块urld事件处理
     * @param url
     * @return  主模块是否处理
     */
    public boolean onMoudleUrlHandle(String url);

    /**
     * 通知执行换站逻辑
     * @param webSiteType
     */
    public void doChangeWebSite(WebSiteConfigManager.WebSiteType webSiteType);


    /**
     * 在直播端 显示换站对话框
     */
    public void onChangeWebsiteDialogShow(Activity activityTarget, boolean isLive);

    /**
     * AppsFlyer统计通知
     * @param params
     */
    public void onAppsFlyerEventNotify(String params);

    /**
     * 登陆回调
     * @param isSuccess
     * @param errno
     * @param errmsg
     * @param userId
     */
    public void onLogin(boolean isSuccess, String errno, String errmsg, String userId);

}
