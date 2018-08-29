package com.qpidnetwork.qnbridgemodule.interfaces;

import android.app.Activity;

import com.qpidnetwork.qnbridgemodule.bean.AdWebObj;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;

/**
 * 服務事件监听器
 * Created by Jagger on 2017/10/17.
 */

public interface OnServiceEventListener {

    /**
     * 服务模块开始事件
     * @param service
     */
    public void onServiceStart(IQNService service);

    /**
     * 服务模块开始事件
     * @param service
     */
    public void onServiceEnd(IQNService service);

    /**
     * 服务模块session过期，需主模块启动重新自动登录
     * @param service
     */
    public void onTokenExpired(IQNService service);

    /**
     * 被踢通知
     * @param service
     */
    public void onKickOffNotify(IQNService service);

    /**
     * 子模块通知主模块买点逻辑
     * @param service
     * @param order_type
     * @param clickFrom
     * @param number
     */
    public void onAddCreditClick(IQNService service, int order_type, String clickFrom, String number);

    /**
     * 通知主模块是否显示广告
     * @param service
     * @param isShow
     */
    public void onAdvertShowNotify(IQNService service, boolean isShow);

    /**
     * 子模块需要menu未读展示通知
     * @param service
     * @param isShow
     */
    public void onModudleUnreadFlagsNotify(IQNService service, boolean isShow);

    /**
     * 子模块需要弹出换站对话框
     * @param service
     * @param isInLive
     */
    public void onChangeWebsiteDialogShowNotify(IQNService service, Activity targetActivity,  boolean isInLive);

    /**
     * 通知主模块是否显示URL浮层广告
     * @param service
     * @param isShow
     * @param adWeb
     */
    public void onURLAdvertShowNotify(IQNService service, boolean isShow , AdWebObj adWeb);

    /**
     * 子模块需要弹出个人资料界面
     * @param service
     */
    public void onShowMyProfileNotify(IQNService service, Activity targetActivity);

    /**
     * 换站通知
     * @param webSiteBean
     */
    public void doChangeWebSite(WebSiteBean webSiteBean);

    /**
     * 子模块登录事件
     * @param service
     * @param isSucess
     */
    public void onModuleLogin(IQNService service, boolean isSucess);
}
