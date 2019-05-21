package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnOtherVersionCheckCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.LSOtherVersionCheckItem;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 检查客户端更新管理器
 * @author Jagger 2018-9-27
 */
public class VersionCheckManager {
	//回调结果封装
	public class VersionResult{
		public boolean isSuccess;
		public int errno;
		public String errmsg;
		public LSOtherVersionCheckItem item;
	}

	//变量
	private Context mContext;
	private Consumer<VersionResult> mObserverResult;
	private Disposable mDisposable;

	private LSOtherVersionCheckItem mVersionItem;

	//单例
	private static VersionCheckManager instance = null;

	public static synchronized VersionCheckManager newInstance(Context context){
		if (instance == null)
			instance = new VersionCheckManager(context);
		return instance;
	}

	public static synchronized VersionCheckManager getInstance() {
		return instance;
	}
	private VersionCheckManager(Context context){
		mContext =  context.getApplicationContext();
	}

	/**
	 * 请求接口<同步配置>
	 */
	public void getVersion() {
		// TODO Auto-generated method stub

		//rxjava
		Observable<VersionResult> observerable = Observable.create(new ObservableOnSubscribe<VersionResult>() {

			@Override
			public void subscribe(final ObservableEmitter<VersionResult> emitter){
				// TODO Auto-generated method stub
				if(mVersionItem == null){
					// 调用接口
					LiveDomainRequestOperator.getInstance().VersionCheck(SystemUtils.getVersionCode(mContext) ,new OnOtherVersionCheckCallback() {

						@Override
						public void onOtherVersionCheck(boolean isSuccess, int errno, String errmsg, LSOtherVersionCheckItem item) {
							// TODO Auto-generated method stub

							VersionResult result = new VersionResult();
							result.errmsg = errmsg;
							result.errno = errno;
							result.isSuccess = isSuccess;
							result.item = item;
							//发射
							emitter.onNext(result);

							//缓存
							if(isSuccess){
								mVersionItem = item;
							}
						}
					});
				}else{
					//使用缓存
					VersionResult result = new VersionResult();
					result.errmsg = "";
					result.errno = 0;
					result.isSuccess = true;
					result.item = mVersionItem;
					//发射
					emitter.onNext(result);
				}
			}
		});

		mDisposable = observerable
//			.doOnNext(doRsponse())						//在外部接收结果前，可做些什么事
			.observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
			.subscribe(mObserverResult);
		
	}
	
	/**
	 * 同步接口接收数据后回调处理
	 * @return
	 */
//	public Consumer<VersionResult> doRsponse();

	/**
	 * 设置处理结果观察者(已转交主线程)
	 * @return 为了外部使用链式代码
	 */
	public VersionCheckManager setVersionResultObserver(Consumer<VersionResult> observerResult) {
		// TODO Auto-generated method stub
		mObserverResult = observerResult;
		return this;
	}

	public LSOtherVersionCheckItem getVersionInfoCache() {
		return mVersionItem;
	}
	
	/**
	 * 销毁、反注册
	 */
	public void destroy(){
		if(mDisposable != null && mDisposable.isDisposed()){
			mDisposable.dispose();
		}
	}

	/**
	 * 显示更新提示框
	 * @param activity
	 * @param dialogUIListener
	 */
	public void showUpdateDialog(Activity activity, DialogUIListener dialogUIListener){
		DialogUIUtils.showAlert(
				activity,
				activity.getString(R.string.live_upgrade_title),
				TextUtils.isEmpty(mVersionItem.verDesc)? activity.getString(R.string.live_upgrade_msg):mVersionItem.verDesc,
				"","",
				activity.getString(R.string.common_btn_cancel),
				activity.getString(R.string.live_upgrade_btn),
				R.color.live_dialog_default_btn_txt,
				R.color.live_dialog_high_light_btn_txt,
				false,
				false,
				false,
				dialogUIListener
				).show();
	}

}
