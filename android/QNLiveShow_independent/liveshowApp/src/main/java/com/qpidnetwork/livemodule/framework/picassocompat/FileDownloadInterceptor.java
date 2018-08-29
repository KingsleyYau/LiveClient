package com.qpidnetwork.livemodule.framework.picassocompat;

import android.util.Base64;

import com.qpidnetwork.livemodule.liveshow.LiveApplication;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

/**
 * 文件下载 拦截器
 * 修改请求头
 * picasso下载图片专用
 * @author Jagger
 * 2017-7-14
 */
public class FileDownloadInterceptor implements Interceptor {

	@Override
	public Response intercept(Chain chain) throws IOException {
		// TODO Auto-generated method stub
		//"Cache-Control", "public,max-age=3600" 表示缓存有效时间为1小时，即在1个小时之内再次请求同一个URL不会访问网络
		Request.Builder request = chain.request().newBuilder();
		request.header("Cache-Control", "public,max-age=3600");
		
		if ( LiveApplication.isDemo ) {
    		String basicAuth = "Basic " + new String(Base64.encode("test:5179".getBytes(), Base64.NO_WRAP));
    		request.addHeader("Authorization", basicAuth);
    	}
		
		return chain.proceed(request.build());
	}

}
