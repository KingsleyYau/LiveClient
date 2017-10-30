package com.qpidnetwork.qnbridgemodule.interfaces;

import android.content.Context;

import com.qpidnetwork.qnbridgemodule.bean.MainModuleConfig;

/**
 * 模块接口类
 * Created by Hunter Mun on 2017/8/10.
 */

public interface IQNService {

    /**
     * 主模块登录通知子模块
     * @param isSucess
     * @param userId
     * @param token
     * @param ga_uid
     */
    void onMainServiceLogin(boolean isSucess, String userId, String token, String ga_uid);

	enum LogoutType {
        AutoLogout,         //session过期等导致后台注销自动登录
        ManualLogout       //手动注销
	}
    /**
     * 主模块注销通知
     */
    void onMainServiceLogout(LogoutType type, String tips);

    /**
     * App 被踢出通知模块
     */
    void onAppKickoff(String tips);
	
    /**
     * 获取模块名称
     */
    String getServiceName();

    /**
     * 对外开放模块入口url，外部可通过url打开模块
     * @return
     */
    String getServiceEnterUrl();

    /**
     * 处理完冲突／换站／登录后，调用打开模块页面跳转
     * @param context
     * @param url
     */
    void openUrl(Context context, String url);

    /**
     * 检查url是否需要登录后才可以操作
     * @param url
     * @return
     */
    boolean checkNeedLogin(String url);

    /**
     * 检测url是否与当前模块冲突
     * @param url
     * @return
     */
    boolean checkServiceConflict(String url);
	
	/**
     * 获取当前操作与本服务冲突时的错误提示
     * @return
     */
    String getServiceConflictTips();

    /**
     * 切换服务等操作，终止服务
     * @return
     */
    boolean stopService();

    /**
     * 同步系统通知设置
     */
    void synSystemNotificationSetting(MainModuleConfig config);

    /**
     * 启动界面广告
     * @param context
     */
    void launchAdvertActivity(Context context);

    /**
     * 服務事件通知監聽器
     * @param onServiceStatusListener
     */
    void setOnServiceStatusChangeListener(OnServiceEventListener onServiceStatusListener);

}
