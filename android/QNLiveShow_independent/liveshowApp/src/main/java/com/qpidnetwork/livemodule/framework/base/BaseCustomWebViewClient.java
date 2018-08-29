package com.qpidnetwork.livemodule.framework.base;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;

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
		UrlOpenType openType = parseDefaultOpenType(url);
		if(openType == UrlOpenType.OPENBYSYSTEMBROWSER){
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.setData(Uri.parse(url));
			mContext.startActivity(intent);
		}else if(openType == UrlOpenType.OPENBYNEWACTIVITY){
			if(!URL2ActivityManager.getInstance().URL2Activity(mContext,url)){
				mContext.startActivity(WebViewActivity.getIntent(mContext, "",
						IPConfigUtil.addCommonParamsToH5Url(url), true));
			}
		}else{
			view.loadUrl(url);
		}
		return true;
	}
	
	/**
	 * 根据Url获取默认打开方式
	 * @return
	 */
	private UrlOpenType parseDefaultOpenType(String url){
		UrlOpenType urlOpenType = UrlOpenType.OPENDEFAULT;
		HashMap<String, String> argMap = parseUrlKeyValue(url);
		if(argMap.containsKey(WEBVIEW_JUMP_ARGUMENT)){
			String value = argMap.get(WEBVIEW_JUMP_ARGUMENT);
			if(!TextUtils.isEmpty(value)){
				if(value.equals("1")){
					urlOpenType = UrlOpenType.OPENBYSYSTEMBROWSER;
				}else if(value.equals("2")){
					urlOpenType = UrlOpenType.OPENBYNEWACTIVITY;
				}
			}
		}
		return urlOpenType;
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
