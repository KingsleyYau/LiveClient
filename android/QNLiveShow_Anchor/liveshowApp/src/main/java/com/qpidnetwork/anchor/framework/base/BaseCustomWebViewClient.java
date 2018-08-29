package com.qpidnetwork.anchor.framework.base;

import android.content.Context;
import android.text.TextUtils;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;

import java.util.HashMap;

/***
 * 自定义WebViewClient,用于处理重定向时自定义跳转
 * @author Hunter Mun
 * @since 8.19. 2016
 */
public class BaseCustomWebViewClient extends WebViewClient{
	
	private static final String WEBVIEW_JUMP_ARGUMENT = "opentype";
	
	private Context mContext;
	
	public BaseCustomWebViewClient(Context context){
		mContext = context;
	}
	
	@Override
	public boolean shouldOverrideUrlLoading(WebView view, String url) {
		if(!URL2ActivityManager.getInstance().URL2Activity(mContext, url)){
			view.loadUrl(url);
		}
		return true;
	}
	
	//根据Url参数决定重定向Url打开方式
	private enum UrlOpenType{
		OPENDEFAULT,
		OPENBYSYSTEMBROWSER,
		OPENBYNEWACTIVITY
	}
	
	
	/**
	 * 解析Url中参数
	 * @param url
	 * @return
	 */
	private HashMap<String, String> parseUrlKeyValue(String url){
		HashMap<String, String> argMap = new HashMap<String, String>();
		if(!TextUtils.isEmpty(url)){
			if(url.contains("?")){
				String[] result = url.split("\\?");
				if(result != null && result.length > 1){
					String[] params = result[1].split("&");
					if(params != null){
						for(String param : params){
							String[] keyValue = param.split("=");
							if(keyValue != null && keyValue.length > 1){
								argMap.put(keyValue[0], keyValue[1]);
							}
						}
					}
				}
			}
		}
		return argMap;
	}
}
