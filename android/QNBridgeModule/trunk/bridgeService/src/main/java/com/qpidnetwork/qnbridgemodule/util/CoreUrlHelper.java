package com.qpidnetwork.qnbridgemodule.util;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.interfaces.IModule;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager.WebSiteType;

import java.util.HashMap;

public class CoreUrlHelper {

    public static final String KEY_URL_SCHEME = "qpidnetwork";
    public static final String KEY_URL_SCHEME_LIVE = "qpidnetwork-live";       //提供另外一套url外部链接跳转，功能上与KEY_URL_SCHEME一致，目前仅用于检测app是否包含直播模块
    public static final String KEY_URL_AUTHORITY = "app";
    public static final String KEY_URL_PATH = "/open";
    public static final String KEY_URL_MODULE = "module";
    public static final String KEY_URL_SOURCE = "source";
    public static final String KEY_URL_SITEID = "site";
    public static final String KEY_URL_SERVICE = "service";
    public static final String KEY_URL_SERVICE_NAME_LIVE = "live";
    public static final String KEY_URL_SERVICE_NAME_QN = "qn";

    //公共字段
    public static final String KEY_URL_PARAM_KEY_TEST = "test";
    public static final String KEY_URL_PARAM_KEY_HTTPPROXY = "httpproxy";

    //url 添加公共params
    public static final String KEY_URL_PARAM_KEY_DEVICE = "device";
    public static final String KEY_URL_PARAM_KEY_APPVER = "appver";
    public static final String KEY_URL_PARAM_KEY_APPID = "appid";
    public static final String KEY_URL_PARAM_DEVICE_VALUE = "30";

    /**
     * 读取roomId
     * @param url
     * @return
     */
    public static WebSiteType getTargetWebType(String url){
        WebSiteType webSiteType = null;
        if(!TextUtils.isEmpty(url)){
            try {
                Uri uri = Uri.parse(url);
                String tempSiteId = uri.getQueryParameter(KEY_URL_SITEID);
                String seviceName = uri.getQueryParameter(KEY_URL_SERVICE);
                if(!TextUtils.isEmpty(seviceName)
                        && seviceName.equals(KEY_URL_SERVICE_NAME_LIVE)){
                    webSiteType = WebSiteType.CharmLive;
                }else {
                    if (!TextUtils.isEmpty(tempSiteId)) {
                        webSiteType = WebSiteConfigManager.getInstance().ParsingWebSite(tempSiteId);
                    }
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        return webSiteType;
    }

    /**
     * 生成GCM push notification url
     * @param url
     * @param siteId
     * @return
     */
    public static String CreateGCMPushNotificationUrl(String url, String siteId){
        String pushUrl = "";
        pushUrl += url;
        if(!TextUtils.isEmpty(siteId)){
            pushUrl += "&" + KEY_URL_SITEID + "=" + siteId;
        }
        return pushUrl;
    }

    /**
     * 解析url获取站点信息
     * @param url
     * @return
     */
    public static String getUrlSiteId(String url){
        String siteId = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            siteId = uri.getQueryParameter(KEY_URL_SITEID);
        }
        return siteId;
    }

    /**
     * 生成换站跳转链接
     * @param type
     * @return
     */
    public static String createWebSiteChangeUrl(WebSiteType type){
        return KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + CoreUrlHelper.KEY_URL_SITEID + "=" + WebSiteConfigManager.getWebSiteID(type);
    }

    /**
     * 检测是否有效的url
     * @param url
     * @return
     */
    public static boolean checkIsValidMoudleUrl(String url){
        boolean isValid = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String scheme = uri.getScheme();
            String authority = uri.getAuthority();
            String path = uri.getPath();
            if(!TextUtils.isEmpty(authority) && !TextUtils.isEmpty(path)&& authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)){
                isValid = true;
            }
        }
        return isValid;
    }

    /**
     * 读取forTest字段
     * @param url
     * @return
     */
    public static boolean readForTestFlags(String url){
        boolean forTest = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String temp = uri.getQueryParameter(KEY_URL_PARAM_KEY_TEST);
            if(!TextUtils.isEmpty(temp)){
                forTest = Integer.valueOf(temp) == 0?false:true;
            }
        }
        return forTest;
    }

    /**
     * 读取httpProxy字段
     * @param url
     * @return
     */
    public static String readHttpProxyFlags(String url){
        String httpProxy = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String temp = uri.getQueryParameter(KEY_URL_PARAM_KEY_HTTPPROXY);
            if(!TextUtils.isEmpty(temp)){
                httpProxy = temp;
            }
        }
        return httpProxy;
    }

    /**
     * 生成基础path
     * @return
     */
    public static String getUrlBasePath(IModule module){
        return KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + CoreUrlHelper.KEY_URL_SITEID + "=" + WebSiteConfigManager.getInstance().getCurrentSiteId();
    }

    /**
     * uri转url
     * @param uri
     * @return
     */
    public static String uriToUrl(Uri uri){
        String url = "";
        if(uri != null){
            url = KEY_URL_SCHEME + "://"
                    + KEY_URL_AUTHORITY
                    + KEY_URL_PATH;
            String queryStr = uri.getQuery();
            if(!TextUtils.isEmpty(queryStr)){
                url += "?" + queryStr;
            }
        }
        return url;
    }

    /**
     * 二次处理webview加载url（增加本地参数）
     * @param url
     * @return
     */
    public static String packageWebviewUrl(Context context, String url){
        HashMap<String, String> querys = new HashMap<String, String>();
        querys.put(KEY_URL_PARAM_KEY_DEVICE, KEY_URL_PARAM_DEVICE_VALUE);

        int versionCode = SystemUtils.getVersionCode(context);
        querys.put(KEY_URL_PARAM_KEY_APPVER, String.valueOf(versionCode));

        String packageName  = context.getPackageName();
        querys.put(KEY_URL_PARAM_KEY_APPID, packageName);

        return StringUtil.appendUrl(url, querys);
    }

    /**
     * 替换指定Url指定key的Value值
     * @param sourceUrl
     * @param key
     * @param destValue
     * @return
     */
    public static String replaceUrlAssignKeyValue(String sourceUrl, String key, String destValue){
        String destUrl = sourceUrl;
        if(!TextUtils.isEmpty(sourceUrl) && !TextUtils.isEmpty(key)){
            destUrl = sourceUrl.replaceAll("(" + key + "=[^&]*)", key + "=" + destValue);
        }
        return destUrl;
    }
}
