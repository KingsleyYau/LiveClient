package com.qpidnetwork.qnbridgemodule.interfaces;

/**
 * 模块接口类
 * Created by Hunter Mun on 2017/8/10.
 */

public interface IQNService {
    /**
     * 主模块登录成功通知
     */
    public void onMainServiceLogin();

	enum LogoutType {
		
	}
    /**
     * 主模块注销通知
     */
    public void onMainServiceLogout(LogoutType type, String tips);

    /**
     * App 被踢出通知模块
     */
    public void onAppKickoff(String tips);

	
	
    /**
     * 获取模块名称
     */
    public String getServiceName();
	
    /**
     * 打开url
     */
    public void openUrl(String url);
	
	/**
     * 是否需要停服务(调用openSpecifyService的url与当前模块相同时调用，是则弹出提示界面)
     * @return
     */
    public String isStopService(String url);
	
	/**
     * 获取当前操作与本服务冲突时的错误提示
     * @return
     */
    public String getServiceConflict();

    /**
     * 终止当前服务，同步操作
     * @return
     */
    public boolean stopService();
}
