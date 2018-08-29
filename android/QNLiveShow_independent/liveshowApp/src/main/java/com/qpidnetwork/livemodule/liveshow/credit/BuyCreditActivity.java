package com.qpidnetwork.livemodule.liveshow.credit;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.text.Html;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebSettings.RenderPriority;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseCustomWebViewClient;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

@SuppressLint("SetJavaScriptEnabled")
@SuppressWarnings("deprecation")
public class BuyCreditActivity extends BaseActionBarFragmentActivity implements IAuthorizationListener {
	private boolean isProceSslError = true;	// 控制是否proceed onReceivedSslError() 
	
	protected final String tag = getClass().getName();
	private static final int LOGIN_CALLBACK = 10001;

	public static final String CREDIT_ORDER_NUMBER = "creditNum";
	public static final String CREDIT_GAANALYTICS_FORBID = "gaForbid";		//GA是否统计当前页面，直播使用时不统计

	public static final int FAILED_PAYMENT = 2020;
	public static final int SUCCESS_PAYMENT = 2021;// 支付成功返回跳转过来的页面
	public static final int PAYMENT_NOTIFY = 2025; //支付过程中的消息提示

	/*JS交互*/
	public static final int NEXT = 100;
	
	public static final int FIRST = 101;
	public static final int HOME = 102;
	
	
	public WebView mWebView;
	private RelativeLayout mWebPage;
	boolean isBlockLoadingNetworkImage = false;
	private String message;// 弹出框提示消息
	//error page
	private View errorPage;
	private Button btnRetry;
	
	private boolean isSessionOutTimeError = false;
	private boolean isLoadError = false;
	private boolean isReload = false; //记录是否重新加载，重新加载成功需清除history

	private ConfigItem configItem;

	@SuppressLint("JavascriptInterface") @Override
	protected void onCreate(Bundle arg0) {
		super.onCreate(arg0);
		TAG = BuyCreditActivity.class.getSimpleName();
		setCustomContentView(R.layout.activity_buy_credit);
		setBackButtonImg(R.drawable.ic_close_grey600_24dp);
		setTitle(getString(R.string.my_coins_title),Color.WHITE);
		//error page
		errorPage = (View)findViewById(R.id.errorPage);
		btnRetry = (Button) findViewById(R.id.btnRetry);
		btnRetry.setOnClickListener(this);

		mWebView = (WebView)findViewById(R.id.webView);
		mWebPage = (RelativeLayout)findViewById(R.id.webPage);
		
		JSInvokeClass js = new JSInvokeClass(mHandler);
//		if (Build.VERSION.SDK_INT != 17)
		mWebView.addJavascriptInterface(js, "payment");

		WebSettings webSettings = mWebView.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setJavaScriptCanOpenWindowsAutomatically(true);// 允许JS弹出框
//		webSettings.setLayoutAlgorithm(LayoutAlgorithm.SINGLE_COLUMN);
		
		webSettings.setRenderPriority(RenderPriority.HIGH);
		webSettings.setBlockNetworkImage(true);
		isBlockLoadingNetworkImage=true;
		
		webSettings.setDefaultTextEncodingName("utf-8");
		webSettings.setBuiltInZoomControls(true);
		webSettings.setDomStorageEnabled(true);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    	webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
		}
//		mWebView.setInitialScale(100);//解决打开后导致页面非常小不好看
		mWebView.setWebViewClient(wvc);
		mWebView.setWebChromeClient(client);
		
//		showProgressDialog("Loading");
		LoginManager.getInstance().addListener(this);
		//拿同步配置的充值url,同步配置接口调用不成功则登录不进去app，也即无法使用充值业务
		configItem = LoginManager.getInstance().getSynConfig();

		if(null != configItem && !TextUtils.isEmpty(configItem.addCreditsUrl)){
			isLoadError = false;
			loadUrl();
		}
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		LoginManager.getInstance().removeListener(this);
		if (mWebView != null) {
			mWebPage.removeView(mWebView);
			mWebView.clearCache(true);
			mWebView.removeAllViews();
			mWebView.destroy();
			mWebView = null;
		}
		hideProgressDialog();
	}

	WebViewClient wvc = new BaseCustomWebViewClient(this) {
		@Override
		public void onPageStarted(WebView view, String url, android.graphics.Bitmap favicon) {
			showProgressDialogBgTranslucent("Loading");
			super.onPageStarted(view, url, favicon);
		};

		@Override
		public void onPageFinished(WebView view, String url) {
			/*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
			if((!isLoadError)&&(!isSessionOutTimeError)){
				errorPage.setVisibility(View.GONE);
			}
			if(isReload){
				mWebView.clearHistory();
			}
			hideProgressDialogIgnoreCount();
			
			if(isBlockLoadingNetworkImage){
				if(mWebView != null){
					mWebView.getSettings().setBlockNetworkImage(false);
				}
				isBlockLoadingNetworkImage = false;
			}
			super.onPageFinished(view, url);
		}

		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			if( url.contains("MBCE0003")) {
	    		//处理session过期重新登陆
				isSessionOutTimeError = true;
				errorPage.setVisibility(View.VISIBLE);
				LoginManager.getInstance().onKickedOff(getResources().getString(R.string.session_timeout_kick_off_tips));
				return true;
	    	}
			if(url.contains("term") || url.contains("privacy")){
				// 修改如下：（链接以默认浏览器打开）
				Intent intent = new Intent(Intent.ACTION_VIEW);
				intent.setData(Uri.parse(url));
				startActivity(intent);
				return true;
			}else{
				return super.shouldOverrideUrlLoading(view, url);
			}
		}

		public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
			handler.proceed("test", "5179");
		}

		public void onFormResubmission(WebView view, Message dontResend, Message resend) {
			resend.sendToTarget();
		};

		@Override
		public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
			if (isProceSslError) {
				handler.proceed();
			} 
			else {
				handler.cancel();
			}
			
			// 统计event
			onAnalyticsEvent(getString(R.string.BuyCredit_Category)
					, getString(R.string.BuyCredit_Action_SSLError)
					, String.valueOf(error.getPrimaryError()));
		}
		
		@Override
		public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
			//普通页面错误
			isLoadError = true;
			errorPage.setVisibility(View.VISIBLE);
		};
	};
	
	WebChromeClient client = new WebChromeClient() {
		public boolean onJsAlert(WebView view, String url, String message, final android.webkit.JsResult result) {
			MaterialDialogAlert dialog = new MaterialDialogAlert(BuyCreditActivity.this);
			dialog.setCancelable(false);
			dialog.setMessage(Html.fromHtml(message));
			dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new OnClickListener(){
				@Override
				public void onClick(View v) {
					result.confirm();
				}
				
			}));
			dialog.show();
			return true;
		};

		public boolean onJsConfirm(WebView view, String url, String message, final android.webkit.JsResult result) {
			MaterialDialogAlert dialog = new MaterialDialogAlert(BuyCreditActivity.this);
			dialog.setTitle(getString(R.string.title_payment_failed));
			dialog.setMessage(Html.fromHtml(message));
			dialog.addButton(dialog.createButton(getString(R.string.common_btn_tap_to_retry), new OnClickListener(){
				@Override
				public void onClick(View v) {
					result.confirm();
				}
				
			}));
			dialog.addButton(dialog.createButton(getString(R.string.common_btn_cancel), null));
			dialog.show();
			return true;
		};
	};
	
	
	/**
	 * 显示支付成功对话框
	 * 
	 * @param msg
	 */
	private void doShowSucPaymentDialog(String msg) {
		MaterialDialogAlert dialog = new MaterialDialogAlert(BuyCreditActivity.this);
		dialog.setTitle(getString(R.string.title_payment_success));
		dialog.setMessage(Html.fromHtml(message));
		dialog.setCancelable(false);
		dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new OnClickListener(){
			@Override
			public void onClick(View v) {
				finish();
			}
			
		}));
		dialog.show();
	}
	
	/**
	 * 显示支付失败对话框
	 * 
	 * @param msg
	 */
	public void doShowFailedPaymentDialog(String msg) {
		MaterialDialogAlert dialog = new MaterialDialogAlert(BuyCreditActivity.this);
		dialog.setTitle(getString(R.string.title_payment_failed));
		dialog.setMessage(Html.fromHtml(message));
		dialog.setCancelable(false);
		dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new OnClickListener(){
			@Override
			public void onClick(View v) {
				finish();
			}
			
		}));
		dialog.show();
	}
	
	/**
	 * 显示提示信息
	 * 
	 * @param msg
	 */
	public void doShowNotifyDialog(String msg) {
		MaterialDialogAlert dialog = new MaterialDialogAlert(BuyCreditActivity.this);
		dialog.setMessage(Html.fromHtml(message));
		dialog.setCancelable(false);
		dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), null));
		dialog.show();
	}

	public void backToFirstPage(){
		if(mWebView.canGoBackOrForward(1 - mWebView.copyBackForwardList().getSize())){
			mWebView.goBackOrForward(1 - mWebView.copyBackForwardList().getSize());
		}
	}
	
	private void loadUrl(){
		/*Cookie 认证*/
		/*getInstance 前必须createInstance */
		CookieSyncManager.createInstance(this);
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
		mWebView.clearCache(true);
		Log.logD(TAG,"configItem.addCreditsUrl: " + configItem.addCreditsUrl);
		mWebView.loadUrl(configItem.addCreditsUrl);
		mWebView.requestFocusFromTouch();
	}
	
	@Override
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
		case R.id.btnRetry:{
			if(isSessionOutTimeError){
				showProgressDialog("Loading...");
//				LoginManager.getInstance().logout();
//				LoginManager.getInstance().autoLogin();
			}else{
				if(configItem!=null && !TextUtils.isEmpty(configItem.addCreditsUrl)){
					isLoadError = false;
					isReload = true;
					loadUrl();
				}
			}
		}break;

		default:
			break;
		}
	}
	
	@Override
	protected void handleUiMessage(Message msg) {
		super.handleUiMessage(msg);
		switch (msg.what) {
		case LOGIN_CALLBACK:{
			HttpRespObject response = (HttpRespObject)msg.obj;
			if(response.isSuccess){
				//session 过期重新登陆
				isSessionOutTimeError = false;			
				isReload = true;
				loadUrl();
			}else{
				//显示错误页（加载页面错误）
				hideProgressDialogIgnoreCount();
				errorPage.setVisibility(View.VISIBLE);
			}
		}break;
		case SUCCESS_PAYMENT:
			message = (String) msg.obj;
			doShowSucPaymentDialog(message);
			break;
		case FAILED_PAYMENT:
			message = (String) msg.obj;
			doShowFailedPaymentDialog(message);
			break;
		case PAYMENT_NOTIFY:
			message = (String) msg.obj;
			doShowNotifyDialog(message);
			break;
		default:
			break;
		}
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (mWebView != null && mWebView.canGoBack()) {
			backToFirstPage();	
			return false;
		}
		return super.onKeyDown(keyCode, event);
	}
	
	/**
	 * 忽视计数器直接隐藏progressDialog
	 */
	public void hideProgressDialogIgnoreCount(){
		try {
			if( mProgressDialogCount > 0 ) {
				mProgressDialogCount = 0;
				if( progressDialog != null ) {
					progressDialog.dismiss();
				}
			}
			
			if(progressDialogTranslucent != null){
				progressDialogTranslucent.dismiss();
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
		Message msg = Message.obtain();
		msg.what = LOGIN_CALLBACK;
		HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
		msg.obj = response;
		sendUiMessage(msg);
	}

	@Override
	public void onLogout(boolean isMannual) {

	}
}
