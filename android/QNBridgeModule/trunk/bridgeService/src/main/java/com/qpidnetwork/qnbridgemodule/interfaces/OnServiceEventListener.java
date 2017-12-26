package com.qpidnetwork.qnbridgemodule.interfaces;

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
     * 点击买点按钮
     */
    public void onAddCreditClick(IQNService service);

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
}
