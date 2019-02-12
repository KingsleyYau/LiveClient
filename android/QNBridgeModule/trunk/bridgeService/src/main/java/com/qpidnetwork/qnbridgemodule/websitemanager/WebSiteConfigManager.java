package com.qpidnetwork.qnbridgemodule.websitemanager;

import android.content.Context;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.interfaces.IModule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WebSiteConfigManager {

    /**
     * 站点类型
     */
    public enum WebSiteType {
        CharmDate,
        LatamDate,
        AsiaMe,
        CharmLive	//假的,只用作直播入口,跟其它站点不一样
    }

    /**
     * 当前站点信息
     */
    private WebSiteType mCurrentWebSiteType;

    private Context mContext = null;
    private static WebSiteConfigManager gWebSiteConfigManager;
    public Map<String, WebSiteBean> mWebSiteMap = new HashMap<String, WebSiteBean>();
    public Map<WebSiteType, IModule> mWebSiteModuleMap = new HashMap<WebSiteType, IModule>();


    /************************************ 单例创建 ********************************************/
    /**
     * 创建站点管理类实例
     *
     * @param context
     * @return 站点管理类实例
     */
    public static WebSiteConfigManager newInstance(Context context) {
        if (gWebSiteConfigManager == null) {
            gWebSiteConfigManager = new WebSiteConfigManager(context);
        }
        return gWebSiteConfigManager;
    }

    /**
     * 获取单例
     * @return
     */
    public static WebSiteConfigManager getInstance(){
        return gWebSiteConfigManager;
    }

    private WebSiteConfigManager(Context context) {
        mContext = context;
    }

    /**
     * 更新站点模块相关配置
     * @param webSiteType
     * @param module
     */
    public void configWebsiteModule(WebSiteType webSiteType, IModule module){
        mWebSiteModuleMap.put(webSiteType, module);
    }

    /**
     * 更新站点配置到公共内存
     * @param siteKey       //与对应枚举name一致
     * @param webSiteBean
     */
    public void configWebsiteInfo(String siteKey, WebSiteBean webSiteBean){
        mWebSiteMap.put(siteKey, webSiteBean);
    }

    /**
     * 根据websiteType获取所属模块信息
     * @param webSiteType
     * @return
     */
    public IModule getWebSiteModuleByType(WebSiteType webSiteType){
        IModule module = null;
        if(mWebSiteModuleMap.containsKey(webSiteType)){
            module = mWebSiteModuleMap.get(webSiteType);
        }
        return module;
    }

    /**
     * 获取指定类型分站对象
     * @param type
     * @return
     */
    public WebSiteBean getWebsiteByWebType(WebSiteType type) {
        return mWebSiteMap.get(type.name());
    }

    /**
     * 取当前WebSite
     * @return
     */
    public WebSiteBean getCurrentWebSite() {
        return getWebsiteByWebType(mCurrentWebSiteType);
    }

    /**
     * 获取当前站点类型
     * @return
     */
    public WebSiteType getCurrentWebSiteType() {
        return mCurrentWebSiteType;
    }

    /**
     * 更新当前选中站点
     * @param webSiteType
     */
    public void setCurrentWebSite(WebSiteType webSiteType){
        this.mCurrentWebSiteType = webSiteType;
    }

    /**
     * 获取当前站点所属模块信息
     * @return
     */
    public IModule getCurrentWebsiteModule(){
        IModule module = null;
        if(mCurrentWebSiteType != null){
            module = getWebSiteModuleByType(mCurrentWebSiteType);
        }
        return module;
    }

    /**
     * 是否当前站点
     * @param siteType
     * @return
     */
    public boolean isCurrentSite(WebSiteType siteType){
        return siteType == mCurrentWebSiteType;
    }

    /**
     * 获取当前站点siteId，用于换站等url拼接
     * @return
     */
    public String getCurrentSiteId(){
        return getWebSiteID(mCurrentWebSiteType);
    }

    public void changeWebsite(WebSiteType webSiteType, WebsiteChangeTask.OnWebsiteChangeTaskCallback callback){
        WebsiteChangeTask task = new WebsiteChangeTask(mCurrentWebSiteType, webSiteType);
        task.setOnChangeWebsiteCallback(callback);
        task.startTask();
    }


    /**
     * 本地ID转为类型
     * @param webSiteLocalId
     * @return
     */
    public static WebSiteType ParsingWebSiteLocalId(String webSiteLocalId){
        WebSiteType webType = null;
        if(!TextUtils.isEmpty(webSiteLocalId)) {
            switch (Integer.valueOf(webSiteLocalId)) {
                case 4: {
                    webType = WebSiteType.CharmDate;
                }
                break;
                case 8: {
                    webType = WebSiteType.LatamDate;
                }
                break;
                case 16: {
                    webType = WebSiteType.AsiaMe;
                }
                break;
                case 32: {
                    webType = WebSiteType.CharmLive;
                }
                break;
                default:
                    webType = WebSiteType.CharmDate;
                    break;
            }
        }
        return webType;
    }

    /**
     * 根据站点类型，获取站点id
     * @param type
     * @return
     */
    public static String getWebSiteID(WebSiteType type){
        int siteId = 4;
        if(type != null) {
            switch (type) {
                case CharmDate: {
                    siteId = 4;
                }
                break;
                case LatamDate: {
                    siteId = 5;
                }
                break;
                case AsiaMe: {
                    siteId = 6;
                }
                break;
                case CharmLive: {
                    //41代表直播站点
                    siteId = 41;
                }
                break;
                default:
                    break;
            }
        }
        return String.valueOf(siteId);
    }

    /**
     * 服务器数据本地同步
     * (服务器ID转为类型)
     * @param webSiteServiceID
     * @return
     */
    public static WebSiteType ParsingWebSite(String webSiteServiceID){
        WebSiteType webType = null;
        if(!TextUtils.isEmpty(webSiteServiceID)) {
            switch (Integer.valueOf(webSiteServiceID)) {
                case 4: {
                    webType = WebSiteType.CharmDate;
                }
                break;
                case 5: {
                    webType = WebSiteType.LatamDate;
                }
                break;
                case 6: {
                    webType = WebSiteType.AsiaMe;
                }
                break;
                case 41: {
                    //41代表直播站点
                    webType = WebSiteType.CharmLive;
                }
                break;
                default:
                    break;
            }
        }
        return webType;
    }

    /**
     * 直播模块使用，读取所有可用非直播模块站点
     * @return
     */
    public List<WebSiteBean> getDefaultAvailableWebSettings(){
        List<WebSiteBean> webList = new ArrayList<WebSiteBean>();
        webList.add(mWebSiteMap.get(WebSiteType.AsiaMe.name()));
        webList.add(mWebSiteMap.get(WebSiteType.CharmDate.name()));
        webList.add(mWebSiteMap.get(WebSiteType.LatamDate.name()));
        return webList;
    }
}
