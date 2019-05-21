package com.qpidnetwork.qnbridgemodule.interfaces;

import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

/**
 * 模块实现公共接口类
 */
public interface IModule {

    /**
     * 初始化模块，指定站点
     * @param website 指定当前站点信息，用于更改域名等模块初始化处理
     */
    public void initOrResetModule(WebSiteBean website);

    /**
     * 模块是否登录状态
     * @return
     */
    public boolean isModuleLogined();

    /**
     * 获取当前站点token，用于换站统一处理
     * @param targetWebsiteType 目标站点
     * @param callback
     */
    public void getWebSiteToken(WebSiteConfigManager.WebSiteType targetWebsiteType, OnGetTokenCallback callback);

    /**
     * 登陆接口
     * @param email
     * @param password
     * @param checkcode
     */
    public void login(String email, String password, String checkcode);

    /**
     * Token登录
     * @param token
     */
    public void loginByToken(String token, String memberId);

    /**
     * 获取验证码
     * @param callback
     */
    public void getVerifyCode(OnGetVerifyCodeCallback callback);

    /**
     * 换站统一处理，注销逻辑
     */
    public void logout();

    /**
     * 启动模块逻辑
     * @param token 换站token
     * @param url 可用于传递参数及模块打开
     * @param isNeedBackHome 是否需要跳转界面回根目录
     */
    public void launchModuleWithUrl(String token, String url, boolean isNeedBackHome);

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
    String getServiceConflictTips(String url);

    /**
     * 获取Module ServiceName
     * @return
     */
    String getModuleServiceName();

    /**
     * 切换服务等操作，终止某些功能
     * @return
     */
    boolean stopFunctions();

    /**
     * 子module通知中心处理事务
     * @param moduleListener
     */
    void setOnMoudleListener(IModuleListener moduleListener);

    /**
     * 是否用作测试(用于外部链接打开直播模块调试使用)
     * @param isForTest
     */
    void setForTest(boolean isForTest);

    /**
     * 设置代理服务器(用于底层http接口处理https代理抓包)
     * @param proxyUrl
     */
    void setProxy(String proxyUrl);

    /**
     * push点击时间GA统计接口(分模块统计)
     * @param url
     */
    void onPushClickGAReport(String url);

    /**
     * GA事件
     * @param category
     * @param action
     * @param label
     */
    void onModuleGAEvent(String category, String action, String label);
}
