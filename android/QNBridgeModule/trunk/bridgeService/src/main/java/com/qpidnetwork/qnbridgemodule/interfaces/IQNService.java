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
     * @param websiteId
     * @param configDomain      //用于同步配置的域名
     */
    void onMainServiceLogin(boolean isSucess, String userId, String token, String ga_uid, int websiteId ,String configDomain);

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
     * @return url是否被捕捉处理
     */
    boolean openUrl(Context context, String url);

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
     * 服务冲突统一提示
     * @return
     */
    String getServiceConflictTips();
	
	/**
     * 获取当前操作与本服务冲突时的错误提示
     * @return
     */
    String getServiceConflictTips(String url);

    /**
     * 切换服务等操作，终止某些功能
     * @return
     */
    boolean stopFunctions();

    /**
     * 同步系统通知设置
     */
    void synSystemNotificationSetting(MainModuleConfig config);

    /**
     * 启动界面广告
     * @param context
     * @param websiteLocalIDInQN  WebSiteManager中站点本地ID,可查看ParsingWebSiteLocalId()
     */
    void launchAdvertActivity(Context context , int websiteLocalIDInQN);

    /**
     * push点击时间GA统计接口
     * @param url
     */
    void onPushClickGAReport(String url);

    /**
     * 服務事件通知監聽器
     * @param onServiceStatusListener
     */
    void setOnServiceStatusChangeListener(OnServiceEventListener onServiceStatusListener);

    /**
     * 是否用作测试
     * @param isForTest
     */
    void setForTest(boolean isForTest);

    /**
     * 设置代理服务器
     * @param proxyUrl
     */
    void setProxy(String proxyUrl);

    /**
     * 服务被启动时触发的事件
     */
    void onServiceStart();

    /**
     * 服务被停止时触发的事件
     */
    void onServiceEnd();

}
