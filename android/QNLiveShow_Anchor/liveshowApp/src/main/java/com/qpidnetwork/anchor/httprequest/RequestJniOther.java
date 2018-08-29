package com.qpidnetwork.anchor.httprequest;


/**
 * 5. 其他接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniOther {
	
	/**
	 * 5.1. 同步配置
	 * @param callback
	 * @return
	 */
	static public native long SynConfig(OnSynConfigCallback callback);
	

	/**
	 * 5.2.获取收入信息
	 * @param callback
	 * @return
	 */
	static public native long GetTodayCredit(OnGetTodayCreditCallback callback);

	/**
	 * 5.3.提交流媒体服务器测速结果
	 * @param sid      	流媒体服务器ID
	 * @param res     	http请求完成时间（毫秒）
	 * @param callback
	 * @return
	 */
	static public native long ServerSpeed(String sid, int res, OnRequestCallback callback);
	


	/**
	 * 5.4.提交crash dump文件（仅独立）
	 * @param deviceId   	     昵称）
	 * @param directory
	 * @return
	 */
	static public native long UploadCrashFile(String deviceId, String directory, String tmpDirectory, OnRequestLSUploadCrashFileCallback callback);

}
