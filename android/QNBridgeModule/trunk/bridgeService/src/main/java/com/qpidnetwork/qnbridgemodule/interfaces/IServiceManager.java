package com.qpidnetwork.qnbridgemodule.interfaces;

/**
 * 模块管理接口类（用于协调多个模块间通信）
 * Created by Hunter Mun on 2017/8/10.
 */

public interface IServiceManager {
    /**
     * 子模块通知主模块登录状态异常
     * @param service
     */
    public void onSubServiceLoginStatusException(IQNService service);

    /**
     * 注册互斥服务
     * @param service
     */
    public boolean startService(IQNService service);

    /**
     * 注销互斥服务
     * @param service
     */
    public void stopService(IQNService service) ;
    /**
     * 注册添加模块
     * @param service
     */
    public void registerService(IQNService service);

    /**
     * 注销删除模块
     * @param service
     */
    public void unregisterService(IQNService service);

    /**
     * 打开指定的模块（添加服务判断及事件处理）
     * @return
     */
    public boolean openSpecifyService(String url);
}
