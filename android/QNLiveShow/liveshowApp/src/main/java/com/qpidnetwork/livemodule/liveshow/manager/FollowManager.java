package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 收藏主播管理器
 * @author Jagger 2018-5-28
 */
public class FollowManager {
	//回调结果封装
	public class FavResult{
		public boolean isSuccess;
		public int errno;
		public String errmsg;
		public LiveRoomListItem item;
	}

	//变量
	private List<Consumer<FavResult>> mObserverResultList;
	private Disposable mDisposable;

	//单例
	private static FollowManager instance = null;

	public static synchronized FollowManager newInstance(Context context){
		if (instance == null)
			instance = new FollowManager(context);
		return instance;
	}

	public static synchronized FollowManager getInstance() {
		return instance;
	}
	private FollowManager(Context context){
		mObserverResultList = new ArrayList<>();
	}

	/**
	 * 设置处理结果观察者(已转交主线程)
	 * @return 为了外部使用链式代码
	 */
	public FollowManager registerSynFavResultObserver(Consumer<FavResult> observerResult) {
		// TODO Auto-generated method stub
		synchronized (mObserverResultList){
			mObserverResultList.add(observerResult);
		}
		return this;
	}

	/**
	 * 反注册结果观察者
	 * @param observerResult
	 */
	public void unregisterSynFavResultObserver(Consumer<FavResult> observerResult) {
		synchronized (mObserverResultList){
			if(mObserverResultList.contains(observerResult)){
				mObserverResultList.remove(observerResult);
			}
		}
	}

	/**
	 * 取同步配置
	 */
	public void summitFollow(@NotNull final LiveRoomListItem liveRoomListItem, final boolean isFollow) {
		//rxjava
		Observable<FavResult> observerable = Observable.create(new ObservableOnSubscribe<FavResult>() {

			@Override
			public void subscribe(final ObservableEmitter<FavResult> emitter){
				LiveRequestOperator.getInstance().AddOrCancelFavorite(liveRoomListItem.userId, "", isFollow, new OnRequestCallback() {
					@Override
					public void onRequest(boolean isSuccess, int errCode, String errMsg) {
						if(isSuccess){
							LiveRoomListItem liveRoomListItemFollow = liveRoomListItem;
							liveRoomListItemFollow.isFollow = isFollow;
							//收藏/取消收藏成功
							FavResult result = new FavResult();
							result.errmsg = errMsg;
							result.errno = errCode;
							result.isSuccess = isSuccess;
							result.item = liveRoomListItemFollow;

							//发射
							emitter.onNext(result);
						}
					}
				});
			}
		});

		mDisposable = observerable
//			.doOnNext(doRsponse())						//在外部接收结果前，可做些什么事
				.observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
				.subscribe(new Consumer<FollowManager.FavResult>(){
					@Override
					public void accept(FollowManager.FavResult FavResult){
						notifySynConfigCallback(FavResult);
					}
				});
	}

	/**
	 * 同步接口接收数据后回调处理
	 * @return
	 */
//	public Consumer<FavResult> doRsponse();

	/**
	 * 分发回调
	 * @param FavResult
	 */
	private void notifySynConfigCallback(FollowManager.FavResult FavResult){
		synchronized (mObserverResultList){
			for(Consumer<FavResult> comsumer : mObserverResultList){
				try {
					comsumer.accept(FavResult);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	/**
	 * 销毁、反注册
	 */
	public void destroy(){
		mObserverResultList.clear();
		if(mDisposable != null && mDisposable.isDisposed()){
			mDisposable.dispose();
		}
	}
}
