package com.qpidnetwork.livemodule.view;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.BaseDialog;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

public class NormalWebviewDialog extends BaseDialog {
	
	private WebView mWebView;
	private View contentView;
	private RelativeLayout rlProgress;
	private LinearLayout rlBody;
	private Context mContext;
	private int webviewContentHeight = 0;
	private ViewGroup.LayoutParams mLayoutParams;
	private WebViewClient webViewClient;
	//判断是否手动点击连接
	private boolean mIsTouch = false;
	//是否由外部限定高度
	private boolean mIsLockHeight = false;

	@SuppressLint("ClickableViewAccessibility")
	public NormalWebviewDialog(Context context){
		super(context);
		this.mContext = context;
		contentView  = LayoutInflater.from(context).inflate(R.layout.live_dialog_normal_webview, null);
		mWebView = (WebView)contentView.findViewById(R.id.webView);
		rlProgress = (RelativeLayout)contentView.findViewById(R.id.rlProgress);
		rlBody = (LinearLayout)contentView.findViewById(R.id.rlBody);
		
		mWebView.getSettings().setJavaScriptEnabled(true);
		//add by Jagger 2018-11-10
		//尝试解决loaddata方式加载时,页面中 <img 指向需要验证的问题
		mWebView.setHttpAuthUsernamePassword("demo-mobile.charmdate.com","Web Site Test","test","5179");
		//
		mWebView.addJavascriptInterface(this, "HTMLOUT");
		//add by Jagger 2017-12-15 改成透明
		mWebView.setBackgroundColor(0); // 设置背景色
		if(mWebView.getBackground() != null){
			mWebView.getBackground().setAlpha(0); // 设置填充透明度 范围：0-255 *首次要保证设置了Background,否则这个getBackground为空, 现在是在XML中设置了
		}

		//为了保证mOnUrlClickedListener是手动点击触发的,而不是页面自动跳转
		mWebView.setOnTouchListener(new View.OnTouchListener() {
			@SuppressLint("ClickableViewAccessibility")
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_UP){
					mIsTouch = true;
				}
				return false;
			}
		});

		webViewClient = new WebViewClient() {
			@Override
			public void onPageStarted(WebView view, String url, Bitmap favicon) {
				rlProgress.setVisibility(View.VISIBLE);
				mIsTouch = false;
			}

			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				boolean isHandle = false;
				if (url.equals("qpidnetwork://app/closewindow")
						|| new AppUrlHandler(mContext).urlHandle(url)) {
					isHandle = true;
				}else{
					isHandle = super.shouldOverrideUrlLoading(view, url);
				}

				if(isHandle){
					//关闭自己
					dismiss();
				}

				return isHandle;
			}

			@Override
			public void onPageFinished(WebView view, String url) {
				if(!mIsLockHeight){
					//取得网页内容高度
					// 使用js获取高度兼容性有问题，改成使用wrap_content 2018.4.3 (Hunter)
					// 由于使用wrap_content,其实WebView的高度是全屏,导致点击空白位置不能消失,所以又改回js获取高度 2018.4.4 (Jagger)
					mWebView.loadUrl("javascript:window.HTMLOUT.getContentHeight(document.getElementsByTagName('html')[0].scrollHeight);");
				}
				rlProgress.setVisibility(View.GONE);
				rlBody.setVisibility(View.VISIBLE);
				mIsTouch = false;
			}
		};

		mWebView.setWebViewClient(webViewClient);
    	rlBody.setVisibility(View.INVISIBLE);
		
		this.setContentView(contentView);
	}

	/**
	 * 加载Url
	 * @param url
	 */
	public void loadUrl(String url){
		if(mWebView != null
				&& !TextUtils.isEmpty(url)){
			// 域名
			String domain = WebSiteConfigManager.getInstance().getCurrentWebSite().getAppSiteHost();
			// Cookie 认证
			/*getInstance 前必须createInstance */
			syncCookie();

			//增加公共头部
			url = CoreUrlHelper.packageWebviewUrl(mContext, url);
			
			mWebView.loadUrl(url);
		}
	}

	/**
	 * 同步webview cookie
	 */
	private void syncCookie() {
		// Cookie 认证
		CookieSyncManager.createInstance(mContext);
		CookieManager cookieManager = CookieManager.getInstance();
		cookieManager.setAcceptCookie(true);
		cookieManager.removeAllCookie();
		CookiesItem[] cookieList = RequestJni.GetCookiesItem();
		if (cookieList != null && cookieList.length > 0) {
			for (CookiesItem item : cookieList) {
				if (item != null) {
					String sessionString = item.cName + "=" + item.value;
					cookieManager.setCookie(item.domain, sessionString);
				}
			}
		}
		CookieSyncManager.getInstance().sync();
	}


	/**
	 * 加载网页内容
	 * @param htmlData
	 */
	public void loadData(String htmlData, int webViewHeight){
		loadData(htmlData);
		if(webViewHeight > 0){
			mIsLockHeight = true;
			webviewContentHeight = webViewHeight;
			resetHeight();
		}
	}

	/**
	 * 加载网页内容
	 * @param htmlData
	 */
	public void loadData(String htmlData){
		if(mWebView != null
				&& !TextUtils.isEmpty(htmlData)){
			// Cookie 认证
			/*getInstance 前必须createInstance */
			CookieSyncManager.createInstance(mContext);
			CookieManager cookieManager = CookieManager.getInstance();
			cookieManager.setAcceptCookie(true);
			cookieManager.removeAllCookie();
			CookiesItem[] cookieList = RequestJni.GetCookiesItem();
			if(cookieList != null && cookieList.length > 0){
				for(CookiesItem item : cookieList){
					if(item != null){
						String sessionString = item.cName + "=" + item.value;
						cookieManager.setCookie(item.domain, sessionString);
					}
				}
			}
			CookieSyncManager.getInstance().sync();

			mWebView.loadData(htmlData, "text/html; charset=UTF-8", null);//这种写法可以正确解码
		}
	}
	
    @JavascriptInterface
    public void getContentHeight(String value) {
        if (!TextUtils.isEmpty(value)) {
        	int heightDP = 16;	//(这个数值与layout是文件中的padding+layout_margin)*2
        	try {
				heightDP += Integer.parseInt(value);
			}catch (NumberFormatException e){
			}

			Log.i("Jagger" , "JS取回广告高度:" + value + "，计算后得:" + heightDP);
            webviewContentHeight = DisplayUtil.dip2px(mContext, heightDP);
            resetHeight();
        }
    }

    /**
     * 重设WEBVIEW显示高度
     */
    private void resetHeight(){
    	Runnable runnable = new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				mLayoutParams = rlBody.getLayoutParams();
		        if(webviewContentHeight < DisplayUtil.dip2px(mContext, 200)){
		            mLayoutParams.height = DisplayUtil.dip2px(mContext, 200);
		        }else if(webviewContentHeight > DisplayUtil.getDisplayMetrics(mContext).heightPixels * 0.8){	//  UnitConversion.dip2px(mContext, 500)){
		        	//edit by Jagger 最大高度改为屏幕80%
		            mLayoutParams.height = (int)(DisplayUtil.getDisplayMetrics(mContext).heightPixels * 0.8);		//UnitConversion.dip2px(mContext, 500);
					Log.i("Jagger" , "广告高度 a:" + mLayoutParams.height);
		        }else {
		            mLayoutParams.height = webviewContentHeight;
					Log.i("Jagger" , "广告高度 b:" + mLayoutParams.height);
		        }
		        
		        rlBody.setLayoutParams(mLayoutParams);
			}
		};
        ((Activity)mContext).runOnUiThread(runnable);
    }
}
