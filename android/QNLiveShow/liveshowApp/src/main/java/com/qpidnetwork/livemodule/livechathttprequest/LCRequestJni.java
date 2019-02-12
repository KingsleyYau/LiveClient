package com.qpidnetwork.livemodule.livechathttprequest;

/**
 * @author Max.Chiu
 * 公共设置模块,设置的参数对所有接口请求都有效
 */
public class LCRequestJni {
//	static {
//		try {
//			System.loadLibrary("lslivechathttprequest");
//		} catch(Exception e) {
//			e.printStackTrace();
//		}
//	}
	
	/**
	 * 无效返回值
	 */
	static public final long InvalidRequestId = -1;
	
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
	 * 设置主站
	 * @param webSite	web站域名	("http://demo.chnlove.com")
	 * @param appSite	app站域名	("http//demo-mobile.chnlove.com")
	 */
    static public native void SetWebSite(String webSite, String appSite);

    /**
     * 设置公共站点
     * @param chatVoiceSite	LiveChat语音站域名 ("http://demo.chnlove.com:9901")
     */
    static public native void SetPublicWebSite(String chatVoiceSite);

	/**
	 * 设置中心站域名 （用于获取可登录站点）
	 * @param changeSite	web站域名	("http://demo-mobile.charmdate.com")
	 */
    static public native void SetChangeSite(String changeSite);
    
	/**
	 * 设置认证
	 * @param user		账号
	 * @param password  密码
	 */
    static public native void SetAuthorization(String user, String password);
    
	/**
	 * 清楚cookiess
	 */
    static public native void CleanCookies();
    
    /**
     * 获取指定站点cookies
     * @param site		域名(例如demo-mobile.chnlove.com)
     * @return
     */
    static public native String GetCookies(String site);
    
    /**
     * 获取所有cookies
     * @return
     */
    static public native String[] GetCookiesInfo();

    
    /**
     * 停止请求
     * @param requestId		请求Id
     */
    static public native void StopRequest(long requestId);
    
    /**
     * 停止所有请求
     */
    static public native void StopAllRequest();

	
    /**
     * 获取返回的body总长度（字节）
     * @param requestId		请求Id
     * @return
     */
    static public native int GetDownloadContentLength(long requestId);
    
    /**
     * 获取已收的body长度（字节）
     * @param requestId		请求Id
     * @return
     */
    static public native int GetRecvLength(long requestId);
    
    /**
     * 获取请求的body总长度（字节）
     * @param requestId		请求Id
     * @return
     */
    static public native int GetUploadContentLength(long requestId);
    
    /**
     * 获取已发的body长度（字节）
     * @param requestId		请求Id
     * @return
     */
    static public native int GetSendLength(long requestId);

	/**
	 * 设置cookies（为了测试QNlivechat的）
	 * @param cookies		cookies
	 * @return
	 */
	static public native void SetCookiesInfo(String[] cookies);

	/**
	 * 设置pp唯一标识
	 * @param appId		pp唯一标识
	 */
	static public native void SetAppId(String appId);
}
