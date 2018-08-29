package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;

/**
 * HttpRequest公共设置模块
 * Created by Hunter Mun on 2017/5/17.
 */

public class RequestJni {

    static {
        try {
            System.loadLibrary("livehttprequest");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
	/**
	 * 设置日志目录
	 * @param directory		日志目录
	 */
	static public native void SetLogDirectory(String directory);
	
	/**
	 * 设置客户端版本号
	 * @param version		客户端版本号
	 */
	static public native void SetVersionCode(String version);
	
	/**
	 * 设置cookies存放路径
	 * @param directory
	 */
	static public native void SetCookiesDirectory(String directory);
	
	/**
	 * 设置域名
	 * @param webSite
	 */
    static public native void SetWebSite(String webSite);
    
    /**
     * 设置图片上传服务器地址
     * @param photoUploadSite
     */
    static public native void SetPhotoUploadSite(String photoUploadSite);

	/**
	 * 设置域名
	 * @param configSite
	 */
	static public native void SetConfigSite(String configSite);
    
    /**
     * 停止请求
     * @param requestId		请求Id
     */
    static public native void StopRequest(long requestId);

	/**
	 * 清楚cookiess
	 */
	static public native void CleanCookies();

	/**
	 * 获取所有cookiesItem
	 * @return
	 */
	static public native CookiesItem[] GetCookiesItem();
    
    /**
     * 获取本机mac地址MD5码，用于生成设备唯一ID（deviceID）
     * @return
     */
    static public native String GetLocalMacMD5();
    
    /**
     * 同步机器唯一标识到Jni层
     * @param deviceId
     */
    static public native void SetDeviceId(String deviceId);

	/**
	 * 设置代理服务器
	 * @param proxyUrl		URL
	 */
	static public native void SetProxy(String proxyUrl);
}
