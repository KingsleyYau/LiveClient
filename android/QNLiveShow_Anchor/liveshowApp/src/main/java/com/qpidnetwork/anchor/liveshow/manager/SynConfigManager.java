package com.qpidnetwork.anchor.liveshow.manager;

import android.content.Context;
import android.util.Log;

import com.qpidnetwork.anchor.httprequest.OnSynConfigCallback;
import com.qpidnetwork.anchor.httprequest.RequestJni;
import com.qpidnetwork.anchor.httprequest.RequestJniOther;
import com.qpidnetwork.anchor.httprequest.item.ConfigItem;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 同步配置工具类
 * Created by Jagger on 2017/12/28.
 */

public class SynConfigManager {
    private final String TAG = SynConfigManager.class.getSimpleName();
    public final static String THROWABLE_FORCE_UPDATE = "syn.THROWABLE_FORCE_UPDATE";
    public final static String THROWABLE_NORMAL_UPDATE = "syn.THROWABLE_NORMAL_UPDATE";

    //回调结果封装
    public class ConfigResult{
        public boolean isSuccess;
        public int errCode;
        public String errMsg;
        public ConfigItem item;
    }

    private Context mContext;
    private Consumer<ConfigResult> mObserverResult;
    private Disposable mDisposable;
    private static ConfigItem mConfigItem;

    public SynConfigManager(Context c){
        mContext = c;
    }

    public static ConfigItem getSynConfigItem(){
        return mConfigItem;
    }

    /**
     * 请求接口<同步配置>
     */
    public void doRequestSynConfig() {
        // TODO Auto-generated method stub

        //RxJava
        Observable<ConfigResult> observerable = Observable.create(new ObservableOnSubscribe<ConfigResult>() {

            @Override
            public void subscribe(final ObservableEmitter<ConfigResult> emitter)
                    throws Exception {
                // 调用接口
                RequestJniOther.SynConfig(new OnSynConfigCallback() {
                    @Override
                    public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem) {
                        Log.d(TAG , "onSynConfig-isSuccess:" + isSuccess + " errCode" + errCode
                                +" errMsg:"+errMsg+" configItem:"+configItem);
                        //doRsponse(isSuccess, errno, errMsg, item);

                        //封装结果
                        ConfigResult result = new ConfigResult();
                        result.errMsg = errMsg;
                        result.errCode = errCode;
                        result.isSuccess = isSuccess;
                        result.item = configItem;
                        //异常处理
                        //判断是否要更新
                        if(isSuccess){
                            //保存好,哪要用可以GET出去
                            mConfigItem = configItem;

                            //设置httpserver地址
                            RequestJni.SetWebSite(configItem.httpServerUrl);

                            UpdateManager.UpdateType updateType = UpdateManager.getInstance(mContext).getUpdateType(configItem);
                            if(updateType == UpdateManager.UpdateType.FORCE) {
                                //因为强制更新要打断之前的请求,所以 以异常方式处理,不把结果回调到外部
                                //抛出异常
                                emitter.onError(new Throwable(THROWABLE_FORCE_UPDATE));
                                return;
                            }
                        }
                        //正常发射结果
                        emitter.onNext(result);
                        emitter.onComplete();
                    }
                });
            }
        });

        mDisposable = observerable
                .observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
                .doOnNext(doBeforeCallback())				//在外部接收结果前，可做些什么事
                .observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
                .subscribe(
                        mObserverResult,
                        new Consumer<Throwable>() {
                            @Override
                            public void accept(Throwable throwable) throws Exception {
                                Log.i("Jagger" , "SynConfigManager Throwable:" + throwable.toString());

                                if(throwable.toString().trim().contains( THROWABLE_FORCE_UPDATE )){
                                    Log.i("Jagger" , "SynConfigManager Throwable:强制更新");
                                    UpdateManager.getInstance(mContext).doForceUpdate();
                                }
                            }
                        });
    }

    /**
     * 设置处理结果观察者(已转交主线程)
     * @return 为了外部使用链式代码
     */
    public SynConfigManager setSynConfigResultObserver(Consumer<ConfigResult> observerResult) {
        // TODO Auto-generated method stub
        mObserverResult = observerResult;
        return this;
    }

    /**
     * 销毁、反注册
     */
    public void dispose(){
        if(mDisposable != null && !mDisposable.isDisposed()){
            mDisposable.dispose();
        }
    }

    /**
     * 回调前需要做些什么东东
     */
    private Consumer<ConfigResult> doBeforeCallback(){
        return new Consumer<ConfigResult>() {
            @Override
            public void accept(ConfigResult configResult) throws Exception {
//                if(configResult.isSuccess){
//                    //是否需要普通更新
//                    //因为普通更新不需要打断之前的请求, 所以把结果照常回调到外部
//                    UpdateManager.UpdateType updateType = UpdateManager.getInstance(mContext).getUpdateType(configResult.item);
//                    if(updateType == UpdateManager.UpdateType.NORMAL){
//                        Log.i("Jagger" , "SynConfigManager doBeforeCallback:普通更新");
//                        UpdateManager.getInstance(mContext).doNormalUpdate();
//                    }
//                }
            }
        };
    }
}
