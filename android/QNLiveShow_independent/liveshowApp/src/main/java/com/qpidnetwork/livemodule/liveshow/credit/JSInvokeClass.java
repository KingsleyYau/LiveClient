package com.qpidnetwork.livemodule.liveshow.credit;

import android.os.Handler;
import android.os.Message;
import android.webkit.JavascriptInterface;

import com.qpidnetwork.livemodule.utils.Log;


/**
 * 网页js调用接口
 */
public class JSInvokeClass {
	private String tag = "JSInvokeClass";
	private Handler handler;

	public JSInvokeClass(Handler handler) {
		this.handler = handler;
	}

	@JavascriptInterface
	public void next() {
		Log.e(tag, "next()");
		handler.sendEmptyMessage(BuyCreditActivity.NEXT);
	}

	@JavascriptInterface
	public void back() { // 此时，可切换回主页或返回原来的页面
		Log.e(tag, "back()");
		handler.sendEmptyMessage(BuyCreditActivity.FIRST);
	}

	/**
	 * 注册跳转
	 * 
	 * @param userId
	 */
	@JavascriptInterface
	public void gohome(String userId) {
		Log.e(tag, "gohome()");
		Message msg = new Message();
		msg.what = BuyCreditActivity.HOME;
		msg.obj = userId;
		handler.sendMessage(msg);
	}

	/**
	 * 充值成功弹出框
	 * 
	 * @param str
	 */
	@JavascriptInterface
	public void alert(String str) {
		Log.e(tag, "alert");
		Message msg = handler.obtainMessage(BuyCreditActivity.SUCCESS_PAYMENT, str);
		handler.sendMessage(msg);
	}

	/**
	 * 充值失败的弹出框
	 * 
	 * @param str
	 */
	@JavascriptInterface
	public void confirm(String str) {
		Log.e(tag, "confirm");
		Message msg = handler.obtainMessage(BuyCreditActivity.FAILED_PAYMENT, str);
		handler.sendMessage(msg);
	}
	
	/**
	 * 支付过程中消息提示弹出框
	 * 
	 * @param message
	 */
	@JavascriptInterface
	public void notify(String message) {
		Log.e(tag, "notify");
		Message msg = handler.obtainMessage(BuyCreditActivity.PAYMENT_NOTIFY, message);
		handler.sendMessage(msg);
	}
	
}
