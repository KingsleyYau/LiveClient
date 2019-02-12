package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;

import com.qpidnetwork.livemodule.httprequest.OnSynConfigCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 同步配置管理器
 * @author Jagger 2018-9-25
 */
public class SynConfigerManager {
	//回调结果封装
	public class ConfigResult{
		public boolean isSuccess;
		public int errno;
		public String errmsg;
		public ConfigItem item;
	}

	//变量
	private Context mContext;
	private Consumer<ConfigResult> mObserverResult;
	private List<Consumer<ConfigResult>> mObserverResultList;
	private Disposable mDisposable;

	private ConfigItem mConfigItem;

	private boolean mIsSynchroning = false;

	//单例
	private static SynConfigerManager instance = null;
	public static synchronized SynConfigerManager getInstance(Context context) {
	   if (instance == null)
	          instance = new SynConfigerManager(context);
	          return instance;
	}
	private SynConfigerManager(Context context){
		mContext = context;
		mObserverResultList = new ArrayList<Consumer<ConfigResult>>();
	}

	/**
	 * 取同步配置
	 */
	public void getSynConfig() {
		// TODO Auto-generated method stub
		//正式代码 检测版本接口未通 2018-10-8
		if(!mIsSynchroning){
			mIsSynchroning = true;
			VersionCheckManager.getInstance(mContext).setVersionResultObserver(new Consumer<VersionCheckManager.VersionResult>() {
				@Override
				public void accept(VersionCheckManager.VersionResult versionResult) throws Exception {
					doGetSynConfig(versionResult.isSuccess, versionResult.errno, versionResult.errmsg);
				}
			}).getVersion();
		}
	}

	/**
	 * 请求接口<同步配置>
	 * @param isGetVersionSuccess 取版本号结果
	 * @param errCode4GetVersion  取版本号错误码
	 * @param errMsg4GetVersion   取版本号错误信息
	 */
	private void doGetSynConfig(final boolean isGetVersionSuccess, final int errCode4GetVersion, final String errMsg4GetVersion){
		//rxjava
		Observable<ConfigResult> observerable = Observable.create(new ObservableOnSubscribe<ConfigResult>() {

			@Override
			public void subscribe(final ObservableEmitter<ConfigResult> emitter){
				// TODO Auto-generated method stub
				if(!isGetVersionSuccess){
					//取版本号失败,返回同步配置失败
					ConfigResult result = new ConfigResult();
					result.errmsg = errMsg4GetVersion;
					result.errno = errCode4GetVersion;
					result.isSuccess = isGetVersionSuccess;
					result.item = null;
					//发射
					emitter.onNext(result);
				}else {
					if(mConfigItem == null){
						// 调用接口
						RequestJniOther.SynConfig(new OnSynConfigCallback() {

							@Override
							public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem) {
								// TODO Auto-generated method stub

								//返回同步配置结果
								ConfigResult result = new ConfigResult();
								result.errmsg = errMsg;
								result.errno = errCode;
								result.isSuccess = isSuccess;
								result.item = configItem;
								//发射
								emitter.onNext(result);

								//缓存
								if(isSuccess){
									mConfigItem = configItem;

									//LiveChat测试代码
									LCRequestJni.SetAuthorization("test", "5179");
									LCRequestJni.SetPublicWebSite(configItem.chatVoiceHostUrl);
									LCRequestJni.SetWebSite(configItem.httpServerUrl, configItem.httpServerUrl);
								}
							}
						});
					}else{
						//使用缓存
						ConfigResult result = new ConfigResult();
						result.errmsg = "";
						result.errno = 0;
						result.isSuccess = true;
						result.item = mConfigItem;
						//发射
						emitter.onNext(result);
					}
				}
			}
		});

		mDisposable = observerable
//			.doOnNext(doRsponse())						//在外部接收结果前，可做些什么事
				.observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
				.subscribe(new Consumer<SynConfigerManager.ConfigResult>(){
					   @Override
					   public void accept(SynConfigerManager.ConfigResult configResult){
						   notifySynConfigCallback(configResult);
					   }
				});
	}
	
	/**
	 * 同步接口接收数据后回调处理
	 * @return
	 */
//	public Consumer<ConfigResult> doRsponse();

	/**
	 * 设置处理结果观察者(已转交主线程)
	 * @return 为了外部使用链式代码
	 */
	public SynConfigerManager setSynConfigResultObserver(Consumer<ConfigResult> observerResult) {
		// TODO Auto-generated method stub
		synchronized (mObserverResultList){
			mObserverResultList.add(observerResult);
		}
		return this;
	}

	/**
	 * 分发回调
	 * @param configResult
	 */
	private void notifySynConfigCallback(SynConfigerManager.ConfigResult configResult){
		mIsSynchroning = false;
		synchronized (mObserverResultList){
			for(Consumer<ConfigResult> comsumer : mObserverResultList){
				try {
					comsumer.accept(configResult);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			mObserverResultList.clear();
		}
	}

	public ConfigItem getConfigItemCache() {
		return mConfigItem;
	}
	
	/**
	 * 销毁、反注册
	 */
	public void destroy(){
		if(mDisposable != null && mDisposable.isDisposed()){
			mDisposable.dispose();
		}
	}
}
